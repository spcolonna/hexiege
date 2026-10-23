// Muestrario de fichas para revisar cómo se ven la piedra, el canto y el borde.
// Uso: flutter test tool/render_pieces_test.dart   → build/pieces_preview.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/ui/fx/piece_art.dart';
import 'package:hexiege/ui/fx/piece_renderer.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';

void main() {
  testWidgets('muestrario', (tester) async {
    await tester.runAsync(() async {
      await PieceArt.load();
      const types = [PieceType.monk, PieceType.dragon, PieceType.shogun, PieceType.kitsune, PieceType.oni, PieceType.gaki, PieceType.oniEye];
      const w = 1700.0, h = 520.0;
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      c.drawRect(const Offset(0, 0) & const Size(w, h), Paint()..color = const Color(0xFF2A221C));
      for (var i = 0; i < types.length; i++) {
        final t = types[i];
        // Arriba en tamaño de tablero; abajo, grande como en el visor.
        PieceRenderer.draw(c, theme: HexTheme.light, type: t, owner: i < 2 ? 0 : 1, c: Offset(120 + i * 240.0, 90), radius: 44, seed: i, ash: t.faction == Faction.oni);
        PieceRenderer.draw(c, theme: HexTheme.light, type: t, owner: i < 2 ? 0 : 1, c: Offset(120 + i * 240.0, 320), radius: 105, seed: i, ash: t.faction == Faction.oni);
      }
      final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      File('build/pieces_preview.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  });
}
