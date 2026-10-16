import 'dart:math';

import 'package:flutter/material.dart';

import '../../engine/pieces.dart';
import '../theme/hex_theme.dart';
import '../theme/settings.dart';
import 'piece_art.dart';

/// Dibuja una ficha de piedra con volumen: sombra, canto (lateral), cara con
/// gradiente y vetas, borde de facción e ilustración (o carácter). Compartido por el tablero, la
/// mano y los chips de UI para que todo se vea igual.
class PieceRenderer {
  static final _glyphCache = <String, TextPainter>{};

  /// Grosor visible del canto, relativo al radio.
  static const depthRatio = 0.16;

  static Path hexAt(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = pi / 180 * (60 * i - 30);
      final pt = c + Offset(cos(a), sin(a)) * r;
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    return path..close();
  }

  /// [c] centro de la casilla en el tablero; [z] altura en el aire (px);
  /// [scale] escala extra (squash/hover); [shadow] false para piezas apiladas debajo.
  static void draw(
    Canvas canvas, {
    required HexTheme theme,
    required PieceType type,
    required int owner,
    required Offset c,
    required double radius,
    double z = 0,
    double scale = 1,
    double opacity = 1,
    bool shadow = true,
    bool paralyzed = false,
    int seed = 0,
  }) {
    final r = radius * 0.92 * scale * (1 + z / 320);
    final depth = radius * depthRatio;
    final face = c - Offset(0, z);

    if (opacity < 1) {
      canvas.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: opacity.clamp(0, 1)));
    }

    if (shadow) {
      final lift = (1 - z / 140).clamp(0.15, 1.0);
      canvas.drawPath(
        hexAt(c + Offset(z * 0.10, depth + 2 + z * 0.12), r * (1 + z / 260)),
        Paint()
          ..color = theme.shadow.withValues(alpha: theme.shadow.a * lift)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5 + z * 0.14),
      );
    }

    // Canto: la misma forma desplazada hacia abajo, en tono del lateral.
    final side = theme.stoneSide[owner];
    canvas.drawPath(hexAt(face + Offset(0, depth), r), Paint()..color = side);
    canvas.drawPath(
      hexAt(face + Offset(0, depth * 0.5), r),
      Paint()..color = Color.lerp(side, theme.stone[owner][1], 0.35)!,
    );

    // Cara
    final facePath = hexAt(face, r);
    canvas.drawPath(
      facePath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.5),
          radius: 1.15,
          colors: theme.stone[owner],
        ).createShader(Rect.fromCircle(center: face, radius: r)),
    );

    // Vetas
    canvas.save();
    canvas.clipPath(facePath);
    final vein = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.6, r * 0.025)
      ..color = (owner == 0 ? Colors.black : Colors.white).withValues(alpha: 0.06);
    for (var i = -2; i <= 2; i++) {
      final y = face.dy + i * r * 0.38 + (seed % 5) * r * 0.06;
      canvas.drawLine(Offset(face.dx - r, y - r * 0.3), Offset(face.dx + r, y + r * 0.22), vein);
    }
    // Brillo especular en el borde superior
    canvas.drawPath(
      hexAt(face - Offset(0, r * 0.06), r * 0.9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = Colors.white.withValues(alpha: owner == 0 ? 0.35 : 0.08),
    );
    canvas.restore();

    canvas.drawPath(
      facePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, r * 0.09)
        ..color = HexTheme.faction(type.faction),
    );
    if (type.isLeader) {
      canvas.drawPath(
        hexAt(face, r * 0.8),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.0, r * 0.06)
          ..color = theme.gold,
      );
    }
    final art = AppSettings.instance.useGlyphs ? null : PieceArt.of(type);
    if (art != null) {
      // Relieve tallado: la ilustración ocupa la cara, recortada al hexágono.
      canvas.save();
      canvas.clipPath(hexAt(face, r * 0.86));
      paintImage(
        canvas: canvas,
        rect: Rect.fromCircle(center: face, radius: r * 0.8),
        image: art,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
      canvas.restore();
    } else {
      text(canvas, type.glyph, face, r * 0.9, theme.glyph[owner]);
    }

    if (paralyzed) {
      canvas.drawPath(facePath, Paint()..color = theme.frost.withValues(alpha: 0.35));
      // Copo dibujado (no depende de fuentes emoji)
      final fc = face + Offset(-r * 0.55, -r * 0.52);
      final flake = Paint()
        ..strokeWidth = max(1.2, r * 0.07)
        ..strokeCap = StrokeCap.round
        ..color = Colors.white;
      for (var k = 0; k < 3; k++) {
        final a = k * pi / 3 + pi / 2;
        final d = Offset(cos(a), sin(a)) * r * 0.2;
        canvas.drawLine(fc - d, fc + d, flake);
      }
    }
    if (opacity < 1) canvas.restore();
  }

  static void text(Canvas canvas, String s, Offset center, double fontSize, Color color) {
    final key = '$s|${fontSize.toStringAsFixed(1)}|${color.toARGB32()}';
    final tp = _glyphCache[key] ??= () {
      if (_glyphCache.length > 400) _glyphCache.clear();
      return TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.w700, height: 1),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
