import 'board.dart';
import 'hex.dart';
import 'moves.dart';
import 'pieces.dart';
import 'rules.dart';

export 'rules.dart';

/// El Líder debe estar en el tablero al terminar este número de turnos propios.
const int leaderDeadlineTurn = 4;

/// Estado completo de una partida y sus reglas.
///
/// Turno: una acción principal (colocar o mover) + opcionalmente la habilidad
/// de facción (antes o después), y luego [endTurn].
class GameState {
  final Rules rules;
  final List<Faction> factions;
  Board board;
  final List<Map<PieceType, int>> hands;
  int current = 0;
  int ply = 0;
  final List<int> turnsTaken;
  final List<int> cooldowns;
  final Map<int, int> paralyzedUntil; // pieceId -> último ply en que está paralizada
  final Map<Hex, int> seals; // celda -> dueño del sello
  final List<bool> shogunSwapUsed;
  final List<int> abilityUses;
  bool mainActionDone = false;
  bool abilityUsedThisTurn = false;
  int? winner;
  bool draw = false;

  /// La partida terminó en empate por el límite de rondas.
  bool endedByLimit = false;
  int _nextId;

  GameState(Faction p0, Faction p1, {this.rules = Rules.standard})
    : factions = [p0, p1],
      board = Board(),
      hands = [Map.of(rules.hands[p0]!), Map.of(rules.hands[p1]!)],
      turnsTaken = [0, 0],
      cooldowns = [0, 0],
      paralyzedUntil = {},
      seals = {},
      shogunSwapUsed = [false, false],
      abilityUses = [0, 0],
      _nextId = 0;

  GameState._copy(GameState o)
    : rules = o.rules,
      factions = o.factions,
      board = Board.copy(o.board),
      hands = [Map.of(o.hands[0]), Map.of(o.hands[1])],
      current = o.current,
      ply = o.ply,
      turnsTaken = List.of(o.turnsTaken),
      cooldowns = List.of(o.cooldowns),
      paralyzedUntil = Map.of(o.paralyzedUntil),
      seals = Map.of(o.seals),
      shogunSwapUsed = List.of(o.shogunSwapUsed),
      abilityUses = List.of(o.abilityUses),
      mainActionDone = o.mainActionDone,
      abilityUsedThisTurn = o.abilityUsedThisTurn,
      winner = o.winner,
      draw = o.draw,
      endedByLimit = o.endedByLimit,
      _nextId = o._nextId;

  GameState copy() => GameState._copy(this);

  /// Saca una ficha de la mano de [owner] y la pone en [at] sin validar reglas.
  /// Solo para armar escenarios (tutorial, tests).
  Piece setupPut(int owner, PieceType type, Hex at) {
    hands[owner][type] = hands[owner][type]! - 1;
    final p = Piece(_nextId++, type, owner);
    board.push(at, p);
    return p;
  }

  bool get isOver => winner != null || draw;

  /// Ronda en curso (empieza en 1).
  int get round => ply ~/ 2 + 1;

  /// Rondas que faltan para el límite, contando la actual (null = sin límite).
  int? get roundsLeft => rules.roundLimit == null ? null : rules.roundLimit! - round + 1;

  /// Asedio: alcanza con ocupar 5 lados del Líder.
  bool get inSiege => rules.siegeRound != null && round >= rules.siegeRound!;

  /// Vecinos ocupados que capturan al Líder ahora mismo.
  int get captureThreshold => inSiege ? 5 : 6;

  /// Vecinos ocupados del Líder de [p] (0 si no está en el tablero).
  int leaderPressure(int p) {
    final h = board.locateLeader(p);
    return h == null ? 0 : board.occupiedNeighbors(h);
  }

  Faction get currentFaction => factions[current];
  int get opponent => 1 - current;

  bool leaderPlaced(int p) => board.locateLeader(p) != null;

  bool isParalyzed(Piece p) {
    final until = paralyzedUntil[p.id];
    return until != null && ply <= until;
  }

  /// La ficha en [h] está junto a una Serpiente enemiga: pierde sus efectos especiales.
  bool isSuppressed(Hex h, int owner) => h.neighbors.any((n) {
    final t = board.top(n);
    return t != null && t.type == PieceType.serpent && t.owner != owner;
  });

