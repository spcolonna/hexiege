import 'package:flutter/material.dart';

import '../engine/pieces.dart';
import 'fx/piece_renderer.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';

/// Ficha individual (mano, reglas, menú) con el mismo render que el tablero.
class PieceChip extends StatelessWidget {
  final PieceType type;
  final int owner;
  final double size;

  /// Altura "en el aire" relativa al tamaño (0 = apoyada).
  final double lift;
  const PieceChip({super.key, required this.type, required this.owner, this.size = 20, this.lift = 0});

  @override
  Widget build(BuildContext context) {
    final w = size * 2.0;
    // Escucha los ajustes: cambiar entre ilustraciones y caracteres la repinta.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => CustomPaint(
        size: Size(w, w + size * 0.3),
        painter: _ChipPainter(type, owner, size, lift, HexTheme.of(context), AppSettings.instance.useGlyphs),
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  final PieceType type;
  final int owner;
  final double size, lift;
  final HexTheme theme;
  final bool glyphs;
  _ChipPainter(this.type, this.owner, this.size, this.lift, this.theme, this.glyphs);

  @override
  void paint(Canvas canvas, Size s) {
    PieceRenderer.draw(
      canvas,
      theme: theme,
      type: type,
      owner: owner,
      c: Offset(s.width / 2, s.height / 2 - size * 0.1),
      radius: size,
      z: lift * size,
    );
  }

  @override
  bool shouldRepaint(covariant _ChipPainter o) =>
      o.type != type || o.owner != owner || o.size != size || o.lift != lift || o.theme != theme || o.glyphs != glyphs;
}
