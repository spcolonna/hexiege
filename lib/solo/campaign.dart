import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'challenges.dart';
import 'stage.dart';

const _sh = Faction.shaolin, _nj = Faction.ninja, _oni = Faction.oni;

Stage _battle(
  String id, {
  required Faction you,
  Faction? opp,
  required AiLevel level,
  Rules rules = Rules.standard,
  bool noAbility = false,
  GameState Function()? build,
}) {
  // Sin indicar, el rival es del otro bando; contra los del propio, partida espejo.
  final rival = opp ?? (you == _sh ? _nj : _sh);
  return Stage(
    id: id,
    kind: StageKind.campaign,
    you: you,
    opp: rival,
    level: level,
    build: build ?? () => fresh(you, rival, rules: rules, noAbility: noAbility ? const {1} : const {}),
  );
}

/// Arranque con el Líder de [owner] ya presionado por 3 fichas enemigas.
GameState _ambush(Faction you, Faction opp, {required int owner}) {
  final leader = (owner == 0 ? you : opp) == _sh ? PieceType.monk : PieceType.shogun;
  final otherLeader = (owner == 0 ? opp : you) == _sh ? PieceType.monk : PieceType.shogun;
  PieceType pick(Faction f, int i) => startingHands[f]!.keys.where((t) => !t.isLeader).elementAt(i);
  final victim = owner == 0 ? you : opp, attacker = owner == 0 ? opp : you;
  final a = 1 - owner;
  return buildScene(
    you: you,
    opp: opp,
    round: 4,
    yourAbility: true,
    oppAbility: true,
    pieces: [
      (owner, leader, const Hex(0, 0)),
      (owner, pick(victim, 0), const Hex(-1, 1)),
      (a, pick(attacker, 0), const Hex(1, 0)),
      (a, pick(attacker, 1), const Hex(1, -1)),
      (a, pick(attacker, 2), const Hex(0, -1)),
      (a, otherLeader, const Hex(2, -1)),
    ],
    yourHand: _rest(owner == 0 ? victim : attacker, owner == 0 ? [0] : [0, 1, 2]),
    oppHand: _rest(owner == 1 ? victim : attacker, owner == 1 ? [0] : [0, 1, 2]),
  );
}

/// Mano de [f] menos una ficha de cada tipo indicado (por índice, sin contar
/// al Líder) y menos el Líder, que ya está en el tablero.
Map<PieceType, int> _rest(Faction f, List<int> used) {
  final hand = Map.of(startingHands[f]!);
  final types = hand.keys.where((t) => !t.isLeader).toList();
  for (final i in used) {
    hand[types[i]] = hand[types[i]]! - 1;
  }
  hand.updateAll((t, n) => t.isLeader ? 0 : n);
  return hand;
}

final _earlySiege = Rules.standard.copyWith(siegeRound: () => 15);
final _fastAbilities = Rules.standard.copyWith(abilityCharges: () => 5, abilityCooldown: 1);
Rules _extra(Faction f, PieceType t, int n) => Rules.standard.copyWith(hands: handsWith(f, {t: n}));

/// Mano mixta del Sello final: media mano de cada facción y los dos Líderes.
const sealHand = {
  PieceType.monk: 1,
  PieceType.dragon: 1,
  PieceType.wukong: 1,
  PieceType.tiger: 1,
  PieceType.crane: 1,
  PieceType.serpent: 1,
  PieceType.shogun: 1,
  PieceType.shinobi: 2,
  PieceType.kunoichi: 1,
  PieceType.tengu: 1,
  PieceType.kitsune: 1,
};

/// El Sello: mano mixta, las dos habilidades con una sola recarga, y el Oni
/// solo cae si lo rodean fichas de las dos facciones.
final sealRules = Rules.standard.copyWith(
  mixedSeal: true,
  dualAbility: {0},
  handsByOwner: () => [sealHand, startingHands[_oni]!],
);

/// F3: Monje y Shogun ya en el tablero frente al Oni.
GameState sealScene() => buildScene(
  you: _sh,
  opp: _oni,
  rules: sealRules,
  round: 2,
  yourAbility: true,
  oppAbility: true,
  pieces: const [(0, PieceType.monk, Hex(-1, 0)), (0, PieceType.shogun, Hex(-1, 1)), (1, PieceType.oni, Hex(0, 0))],
  yourHand: {...sealHand, PieceType.monk: 0, PieceType.shogun: 0},
  oppHand: {...startingHands[_oni]!, PieceType.oni: 0},
);

Stage _final(String id, Faction you, AiLevel level, {List<String> requires = const [], GameState Function()? build}) =>
    Stage(
      id: id,
      kind: StageKind.campaign,
      you: you,
      opp: _oni,
      level: level,
      requires: requires,
      build: build ?? () => fresh(you, _oni),
    );

class Campaign {
  /// shaolin, ninja o finale (clave de los textos).
  final String id;
  final Faction faction;
  final List<Stage> stages;
  const Campaign(this.id, this.faction, this.stages);

  String get title => tr('campaign.$id.title');
  String get blurb => tr('campaign.$id.blurb');
  bool get isFinale => faction == _oni;
}

/// Batallas gratis por campaña (el Acto I).
const kFreeStagesPerCampaign = 6;

final campaigns = [
  Campaign('shaolin', _sh, shaolinCampaign),
  Campaign('ninja', _nj, ninjaCampaign),
  Campaign('finale', _oni, finale),
];

