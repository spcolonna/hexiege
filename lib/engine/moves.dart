import 'dart:math';

import 'board.dart';
import 'hex.dart';
import 'pieces.dart';

/// Paso deslizante en el suelo. [b] debe tener la ficha que se mueve ya levantada.
/// - Libertad de movimiento: no puede pasar entre dos fichas (salvo [ignoreGate]).
/// - Contacto: debe seguir tocando la colmena durante el paso.
bool canSlide(Board b, Hex from, Hex to, {bool ignoreGate = false}) {
  if (b.isOccupied(to)) return false;
  final cn = commonNeighbors(from, to);
  final o1 = b.isOccupied(cn[0]), o2 = b.isOccupied(cn[1]);
  if (!ignoreGate && o1 && o2) return false;
  return o1 || o2;
}

/// Destinos alcanzables deslizándose entre 1 y [maxSteps] pasos sin repetir celdas
/// ([maxSteps] null = ilimitado).
Set<Hex> slideReach(Board b, Hex src, {int? maxSteps, bool ignoreGate = false}) {
  final result = <Hex>{};
  if (maxSteps == null) {
    final seen = <Hex>{src};
    final queue = [src];
    while (queue.isNotEmpty) {
      final c = queue.removeLast();
      for (final n in c.neighbors) {
        if (!seen.contains(n) && canSlide(b, c, n, ignoreGate: ignoreGate)) {
          seen.add(n);
          result.add(n);
          queue.add(n);
        }
      }
    }
    return result;
  }
  void dfs(Hex c, Set<Hex> path, int depth) {
    if (depth == maxSteps) return;
    for (final n in c.neighbors) {
      if (path.contains(n) || !canSlide(b, c, n, ignoreGate: ignoreGate)) continue;
      result.add(n);
      dfs(n, {...path, n}, depth + 1);
    }
  }

  dfs(src, {src}, 0);
  return result;
}

/// Paso de 1 casilla que permite subir/bajar de pilas (Rey Mono).
Set<Hex> climbSteps(Board b, Hex src) {
  final srcH = b.height(src); // altura que queda debajo, ya levantada la ficha
  final result = <Hex>{};
  for (final n in src.neighbors) {
    final dstH = b.height(n);
    final cn = commonNeighbors(src, n);
    final h1 = b.height(cn[0]), h2 = b.height(cn[1]);
    if (min(h1, h2) > max(srcH, dstH)) continue; // compuerta
    if (srcH == 0 && dstH == 0 && h1 == 0 && h2 == 0) continue; // perdería contacto
    result.add(n);
  }
  return result;
}

/// Salta en línea recta sobre >=1 fichas contiguas ([exactly] = cantidad exacta a saltar).
Set<Hex> jumps(Board b, Hex src, {int? exactly}) {
  final result = <Hex>{};
  for (final d in Hex.directions) {
    var c = src + d;
    var count = 0;
    while (b.isOccupied(c)) {
      c = c + d;
      count++;
    }
    if (count == 0) continue;
    if (exactly != null && count != exactly) continue;
    result.add(c);
  }
  return result;
}

/// Embestida: 1..[maxSteps] casillas en línea recta, deslizando paso a paso.
Set<Hex> charges(Board b, Hex src, {int maxSteps = 3}) {
  final result = <Hex>{};
  for (final d in Hex.directions) {
    var c = src;
    for (var k = 0; k < maxSteps; k++) {
      final n = c + d;
      if (!canSlide(b, c, n)) break;
      result.add(n);
      c = n;
    }
  }
  return result;
}

/// Teletransporte: cualquier hueco que toque al menos 2 fichas.
Set<Hex> teleports(Board b, Hex src) {
  final candidates = <Hex>{};
  for (final h in b.occupied) {
    for (final n in h.neighbors) {
      if (!b.isOccupied(n) && n != src && b.occupiedNeighbors(n) >= 2) candidates.add(n);
    }
  }
  return candidates;
}

/// Destinos de movimiento normal de una ficha de tipo [type] en [src].
/// [b] ya tiene la ficha levantada. No incluye efectos ni el intercambio del Shogun.
Set<Hex> destinationsFor(PieceType type, Board b, Hex src) {
  final Set<Hex> dests = switch (type) {
    PieceType.monk || PieceType.shogun => slideReach(b, src, maxSteps: 1),
    PieceType.dragon => jumps(b, src),
    PieceType.wukong => _wukong(b, src),
    PieceType.tiger => charges(b, src),
    PieceType.crane => jumps(b, src, exactly: 2),
    PieceType.serpent || PieceType.kunoichi || PieceType.kitsune => slideReach(b, src, maxSteps: 2),
    PieceType.shinobi => slideReach(b, src, ignoreGate: true),
    PieceType.tengu => teleports(b, src),
    PieceType.shadow => slideReach(b, src, maxSteps: 1),
  };
  dests.remove(src);
  return dests;
}

Set<Hex> _wukong(Board b, Hex src) {
  final result = climbSteps(b, src);
  if (b.height(src) == 0) {
    // En el suelo: puede copiar el patrón de una ficha adyacente.
    final copied = <PieceType>{};
    for (final n in src.neighbors) {
      final t = b.top(n)?.type;
      if (t != null && t != PieceType.wukong) copied.add(t);
    }
    for (final t in copied) {
      result.addAll(destinationsFor(t, b, src));
    }
  }
  return result;
}
