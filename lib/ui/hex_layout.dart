import 'dart:math';
import 'dart:ui';

import '../engine/hex.dart';

/// Conversión hex <-> píxel para hexágonos "pointy-top".
class HexLayout {
  final double size;
  final Offset center;
  const HexLayout(this.size, this.center);

  static final _sqrt3 = sqrt(3);

  Offset toPixel(Hex h) => center + Offset(size * _sqrt3 * (h.q + h.r / 2), size * 1.5 * h.r);

  Hex fromPixel(Offset p) {
    final pt = p - center;
    final q = (_sqrt3 / 3 * pt.dx - 1 / 3 * pt.dy) / size;
    final r = (2 / 3 * pt.dy) / size;
    return _round(q, r);
  }

  Path hexPath(Hex h, {double scale = 1}) {
    final c = toPixel(h);
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = pi / 180 * (60 * i - 30);
      final pt = c + Offset(cos(a), sin(a)) * size * scale;
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  static Hex _round(double q, double r) {
    final s = -q - r;
    var rq = q.roundToDouble(), rr = r.roundToDouble(), rs = s.roundToDouble();
    final dq = (rq - q).abs(), dr = (rr - r).abs(), ds = (rs - s).abs();
    if (dq > dr && dq > ds) {
      rq = -rr - rs;
    } else if (dr > ds) {
      rr = -rq - rs;
    }
    return Hex(rq.toInt(), rr.toInt());
  }
}
