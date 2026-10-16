import 'package:flutter/material.dart';

import '../../engine/pieces.dart';
import 'ui_style.dart';

/// Material de la mesa sobre la que se juega.
enum TableMaterial { planks, lacquer }

/// Tokens visuales de Hexiege. Es un [ThemeExtension]: Flutter interpola (`lerp`)
/// entre temas, así que cambiar de facción o de luz es un fundido suave.
///
/// Cada facción tiene su mesa (claro y oscuro son la luz sobre esa misma mesa):
/// Shaolin juega sobre madera de templo con jade y oro; Ninja sobre cedro
/// gastado o laca negra, con bermellón y latón.
@immutable
class HexTheme extends ThemeExtension<HexTheme> {
  final Brightness brightness;
  final TableMaterial table;

  /// Veta de la madera o reflejo de la laca.
  final Color tableGrain;

  /// Color propio de la facción para botones principales y detalles.
  final Color accent;

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
    required this.table,
    required this.tableGrain,
    required this.accent,
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

  static const _shaolinStone = [
    [Color(0xFFFBF8F0), Color(0xFFD5E0CF)],
    [Color(0xFF4A4A56), Color(0xFF17171D)],
  ];

  /// Shaolin, de día: tablas de hinoki claro, papel de arroz, jade y oro.
  static const shaolinLight = HexTheme(
    brightness: Brightness.light,
    table: TableMaterial.planks,
    tableGrain: Color(0x1F7A4E1E),
    accent: Color(0xFF23885C),
    backdropTop: Color(0xFFEAD9B8),
    backdropBottom: Color(0xFFD3B98C),
    backdropGlow: Color(0x55FFF6DE),
    backdropPattern: Color(0x0C5B4630),
    surface: Color(0xF2FBF5E6),
    surfaceHigh: Color(0xFFFFFBF0),
    outline: Color(0x334A3A20),
    text: Color(0xFF2A241B),
    textMuted: Color(0x992A241B),
    grid: Color(0x245A4026),
    shadow: Color(0x73402C10),
    lastMove: Color(0x33B8862B),
    stone: [
      [Color(0xFFFFFFFF), Color(0xFFDCE6D6)],
      [Color(0xFF50505C), Color(0xFF1B1B22)],
    ],
    stoneSide: [Color(0xFFA9B5A4), Color(0xFF0B0B0F)],
    glyph: [Color(0xFF1D3B2A), Color(0xFFF0E8D6)],
    gold: Color(0xFFA87A22),
    highlight: Color(0xFF1F9E68),
    danger: Color(0xFFD0414F),
    frost: Color(0xFF3A8FE0),
  );

  /// Shaolin, de noche: teca oscura bajo lámparas, jade y oro.
  static const shaolinDark = HexTheme(
    brightness: Brightness.dark,
    table: TableMaterial.planks,
    tableGrain: Color(0x2A000000),
    accent: Color(0xFF3DB585),
    backdropTop: Color(0xFF3B2A1B),
    backdropBottom: Color(0xFF1C130C),
    backdropGlow: Color(0x40F0C070),
    backdropPattern: Color(0x09FFFFFF),
    surface: Color(0xEB2A2018),
    surfaceHigh: Color(0xFF33271D),
    outline: Color(0x26F3E2BF),
    text: Color(0xFFF3E9D6),
    textMuted: Color(0x99F3E9D6),
    grid: Color(0x1FFFE9C0),
    shadow: Color(0xB3000000),
    lastMove: Color(0x26E3BE5A),
    stone: _shaolinStone,
    stoneSide: [Color(0xFF9AA897), Color(0xFF09090C)],
    glyph: [Color(0xFF1D3B2A), Color(0xFFF0E8D6)],
    gold: Color(0xFFE3BE5A),
    highlight: Color(0xFF7FE0B0),
    danger: Color(0xFFF07A84),
    frost: Color(0xFF8CC8FF),
  );

