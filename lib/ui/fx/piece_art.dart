import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../../engine/pieces.dart';

/// Ilustraciones de las fichas (`assets/pieces/<facción>_<tipo>.webp`). Las que
/// falten se dibujan con su carácter, así el juego funciona sin el arte.
class PieceArt {
  static final _images = <PieceType, ui.Image>{};

  static String assetPath(PieceType t) => 'assets/pieces/${t.faction.name}_${t.name}.webp';

  static ui.Image? of(PieceType t) => _images[t];

  /// Carga las que existan. Se llama una vez al arrancar.
  static Future<void> load() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final available = manifest.listAssets().toSet();
      for (final t in PieceType.values) {
        final path = assetPath(t);
        if (!available.contains(path)) continue;
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 256);
        _images[t] = (await codec.getNextFrame()).image;
      }
    } catch (_) {
      // Sin arte: se usan los caracteres.
    }
  }
}
