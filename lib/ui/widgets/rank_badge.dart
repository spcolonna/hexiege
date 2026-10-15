import 'dart:math';

import 'package:flutter/material.dart';

import '../../match/ladder.dart';

extension RankStyle on Rank {
  Color get color => switch (this) {
    Rank.novice => const Color(0xFFB07A4A),
    Rank.disciple => const Color(0xFF9AA7B4),
    Rank.warrior => const Color(0xFFE0A93B),
    Rank.veteran => const Color(0xFF3FA58C),
    Rank.legend => const Color(0xFFC0446A),
  };

  /// Color para texto: más oscuro en tema claro, para que se lea.
  Color textOn(bool dark) => dark ? color : Color.lerp(color, Colors.black, 0.35)!;

  /// Glifo del emblema.
  String get glyph => switch (this) {
    Rank.novice => '初',
    Rank.disciple => '徒',
    Rank.warrior => '武',
    Rank.veteran => '師',
    Rank.legend => '王',
  };
}

/// Emblema hexagonal del rango.
class RankBadge extends StatelessWidget {
  final Rank rank;
  final double size;
  const RankBadge({super.key, required this.rank, this.size = 44});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _HexBadgePainter(rank.color),
      child: Center(
        child: Text(
          rank.glyph,
          style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
        ),
      ),
    ),
  );
}

class _HexBadgePainter extends CustomPainter {
  final Color color;
  _HexBadgePainter(this.color);

  Path _hex(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = pi / 3 * i - pi / 2;
      final v = c + Offset(cos(a), sin(a)) * r;
      i == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawPath(
      _hex(c + Offset(0, r * 0.06), r),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
    canvas.drawPath(_hex(c, r), Paint()..color = Color.lerp(color, Colors.black, 0.3)!);
    canvas.drawPath(
      _hex(c, r * 0.84),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [Color.lerp(color, Colors.white, 0.3)!, color],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_HexBadgePainter old) => old.color != color;
}
