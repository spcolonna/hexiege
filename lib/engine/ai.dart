import 'dart:math';

import 'game_state.dart';
import 'hex.dart';
import 'pieces.dart';

/// Una acción atómica dentro de un turno.
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

enum AiLevel { easy, normal }

extension AiLevelInfo on AiLevel {
  String get displayName => switch (this) {
    AiLevel.easy => 'Fácil',
    AiLevel.normal => 'Normal',
  };
}

const double _win = 1e6;

/// IA: genera turnos candidatos (habilidad opcional + acción principal) y
/// en nivel Normal hace minimax a 2 capas (mi turno + mejor respuesta rival).
class AiPlayer {
  final AiLevel level;

  /// Si es false, nunca usa la habilidad de facción (útil para medir su impacto).
  final bool useAbilities;
  final Random _rng;
  AiPlayer(this.level, {int? seed, this.useAbilities = true}) : _rng = Random(seed);

  /// Acciones a aplicar en orden; después hay que llamar a [GameState.endTurn].
  List<AiAction> chooseTurn(GameState g) {
    final me = g.current;
    final candidates = _candidateTurns(g);
    if (candidates.isEmpty) return const [];

    for (final c in candidates) {
      if (c.state.winner == me) return c.actions;
    }
    for (final c in candidates) {
      c.score = evaluate(c.state, me) + _rng.nextDouble();
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));

    if (level == AiLevel.easy) {
      // Greedy con algo de ruido: a veces elige una de las mejores 4.
      final pool = candidates.take(4).toList();
      return (_rng.nextDouble() < 0.6 ? pool.first : pool[_rng.nextInt(pool.length)]).actions;
    }

    var best = candidates.first;
    var bestScore = double.negativeInfinity;
    for (final c in candidates.take(20)) {
      final v = _worstReply(c.state, me, bestScore);
      if (v > bestScore) {
        bestScore = v;
        best = c;
      }
    }
    return best.actions;
  }

  /// Valor del peor caso tras la mejor respuesta del rival (poda alfa).
  double _worstReply(GameState afterMine, int me, double alpha) {
    if (afterMine.isOver) return evaluate(afterMine, me);
    final opp = afterMine.copy();
    if (!opp.endTurn()) return evaluate(afterMine, me);
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

  List<_Candidate> _candidateTurns(GameState g) {
    final result = <_Candidate>[];
    void addMains(GameState base, List<AiAction> prefix) {
      final mains = mainActions(base);
      if (mains.isEmpty) {
        result.add(_Candidate(prefix, base));
        return;
      }
      for (final m in mains) {
        final s = base.copy();
        if (m.apply(s)) result.add(_Candidate([...prefix, m], s));
      }
    }

    addMains(g, const []);

    if (useAbilities && g.abilityAvailable) {
      final me = g.current;
      final abilities = <_Candidate>[];
      for (final a in abilityActions(g)) {
        final s = g.copy();
        if (a.apply(s)) abilities.add(_Candidate([a], s)..score = evaluate(s, me));
      }
      abilities.sort((a, b) => b.score.compareTo(a.score));
      for (final a in abilities.take(level == AiLevel.easy ? 2 : 4)) {
        if (a.state.isOver) {
          result.add(a);
        } else {
          addMains(a.state, a.actions);
        }
      }
    }
    return result;
  }
}

class _Candidate {
  final List<AiAction> actions;
  final GameState state;
  double score = 0;
  _Candidate(this.actions, this.state);
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
  final n = g.board.occupiedNeighbors(h);
  var d = _surroundValue[n];
  if (g.board.height(h) > 1) d += 20; // tiene un Rey Mono encima
  if (n >= 3 && !g.board.canLift(h)) d += 10; // inmovilizado
  return d;
}
