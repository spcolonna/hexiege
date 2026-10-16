import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';

/// Ficha de un escenario: dueño (0 = vos), tipo y casilla.
typedef Placed = (int, PieceType, Hex);

enum StageKind { puzzle, challenge, campaign }

/// Una partida de un jugador contra la IA: un problema, un desafío o una
/// batalla de campaña. Vos sos siempre el jugador 0 (fichas claras, abajo).
class Stage {
  final String id;
  final StageKind kind;
  final Faction you;
  final Faction opp;
  final AiLevel level;

  /// Problemas: turnos propios para cercar al Líder (la IA defiende con el solver).
  final int? puzzleTurns;
  final GameState Function() build;

  const Stage({
    required this.id,
    required this.kind,
    required this.you,
    required this.opp,
    required this.build,
    this.level = AiLevel.normal,
    this.puzzleTurns,
  });

  bool get isPuzzle => puzzleTurns != null;

  String get title => tr('stage.$id.title');

  /// Objetivo en una línea (se muestra durante la partida).
  String get goal => isPuzzle ? trN('stage.puzzleGoal', puzzleTurns!) : tr('stage.$id.goal');

  /// Texto previo a la partida (campaña) o pista (problemas).
  String get intro => tr('stage.$id.intro');

  /// Turnos que le quedan al jugador en un problema (null si no es problema).
  int? turnsLeft(GameState start, GameState now) =>
      puzzleTurns == null ? null : puzzleTurns! - (now.turnsTaken[0] - start.turnsTaken[0]);

  /// true = superado, false = fallado, null = sigue en juego.
  bool? verdict(GameState start, GameState now) {
    if (now.winner == 0) return true;
    if (now.isOver) return false;
    final left = turnsLeft(start, now);
    if (left != null && left <= 0) return false;
    return null;
  }
}

/// Arma una posición a mano: fichas, mano restante, ronda y habilidades.
/// Siempre empieza moviendo el jugador 0.
GameState buildScene({
  required Faction you,
  required Faction opp,
  required List<Placed> pieces,
  Rules rules = Rules.standard,
  int round = 6,
  Map<PieceType, int> yourHand = const {},
  Map<PieceType, int> oppHand = const {},
  bool yourAbility = false,
  bool oppAbility = false,
}) {
  final g = GameState(you, opp, rules: rules);
  for (final (owner, type, at) in pieces) {
    g.setupPut(owner, type, at);
  }
  for (final (p, hand) in [(0, yourHand), (1, oppHand)]) {
    g.hands[p].updateAll((t, _) => hand[t] ?? 0);
  }
  g.ply = (round - 1) * 2;
  g.turnsTaken
    ..[0] = round - 1
    ..[1] = round - 1;
  for (final (p, on) in [(0, yourAbility), (1, oppAbility)]) {
    if (on) continue;
    if (rules.abilityCharges != null) {
      g.abilityUses[p] = rules.abilityCharges!;
    } else {
      g.cooldowns[p] = 1 << 20;
    }
  }
  return g;
}
