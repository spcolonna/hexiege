import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';

/// Una lección del tutorial: un escenario armado a mano, un objetivo de una
/// sola jugada y el texto del Sensei. Vos sos siempre el Jugador 1 (Shaolin).
class Lesson {
  /// Clave de sus textos (`lesson.<id>.title`, `.body`, `.goal` y `.retry` opcional).
  final String id;
  final GameState Function() build;

  /// ¿Se cumplió el objetivo? [start] es el escenario recién armado.
  final bool Function(GameState start, GameState now) done;

  /// Tipos que se pueden colocar desde la mano (null = los que permita el motor).
  final Set<PieceType>? hand;
  final bool ability;

  /// Casillas a destacar mientras la lección está en curso.
  final Set<Hex> spotlight;

  const Lesson({
    required this.id,
    required this.build,
    required this.done,
    this.hasRetry = false,
    this.hand,
    this.ability = false,
    this.spotlight = const {},
  });

  /// Tiene un texto propio para cuando la jugada no es la pedida.
  final bool hasRetry;

  String get title => tr('lesson.$id.title');
  String get body => tr('lesson.$id.body', {
    'charges': Rules.standard.abilityCharges!,
    'cooldown': Rules.standard.abilityCooldown,
  });
  String get goal => tr('lesson.$id.goal');
  String get retry => tr(hasRetry ? 'lesson.$id.retry' : 'lesson.retry');
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
    id: 'l1',
    hand: {_d},
    spotlight: {Hex.origin},
    build: () => _scene(const [], turns: 0, emptyHand: false),
    done: (s, g) => _own(g) > _own(s),
  ),
  Lesson(
    id: 'l2',
    hand: {_cr},
    build: () => _scene(
      const [(0, _se, Hex(-1, 0)), (0, _ti, Hex(0, 0)), (1, _sh, Hex(1, 0)), (1, _ki, Hex(2, 0))],
      turns: 1,
      emptyHand: false,
    ),
    done: (s, g) => _own(g) > _own(s),
  ),
  Lesson(
    id: 'l3',
    build: () => _scene(const [
      (0, _se, Hex(-1, 0)),
      (0, _ti, Hex(0, 0)),
      (1, _sh, Hex(1, 0)),
      (1, _ki, Hex(2, 0)),
    ], emptyHand: false),
    done: (s, g) => g.leaderPlaced(0),
  ),
  Lesson(
    id: 'l4',
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
    id: 'l5',
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
    id: 'l6',
    hasRetry: true,
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
    id: 'l7',
    hasRetry: true,
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
        g.lastActionWasAbility &&
        g.winner == null &&
        // Reubicar la ficha enemiga: el Monje no se mueve de lugar.
        g.board.locateLeader(0) == s.board.locateLeader(0) &&
        g.board.occupiedNeighbors(g.board.locateLeader(0)!) <= 4,
  ),
];
