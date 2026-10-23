part of 'script.dart';

/// Escenarios de las viñetas: el fondo que la pincelada de cada panel deja
/// ver. El arte va en `assets/story/bg_<id>.webp`; mientras falte, se pinta
/// un degradé con colinas de tinta en los colores de [top] y [bottom].
enum Place {
  wall('bg_wall', 0xFF1E2A44, 0xFF0E1320, '壁'),
  yard('bg_yard', 0xFFE9D9B4, 0xFFB79C6B, '庭'),
  road('bg_road', 0xFFE8C99A, 0xFF8E6B45, '道'),
  cells('bg_cells', 0xFF3A3530, 0xFF151210, '牢'),
  gate('bg_gate', 0xFFD9A066, 0xFF4A2E22, '門'),
  abbotHall('bg_abbot_hall', 0xFFB8573A, 0xFF3B1A12, '堂'),
  mountainPath('bg_mountain_path', 0xFFCFD8D2, 0xFF5E7066, '山'),
  bridge('bg_bridge', 0xFFC9DCE0, 0xFF4E6E78, '橋'),
  shrine('bg_shrine', 0xFFD8E2C4, 0xFF4F6B3E, '社'),
  forest('bg_forest', 0xFF26362C, 0xFF0C140F, '森'),
  valley('bg_valley', 0xFFE4E6E2, 0xFF8E9A96, '霧'),
  courtyard('bg_courtyard', 0xFFE6D7B8, 0xFF8C6E4A, '寺'),
  dormitory('bg_dormitory', 0xFF4A3A2C, 0xFF1A130D, '寮'),
  library('bg_library', 0xFF3E5A48, 0xFF14201A, '書'),
  ashCourtyard('bg_ash_courtyard', 0xFF8A8580, 0xFF2A2522, '灰'),
  pagoda('bg_pagoda', 0xFF5A1E22, 0xFF120709, '塔'),
  pagodaTop('bg_pagoda_top', 0xFF2B2440, 0xFF0B0814, '頂'),
  cryptStairs('bg_crypt_stairs', 0xFF6B4A2C, 0xFF140C06, '段'),
  crypt('bg_crypt', 0xFF3A2016, 0xFF0A0504, '窟'),
  garden('bg_garden', 0xFFEDE6D6, 0xFFA59C88, '石'),
  brokenGarden('bg_broken_garden', 0xFF9A6A4A, 0xFF231511, '裂'),
  epilogue('bg_epilogue', 0xFFF2DCD8, 0xFFB98A80, '和');

  final String art;
  final int top, bottom;
  final String glyph;
  const Place(this.art, this.top, this.bottom, this.glyph);

  String get asset => 'assets/story/$art.webp';

  /// Lugares en penumbra: el cuadro se cierra en tinta por los bordes.
  bool get night => switch (this) {
    wall || cells || forest || dormitory || cryptStairs || crypt || pagodaTop => true,
    _ => false,
  };
}

/// Dónde transcurre cada momento ("escena.índice" del mensaje que lo abre).
const _momentPlaces = <String, Place>{
  's1.pre.0': Place.wall,
  's2.pre.0': Place.yard,
  's3.pre.0': Place.road,
  's4.pre.0': Place.cells,
  's4.post.0': Place.cells,
  's5.pre.0': Place.wall,
  's6.pre.0': Place.gate,
  's7.pre.0': Place.mountainPath,
  's8.pre.0': Place.bridge,
  's9.pre.0': Place.shrine,
  's10.pre.0': Place.forest,
  's11.pre.0': Place.valley,
  's12.pre.0': Place.shrine,
  's13.pre.0': Place.courtyard,
  's14.pre.0': Place.dormitory,
  's15.pre.0': Place.library,
  's16.pre.0': Place.ashCourtyard,
  's17.pre.0': Place.abbotHall,
  's18.pre.0': Place.gate,
  's19.pre.0': Place.pagoda,
  's24.pre.0': Place.pagodaTop,
  'n1.pre.0': Place.pagoda,
  'n2.pre.0': Place.yard,
  'n3.pre.0': Place.courtyard,
  'n4.pre.0': Place.cryptStairs,
  'n5.pre.0': Place.courtyard,
  'n6.pre.0': Place.cells,
  'n7.pre.0': Place.pagoda,
  'n8.pre.0': Place.garden,
  'n10.pre.0': Place.mountainPath,
  'n12.pre.0': Place.shrine,
  'n13.pre.0': Place.courtyard,
  'n14.pre.0': Place.crypt,
  'n18.pre.0': Place.pagoda,
  'n19.pre.0': Place.courtyard,
  'n24.pre.0': Place.library,
};

final _sceneOrder = _script.keys.toList();

/// Escenario del mensaje [i] de la escena [id]: el del último momento o
/// `lugar` hasta ahí; si la escena no abre uno, sigue donde terminó la anterior.
Place _placeAt(String id, int i) {
  for (var s = _sceneOrder.indexOf(id); s >= 0; s--) {
    final sid = _sceneOrder[s];
    final beats = _script[sid]!;
    for (var k = (sid == id ? i : beats.length - 1); k >= 0; k--) {
      final cue = beats[k].cues.lastWhere((c) => c.kind == CueKind.place, orElse: () => const Cue.page());
      final p = cue.place ?? _momentPlaces['$sid.$k'];
      if (p != null) return p;
    }
  }
  return Place.courtyard;
}

/// Contra quién peleás en cada batalla de la historia: el personaje de la
/// viñeta o, si no tiene nombre, la tropa (ninjas, guardias).
const _opponents = <String, Who>{
  's1': Who.ninja,
  's2': Who.scout,
  's3': Who.ninja,
  's4': Who.ninja,
  's5': Who.ninja,
  's6': Who.kuro,
  's7': Who.ninja,
  's8': Who.ninja,
  's9': Who.jubei,
  's10': Who.ninja,
  's11': Who.ninja,
  's12': Who.aya,
  's13': Who.gon,
  's14': Who.novice,
  's15': Who.mei,
  's16': Who.ninja,
  's17': Who.kunoichi,
  's18': Who.tao,
  's19': Who.guard,
  's20': Who.kunoichi,
  's21': Who.ninja,
  's22': Who.kuro,
  's23': Who.guard,
  's24': Who.kage,
  'n1': Who.guard,
  'n2': Who.novice,
  'n3': Who.guard,
  'n4': Who.gon,
  'n5': Who.guard,
  'n6': Who.mei,
  'n7': Who.kuro,
  'n8': Who.guard,
  'n9': Who.guard,
  'n10': Who.jubei,
  'n11': Who.guard,
  'n12': Who.ren,
  'n13': Who.guard,
  'n14': Who.guard,
  'n15': Who.oni,
  'n16': Who.tao,
  'n17': Who.guard,
  'n18': Who.kage,
  'n19': Who.guard,
  'n20': Who.guard,
  'n21': Who.jubei,
  'n22': Who.gon,
  'n23': Who.mei,
  'n24': Who.abbot,
  'f1': Who.oni,
  'f2': Who.oni,
  'f3': Who.oni,
};