  /// Ninja, de día: cedro gastado color ceniza, bermellón y latón.
  static const ninjaLight = HexTheme(
    brightness: Brightness.light,
    table: TableMaterial.planks,
    tableGrain: Color(0x1C2A1E1A),
    accent: Color(0xFFB8323F),
    backdropTop: Color(0xFFD8D0C5),
    backdropBottom: Color(0xFFB0A596),
    backdropGlow: Color(0x44FFF4EE),
    backdropPattern: Color(0x0C3A2A2A),
    surface: Color(0xF2F5F0EA),
    surfaceHigh: Color(0xFFFBF8F4),
    outline: Color(0x33302422),
    text: Color(0xFF1F1A19),
    textMuted: Color(0x991F1A19),
    grid: Color(0x24302420),
    shadow: Color(0x73281A14),
    lastMove: Color(0x33B8323F),
    stone: [
      [Color(0xFFFFFFFF), Color(0xFFE2DED6)],
      [Color(0xFF4E4A50), Color(0xFF19171B)],
    ],
    stoneSide: [Color(0xFFB0AAA0), Color(0xFF0B0A0C)],
    glyph: [Color(0xFF3A1E20), Color(0xFFF0E4DC)],
    gold: Color(0xFF94733A),
    highlight: Color(0xFF1F9E68),
    danger: Color(0xFFC8303E),
    frost: Color(0xFF3A8FE0),
  );

  /// Ninja, de noche: laca negra con fondo rojo, latón y polvo de oro.
  static const ninjaDark = HexTheme(
    brightness: Brightness.dark,
    table: TableMaterial.lacquer,
    tableGrain: Color(0x14FF8A80),
    accent: Color(0xFFD94B58),
    backdropTop: Color(0xFF1E1013),
    backdropBottom: Color(0xFF0A0506),
    backdropGlow: Color(0x30C0404F),
    backdropPattern: Color(0x09FFFFFF),
    surface: Color(0xEB1C1315),
    surfaceHigh: Color(0xFF261B1D),
    outline: Color(0x26F2D6CC),
    text: Color(0xFFF2E6E0),
    textMuted: Color(0x99F2E6E0),
    grid: Color(0x1CFFD9D0),
    shadow: Color(0xC0000000),
    lastMove: Color(0x26D94B58),
    stone: [
      [Color(0xFFFBF8F0), Color(0xFFDCD6CC)],
      [Color(0xFF4A4448), Color(0xFF151214)],
    ],
    stoneSide: [Color(0xFFA09A90), Color(0xFF070607)],
    glyph: [Color(0xFF3A1E20), Color(0xFFF0E4DC)],
    gold: Color(0xFFC9A55A),
    highlight: Color(0xFF7FE0B0),
    danger: Color(0xFFF07A84),
    frost: Color(0xFF8CC8FF),
  );

  /// Tema por defecto (Shaolin), para pantallas sin facción.
  static const light = shaolinLight;
  static const dark = shaolinDark;

  /// La mesa de [f] con la luz [b].
  static HexTheme forFaction(Faction f, Brightness b) => switch ((f, b)) {
    (Faction.shaolin, Brightness.light) => shaolinLight,
    (Faction.shaolin, Brightness.dark) => shaolinDark,
    (Faction.ninja, Brightness.light) => ninjaLight,
    (Faction.ninja, Brightness.dark) => ninjaDark,
  };

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
      table: t < 0.5 ? table : other.table,
      tableGrain: c(tableGrain, other.tableGrain),
      accent: c(accent, other.accent),
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

  ThemeData toThemeData([Skin skin = Skin.box]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
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
      fontFamily: skin.uiFont,
      extensions: [this, skin],
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceHigh,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          side: BorderSide(color: gold.withValues(alpha: 0.45)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: gold.withValues(alpha: 0.45)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: outline))),
      ),
    );
  }
}
