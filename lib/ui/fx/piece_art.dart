import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../../engine/pieces.dart';

/// Ilustraciones de las fichas (`assets/pieces/<facción>_<tipo>.webp`). Las que
/// falten se dibujan con su carácter, así el juego funciona sin el arte.
class PieceArt {
  static final _images = <PieceType, ui.Image>{};
  static final _stones = <Faction, ui.Image>{};

  static String assetPath(PieceType t) => 'assets/pieces/${t.faction.name}_${t.name}.webp';

  static ui.Image? of(PieceType t) => _images[t];

  /// Textura de la piedra de las fichas de [f] (`assets/textures/<facción>_stone.webp`).
  static ui.Image? stone(Faction f) => _stones[f];

  static final _full = <String, Future<ui.Image?>>{};

  /// La ilustración a resolución completa, para verla de cerca (se carga una vez).
  static Future<ui.Image?> full(PieceType t) => _decode(assetPath(t));

  /// El emblema de la facción (`assets/emblems/<facción>_emblem.webp`).
  static Future<ui.Image?> emblem(Faction f) => _decode('assets/emblems/${f.name}_emblem.webp');

  static Future<ui.Image?> _decode(String path) => _full[path] ??= () async {
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    } catch (_) {
      return null;
    }
  }();

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
      for (final f in Faction.values) {
        final path = 'assets/textures/${f.name}_stone.webp';
        if (!available.contains(path)) continue;
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        _stones[f] = (await codec.getNextFrame()).image;
      }
    } catch (_) {
      // Sin arte: se usan los caracteres y la piedra pintada.
    }
  }
}
