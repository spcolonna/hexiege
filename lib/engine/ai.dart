import 'dart:math';

import '../i18n/i18n.dart';
import 'game_state.dart';
import 'hex.dart';
import 'pieces.dart';

/// La acción de un turno (cada una cierra el turno).
sealed class AiAction {
  const AiAction();
  bool apply(GameState g);
}

class PlaceAction extends AiAction {
  final PieceType type;
  final Hex at;
  const PlaceAction(this.type, this.at);
  @override
  bool apply(GameState g) => g.place(type, at);
  @override
  String toString() => 'place ${type.name} $at';
}

class MoveAction extends AiAction {
  final Hex from, to;
  final Hex? paralyze, seal;
  const MoveAction(this.from, this.to, {this.paralyze, this.seal});
  @override
  bool apply(GameState g) => g.move(from, to, paralyze: paralyze, seal: seal);
  @override
  String toString() => 'move $from->$to';
}

class SwapAction extends AiAction {
  final Hex from, to;
  const SwapAction(this.from, this.to);
  @override
  bool apply(GameState g) => g.shogunSwap(from, to);
}

class KawarimiAction extends AiAction {
  final Hex at;
  const KawarimiAction(this.at);
  @override
  bool apply(GameState g) => g.kawarimi(at);
}

class JadeRelocateAction extends AiAction {
  final Hex from, to;
  const JadeRelocateAction(this.from, this.to);
  @override
  bool apply(GameState g) => g.jadeRelocate(from, to);
}

class JadeSwapAction extends AiAction {
  final Hex a, b;
  const JadeSwapAction(this.a, this.b);
  @override
  bool apply(GameState g) => g.jadeSwap(a, b);
}

/// Niveles de la IA, de más débil a más fuerte. No se eligen a mano: el
/// emparejamiento los asigna según el rendimiento del jugador.
enum AiLevel { novice, easy, normal, hard, master }

extension AiLevelInfo on AiLevel {
  String get displayName => switch (this) {
    _ => tr('ai.$name'),
  };
}

const double _win = 1e6;

/// Presupuesto de los niveles que buscan en profundidad: turnos máximos a
/// mirar, cuántas jugadas se exploran en cada capa (haz) y tiempo límite.
typedef _Budget = ({int depth, List<int> beam, int ms});
const _budgets = <AiLevel, _Budget>{
  AiLevel.hard: (depth: 3, beam: [12, 8], ms: 1200),
  AiLevel.master: (depth: 4, beam: [16, 10, 6], ms: 2500),
};

class _Timeout implements Exception {}

/// Castigo por volver a una posición que la IA ya produjo: evita que las
/// partidas se estanquen en idas y vueltas.
const double _repeatPenalty = 12;

/// IA: genera turnos candidatos (una acción: principal o habilidad).
/// - Aprendiz / Fácil: codiciosa con ruido.
/// - Normal: minimax a 2 capas (mi turno + mejor respuesta rival).
/// - Difícil / Maestro: alfa-beta por turnos completos con profundización
///   iterativa, haz acotado y tiempo límite; el rival también usa habilidades.
class AiPlayer {
  final AiLevel level;

  /// Si es false, nunca usa la habilidad de facción (útil para medir su impacto).
  final bool useAbilities;
  final Random _rng;

  /// Profundidad completada en la última búsqueda (diagnóstico / tests).
  int lastDepth = 0;

  /// Posiciones que dejó esta IA al terminar sus turnos (huella → veces).
  /// Quien recrea la IA en cada turno (la UI) debe pasar el historial.
  final Map<String, int> seen;

  late Stopwatch _clock;
  late int _deadlineMs;

  AiPlayer(this.level, {int? seed, this.useAbilities = true, Map<String, int>? seen})
    : _rng = Random(seed),
      seen = seen ?? {};

