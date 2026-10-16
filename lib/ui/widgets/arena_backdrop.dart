import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/hex_theme.dart';

/// Fondo: la mesa de la facción (tablas de madera o laca), con la luz de la
/// lámpara en el centro y viñeta. Punto de extensión para cosméticos vía [HexTheme].
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
    switch (t.table) {
      case TableMaterial.planks:
        _planks(canvas, size);
      case TableMaterial.lacquer:
        _lacquer(canvas, size);
    }
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
    // Viñeta
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: t.isDark ? 0.5 : 0.16),
          ],
          stops: const [0.5, 1],
        ).createShader(Rect.fromCircle(center: center, radius: size.longestSide * 0.75)),
    );
  }

  /// Tablas horizontales con tono propio, juntas y veta ondulada.
  void _planks(Canvas canvas, Size size) {
    final rng = Random(7);
    final h = max(64.0, size.width / 4.2);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = t.tableGrain;
    for (var i = 0; i * h < size.height; i++) {
      final top = i * h;
      final rect = Rect.fromLTWH(0, top, size.width, h);
      // Cada tabla un poco más clara u oscura.
      final shade = (rng.nextDouble() - 0.5) * (t.isDark ? 0.10 : 0.07);
      canvas.drawRect(rect, Paint()..color = (shade > 0 ? Colors.white : Colors.black).withValues(alpha: shade.abs()));
      // Veta: líneas onduladas que siguen la tabla.
      for (var k = 0; k < 7; k++) {
        final y0 = top + h * (0.1 + 0.8 * rng.nextDouble());
        final amp = h * (0.03 + 0.06 * rng.nextDouble());
        final freq = 2 * pi / (size.width * (0.5 + rng.nextDouble()));
        final phase = rng.nextDouble() * 2 * pi;
        final path = Path()..moveTo(0, y0);
        for (var x = 0.0; x <= size.width; x += 8) {
          path.lineTo(x, y0 + amp * sin(x * freq + phase) + amp * 0.4 * sin(x * freq * 3.1 + phase));
        }
        grain.strokeWidth = 0.6 + rng.nextDouble() * 1.4;
        canvas.drawPath(path, grain);
      }
      // Nudo ocasional.
      if (rng.nextDouble() < 0.35) {
        final c = Offset(size.width * rng.nextDouble(), top + h * (0.3 + 0.4 * rng.nextDouble()));
        for (var r = 1; r <= 3; r++) {
          canvas.drawOval(Rect.fromCenter(center: c, width: 26.0 * r, height: 8.0 * r), grain..strokeWidth = 1);
        }
      }
      // Junta entre tablas: sombra y filo de luz.
      canvas.drawLine(
        Offset(0, top),
        Offset(size.width, top),
        Paint()
          ..strokeWidth = 1.5
          ..color = Colors.black.withValues(alpha: t.isDark ? 0.45 : 0.16),
      );
      canvas.drawLine(
        Offset(0, top + 1.5),
        Offset(size.width, top + 1.5),
        Paint()
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: t.isDark ? 0.04 : 0.25),
      );
    }
  }

  /// Laca: reflejo diagonal amplio y polvo de oro (maki-e) hacia una esquina.
  void _lacquer(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, 1),
          colors: [Colors.transparent, t.tableGrain, Colors.transparent],
          stops: const [0.25, 0.42, 0.6],
        ).createShader(rect),
    );
    final rng = Random(11);
    final dust = Paint()..color = t.gold.withValues(alpha: 0.35);
    for (var i = 0; i < 140; i++) {
      // Más densidad abajo a la derecha, como polvo que se desliza.
      final x = size.width * (1 - pow(rng.nextDouble(), 2.2));
      final y = size.height * (1 - pow(rng.nextDouble(), 1.6));
      canvas.drawCircle(Offset(x, y), 0.4 + rng.nextDouble() * 1.3, dust);
    }
  }

  @override
  bool shouldRepaint(covariant _ArenaPainter o) => o.t != t || o.accent != accent;
}
