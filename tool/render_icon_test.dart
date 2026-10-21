// Dibuja el ícono de la app con el arte real del juego: una tablilla ema de
// madera colgada de su cordón rojo y, encima, las fichas de mármol.
// Uso: flutter test tool/render_icon_test.dart   → store/icon/*.png
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/ui/fx/piece_art.dart';
import 'package:hexiege/ui/fx/piece_renderer.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';

const _size = 1024.0;
const _red = Color(0xFFB8322A);

Path _ema(Rect r) {
  final roof = r.width * 0.2;
  return Path()
    ..moveTo(r.center.dx, r.top)
    ..lineTo(r.right, r.top + roof)
    ..lineTo(r.right, r.bottom)
    ..lineTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + roof)
    ..close();
}

void _background(Canvas c, {required bool transparent}) {
  if (transparent) return;
  final full = Offset.zero & const Size(_size, _size);
  c.drawRect(
    full,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.2),
        radius: 0.95,
        colors: [Color(0xFF4A3526), Color(0xFF231A14)],
      ).createShader(full),
  );
}

/// La tablilla: madera con veta, canto oscuro, sombra y el cordón rojo.
void _plaque(Canvas c, Rect r) {
  final path = _ema(r);
  c.drawPath(
    path.shift(const Offset(0, 22)),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
  );
  // Canto de la madera.
  c.drawPath(path.shift(const Offset(0, 14)), Paint()..color = const Color(0xFF6B4524));
  c.save();
  c.clipPath(path);
  c.drawRect(
    r,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE2B57E), Color(0xFFC08A52), Color(0xFFA9733F)],
      ).createShader(r),
  );
  // Veta: líneas onduladas apenas más oscuras.
  final rnd = Random(4);
  for (var i = 0; i < 46; i++) {
    final x0 = r.left + r.width * i / 46 + rnd.nextDouble() * 8;
    final p = Path()..moveTo(x0, r.top);
    for (var y = r.top; y <= r.bottom; y += 16) {
      p.lineTo(x0 + 6 * sin(y / 70 + i) + 3 * sin(y / 23 + i * 2.1), y);
    }
    c.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + rnd.nextDouble() * 2.5
        ..color = const Color(0xFF7A4E26).withValues(alpha: 0.10 + rnd.nextDouble() * 0.14),
    );
  }
  // Luz cálida desde arriba a la izquierda.
  c.drawRect(
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.6),
        radius: 1.2,
        colors: [Colors.white.withValues(alpha: 0.18), Colors.black.withValues(alpha: 0.18)],
      ).createShader(r),
  );
  c.restore();
  c.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFF5E3B1E).withValues(alpha: 0.7),
  );
  // Agujero y cordón.
  final hole = Offset(r.center.dx, r.top + r.width * 0.13);
  c.drawCircle(hole, 13, Paint()..color = const Color(0xFF3A2414));
  final cord = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 11
    ..strokeCap = StrokeCap.round
    ..color = _red;
  c.drawLine(hole, Offset(r.center.dx - 34, 0), cord);
  c.drawLine(hole, Offset(r.center.dx + 34, 0), cord);
  c.drawCircle(hole + const Offset(0, -6), 15, Paint()..color = _red);
}

void _piece(Canvas c, PieceType type, int tone, Offset at, double r, ui.Image? art) {
  final theme = HexTheme.light;
  final depth = r * 0.2;
  c.drawPath(
    PieceRenderer.hexAt(at + Offset(r * 0.06, depth + r * 0.1), r),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.1),
  );
  final side = theme.stoneSideOf(tone);
  c.drawPath(PieceRenderer.hexAt(at + Offset(0, depth), r), Paint()..color = side);
  c.drawPath(
    PieceRenderer.hexAt(at + Offset(0, depth * 0.5), r),
    Paint()..color = Color.lerp(side, theme.stoneOf(tone)[1], 0.35)!,
  );
  PieceRenderer.drawFace(c, theme: theme, type: type, tone: tone, face: at, r: r, seed: 3, art: art, featured: true);
}

Future<void> _save(ui.Picture pic, String name, {int size = 1024}) async {
  final img = await pic.toImage(size, size);
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  File('store/icon/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  testWidgets('ícono', (tester) async {
    await tester.runAsync(() async {
      await PieceArt.load();
      final monk = await PieceArt.full(PieceType.monk);
      final shogun = await PieceArt.full(PieceType.shogun);

      for (final (name, transparent) in [('app_icon', false), ('app_icon_fg', true)]) {
        final rec = ui.PictureRecorder();
        final c = Canvas(rec);
        _background(c, transparent: transparent);
        // El primer plano adaptativo de Android va al 72 %: se escala al centro.
        if (transparent) {
          c.translate(_size / 2, _size / 2);
          c.scale(0.72);
          c.translate(-_size / 2, -_size / 2);
        }
        final plaque = Rect.fromCenter(center: const Offset(_size / 2, _size * 0.54), width: 760, height: 800);
        _plaque(c, plaque);
        _piece(c, PieceType.shogun, 1, plaque.center + const Offset(150, -40), 178, shogun);
        _piece(c, PieceType.monk, 0, plaque.center + const Offset(-120, 90), 210, monk);
        await _save(rec.endRecording(), name);
      }
    });
  });
}
