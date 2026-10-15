import '../engine/ai.dart';
import '../engine/game_state.dart';

/// Un turno completo: las acciones en orden y el estado resultante (sin terminar el turno).
typedef Turn = ({List<AiAction> actions, GameState state});

/// Todos los turnos posibles de quien mueve: una acción principal y, si está
/// disponible, la habilidad de facción antes o después.
List<Turn> fullTurns(GameState g) {
  final out = <Turn>[];
  void abilityAfter(GameState s, List<AiAction> prefix) {
    if (s.isOver || !s.abilityAvailable) return;
    for (final a in abilityActions(s)) {
      final t = s.copy();
      if (a.apply(t)) out.add((actions: [...prefix, a], state: t));
    }
  }

  void mainsFrom(GameState s, List<AiAction> prefix, {required bool thenAbility}) {
    final mains = mainActions(s);
    if (mains.isEmpty) {
      out.add((actions: prefix, state: s.copy()));
      return;
    }
    for (final m in mains) {
      final t = s.copy();
      if (!m.apply(t)) continue;
      out.add((actions: [...prefix, m], state: t));
      if (thenAbility) abilityAfter(t, [...prefix, m]);
    }
  }

  mainsFrom(g, const [], thenAbility: true);
  if (g.abilityAvailable) {
    for (final a in abilityActions(g)) {
      final s = g.copy();
      if (!a.apply(s)) continue;
      if (s.isOver) {
        out.add((actions: [a], state: s));
      } else {
        mainsFrom(s, [a], thenAbility: false);
      }
    }
  }
  return out;
}

/// Estado tras cerrar el turno, o null si la partida terminó.
GameState? _passTurn(GameState s) {
  if (s.isOver) return null;
  final next = s.copy()..endTurn();
  return next.isOver ? null : next;
}

/// Primer turno de una victoria forzada de quien mueve en [turns] turnos
/// propios o menos, contra cualquier defensa. null si no la hay.
List<AiAction>? forcedWin(GameState g, int turns) {
  final me = g.current;
  final options = fullTurns(g);
  for (final o in options) {
    if (o.state.winner == me) return o.actions;
  }
  if (turns <= 1) return null;
  // Primero las jugadas que más aprietan al Líder rival: suelen ser las buenas.
  options.sort((a, b) => b.state.leaderPressure(1 - me).compareTo(a.state.leaderPressure(1 - me)));
  for (final o in options) {
    final next = _passTurn(o.state);
    if (next != null && _everyReplyLoses(next, me, turns - 1)) return o.actions;
  }
  return null;
}

bool _everyReplyLoses(GameState g, int attacker, int turns) {
  for (final r in fullTurns(g)) {
    if (r.state.winner == attacker) continue;
    final next = _passTurn(r.state);
    if (next == null || forcedWin(next, turns) == null) return false;
  }
  return true;
}

/// Todos los primeros turnos que ganan por la fuerza (para verificar problemas).
List<List<AiAction>> allForcedWins(GameState g, int turns) {
  final me = g.current;
  final wins = <List<AiAction>>[];
  for (final o in fullTurns(g)) {
    if (o.state.winner == me) {
      wins.add(o.actions);
    } else if (turns > 1) {
      final next = _passTurn(o.state);
      if (next != null && _everyReplyLoses(next, me, turns - 1)) wins.add(o.actions);
    }
  }
  return wins;
}

/// Defensa del rival en un problema: si alguna respuesta evita el cerco en los
/// [attackerTurns] turnos que le quedan al atacante, juega la mejor de ellas;
/// si no, la que la IA considere mejor.
List<AiAction> defend(GameState g, int attackerTurns) {
  final me = g.current, attacker = 1 - me;
  Turn? best;
  var bestScore = double.negativeInfinity;
  for (final r in fullTurns(g)) {
    if (r.state.winner == attacker) continue;
    final next = _passTurn(r.state);
    final safe = next == null || attackerTurns <= 0 || forcedWin(next, attackerTurns) == null;
    if (!safe) continue;
    final score = evaluate(r.state, me);
    if (score > bestScore) {
      bestScore = score;
      best = r;
    }
  }
  return best?.actions ?? AiPlayer(AiLevel.hard).chooseTurn(g);
}
