import '../engine/pieces.dart';

/// Aro que rodea al avatar. Hoy se eligen libremente; a futuro, premios de la
/// ladder o compras en la tienda.
class FrameDef {
  final String id;
  const FrameDef(this.id);

  String get asset => 'assets/frames/frame_$id.webp';
  String get nameKey => 'frame.$id';
}

/// Piedra de las fichas de una facción. La clásica es la textura base.
class StoneDef {
  final String id;
  final Faction faction;
  const StoneDef(this.id, this.faction);

  bool get isClassic => id == Cosmetics.classic;
  String get asset =>
      isClassic ? 'assets/textures/${faction.name}_stone.webp' : 'assets/textures/${faction.name}_stone_$id.webp';
  String get nameKey => 'stone.$id';
}

/// Tapete debajo del tablero. Sin tapete elegido, la mesa la pinta el tema de la facción.
class TableDef {
  final String id;

  /// Tapete oscuro: la grilla del tablero va en claro para que se vea.
  final bool dark;
  const TableDef(this.id, {required this.dark});

  String get asset => 'assets/tables/table_$id.webp';
  String get nameKey => 'table.$id';
}

class Cosmetics {
  static const classic = 'classic';

  static const frames = [FrameDef('bronze'), FrameDef('jade'), FrameDef('gold'), FrameDef('obsidian')];

  static const stones = [
    StoneDef(classic, Faction.shaolin),
    StoneDef('imperial', Faction.shaolin),
    StoneDef('sandstone', Faction.shaolin),
    StoneDef(classic, Faction.ninja),
    StoneDef('vermilion', Faction.ninja),
    StoneDef('iron', Faction.ninja),
  ];

  static const tables = [
    TableDef('temple_wood', dark: false),
    TableDef('black_lacquer', dark: true),
    TableDef('tatami', dark: false),
    TableDef('red_silk', dark: true),
    TableDef('river_slate', dark: true),
  ];

  static FrameDef? frame(String? id) => frames.where((f) => f.id == id).firstOrNull;
  static TableDef? table(String? id) => tables.where((t) => t.id == id).firstOrNull;
  static List<StoneDef> stonesOf(Faction f) => stones.where((s) => s.faction == f).toList();
  static StoneDef? stone(Faction f, String? id) => stones.where((s) => s.faction == f && s.id == id).firstOrNull;
}