/// «El camino del Templo»: Ren, discípulo del Abad. 4 actos de 6; jefes en 6, 12, 18 y 24.
final shaolinCampaign = <Stage>[
  // Acto I (gratis)
  _battle('s1', you: _sh, level: AiLevel.novice),
  _battle('s2', you: _sh, level: AiLevel.easy, noAbility: true),
  _battle('s3', you: _sh, level: AiLevel.easy, build: () => _ambush(_sh, _nj, owner: 0)),
  _battle('s4', you: _sh, level: AiLevel.easy),
  _battle('s5', you: _sh, level: AiLevel.easy, rules: _earlySiege),
  _battle('s6', you: _sh, level: AiLevel.easy, rules: _extra(_nj, PieceType.shinobi, 4)),
  // Acto II
  _battle('s7', you: _sh, level: AiLevel.easy),
  _battle('s8', you: _sh, level: AiLevel.normal, rules: _earlySiege),
  _battle('s9', you: _sh, level: AiLevel.normal),
  _battle('s10', you: _sh, level: AiLevel.normal, rules: _extra(_nj, PieceType.shinobi, 4)),
  _battle('s11', you: _sh, level: AiLevel.normal, rules: _fastAbilities),
  _battle('s12', you: _sh, level: AiLevel.normal),
  // Acto III
  _battle('s13', you: _sh, opp: _sh, level: AiLevel.normal),
  _battle('s14', you: _sh, opp: _sh, level: AiLevel.normal, noAbility: true),
  _battle('s15', you: _sh, opp: _sh, level: AiLevel.normal),
  _battle('s16', you: _sh, level: AiLevel.hard, rules: _earlySiege),
  _battle('s17', you: _sh, level: AiLevel.hard, rules: _extra(_nj, PieceType.kunoichi, 3)),
  _battle('s18', you: _sh, opp: _sh, level: AiLevel.hard, rules: _fastAbilities),
  // Acto IV
  _battle('s19', you: _sh, level: AiLevel.hard),
  _battle('s20', you: _sh, level: AiLevel.hard, rules: _extra(_nj, PieceType.kunoichi, 3)),
  _battle('s21', you: _sh, level: AiLevel.hard, rules: _extra(_nj, PieceType.tengu, 3)),
  _battle('s22', you: _sh, level: AiLevel.hard, rules: _extra(_nj, PieceType.shinobi, 4)),
  _battle('s23', you: _sh, level: AiLevel.hard, rules: _earlySiege),
  _battle('s24', you: _sh, level: AiLevel.master),
];

/// «Sombras sobre el Templo»: Aya, kunoichi del clan. 4 actos de 6; jefes en 6, 12, 18 y 24.
final ninjaCampaign = <Stage>[
  // Acto I (gratis)
  _battle('n1', you: _nj, level: AiLevel.novice),
  _battle('n2', you: _nj, level: AiLevel.easy, noAbility: true),
  _battle('n3', you: _nj, level: AiLevel.easy, build: () => _ambush(_nj, _sh, owner: 1)),
  _battle('n4', you: _nj, level: AiLevel.easy),
  _battle('n5', you: _nj, level: AiLevel.easy, rules: _earlySiege),
  _battle('n6', you: _nj, level: AiLevel.easy, rules: _extra(_sh, PieceType.tiger, 3)),
  // Acto II
  _battle('n7', you: _nj, opp: _nj, level: AiLevel.easy),
  _battle('n8', you: _nj, level: AiLevel.normal, rules: _earlySiege),
  _battle('n9', you: _nj, level: AiLevel.normal, rules: _extra(_sh, PieceType.tiger, 3)),
  _battle('n10', you: _nj, level: AiLevel.normal),
  _battle('n11', you: _nj, level: AiLevel.normal, rules: _fastAbilities),
  _battle('n12', you: _nj, level: AiLevel.normal),
  // Acto III
  _battle('n13', you: _nj, level: AiLevel.normal),
  _battle('n14', you: _nj, level: AiLevel.normal, noAbility: true),
  _battle('n15', you: _nj, level: AiLevel.hard, rules: _extra(_sh, PieceType.shinobi, 4)),
  _battle('n16', you: _nj, level: AiLevel.hard),
  _battle('n17', you: _nj, level: AiLevel.hard, rules: _earlySiege),
  _battle('n18', you: _nj, level: AiLevel.hard, rules: _fastAbilities),
  // Acto IV
  _battle('n19', you: _nj, level: AiLevel.hard),
  _battle('n20', you: _nj, level: AiLevel.hard, rules: _extra(_sh, PieceType.tiger, 3)),
  _battle('n21', you: _nj, level: AiLevel.hard),
  _battle('n22', you: _nj, level: AiLevel.hard, rules: _extra(_sh, PieceType.dragon, 3)),
  _battle('n23', you: _nj, level: AiLevel.hard, rules: _earlySiege),
  _battle('n24', you: _nj, level: AiLevel.master),
];

/// «El Sello»: se abre con las dos campañas terminadas. Ren solo, Aya sola y los dos juntos.
final finale = <Stage>[
  _final('f1', _sh, AiLevel.hard, requires: const ['s24', 'n24']),
  _final('f2', _nj, AiLevel.hard),
  _final('f3', _sh, AiLevel.master, build: sealScene),
];
