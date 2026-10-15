import 'dart:math';

import 'package:flutter/material.dart';

import '../fx/piece_renderer.dart';
import '../theme/hex_theme.dart';

/// Fondo de la arena: degradado, patrón de hexágonos grandes y luz central.
/// Punto de extensión para cosméticos (fondos desbloqueables) vía [HexTheme].
class ArenaBackdrop extends StatelessWidget {
  final Widget child;

  /// Color de acento (facción del turno) que tiñe levemente la luz.
  final Color? accent;
  const ArenaBackdrop({super.key, required this.child, this.accent});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.backdropTop, t.backdropBottom],
        ),
      ),
      child: CustomPaint(painter: _ArenaPainter(t, accent), child: child),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  final HexTheme t;
  final Color? accent;
  _ArenaPainter(this.t, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final glow = accent == null
        ? t.backdropGlow
        : Color.lerp(t.backdropGlow, accent!.withValues(alpha: t.backdropGlow.a), 0.25)!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 0.75,
          colors: [glow, glow.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: size.longestSide * 0.6)),
    );
    // Patrón de hexágonos grandes, muy tenue
    final r = size.width / 1.8; // mucho más grande que una casilla: no compite con la grilla
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = t.backdropPattern;
    final w = sqrt(3) * r, h = 1.5 * r;
    for (var row = -1; row * h < size.height + r; row++) {
      for (var col = -1; col * w < size.width + w; col++) {
        final c = Offset(col * w + (row.isOdd ? w / 2 : 0), row * h);
        canvas.drawPath(PieceRenderer.hexAt(c, r * 0.97), paint);
      }
    }
    // Viñeta
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: t.isDark ? 0.45 : 0.10),
          ],
          stops: const [0.55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: size.longestSide * 0.75)),
    );
  }

  @override
  bool shouldRepaint(covariant _ArenaPainter o) => o.t != t || o.accent != accent;
}
