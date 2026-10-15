import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import 'challenges.dart';
import 'stage.dart';

const _sh = Faction.shaolin, _nj = Faction.ninja;

Stage _battle(
  String id,
  String title,
  String goal,
  String story, {
  required Faction you,
  required AiLevel level,
  GameState Function()? build,
}) {
  final opp = you == _sh ? _nj : _sh;
  return Stage(
    id: id,
    kind: StageKind.campaign,
    title: title,
    goal: goal,
    intro: story,
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
  final String title;
  final String blurb;
  final Faction faction;
  final List<Stage> stages;
  const Campaign(this.title, this.blurb, this.faction, this.stages);
}

final campaigns = [
  Campaign('El camino del Templo', 'Defendé el Templo de la invasión ninja.', _sh, shaolinCampaign),
  Campaign('Sombras sobre el Templo', 'Infiltrate y robá el pergamino de Jade.', _nj, ninjaCampaign),
];

/// Campaña Shaolin: defender el Templo de la invasión Ninja.
final shaolinCampaign = <Stage>[
  _battle(
    's1',
    'Las puertas del Templo',
    'Rodeá al Gran Shogun.',
    'Una sombra cruzó el muro del Templo esta noche. El Abad te envía a ver quién se atreve.',
    you: _sh,
    level: AiLevel.novice,
  ),
  _battle(
    's2',
    'Patio de entrenamiento',
    'Ganá. El explorador ninja no usa su habilidad.',
    'Atrapaste a un explorador. Antes de interrogarlo, el Abad quiere ver cómo peleás.',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, noAbility: {1}),
  ),
  _battle(
    's3',
    'Emboscada en el bosque',
    'Tu Monje empieza con 3 fichas enemigas al lado. Ganá.',
    'De camino al pueblo, tres sombras caen de los árboles. No hay tiempo para formar.',
    you: _sh,
    level: AiLevel.easy,
    build: () => _ambush(_sh, _nj, owner: 0),
  ),
  _battle(
    's4',
    'El puente de piedra',
    'El Asedio empieza en la ronda 15. Ganá.',
    'Los ninjas bloquean el único puente. La batalla será larga y sin retirada.',
    you: _sh,
    level: AiLevel.normal,
    build: () => fresh(_sh, _nj, rules: _earlySiege),
  ),
  _battle(
    's5',
    'Cuatro sombras',
    'El rival tiene 4 Shinobi. Ganá.',
    'El clan mandó refuerzos: los Shinobi se cuelan por cualquier rendija.',
    you: _sh,
    level: AiLevel.normal,
    build: () => fresh(_sh, _nj, rules: _extra(_nj, PieceType.shinobi, 4)),
  ),
  _battle(
    's6',
    'Niebla en el valle',
    'Habilidades: 5 usos y 1 turno de recarga. Ganá.',
    'En la niebla nada se queda quieto. Ni tus fichas ni las suyas.',
    you: _sh,
    level: AiLevel.easy,
    build: () => fresh(_sh, _nj, rules: _fastAbilities),
  ),
  _battle(
    's7',
    'La pagoda',
    'Ganá.',
    'El Shogun se refugió en la pagoda con su guardia. Subí piso por piso.',
    you: _sh,
    level: AiLevel.hard,
  ),
  _battle(
    's8',
    'El Gran Shogun',
    'Ganá la batalla final.',
    'En la cima te espera el Gran Shogun. Esta vez pelea él mismo, con todo lo que sabe.',
    you: _sh,
    level: AiLevel.master,
  ),
];

/// Campaña Ninja: infiltrarse en el Templo y robar el pergamino de Jade.
final ninjaCampaign = <Stage>[
  _battle(
    'n1',
    'Sobre el muro',
    'Rodeá al Monje Superior.',
    'El pergamino de Jade está en el Templo. Primero hay que pasar al guardia del muro.',
    you: _nj,
    level: AiLevel.novice,
  ),
  _battle(
    'n2',
    'Los novicios',
    'Ganá. Los novicios no saben meditar.',
    'Unos novicios dan la alarma. Todavía no aprendieron la Meditación de Jade.',
    you: _nj,
    level: AiLevel.easy,
    build: () => fresh(_nj, _sh, noAbility: {1}),
  ),
  _battle(
    'n3',
    'Golpe por sorpresa',
    'El Monje rival empieza con 3 de tus fichas al lado. Ganá.',
    'Caés sobre el patio antes de que el maestro de guardia pueda reaccionar.',
    you: _nj,
    level: AiLevel.easy,
    build: () => _ambush(_nj, _sh, owner: 1),
  ),
  _battle(
    'n4',
    'El jardín de piedra',
    'El Asedio empieza en la ronda 15. Ganá.',
    'Los monjes cerraron el jardín. Hay que abrirse paso antes de que lleguen más.',
    you: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _sh, rules: _earlySiege),
  ),
  _battle(
    'n5',
    'Los guardianes',
    'El rival tiene 3 Tigres. Ganá.',
    'Los Tigres de Mármol custodian la biblioteca. Empujan todo lo que encuentran.',
    you: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _sh, rules: _extra(_sh, PieceType.tiger, 3)),
  ),
  _battle(
    'n6',
    'Humo y espejos',
    'Habilidades: 5 usos y 1 turno de recarga. Ganá.',
    'Bombas de humo por todas partes. Que ningún monje sepa dónde estás.',
    you: _nj,
    level: AiLevel.normal,
    build: () => fresh(_nj, _sh, rules: _fastAbilities),
  ),
  _battle(
    'n7',
    'La biblioteca',
    'Ganá.',
    'El pergamino está a la vista. Los mejores monjes del Templo se interponen.',
    you: _nj,
    level: AiLevel.hard,
  ),
  _battle(
    'n8',
    'El Abad',
    'Ganá la batalla final.',
    'El Abad en persona bloquea la salida. Nadie le ganó en cuarenta años.',
    you: _nj,
    level: AiLevel.master,
  ),
];
