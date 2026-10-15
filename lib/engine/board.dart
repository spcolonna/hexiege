import 'hex.dart';
import 'pieces.dart';

/// Tablero sin límites: cada celda ocupada guarda una pila (la última es la de arriba).
class Board {
  final Map<Hex, List<Piece>> _stacks;

  Board() : _stacks = {};
  Board.copy(Board o) : _stacks = {for (final e in o._stacks.entries) e.key: List.of(e.value)};

  Iterable<Hex> get occupied => _stacks.keys;
  bool get isEmpty => _stacks.isEmpty;
  bool isOccupied(Hex h) => _stacks.containsKey(h);
  int height(Hex h) => _stacks[h]?.length ?? 0;
  Piece? top(Hex h) => _stacks[h]?.last;
  List<Piece> stackAt(Hex h) => List.unmodifiable(_stacks[h] ?? const []);

  void push(Hex h, Piece p) => (_stacks[h] ??= []).add(p);

  Piece pop(Hex h) {
    final s = _stacks[h]!;
    final p = s.removeLast();
    if (s.isEmpty) _stacks.remove(h);
    return p;
  }

  Hex? find(int pieceId) {
    for (final e in _stacks.entries) {
      if (e.value.any((p) => p.id == pieceId)) return e.key;
    }
    return null;
  }

  Hex? locateLeader(int owner) {
    for (final e in _stacks.entries) {
      if (e.value.any((p) => p.owner == owner && p.type.isLeader)) return e.key;
    }
    return null;
  }

  Iterable<MapEntry<Hex, Piece>> get tops => _stacks.entries.map((e) => MapEntry(e.key, e.value.last));

  int occupiedNeighbors(Hex h) => h.neighbors.where(isOccupied).length;

  bool isSurrounded(Hex h) => h.neighbors.every(isOccupied);

  /// One-Hive: ¿siguen conectadas todas las celdas si se vacía [without]?
  bool isConnected({Hex? without}) {
    final cells = _stacks.keys.where((h) => h != without || height(h) > 1).toSet();
    return isSetConnected(cells);
  }

  /// La ficha de arriba de [h] puede levantarse sin romper la colmena.
  bool canLift(Hex h) => height(h) > 1 || isConnected(without: h);
}

bool isSetConnected(Set<Hex> cells) {
  if (cells.length <= 1) return true;
  final seen = <Hex>{cells.first};
  final queue = [cells.first];
  while (queue.isNotEmpty) {
    final c = queue.removeLast();
    for (final n in c.neighbors) {
      if (cells.contains(n) && seen.add(n)) queue.add(n);
    }
  }
  return seen.length == cells.length;
}
