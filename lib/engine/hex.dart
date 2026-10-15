/// Coordenadas axiales (q, r) para un tablero hexagonal "pointy-top".
class Hex {
  final int q;
  final int r;
  const Hex(this.q, this.r);

  static const origin = Hex(0, 0);

  /// Orden cíclico: direcciones consecutivas son vecinas entre sí.
  static const directions = [Hex(1, 0), Hex(1, -1), Hex(0, -1), Hex(-1, 0), Hex(-1, 1), Hex(0, 1)];

  Hex operator +(Hex o) => Hex(q + o.q, r + o.r);
  Hex operator -(Hex o) => Hex(q - o.q, r - o.r);
  Hex operator *(int k) => Hex(q * k, r * k);

  Hex neighbor(int dir) => this + directions[dir];
  List<Hex> get neighbors => [for (final d in directions) this + d];

  int distanceTo(Hex o) {
    final dq = q - o.q, dr = r - o.r;
    return (dq.abs() + dr.abs() + (dq + dr).abs()) ~/ 2;
  }

  /// Índice de dirección si [o] es vecino, si no -1.
  int directionTo(Hex o) => directions.indexOf(o - this);

  @override
  bool operator ==(Object other) => other is Hex && other.q == q && other.r == r;
  @override
  int get hashCode => q * 1000003 ^ r;
  @override
  String toString() => '($q,$r)';
}

/// Las dos celdas adyacentes a la vez a [a] y [b] (que deben ser vecinas).
List<Hex> commonNeighbors(Hex a, Hex b) {
  final i = a.directionTo(b);
  assert(i >= 0, 'commonNeighbors requiere celdas vecinas');
  return [a.neighbor((i + 1) % 6), a.neighbor((i + 5) % 6)];
}
