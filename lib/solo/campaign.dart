import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'challenges.dart';
import 'stage.dart';

const _sh = Faction.shaolin, _nj = Faction.ninja;

Stage _battle(
  String id, {
  required Faction you,
  required AiLevel level,
  GameState Function()? build,
}) {
  final opp = you == _sh ? _nj : _sh;
  return Stage(
    id: id,
    kind: StageKind.campaign,
    you: you,
    opp: opp,
    level: level,
    build: build ?? () => fresh(you, opp),
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

class Campaign {
  final Faction faction;
  final List<Stage> stages;
  const Campaign(this.faction, this.stages);

  String get title => tr('campaign.${faction.name}.title');
  String get blurb => tr('campaign.${faction.name}.blurb');
}

final campaigns = [Campaign(_sh, shaolinCampaign), Campaign(_nj, ninjaCampaign)];

/// Campaña Shaolin: defender el Templo de la invasión Ninja.
final shaolinCampaign = <Stage>[
  _battle(
    's1',
    you: _sh,
    level: AiLevel.novice,
  ),
  _battle(
    's2',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, noAbility: {1}),
  ),
  _battle(
    's3',
    you: _sh,
    level: AiLevel.easy,
    build: () => _ambush(_sh, _nj, owner: 0),
  ),
  _battle(
    's4',
    you: _sh,
    level: AiLevel.normal,
    build: () => fresh(_sh, _nj, rules: _earlySiege),
  ),
  _battle(
    's5',
    you: _sh,
    level: AiLevel.normal,
    build: () => fresh(_sh, _nj, rules: _extra(_nj, PieceType.shinobi, 4)),
  ),
  _battle(
    's6',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, rules: _fastAbilities),
  ),
  _battle(
    's7',
    you: _sh,
    level: AiLevel.hard,
  ),
  _battle(
    's8',
    you: _sh,
    level: AiLevel.master,
  ),
];

/// Campaña Ninja: infiltrarse en el Templo y robar el pergamino de Jade.
final ninjaCampaign = <Stage>[
  _battle(
    'n1',
    you: _nj,
    level: AiLevel.novice,
  ),
  _battle(
    'n2',
    you: _nj,
    level: AiLevel.easy,
    build: () => fresh(_nj, _sh, noAbility: {1}),
  ),
  _battle(
    'n3',
    you: _nj,
    level: AiLevel.easy,
    build: () => _ambush(_nj, _sh, owner: 1),
  ),
  _battle(
    'n4',
    you: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _sh, rules: _earlySiege),
  ),
  _battle(
    'n5',
    you: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _sh, rules: _extra(_sh, PieceType.tiger, 3)),
  ),
  _battle(
    'n6',
    you: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _sh, rules: _fastAbilities),
  ),
  _battle(
    'n7',
    you: _nj,
    level: AiLevel.hard,
  ),
  _battle(
    'n8',
    you: _nj,
    level: AiLevel.master,
  ),
];
