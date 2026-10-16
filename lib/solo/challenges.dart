import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import 'stage.dart';

/// Partida desde el tablero vacío con reglas propias. [noAbility] deja sin
/// habilidad al jugador indicado (0 = vos, 1 = la IA).
GameState fresh(Faction you, Faction opp, {Rules rules = Rules.standard, Set<int> noAbility = const {}}) {
  final g = GameState(you, opp, rules: rules);
  for (final p in noAbility) {
    g.abilityUses[p] = rules.abilityCharges ?? 0;
    if (rules.abilityCharges == null) g.cooldowns[p] = 1 << 20;
  }
  return g;
}

/// Mano de [f] con cambios: tipo → cantidad.
Map<Faction, Map<PieceType, int>> handsWith(Faction f, Map<PieceType, int> changes) => {
  for (final e in startingHands.entries) e.key: e.key == f ? {...e.value, ...changes} : e.value,
};

const _sh = Faction.shaolin, _nj = Faction.ninja;

Stage _challenge(
  String id, {
  required Faction you,
  Faction? opp,
  required AiLevel level,
  required GameState Function() build,
}) => Stage(
  id: id,
  kind: StageKind.challenge,
  you: you,
  opp: opp ?? (you == _sh ? _nj : _sh),
  level: level,
  build: build,
);

final _sprint = Rules.standard.copyWith(siegeRound: () => 20, roundLimit: () => 30);
final _earlySiege = Rules.standard.copyWith(siegeRound: () => 8, roundLimit: () => 30);
final _noDragons = Rules.standard.copyWith(hands: handsWith(_sh, {PieceType.dragon: 0}));
final _tenguHorde = Rules.standard.copyWith(hands: handsWith(_nj, {PieceType.tengu: 3}));
final _lastStand = Rules.standard.copyWith(siegeRound: () => null, roundLimit: () => 30);

/// Desafíos: reglas especiales u objetivos con condiciones, de menor a mayor dificultad.
final challenges = <Stage>[
  _challenge(
    'c01',
    you: _sh,
    level: AiLevel.novice,
    build: () => fresh(_sh, _nj, rules: _sprint),
  ),
  _challenge(
    'c02',
    you: _nj,
    level: AiLevel.easy,
    build: () => fresh(_nj, _sh, noAbility: {0}),
  ),
  _challenge(
    'c03',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, rules: _earlySiege),
  ),
  _challenge(
    'c04',
    you: _sh,
    opp: _sh,
    level: AiLevel.normal,
    build: () => fresh(_sh, _sh),
  ),
  _challenge(
    'c05',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, rules: _noDragons),
  ),
  _challenge(
    'c06',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, rules: _tenguHorde),
  ),
  _challenge(
    'c07',
    you: _nj,
    level: AiLevel.hard,
    build: () => fresh(_nj, _sh, noAbility: {1}),
  ),
  _challenge(
    'c08',
    you: _nj,
    opp: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _nj),
  ),
  _challenge(
    'c09',
    you: _sh,
    level: AiLevel.normal,
    build: () => buildScene(
      you: _sh,
      opp: _nj,
      rules: _lastStand,
      round: 6,
      yourAbility: true,
      oppAbility: true,
      pieces: const [
        (0, PieceType.monk, Hex(0, 0)),
        (1, PieceType.shinobi, Hex(1, 0)),
        (1, PieceType.kunoichi, Hex(1, -1)),
        (0, PieceType.serpent, Hex(0, -1)),
        (1, PieceType.kitsune, Hex(-1, 0)),
        (0, PieceType.tiger, Hex(1, 1)),
        (0, PieceType.dragon, Hex(-1, 2)),
        (1, PieceType.shogun, Hex(2, -1)),
        (1, PieceType.shinobi, Hex(2, 0)),
        (0, PieceType.crane, Hex(0, 2)),
      ],
      yourHand: const {
        PieceType.dragon: 1,
        PieceType.wukong: 1,
        PieceType.tiger: 1,
        PieceType.crane: 1,
        PieceType.serpent: 2,
      },
      oppHand: const {
        PieceType.shinobi: 1,
        PieceType.kunoichi: 1,
        PieceType.tengu: 2,
        PieceType.kitsune: 1,
        PieceType.shadow: 1,
      },
    ),
  ),
  _challenge(
    'c10',
    you: _sh,
    level: AiLevel.master,
    build: () => fresh(_sh, _nj),
  ),
];
