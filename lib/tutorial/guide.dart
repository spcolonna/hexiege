import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';

/// Consejo del Sensei durante la Iniciación: qué conviene hacer ahora y dónde
/// mirar. Se deriva solo del estado de la partida, así que vale para
/// cualquier jugada que haga el jugador.
class GuideTip {
  /// Clave de sus textos (`guide.<id>.title` y `guide.<id>.body`).
  final String id;
  final Map<String, Object> args;

  /// Casillas a señalar (la jugada sugerida, o los huecos que importan).
  final Set<Hex> spotlight;

  const GuideTip(this.id, {this.args = const {}, this.spotlight = const {}});

  String get title => tr('guide.$id.title', args);
  String get body => tr('guide.$id.body', args);
}

/// Casillas de una jugada sugerida: de dónde sale y adónde va.
Set<Hex> suggestionCells(AiAction? a) => switch (a) {
  PlaceAction(:final at) => {at},
  MoveAction(:final from, :final to) || SwapAction(:final from, :final to) => {from, to},
  KawarimiAction(:final at) => {at},
  JadeRelocateAction(:final from, :final to) => {from, to},
  JadeSwapAction(:final a, :final b) => {a, b},
  null => const {},
};

/// El consejo para [me] en [g], o null si no le toca. [seen] son los consejos
/// de una sola vez que ya se mostraron; [suggestion] es la jugada que el
/// Sensei haría en su lugar.
GuideTip? guideTip(GameState g, int me, {Set<String> seen = const {}, AiAction? suggestion}) {
  if (g.isOver || g.current != me) return null;
  final opp = 1 - me;
  final hint = suggestionCells(suggestion);
  final leader = startingHands[g.factions[me]]!.keys.firstWhere((t) => t.isLeader);
  final mine = g.leaderMargin(me), theirs = g.leaderMargin(opp);

  // Lo urgente primero: un Líder a punto de caer, el propio o el rival.
  if (theirs != null && theirs <= 2) {
    return GuideTip(theirs == 1 ? 'finish' : 'attack', args: {'n': theirs}, spotlight: g.leaderOpenings(opp));
  }
  if (mine != null && mine <= 2) {
    return GuideTip('defend', args: {'n': mine}, spotlight: {...g.leaderOpenings(me), ...hint});
  }
  if (g.mustPlaceLeader) {
    return GuideTip('leader', args: {'leader': leader.displayName}, spotlight: hint);
  }
  if (!g.leaderPlaced(me)) {
    return GuideTip(
      g.turnsTaken[me] == 0 ? 'welcome' : 'place',
      args: {'leader': leader.displayName, 'n': leaderDeadlineTurn - g.turnsTaken[me]},
      spotlight: hint,
    );
  }
  if (!seen.contains('move') && g.hasAnyAction()) return GuideTip('move', spotlight: hint);
  if (!seen.contains('ability') && g.abilityAvailable) {
    return GuideTip(
      'ability',
      args: {'ability': g.factions[me].abilityName, 'desc': g.factions[me].abilityDescription},
      spotlight: hint,
    );
  }
  if (!seen.contains('pieces') && g.turnsTaken[me] >= 5) return GuideTip('pieces', spotlight: hint);
  return GuideTip('press', args: {'n': theirs ?? 6}, spotlight: hint);
}

/// Consejos que se muestran una sola vez (los demás se repiten mientras valgan).
const onceTips = {'move', 'ability', 'pieces'};
