import 'board.dart';
import 'events.dart';
import 'hex.dart';
import 'moves.dart';
import 'pieces.dart';
import 'rules.dart';

export 'events.dart';
export 'rules.dart';

/// El Líder debe estar en el tablero al terminar este número de turnos propios.
const int leaderDeadlineTurn = 4;

/// Estado completo de una partida y sus reglas.
///
/// Turno: exactamente una acción (colocar, mover, intercambio del Shogun o
/// habilidad de facción). Cada acción cierra el turno sola; si no hay ninguna
/// acción legal, el jugador debe [pass].
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

  /// La última acción (que cerró el turno) fue la habilidad de facción.
  bool lastActionWasAbility = false;
  int? winner;
  bool draw = false;

  /// La partida terminó en empate por el límite de rondas.
  bool endedByLimit = false;
  int _nextId;

  /// Si está activo, cada acción deja en [lastEvents] lo que pasó. No se copia:
  /// las copias de la IA no pagan el costo.
  bool recordEvents = false;

  /// Eventos de la última acción exitosa (con [recordEvents]).
  List<GameEvent> lastEvents = const [];

  GameState(Faction p0, Faction p1, {this.rules = Rules.standard})
    : factions = [p0, p1],
      board = Board(),
      hands = rules.handsByOwner != null
          ? [Map.of(rules.handsByOwner![0]), Map.of(rules.handsByOwner![1])]
          : [Map.of(rules.hands[p0]!), Map.of(rules.hands[p1]!)],
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
      lastActionWasAbility = o.lastActionWasAbility,
      winner = o.winner,
      draw = o.draw,
      endedByLimit = o.endedByLimit,
      _nextId = o._nextId;

  GameState copy() => GameState._copy(this);

  /// Foto de la partida para retomarla (solo con las reglas estándar).
  Map<String, Object?> toJson() => {
    'factions': [for (final f in factions) f.name],
    'board': [
      for (final h in board.occupied)
        {
          'q': h.q,
          'r': h.r,
          'stack': [for (final p in board.stackAt(h)) [p.id, p.type.name, p.owner]],
        },
    ],
    'hands': [
      for (final hand in hands) {for (final e in hand.entries) e.key.name: e.value},
    ],
    'current': current,
    'ply': ply,
    'turnsTaken': turnsTaken,
    'cooldowns': cooldowns,
    'paralyzedUntil': {for (final e in paralyzedUntil.entries) '${e.key}': e.value},
    'seals': [for (final e in seals.entries) [e.key.q, e.key.r, e.value]],
    'shogunSwapUsed': shogunSwapUsed,
    'abilityUses': abilityUses,
    'lastActionWasAbility': lastActionWasAbility,
    'nextId': _nextId,
  };

  /// Inversa de [toJson]; lanza si la foto no es válida.
  factory GameState.fromJson(Map<String, Object?> j) {
    List<Object?> list(String k) => j[k]! as List<Object?>;
    final f = [for (final n in list('factions')) Faction.values.byName(n! as String)];
    final g = GameState(f[0], f[1]);
    for (final c in list('board').cast<Map<String, Object?>>()) {
      final h = Hex(c['q']! as int, c['r']! as int);
      for (final p in (c['stack']! as List<Object?>).cast<List<Object?>>()) {
        g.board.push(h, Piece(p[0]! as int, PieceType.values.byName(p[1]! as String), p[2]! as int));
      }
    }
    final hands = list('hands').cast<Map<String, Object?>>();
    for (var i = 0; i < 2; i++) {
      g.hands[i]
        ..clear()
        ..addAll({for (final e in hands[i].entries) PieceType.values.byName(e.key): e.value! as int});
    }
    void ints(List<int> to, String k) => to.setAll(0, list(k).cast<int>());
    ints(g.turnsTaken, 'turnsTaken');
    ints(g.cooldowns, 'cooldowns');
    ints(g.abilityUses, 'abilityUses');
    g.shogunSwapUsed.setAll(0, list('shogunSwapUsed').cast<bool>());
    for (final e in (j['paralyzedUntil']! as Map<String, Object?>).entries) {
      g.paralyzedUntil[int.parse(e.key)] = e.value! as int;
    }
    for (final s in list('seals').cast<List<Object?>>()) {
      g.seals[Hex(s[0]! as int, s[1]! as int)] = s[2]! as int;
    }
    g
      ..current = j['current']! as int
      ..ply = j['ply']! as int
      ..lastActionWasAbility = j['lastActionWasAbility']! as bool
      .._nextId = j['nextId']! as int;
    return g;
  }

  /// Saca una ficha de la mano de [owner] y la pone en [at] sin validar reglas.
  /// Solo para armar escenarios (tutorial, tests).
  Piece setupPut(int owner, PieceType type, Hex at) {
    // Fichas que no están en la mano (escenas armadas) no la dejan negativa.
    hands[owner][type] = (hands[owner][type] ?? 1) - 1;
    final p = Piece(_nextId++, type, owner);
    board.push(at, p);
    return p;
  }

  /// Cierra el turno actual sin acción. Solo para armar escenarios (tests).
  void setupSkipTurn() => _finishTurn();

  bool get isOver => winner != null || draw;

  /// Ronda en curso (empieza en 1).
  int get round => ply ~/ 2 + 1;

  /// Rondas que faltan para el límite, contando la actual (null = sin límite).
  int? get roundsLeft => rules.roundLimit == null ? null : rules.roundLimit! - round + 1;

  /// Asedio: alcanza con ocupar 5 lados del Líder.
  bool get inSiege => rules.siegeRound != null && round >= rules.siegeRound!;

  /// Vecinos ocupados que capturan al Líder ahora mismo.
  int get captureThreshold => inSiege ? 5 : 6;

  /// Vecinos ocupados del Líder de [p] más rodeado (0 si no está en el tablero).
  int leaderPressure(int p) =>
      board.locateLeaders(p).fold(0, (m, h) => board.occupiedNeighbors(h) > m ? board.occupiedNeighbors(h) : m);

  /// Lados que le faltan al rival para capturar al Líder de [p] más rodeado
  /// (null si no está en el tablero).
  int? leaderMargin(int p) {
    int? best;
    for (final h in board.locateLeaders(p)) {
      final m = captureThreshold - board.occupiedNeighbors(h);
      if (best == null || m < best) best = m;
    }
    return best;
  }

  /// Cómo quedó rodeado el Líder caído de [p]: lados ocupados y de quién son
  /// las fichas de arriba (null si ninguno de sus Líderes está capturado).
  ({Hex leader, int sides, int enemy, int own})? captureBreakdown(int p) {
    for (final h in board.locateLeaders(p)) {
      if (!leaderCapturedOn(board, p, h)) continue;
      final around = [for (final n in h.neighbors) ?board.top(n)];
      final own = around.where((x) => x.owner == p).length;
      return (leader: h, sides: around.length, enemy: around.length - own, own: own);
    }
    return null;
  }

  /// Casillas libres junto al Líder de [p] que, ocupadas, lo dejan capturado
  /// o a un paso (solo cuando le faltan [within] lados o menos).
  Set<Hex> leaderOpenings(int p, {int within = 2}) => {
    for (final h in board.locateLeaders(p))
      if (captureThreshold - board.occupiedNeighbors(h) case final m when m > 0 && m <= within)
        ...h.neighbors.where((n) => !board.isOccupied(n)),
  };

  /// El Líder de [owner] en [h] está capturado en [b]. Con [Rules.mixedSeal],
  /// el Líder Oni además necesita fichas rivales de las dos facciones alrededor.
  bool leaderCapturedOn(Board b, int owner, Hex h) {
    if (b.occupiedNeighbors(h) < captureThreshold) return false;
    if (!rules.mixedSeal || !b.stackAt(h).any((p) => p.owner == owner && p.type == PieceType.oni)) return true;
    return hasMixedSurround(b, owner, h);
  }

  /// Entre las fichas de arriba alrededor de [h] hay una Shaolin y una Ninja
  /// que no son de [owner].
  static bool hasMixedSurround(Board b, int owner, Hex h) {
    final around = {
      for (final n in h.neighbors)
        if (b.top(n) case final t? when t.owner != owner) t.type.faction,
    };
    return around.contains(Faction.shaolin) && around.contains(Faction.ninja);
  }

  Faction get currentFaction => factions[current];
  int get opponent => 1 - current;

  bool leaderPlaced(int p) => board.locateLeader(p) != null;

  bool isParalyzed(Piece p) {
    final until = paralyzedUntil[p.id];
    return until != null && ply <= until;
  }

  /// La ficha en [h] está junto a una Serpiente enemiga (o a 2 casillas de un
  /// Ojo del Oni): pierde sus efectos especiales.
  bool isSuppressed(Hex h, int owner) => _suppressedOn(board, h, owner);

  static bool _suppressedOn(Board b, Hex h, int owner) {
    bool enemy(Hex n, PieceType type) {
      final t = b.top(n);
      return t != null && t.type == type && t.owner != owner;
    }

    for (final n in h.neighbors) {
      if (enemy(n, PieceType.serpent) || enemy(n, PieceType.oniEye)) return true;
      for (final m in n.neighbors) {
        if (m != h && enemy(m, PieceType.oniEye)) return true;
      }
    }
    return false;
  }

  /// La ficha en [h] tiene un efecto especial que hoy anula una Serpiente rival.
  bool isNullified(Hex h) {
    final p = board.top(h);
    if (p == null || !isSuppressed(h, p.owner)) return false;
    return switch (p.type) {
      PieceType.tiger => true,
      PieceType.kunoichi => rules.kunoichiParalysis,
      PieceType.gaki => true,
      PieceType.shadow => rules.shadowSeal,
      PieceType.shogun => rules.shogunSwap && !shogunSwapUsed[p.owner],
      _ => false,
    };
  }

  void _begin() {
    if (recordEvents) lastEvents = [];
  }

  /// Debe colocar al Líder este turno.
  bool get mustPlaceLeader => !leaderPlaced(current) && turnsTaken[current] >= leaderDeadlineTurn - 1;

  // ---------------------------------------------------------------- Colocación

  List<PieceType> placeableTypes() {
    if (isOver) return [];
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
    _begin();
    hands[current][type] = hands[current][type]! - 1;
    final piece = Piece(_nextId++, type, current);
    board.push(at, piece);
    if (recordEvents) lastEvents.add(PiecePlaced(current, piece, at));
    _landed(at);
    _finishTurn();
    return true;
  }

  // ---------------------------------------------------------------- Movimiento

  bool _canMoveFrom(Hex src) {
    if (isOver || !leaderPlaced(current) || mustPlaceLeader) return false;
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
    for (final enemyLeader in limited ? lifted.locateLeaders(1 - p.owner) : const <Hex>[]) {
      bool nextToLeader(Hex d) => d.distanceTo(enemyLeader) == 1;
      if (p.type == PieceType.tengu) {
        // notClosing: prohibido solo el hueco que completaría el cerco.
        if (rules.tenguNearLeader == TenguNearLeader.never) {
          dests.removeWhere(nextToLeader);
        } else {
          dests.removeWhere(
            (d) => nextToLeader(d) && leaderCapturedOn(Board.copy(lifted)..push(d, p), 1 - p.owner, enemyLeader),
          );
        }
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
    if (isOver || !rules.shogunSwap || shogunSwapUsed[current]) return {};
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

  bool hasAnyAbilityAction() =>
      (hasAbility(Faction.shaolin) && (jadeRelocateSources().isNotEmpty || jadeSwapSources().isNotEmpty)) ||
      (hasAbility(Faction.ninja) && kawarimiTargets().isNotEmpty);

  /// Hay alguna acción legal; si no, el jugador debe pasar.
  bool hasAnyAction() => !isOver && (hasAnyMainAction() || hasAnyAbilityAction());

  /// Objetivos de efectos opcionales tras mover [from] -> [to] (para la UI).
  ({Set<Hex> paralyze, Set<Hex> seal}) effectOptions(Hex from, Hex to) {
    final p = board.top(from);
    if (p == null) return (paralyze: <Hex>{}, seal: <Hex>{});
    final b = Board.copy(board);
    b.push(to, b.pop(from));
    return _effectOptionsOn(b, p, to);
  }

  ({Set<Hex> paralyze, Set<Hex> seal}) _effectOptionsOn(Board b, Piece p, Hex at, {bool ignoreSerpent = false}) {
    if (!ignoreSerpent && _suppressedOn(b, at, p.owner)) return (paralyze: <Hex>{}, seal: <Hex>{});
    if ((p.type == PieceType.kunoichi && rules.kunoichiParalysis) || p.type == PieceType.gaki) {
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
    _begin();
    final p = board.pop(from);
    board.push(to, p);
    if (recordEvents) lastEvents.add(Moved(current, p, from, to, climbed: board.height(to) > 1));
    _landed(to);

    final opts = _effectOptionsOn(board, p, to);
    if (p.type == PieceType.tiger) {
      if (!isSuppressed(to, p.owner)) {
        _tigerPush(from, to);
      } else if (recordEvents && _tigerPushTarget(board, from, to) != null) {
        lastEvents.add(Cancelled(current, p, to, CancelledEffect.push));
      }
    }
    if (paralyze != null && opts.paralyze.contains(paralyze)) {
      final t = board.top(paralyze)!;
      _paralyze(t);
      if (recordEvents) lastEvents.add(Paralyzed(current, t, paralyze));
    }
    if (seal != null && opts.seal.contains(seal)) {
      seals.removeWhere((_, owner) => owner == current);
      seals[seal] = current;
      if (recordEvents) lastEvents.add(SealPlaced(current, seal));
    }
    final hasEffect = p.type == PieceType.kunoichi || p.type == PieceType.gaki || p.type == PieceType.shadow;
    if (recordEvents && hasEffect && isSuppressed(to, p.owner)) {
      final would = _effectOptionsOn(board, p, to, ignoreSerpent: true);
      if (would.paralyze.isNotEmpty || would.seal.isNotEmpty) {
        final effect = p.type == PieceType.shadow ? CancelledEffect.seal : CancelledEffect.paralyze;
        lastEvents.add(Cancelled(current, p, to, effect));
      }
    }
    _finishTurn();
    return true;
  }

  bool shogunSwap(Hex from, Hex to) {
    if (!shogunSwapTargets(from).contains(to)) return false;
    _begin();
    final a = board.pop(from), b = board.pop(to);
    board.push(from, b);
    board.push(to, a);
    shogunSwapUsed[current] = true;
    if (recordEvents) lastEvents.add(ShogunSwapped(current, from, to));
    _finishTurn();
    return true;
  }

  /// Ficha que empujaría el Tigre al llegar a [to] y adónde ([target], [dest]), o null.
  ({Hex target, Hex dest, Board after})? _tigerPushTarget(Board board, Hex from, Hex to) {
    final diff = to - from;
    final dir = Hex.directions.firstWhere((d) => [1, 2, 3].any((k) => d * k == diff), orElse: () => const Hex(0, 0));
    if (dir == const Hex(0, 0)) return null;
    final target = to + dir;
    final dest = target + dir;
    final t = board.top(target);
    if (t == null || t.owner == board.top(to)!.owner || board.height(target) != 1 || board.isOccupied(dest)) {
      return null;
    }
    final b = Board.copy(board);
    b.push(dest, b.pop(target));
    if (!b.isConnected()) return null;
    return (target: target, dest: dest, after: b);
  }

  /// Empujón que haría el Tigre de [from] si fuera a [to] (sin mover nada), o null.
  ({Hex target, Hex dest})? tigerPushPreview(Hex from, Hex to) {
    final b = Board.copy(board);
    b.push(to, b.pop(from));
    if (_suppressedOn(b, to, b.top(to)!.owner)) return null;
    final push = _tigerPushTarget(b, from, to);
    return push == null ? null : (target: push.target, dest: push.dest);
  }

  void _tigerPush(Hex from, Hex to) {
    final push = _tigerPushTarget(board, from, to);
    if (push == null) return;
    board = push.after;
    if (recordEvents) lastEvents.add(Pushed(current, board.top(push.dest)!, push.target, push.dest));
    _landed(push.dest);
  }

  // ---------------------------------------------------------------- Habilidades

  /// Usos de habilidad que le quedan a [p] (null = ilimitados).
  int? abilityChargesLeft(int p) => rules.abilityCharges == null ? null : rules.abilityCharges! - abilityUses[p];

  /// El jugador actual tiene la habilidad de [f] (la de su facción, o las dos
  /// con [Rules.dualAbility]).
  bool hasAbility(Faction f) => factions[current] == f || rules.dualAbility.contains(current);

  bool get abilityAvailable =>
      !isOver &&
      (hasAbility(Faction.shaolin) || hasAbility(Faction.ninja)) &&
      cooldowns[current] == 0 &&
      leaderPlaced(current) &&
      (abilityChargesLeft(current) ?? 1) > 0;

  /// Las habilidades no mueven Líderes ni al Ojo del Oni.
  bool _movableByAbility(Piece p) => !p.type.isLeader && p.type != PieceType.oniEye;

  /// Ficha perimetral: sola en su celda, removible sin romper la colmena y con algún hueco al lado.
  bool _isPerimeter(Hex h) => board.height(h) == 1 && board.canLift(h) && h.neighbors.any((n) => !board.isOccupied(n));

  // Shaolin: Meditación de Jade
  Set<Hex> jadeRelocateSources() {
    if (!abilityAvailable || !hasAbility(Faction.shaolin)) return {};
    return board.tops
        .where((e) => e.value.owner != current && _movableByAbility(e.value) && _isPerimeter(e.key))
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
    _begin();
    final p = board.pop(src);
    board.push(dst, p);
    if (recordEvents) lastEvents.add(JadeRelocated(current, p, src, dst));
    _landed(dst);
    _useAbility();
    return true;
  }

  Set<Hex> jadeSwapSources() {
    if (!abilityAvailable || !hasAbility(Faction.shaolin)) return {};
    return board.tops
        .where((e) => e.value.owner == current && board.height(e.key) == 1)
        .map((e) => e.key)
        .where((h) => jadeSwapTargets(h).isNotEmpty)
        .toSet();
  }

  Set<Hex> jadeSwapTargets(Hex a) {
    if (!abilityAvailable || !hasAbility(Faction.shaolin)) return {};
    final pa = board.top(a);
    if (pa == null || pa.owner != current || board.height(a) != 1) return {};
    return a.neighbors.where((n) {
      final t = board.top(n);
      return t != null && t.owner == current && board.height(n) == 1 && t.type != pa.type;
    }).toSet();
  }

  bool jadeSwap(Hex a, Hex b) {
    if (!jadeSwapTargets(a).contains(b)) return false;
    _begin();
    final pa = board.pop(a), pb = board.pop(b);
    board.push(a, pb);
    board.push(b, pa);
    if (recordEvents) lastEvents.add(JadeSwapped(current, pa, pb, a, b));
    _useAbility();
    return true;
  }

  // Ninja: Kawarimi
  Set<Hex> kawarimiTargets() {
    if (!abilityAvailable || !hasAbility(Faction.ninja)) return {};
    return board.tops.where((e) => _movableByAbility(e.value) && _isPerimeter(e.key)).map((e) => e.key).toSet();
  }

  bool kawarimi(Hex h) {
    if (!kawarimiTargets().contains(h)) return false;
    _begin();
    final p = board.pop(h);
    if (recordEvents) lastEvents.add(Returned(current, p, h));
    hands[p.owner][p.type] = (hands[p.owner][p.type] ?? 0) + 1;
    paralyzedUntil.remove(p.id);
    _useAbility();
    return true;
  }

  void _useAbility() {
    cooldowns[current] = rules.abilityCooldown;
    abilityUses[current]++;
    _finishTurn(ability: true);
  }

  // ---------------------------------------------------------------- Turno

  /// Sin ninguna acción legal: cede el turno.
  bool get canPass => !isOver && !hasAnyAction();

  bool pass() {
    if (!canPass) return false;
    _begin();
    if (recordEvents) lastEvents.add(Passed(current));
    _finishTurn();
    return true;
  }

  /// Cierra el turno tras una acción: chequea victoria y pasa al rival.
  void _finishTurn({bool ability = false}) {
    lastActionWasAbility = ability;
    _checkWin();
    if (isOver) return;
    turnsTaken[current]++;
    final wasSiege = inSiege;
    ply++;
    // Al empezar el Asedio cuentan los cercos de 5 que ya estaban armados.
    if (!wasSiege && inSiege) {
      _checkWin();
      if (isOver) return;
    }
    if (rules.roundLimit != null && ply >= rules.roundLimit! * 2) {
      endedByLimit = true;
      draw = true;
      return;
    }
    current = opponent;
    if (cooldowns[current] > 0) cooldowns[current]--;
    paralyzedUntil.removeWhere((_, until) => until < ply);
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
    if (recordEvents) lastEvents.add(Paralyzed(current, p, h, bySeal: true));
  }

  void _checkWin() {
    // Con dos Líderes (final de la historia) alcanza con que caiga uno.
    final lost = [for (var p = 0; p < 2; p++) board.locateLeaders(p).any((h) => leaderCapturedOn(board, p, h))];
    if (lost[0] && lost[1]) {
      draw = true;
    } else if (lost[0]) {
      winner = 1;
    } else if (lost[1]) {
      winner = 0;
    }
  }
}
