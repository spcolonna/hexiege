import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';

/// Una lección del tutorial: un escenario armado a mano, un objetivo de una
/// sola jugada y el texto del Sensei. Vos sos siempre el Jugador 1 (Shaolin).
class Lesson {
  final String title;
  final String body;
  final String goal;
  final String retry;
  final GameState Function() build;

  /// ¿Se cumplió el objetivo? [start] es el escenario recién armado.
  final bool Function(GameState start, GameState now) done;

  /// Tipos que se pueden colocar desde la mano (null = los que permita el motor).
  final Set<PieceType>? hand;
  final bool ability;

  /// Casillas a destacar mientras la lección está en curso.
  final Set<Hex> spotlight;

  const Lesson({
    required this.title,
    required this.body,
    required this.goal,
    required this.build,
    required this.done,
    this.retry = 'Casi. Probá de nuevo.',
    this.hand,
    this.ability = false,
    this.spotlight = const {},
  });
}

GameState _scene(List<(int, PieceType, Hex)> pieces, {int turns = 3, bool emptyHand = true}) {
  final g = GameState(Faction.shaolin, Faction.ninja);
  for (final (owner, type, at) in pieces) {
    g.setupPut(owner, type, at);
  }
  g.turnsTaken
    ..[0] = turns
    ..[1] = turns;
  if (emptyHand) g.hands[0].updateAll((_, _) => 0);
  return g;
}

int _own(GameState g) => g.board.tops.where((e) => e.value.owner == 0).length;

bool _moved(GameState start, GameState now, PieceType type) {
  final id = start.board.tops.firstWhere((e) => e.value.owner == 0 && e.value.type == type).value.id;
  return start.board.find(id) != now.board.find(id);
}

const _m = PieceType.monk, _d = PieceType.dragon, _ti = PieceType.tiger, _cr = PieceType.crane;
const _se = PieceType.serpent, _sg = PieceType.shogun, _sh = PieceType.shinobi;
const _ku = PieceType.kunoichi, _ki = PieceType.kitsune;

final lessons = <Lesson>[
  Lesson(
    title: 'La colmena',
    body:
        'Hexiege no tiene tablero: las fichas que colocás forman la colmena, '
        'y crece hacia donde la lleven los jugadores.',
    goal: 'Elegí el Dragón de tu mano y colocalo en el centro.',
    hand: {_d},
    spotlight: {Hex.origin},
    build: () => _scene(const [], turns: 0, emptyHand: false),
    done: (s, g) => _own(g) > _own(s),
  ),
  Lesson(
    title: 'Colocar fichas',
    body:
        'Las fichas nuevas solo pueden tocar fichas tuyas, nunca enemigas. '
        'Las casillas válidas se iluminan al elegir una ficha.',
    goal: 'Colocá la Grulla junto a tus fichas.',
    hand: {_cr},
    build: () => _scene(
      const [(0, _se, Hex(-1, 0)), (0, _ti, Hex(0, 0)), (1, _sh, Hex(1, 0)), (1, _ki, Hex(2, 0))],
      turns: 1,
      emptyHand: false,
    ),
    done: (s, g) => _own(g) > _own(s),
  ),
  Lesson(
    title: 'Tu Líder',
    body:
        'El Monje Superior es tu Líder (borde dorado). Tiene que entrar antes de tu 4.º turno '
        'y, mientras no esté en juego, no podés mover fichas.',
    goal: 'Es tu 4.º turno: colocá al Monje.',
    build: () => _scene(const [
      (0, _se, Hex(-1, 0)),
      (0, _ti, Hex(0, 0)),
      (1, _sh, Hex(1, 0)),
      (1, _ki, Hex(2, 0)),
    ], emptyHand: false),
    done: (s, g) => g.leaderPlaced(0),
  ),
  Lesson(
    title: 'Una sola colmena',
    body:
        'Tocá una ficha tuya para ver adónde puede ir. La colmena nunca se puede partir: '
        'las fichas que la sostienen quedan trabadas.',
    goal: 'El Monje y el Tigre sostienen la fila. Mové la Serpiente.',
    spotlight: {Hex(-2, 0)},
    build: () => _scene(const [
      (0, _se, Hex(-2, 0)),
      (0, _m, Hex(-1, 0)),
      (0, _ti, Hex(0, 0)),
      (1, _sh, Hex(1, 0)),
      (1, _sg, Hex(2, 0)),
    ]),
    done: (s, g) => _moved(s, g, _se),
  ),
  Lesson(
    title: 'Cada ficha es distinta',
    body:
        'Cada ficha se mueve a su manera. El Dragón vuela en línea recta por encima de la colmena. '
        'Mantené apretada cualquier ficha para leer cómo se mueve.',
    goal: 'Hacé volar al Dragón hasta el otro extremo.',
    spotlight: {Hex(-2, 0), Hex(3, 0)},
    build: () => _scene(const [
      (0, _d, Hex(-2, 0)),
      (0, _m, Hex(-1, 0)),
      (0, _se, Hex(0, 0)),
      (1, _sh, Hex(1, 0)),
      (1, _sg, Hex(2, 0)),
    ]),
    done: (s, g) => _moved(s, g, _d),
  ),
  Lesson(
    title: 'Rodeá al Líder',
    body:
        'Ganás cuando el Líder enemigo queda rodeado por los 6 lados, con fichas de cualquier color. '
        'Al Shogun le falta una sola.',
    goal: 'Cerrá el cerco con la Serpiente.',
    retry: 'Así no se cierra el cerco. Probá de nuevo.',
    spotlight: {Hex(1, -1)},
    build: () => _scene(const [
      (1, _sg, Hex(0, 0)),
      (0, _ti, Hex(1, 0)),
      (0, _se, Hex(0, -1)),
      (1, _sh, Hex(-1, 0)),
      (0, _cr, Hex(-1, 1)),
      (1, _ki, Hex(0, 1)),
      (0, _se, Hex(2, -1)),
      (0, _m, Hex(-1, 2)),
    ]),
    done: (s, g) => g.winner == 0,
  ),
  Lesson(
    title: 'Habilidad de facción',
    body:
        'Además de tu jugada, cada facción tiene una habilidad que se recarga en 3 turnos. '
        'Shaolin tiene la Meditación de Jade. Tu Monje tiene 5 vecinos: ¡está en peligro!',
    goal: 'Usá la habilidad para reubicar una ficha enemiga lejos del Monje.',
    retry: 'Tu Monje sigue en peligro. Probá de nuevo.',
    ability: true,
    spotlight: {Hex(0, 0)},
    build: () => _scene(const [
      (0, _m, Hex(0, 0)),
      (1, _ku, Hex(1, 0)),
      (0, _se, Hex(1, -1)),
      (1, _sh, Hex(0, -1)),
      (0, _ti, Hex(-1, 0)),
      (1, _sg, Hex(-1, 1)),
    ]),
    done: (s, g) =>
        g.abilityUsedThisTurn && g.winner == null && g.board.occupiedNeighbors(g.board.locateLeader(0)!) <= 4,
  ),
];
