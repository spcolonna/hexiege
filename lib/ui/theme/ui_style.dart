import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';

/// Estilo de la interfaz fuera del tablero. Es un cosmético: cambia tipografía,
/// forma de paneles, botones y popups, y el armado del menú. Los colores siguen
/// siendo los de la facción ([HexTheme]).
enum UiStyle {
  /// Interior de la caja del juego: bandejas talladas y huecos hexagonales.
  box,

  /// Tablillas votivas (ema) y papel washi, con pincel y sello rojo.
  ema,

  /// Panal: el menú es un pequeño tablero de casillas hexagonales.
  comb;

  String get displayName => tr('uiStyle.$name');
  String get blurb => tr('uiStyle.$name.blurb');
}

/// Qué estilos tiene el jugador. Hoy todos están abiertos para probarlos; el
/// día que sean de pago alcanza con poner [allFree] en false y sumar las
/// compras a [owned].
class StyleUnlocks {
  static const allFree = true;

  /// El estilo que viene con el juego.
  static const base = UiStyle.box;

  static bool isUnlocked(UiStyle s, Set<String> owned) => allFree || s == base || owned.contains(s.name);
}

/// Tokens del estilo activo. Viaja en el [ThemeData] como extensión para que
/// cualquier widget lo lea con [Skin.of] y se reconstruya al cambiarlo.
@immutable
class Skin extends ThemeExtension<Skin> {
  final UiStyle style;

  /// Títulos, logo y números grandes.
  final String displayFont;
  final FontWeight displayWeight;
  final double displayTracking;

  /// Texto de interfaz (botones, listas, cuerpo).
  final String uiFont;

  /// Kanji de los sellos e insignias.
  final String glyphFont;

  const Skin._({
    required this.style,
    required this.displayFont,
    required this.displayWeight,
    required this.displayTracking,
    required this.uiFont,
    required this.glyphFont,
  });

  static const box = Skin._(
    style: UiStyle.box,
    displayFont: 'ShipporiMincho',
    displayWeight: FontWeight.w800,
    displayTracking: 0.2,
    uiFont: 'ZenKakuGothic',
    glyphFont: 'ZenOldMincho',
  );

  static const ema = Skin._(
    style: UiStyle.ema,
    displayFont: 'YujiSyuku',
    displayWeight: FontWeight.w400,
    displayTracking: -1.5,
    uiFont: 'ZenOldMincho',
    glyphFont: 'YujiSyuku',
  );

  static const comb = Skin._(
    style: UiStyle.comb,
    displayFont: 'KaiseiTokumin',
    displayWeight: FontWeight.w800,
    displayTracking: 0,
    uiFont: 'ZenMaruGothic',
    glyphFont: 'ZenOldMincho',
  );

  static Skin forStyle(UiStyle s) => switch (s) {
    UiStyle.box => box,
    UiStyle.ema => ema,
    UiStyle.comb => comb,
  };

  static Skin of(BuildContext context) => Theme.of(context).extension<Skin>() ?? box;

  /// Estilo de título en el tamaño [size].
  TextStyle display(double size, {Color? color, double? height}) => TextStyle(
    fontFamily: displayFont,
    fontWeight: displayWeight,
    fontSize: size,
    letterSpacing: displayTracking * size / 20,
    color: color,
    height: height ?? 1.1,
  );

  /// Kanji de sellos e insignias.
  TextStyle glyph(double size, {Color? color}) => TextStyle(
    fontFamily: glyphFont,
    fontWeight: style == UiStyle.ema ? FontWeight.w400 : FontWeight.w700,
    fontSize: size,
    color: color,
    height: 1,
  );

  @override
  Skin copyWith() => this;

  @override
  Skin lerp(Skin? other, double t) => other == null || t < 0.5 ? this : other;
}