  /// Debe colocar al Líder este turno.
  bool get mustPlaceLeader => !leaderPlaced(current) && turnsTaken[current] >= leaderDeadlineTurn - 1;

  // ---------------------------------------------------------------- Colocación

  List<PieceType> placeableTypes() {
    if (isOver || mainActionDone) return [];
    final types = hands[current].entries.where((e) => e.value > 0).map((e) => e.key);
    final list = mustPlaceLeader ? types.where((t) => t.isLeader).toList() : types.toList();
    if (list.isEmpty || placementTargets().isEmpty) return [];
    return list;
  }

  Set<Hex> placementTargets() {
    if (board.isEmpty) return {Hex.origin};
    final ownCount = board.tops.where((e) => e.value.owner == current).length;
    if (ownCount == 0) {
      return {
        for (final h in board.occupied)
          for (final n in h.neighbors)
            if (!board.isOccupied(n)) n,
      };
    }
    final result = <Hex>{};
    for (final e in board.tops) {
      if (e.value.owner != current) continue;
      for (final n in e.key.neighbors) {
        if (board.isOccupied(n)) continue;
        final touchesEnemy = n.neighbors.any((m) {
          final t = board.top(m);
          return t != null && t.owner != current;
        });
        if (!touchesEnemy) result.add(n);
      }
    }
    return result;
  }

  bool place(PieceType type, Hex at) {
    if (!placeableTypes().contains(type) || !placementTargets().contains(at)) return false;
    hands[current][type] = hands[current][type]! - 1;
    board.push(at, Piece(_nextId++, type, current));
    _landed(at);
    mainActionDone = true;
    _checkWin();
    return true;
  }

  // ---------------------------------------------------------------- Movimiento

  bool _canMoveFrom(Hex src) {
    if (isOver || mainActionDone || !leaderPlaced(current) || mustPlaceLeader) return false;
    final p = board.top(src);
    if (p == null || p.owner != current || isParalyzed(p)) return false;
    return board.canLift(src);
  }

  Set<Hex> moveTargets(Hex src) {
    if (!_canMoveFrom(src)) return {};
    final lifted = Board.copy(board);
    final p = lifted.pop(src);
    final dests = destinationsFor(p.type, lifted, src, rules);
    final limited =
        (p.type == PieceType.tengu && rules.tenguNearLeader != TenguNearLeader.allowed) ||
        (p.type == PieceType.shinobi && !rules.shinobiGateNextToLeader);
    final enemyLeader = limited ? lifted.locateLeader(1 - p.owner) : null;
    if (enemyLeader != null) {
      bool nextToLeader(Hex d) => d.distanceTo(enemyLeader) == 1;
      if (p.type == PieceType.tengu) {
        // notClosing: prohibido solo el hueco que completaría el cerco.
        final closes = lifted.occupiedNeighbors(enemyLeader) + 1 >= captureThreshold;
        if (rules.tenguNearLeader == TenguNearLeader.never || closes) dests.removeWhere(nextToLeader);
      }
      if (p.type == PieceType.shinobi && !rules.shinobiGateNextToLeader) {
        final gated = slideReach(lifted, src, maxSteps: rules.shinobiRange);
        dests.removeWhere((d) => nextToLeader(d) && !gated.contains(d));
      }
    }
    // Defensa extra: la colmena resultante debe quedar conectada.
    return dests.where((d) {
      final b = Board.copy(lifted)..push(d, p);
      return b.isConnected();
    }).toSet();
  }

  /// Intercambio del Shogun con un Shinobi adyacente (1 vez por partida).
  Set<Hex> shogunSwapTargets(Hex src) {
    if (isOver || mainActionDone || !rules.shogunSwap || shogunSwapUsed[current]) return {};
    final p = board.top(src);
    if (p == null || p.owner != current || p.type != PieceType.shogun) return {};
    if (isParalyzed(p) || board.height(src) > 1 || isSuppressed(src, current)) return {};
    return src.neighbors.where((n) {
      final t = board.top(n);
      return t != null && t.owner == current && t.type == PieceType.shinobi && board.height(n) == 1 && !isParalyzed(t);
    }).toSet();
  }