  /// La acción del turno (lista de 0 o 1). Vacía = no hay jugadas: [GameState.pass].
  List<AiAction> chooseTurn(GameState g) {
    final me = g.current;
    final candidates = _candidateTurns(g, abilityBeam: _abilityBeam);
    if (candidates.isEmpty) return const [];

    for (final c in candidates) {
      if (c.state.winner == me) return c.actions;
    }
    for (final c in candidates) {
      c.penalty = _repeatPenalty * (seen[c.state.board.key] ?? 0);
      c.score = evaluate(c.state, me) - c.penalty + _rng.nextDouble();
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    final chosen = _pick(candidates, me);
    final key = chosen.state.board.key;
    seen[key] = (seen[key] ?? 0) + 1;
    return chosen.actions;
  }

  _Candidate _pick(List<_Candidate> candidates, int me) {
    switch (level) {
      case AiLevel.novice:
        // Juega "a ojo": rara vez la mejor y a veces se olvida del peligro.
        final pool = candidates.take(8).toList();
        return _rng.nextDouble() < 0.35 ? pool.first : pool[_rng.nextInt(pool.length)];
      case AiLevel.easy:
        // Greedy con algo de ruido: a veces elige una de las mejores 4.
        final pool = candidates.take(4).toList();
        return _rng.nextDouble() < 0.6 ? pool.first : pool[_rng.nextInt(pool.length)];
      case AiLevel.normal:
        var best = candidates.first;
        var bestScore = double.negativeInfinity;
        for (final c in candidates.take(20)) {
          final v = _worstReply(c.state, me, bestScore + c.penalty) - c.penalty;
          if (v > bestScore) {
            bestScore = v;
            best = c;
          }
        }
        return best;
      case AiLevel.hard:
      case AiLevel.master:
        return _deepSearch(candidates, me, _budgets[level]!);
    }
  }

  int get _abilityBeam => switch (level) {
    AiLevel.novice || AiLevel.easy => 2,
    AiLevel.normal => 4,
    AiLevel.hard || AiLevel.master => 5,
  };

  /// Valor del peor caso tras la mejor respuesta del rival (poda alfa).
  double _worstReply(GameState afterMine, int me, double alpha) {
    if (afterMine.isOver) return evaluate(afterMine, me);
    final opp = afterMine;
    final replies = mainActions(opp);
    if (replies.isEmpty) return evaluate(opp, me);
    var worst = double.infinity;
    for (final r in replies) {
      final s = opp.copy();
      if (!r.apply(s)) continue;
      final v = evaluate(s, me);
      if (v < worst) worst = v;
      if (worst <= alpha) break; // no puede superar a la mejor ya encontrada
    }
    return worst == double.infinity ? evaluate(opp, me) : worst;
  }

  /// Profundización iterativa: busca a 2, 3, ... turnos hasta agotar la
  /// profundidad o el tiempo, y devuelve lo mejor de la última vuelta completa.
  _Candidate _deepSearch(List<_Candidate> root, int me, _Budget b) {
    _clock = Stopwatch()..start();
    _deadlineMs = b.ms;
    var best = root.first;
    lastDepth = 1;
    final pool = root.take(b.beam[0]).toList();
    for (var depth = 2; depth <= b.depth; depth++) {
      try {
        var alpha = double.negativeInfinity;
        _Candidate? iterBest;
        for (final c in pool) {
          final v =
              _afterTurn(c, depth - 1, 1, alpha + c.penalty, double.infinity, me, b) -
              c.penalty +
              _rng.nextDouble() * 0.5;
          c.score = v;
          if (v > alpha) {
            alpha = v;
            iterBest = c;
          }
        }
        best = iterBest ?? best;
        lastDepth = depth;
        // La próxima vuelta empieza por las mejores: más podas.
        pool.sort((a, b) => b.score.compareTo(a.score));
        if (alpha >= _win / 2) break; // victoria forzada encontrada
      } on _Timeout {
        break;
      }
    }
    return best;
  }

  /// Valor de un turno ya jugado ([c]) mirando [depth] turnos más.
  double _afterTurn(_Candidate c, int depth, int layer, double alpha, double beta, int me, _Budget b) {
    if (c.state.isOver || depth == 0) return _terminal(c.state, me, depth);
    return _search(c.state, depth, layer, alpha, beta, me, b);
  }

  /// Minimax con poda alfa-beta; [g] está al inicio del turno de quien mueve.
  double _search(GameState g, int depth, int layer, double alpha, double beta, int me, _Budget b) {
    if (_clock.elapsedMilliseconds > _deadlineMs) throw _Timeout();
    final maximizing = g.current == me;
    final cands = _candidateTurns(g, abilityBeam: 2);
    if (cands.isEmpty) return evaluate(g, me);
    for (final c in cands) {
      c.score = _terminal(c.state, me, depth - 1);
    }
    cands.sort((a, b) => maximizing ? b.score.compareTo(a.score) : a.score.compareTo(b.score));
    // Última capa (o victoria inmediata): alcanza con la evaluación estática.
    if (depth == 1 || cands.first.state.isOver) return cands.first.score;

    final width = layer < b.beam.length ? b.beam[layer] : 4;
    var v = maximizing ? double.negativeInfinity : double.infinity;
    for (final c in cands.take(width)) {
      final s = _afterTurn(c, depth - 1, layer + 1, alpha, beta, me, b);
      if (maximizing) {
        if (s > v) v = s;
        if (v > alpha) alpha = v;
      } else {
        if (s < v) v = s;
        if (v < beta) beta = v;
      }
      if (alpha >= beta) break;
    }
    return v;
  }

  /// Evaluación que prefiere ganar pronto y perder lo más tarde posible.
  double _terminal(GameState s, int me, int depthLeft) {
    final v = evaluate(s, me);
    if (s.winner == null) return v;
    return v > 0 ? v + depthLeft : v - depthLeft;
  }

  List<_Candidate> _candidateTurns(GameState g, {required int abilityBeam}) {
    final result = <_Candidate>[];
    for (final m in mainActions(g)) {
      final s = g.copy();
      if (m.apply(s)) result.add(_Candidate([m], s));
    }
    if (useAbilities && g.abilityAvailable) {
      final me = g.current;
      final abilities = <_Candidate>[];
      for (final a in abilityActions(g)) {
        final s = g.copy();
        if (a.apply(s)) abilities.add(_Candidate([a], s)..score = evaluate(s, me));
      }
      abilities.sort((a, b) => b.score.compareTo(a.score));
      result.addAll(abilities.take(abilityBeam));
    }
    if (result.isEmpty) {
      final s = g.copy();
      if (s.pass()) result.add(_Candidate(const [], s));
    }
    return result;
  }
}

class _Candidate {
  final List<AiAction> actions;
  final GameState state;
  double score = 0;
  double penalty = 0;
  _Candidate(this.actions, this.state);
}

extension PlayTurn on GameState {
  /// Juega el turno que devolvió la IA: su acción, o pasar si vino vacío.
  bool play(List<AiAction> turn) => turn.isEmpty ? pass() : turn.every((a) => a.apply(this));
}

/// Todas las acciones principales legales (colocar / mover / intercambio Shogun).
List<AiAction> mainActions(GameState g) {
  final result = <AiAction>[];
  final types = g.placeableTypes();
  if (types.isNotEmpty) {
    final targets = g.placementTargets();
    for (final t in types) {
      for (final h in targets) {
        result.add(PlaceAction(t, h));
      }
    }
  }
  final own = g.board.tops.where((e) => e.value.owner == g.current).map((e) => e.key).toList();
  for (final src in own) {
    for (final d in g.moveTargets(src)) {
      final fx = g.effectOptions(src, d);
      if (fx.paralyze.isNotEmpty) {
        for (final t in fx.paralyze) {
          result.add(MoveAction(src, d, paralyze: t));
        }
      } else if (fx.seal.isNotEmpty) {
        for (final t in fx.seal) {
          result.add(MoveAction(src, d, seal: t));
        }
      } else {
        result.add(MoveAction(src, d));
      }
    }
    for (final t in g.shogunSwapTargets(src)) {
      result.add(SwapAction(src, t));
    }
  }
  return result;
}

List<AiAction> abilityActions(GameState g) {
  if (!g.abilityAvailable) return const [];
  return switch (g.currentFaction) {
    Faction.ninja => [for (final h in g.kawarimiTargets()) KawarimiAction(h)],
    Faction.shaolin => [
      for (final s in g.jadeRelocateSources())
        for (final d in g.jadeRelocateTargets(s)) JadeRelocateAction(s, d),
      for (final a in g.jadeSwapSources())
        for (final b in g.jadeSwapTargets(a))
          if (a.q < b.q || (a.q == b.q && a.r < b.r)) JadeSwapAction(a, b),
    ],
  };
}

/// Evaluación estática desde la perspectiva de [me]. Positivo = bueno para [me].
double evaluate(GameState g, int me) {
  if (g.draw) return -500;
  if (g.winner != null) return g.winner == me ? _win : -_win;
  final opp = 1 - me;
  var s = _leaderDanger(g, opp) - _leaderDanger(g, me);
  final leaders = [g.board.locateLeader(0), g.board.locateLeader(1)];
  for (final e in g.board.tops) {
    final p = e.value;
    final sign = p.owner == me ? 1.0 : -1.0;
    s += 2 * sign; // desarrollo
    if (g.isParalyzed(p)) {
      s -= 4 * sign;
    } else if (g.board.canLift(e.key)) {
      s += 3 * sign; // movilidad aproximada
    }
    // Presión: acercar fichas propias al Líder rival.
    final target = leaders[1 - p.owner];
    if (target != null && !p.type.isLeader) {
      final dist = e.key.distanceTo(target);
      s -= 0.6 * sign * dist;
      if (dist == 1) s += 6 * sign;
    }
  }
  for (final p in [me, opp]) {
    if (!g.leaderPlaced(p) && g.turnsTaken[p] >= 2) s += p == me ? -15 : 15;
  }
  return s;
}

const _surroundValue = <double>[0, 4, 12, 30, 70, 160, 0];

/// Cuán comprometido está el Líder de [p].
double _leaderDanger(GameState g, int p) {
  final h = g.board.locateLeader(p);
  if (h == null) return 0;
  // En el Asedio cada vecino vale como uno más (5 lados ya capturan).
  final n = min(g.board.occupiedNeighbors(h) + (g.inSiege ? 1 : 0), 6);
  var d = _surroundValue[n];
  if (g.board.height(h) > 1) d += 20; // tiene un Rey Mono encima
  if (n >= 3 && !g.board.canLift(h)) d += 10; // inmovilizado
  return d;
}
