import 'package:flutter/material.dart';

import '../../engine/pieces.dart';

/// Tokens visuales de Hexiege. Es un [ThemeExtension]: Flutter interpola (`lerp`)
/// entre claro y oscuro, así que el cambio en plena partida es un fundido suave.
///
/// Pensado para cosméticos: una "arena" o skin futura es otra instancia de esta
/// clase (fondo, materiales de fichas, tablero) sin tocar el resto de la UI.
@immutable
class HexTheme extends ThemeExtension<HexTheme> {
  final Brightness brightness;

  // Arena (fondo)
  final Color backdropTop;
  final Color backdropBottom;
  final Color backdropGlow; // luz central bajo el tablero
  final Color backdropPattern; // patrón de hexágonos grandes

  // Superficies de UI
  final Color surface;
  final Color surfaceHigh;
  final Color outline;
  final Color text;
  final Color textMuted;

  // Tablero
  final Color grid;
  final Color shadow;
  final Color lastMove;

  // Fichas: material por jugador (cara superior clara→oscura, lateral, glifo)
  final List<List<Color>> stone;
  final List<Color> stoneSide;
  final List<Color> glyph;

  // Acentos
  final Color gold;
  final Color highlight;
  final Color danger;
  final Color frost;

  const HexTheme({
    required this.brightness,
    required this.backdropTop,
    required this.backdropBottom,
    required this.backdropGlow,
    required this.backdropPattern,
    required this.surface,
    required this.surfaceHigh,
    required this.outline,
    required this.text,
    required this.textMuted,
    required this.grid,
    required this.shadow,
    required this.lastMove,
    required this.stone,
    required this.stoneSide,
    required this.glyph,
    required this.gold,
    required this.highlight,
    required this.danger,
    required this.frost,
  });

  /// Noche de tinta: madera oscura y lámparas cálidas.
  static const dark = HexTheme(
    brightness: Brightness.dark,
    backdropTop: Color(0xFF1E1B17),
    backdropBottom: Color(0xFF0F0E0C),
    backdropGlow: Color(0x33E8C77A),
    backdropPattern: Color(0x09FFFFFF),
    surface: Color(0xE6221F1B),
    surfaceHigh: Color(0xFF2E2A24),
    outline: Color(0x1FFFFFFF),
    text: Color(0xFFF2ECDF),
    textMuted: Color(0x99F2ECDF),
    grid: Color(0x1CFFFFFF),
    shadow: Color(0xB3000000),
    lastMove: Color(0x26E3BE5A),
    stone: [
      [Color(0xFFFBF8F0), Color(0xFFD5E0CF)],
      [Color(0xFF4A4A56), Color(0xFF17171D)],
    ],
    stoneSide: [Color(0xFF9AA897), Color(0xFF09090C)],
    glyph: [Color(0xFF1D3B2A), Color(0xFFF0E8D6)],
    gold: Color(0xFFE3BE5A),
    highlight: Color(0xFF7FE0B0),
    danger: Color(0xFFF07A84),
    frost: Color(0xFF8CC8FF),
  );

  /// Papel de arroz y tinta: claro y cálido.
  static const light = HexTheme(
    brightness: Brightness.light,
    backdropTop: Color(0xFFF6F0E3),
    backdropBottom: Color(0xFFE2D6BE),
    backdropGlow: Color(0x66FFFFFF),
    backdropPattern: Color(0x0C5B4630),
    surface: Color(0xEEFFFBF2),
    surfaceHigh: Color(0xFFFFFFFF),
    outline: Color(0x22332A1E),
    text: Color(0xFF2A241B),
    textMuted: Color(0x992A241B),
    grid: Color(0x1F4A3A26),
    shadow: Color(0x66402C10),
    lastMove: Color(0x33B8862B),
    stone: [
      [Color(0xFFFFFFFF), Color(0xFFDCE6D6)],
      [Color(0xFF50505C), Color(0xFF1B1B22)],
    ],
    stoneSide: [Color(0xFFA9B5A4), Color(0xFF0B0B0F)],
    glyph: [Color(0xFF1D3B2A), Color(0xFFF0E8D6)],
    gold: Color(0xFFB8862B),
    highlight: Color(0xFF1F9E68),
    danger: Color(0xFFD0414F),
    frost: Color(0xFF3A8FE0),
  );

  static HexTheme of(BuildContext context) => Theme.of(context).extension<HexTheme>()!;

  bool get isDark => brightness == Brightness.dark;

  /// Colores de facción (constantes entre temas: son identidad, no ambiente).
  static Color faction(Faction f) => switch (f) {
    Faction.shaolin => const Color(0xFF2F9E6E),
    Faction.ninja => const Color(0xFFC0404F),
  };

  @override
  HexTheme copyWith() => this;

  @override
  HexTheme lerp(HexTheme? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    List<Color> l(List<Color> a, List<Color> b) => [for (var i = 0; i < a.length; i++) c(a[i], b[i])];
    return HexTheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      backdropTop: c(backdropTop, other.backdropTop),
      backdropBottom: c(backdropBottom, other.backdropBottom),
      backdropGlow: c(backdropGlow, other.backdropGlow),
      backdropPattern: c(backdropPattern, other.backdropPattern),
      surface: c(surface, other.surface),
      surfaceHigh: c(surfaceHigh, other.surfaceHigh),
      outline: c(outline, other.outline),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      grid: c(grid, other.grid),
      shadow: c(shadow, other.shadow),
      lastMove: c(lastMove, other.lastMove),
      stone: [l(stone[0], other.stone[0]), l(stone[1], other.stone[1])],
      stoneSide: l(stoneSide, other.stoneSide),
      glyph: l(glyph, other.glyph),
      gold: c(gold, other.gold),
      highlight: c(highlight, other.highlight),
      danger: c(danger, other.danger),
      frost: c(frost, other.frost),
    );
  }

  ThemeData toThemeData() {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: brightness,
      primary: gold,
      onPrimary: isDark ? Colors.black : Colors.white,
      surface: surfaceHigh,
      onSurface: text,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: backdropBottom,
      extensions: [this],
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surfaceHigh, showDragHandle: true),
      dialogTheme: DialogThemeData(backgroundColor: surfaceHigh),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: outline))),
      ),
    );
  }
}