  Iterable<Hex> movablePieces() => board.tops
      .where((e) => e.value.owner == current)
      .map((e) => e.key)
      .where((h) => moveTargets(h).isNotEmpty || shogunSwapTargets(h).isNotEmpty);

  bool hasAnyMainAction() => placeableTypes().isNotEmpty || movablePieces().isNotEmpty;

  /// Objetivos de efectos opcionales tras mover [from] -> [to] (para la UI).
  ({Set<Hex> paralyze, Set<Hex> seal}) effectOptions(Hex from, Hex to) {
    final p = board.top(from);
    if (p == null) return (paralyze: <Hex>{}, seal: <Hex>{});
    final b = Board.copy(board);
    b.push(to, b.pop(from));
    return _effectOptionsOn(b, p, to);
  }

  ({Set<Hex> paralyze, Set<Hex> seal}) _effectOptionsOn(Board b, Piece p, Hex at) {
    final suppressed = at.neighbors.any((n) {
      final t = b.top(n);
      return t != null && t.type == PieceType.serpent && t.owner != p.owner;
    });
    if (suppressed) return (paralyze: <Hex>{}, seal: <Hex>{});
    if (p.type == PieceType.kunoichi && rules.kunoichiParalysis) {
      return (
        paralyze: at.neighbors.where((n) {
          final t = b.top(n);
          return t != null && t.owner != p.owner;
        }).toSet(),
        seal: <Hex>{},
      );
    }
    if (p.type == PieceType.shadow && rules.shadowSeal) {
      return (
        paralyze: <Hex>{},
        seal: at.neighbors.where((n) => n != at && !b.isOccupied(n) && !seals.containsKey(n)).toSet(),
      );
    }
    return (paralyze: <Hex>{}, seal: <Hex>{});
  }

  bool move(Hex from, Hex to, {Hex? paralyze, Hex? seal}) {
    if (!moveTargets(from).contains(to)) return false;
    final p = board.pop(from);
    board.push(to, p);
    _landed(to);

    final opts = _effectOptionsOn(board, p, to);
    if (p.type == PieceType.tiger && !isSuppressed(to, p.owner)) _tigerPush(from, to);
    if (paralyze != null && opts.paralyze.contains(paralyze)) _paralyze(board.top(paralyze)!);
    if (seal != null && opts.seal.contains(seal)) {
      seals.removeWhere((_, owner) => owner == current);
      seals[seal] = current;
    }
    mainActionDone = true;
    _checkWin();
    return true;
  }

  bool shogunSwap(Hex from, Hex to) {
    if (!shogunSwapTargets(from).contains(to)) return false;
    final a = board.pop(from), b = board.pop(to);
    board.push(from, b);
    board.push(to, a);
    shogunSwapUsed[current] = true;
    mainActionDone = true;
    _checkWin();
    return true;
  }

  void _tigerPush(Hex from, Hex to) {
    final diff = to - from;
    final dir = Hex.directions.firstWhere((d) => [1, 2, 3].any((k) => d * k == diff), orElse: () => const Hex(0, 0));
    if (dir == const Hex(0, 0)) return;
    final target = to + dir;
    final dest = target + dir;
    final t = board.top(target);
    if (t == null || t.owner == current || board.height(target) != 1 || board.isOccupied(dest)) return;
    final b = Board.copy(board);
    b.push(dest, b.pop(target));
    if (!b.isConnected()) return;
    board = b;
    _landed(dest);
  }

  // ---------------------------------------------------------------- Habilidades

  /// Usos de habilidad que le quedan a [p] (null = ilimitados).
  int? abilityChargesLeft(int p) => rules.abilityCharges == null ? null : rules.abilityCharges! - abilityUses[p];

  bool get abilityAvailable =>
      !isOver &&
      !abilityUsedThisTurn &&
      cooldowns[current] == 0 &&
      leaderPlaced(current) &&
      (abilityChargesLeft(current) ?? 1) > 0;

  /// Ficha perimetral: sola en su celda, removible sin romper la colmena y con algún hueco al lado.
  bool _isPerimeter(Hex h) => board.height(h) == 1 && board.canLift(h) && h.neighbors.any((n) => !board.isOccupied(n));

  // Shaolin: Meditación de Jade
  Set<Hex> jadeRelocateSources() {
    if (!abilityAvailable || currentFaction != Faction.shaolin) return {};
    return board.tops
        .where((e) => e.value.owner != current && !e.value.type.isLeader && _isPerimeter(e.key))
        .map((e) => e.key)
        .toSet();
  }

  Set<Hex> jadeRelocateTargets(Hex src) {
    if (!jadeRelocateSources().contains(src)) return {};
    final b = Board.copy(board)..pop(src);
    return {
      for (final h in b.occupied)
        for (final n in h.neighbors)
          if (!b.isOccupied(n) && n != src) n,
    };
  }

  bool jadeRelocate(Hex src, Hex dst) {
    if (!jadeRelocateTargets(src).contains(dst)) return false;
    board.push(dst, board.pop(src));
    _landed(dst);
    _useAbility();
    return true;
  }

  Set<Hex> jadeSwapSources() {
    if (!abilityAvailable || currentFaction != Faction.shaolin) return {};
    return board.tops
        .where((e) => e.value.owner == current && board.height(e.key) == 1)
        .map((e) => e.key)
        .where((h) => jadeSwapTargets(h).isNotEmpty)
        .toSet();
  }

  Set<Hex> jadeSwapTargets(Hex a) {
    if (!abilityAvailable || currentFaction != Faction.shaolin) return {};
    final pa = board.top(a);
    if (pa == null || pa.owner != current || board.height(a) != 1) return {};
    return a.neighbors.where((n) {
      final t = board.top(n);
      return t != null && t.owner == current && board.height(n) == 1 && t.type != pa.type;
    }).toSet();
  }

  bool jadeSwap(Hex a, Hex b) {
    if (!jadeSwapTargets(a).contains(b)) return false;
    final pa = board.pop(a), pb = board.pop(b);
    board.push(a, pb);
    board.push(b, pa);
    _useAbility();
    return true;
  }

  // Ninja: Kawarimi
  Set<Hex> kawarimiTargets() {
    if (!abilityAvailable || currentFaction != Faction.ninja) return {};
    return board.tops.where((e) => !e.value.type.isLeader && _isPerimeter(e.key)).map((e) => e.key).toSet();
  }

  bool kawarimi(Hex h) {
    if (!kawarimiTargets().contains(h)) return false;
    final p = board.pop(h);
    hands[p.owner][p.type] = (hands[p.owner][p.type] ?? 0) + 1;
    paralyzedUntil.remove(p.id);
    _useAbility();
    return true;
  }

  void _useAbility() {
    abilityUsedThisTurn = true;
    cooldowns[current] = rules.abilityCooldown;
    abilityUses[current]++;
    _checkWin();
  }

  // ---------------------------------------------------------------- Turno

  bool get canEndTurn => !isOver && (mainActionDone || !hasAnyMainAction());

  bool endTurn() {
    if (!canEndTurn) return false;
    turnsTaken[current]++;
    ply++;
    if (rules.roundLimit != null && ply >= rules.roundLimit! * 2) {
      endedByLimit = true;
      draw = true;
      return true;
    }
    current = opponent;
    mainActionDone = false;
    abilityUsedThisTurn = false;
    if (cooldowns[current] > 0) cooldowns[current]--;
    paralyzedUntil.removeWhere((_, until) => until < ply);
    return true;
  }

  // ---------------------------------------------------------------- Interno

  void _paralyze(Piece p) {
    // Bloquea el próximo turno del dueño de la ficha.
    paralyzedUntil[p.id] = p.owner == current ? ply + 2 : ply + 1;
  }

  void _landed(Hex h) {
    final owner = seals[h];
    final p = board.top(h);
    if (owner == null || p == null || p.owner == owner) return;
    seals.remove(h);
    _paralyze(p);
  }

  void _checkWin() {
    final lost = [
      for (var p = 0; p < 2; p++)
        () {
          final h = board.locateLeader(p);
          return h != null && board.occupiedNeighbors(h) >= captureThreshold;
        }(),
    ];
    if (lost[0] && lost[1]) {
      draw = true;
    } else if (lost[0]) {
      winner = 1;
    } else if (lost[1]) {
      winner = 0;
    }
  }
}
