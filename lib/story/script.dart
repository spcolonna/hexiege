import '../engine/pieces.dart';
import '../i18n/i18n.dart';

part 'script.g.dart';

/// Quién habla en una viñeta.
enum Who {
  narrator,
  ren,
  aya,
  abbot,
  kage,
  mei,
  tao,
  gon,
  kuro,
  jubei,
  fox,
  oni,
  ninja,
  scout,
  novice,
  guard,
  kunoichi;

  String get displayName => tr('who.$name');

  /// Bando del personaje (null = ninguno: la Zorra, Jubei, el narrador).
  Faction? get side => switch (this) {
    ren || abbot || mei || tao || gon || novice => Faction.shaolin,
    aya || kage || kuro || ninja || scout || guard || kunoichi => Faction.ninja,
    oni => Faction.oni,
    narrator || jubei || fox => null,
  };

  /// Retrato del catálogo de avatares o, mientras no haya arte, un carácter.
  String get avatar => switch (this) {
    ren => 'novice',
    aya => 'fan',
    mei => 'abbess',
    tao => 'drunken',
    gon => 'staff',
    kuro => 'jonin',
    jubei => 'ronin',
    fox => 'kitsune',
    abbot => '師',
    kage => '影',
    oni => '鬼',
    ninja || scout => '忍',
    novice => '童',
    guard => '衛',
    kunoichi => '扇',
    narrator => '',
  };
}

enum BeatKind { moment, say, think, narrate }

/// Un mensaje de la viñeta: un cambio de momento (lugar o tiempo), una línea
/// dicha o pensada, o narración.
class Beat {
  final BeatKind kind;
  final Who? who;
  const Beat.moment() : kind = BeatKind.moment, who = null;
  const Beat.say(Who this.who) : kind = BeatKind.say;
  const Beat.think(Who this.who) : kind = BeatKind.think;
  const Beat.narrate(Who this.who) : kind = BeatKind.narrate;
}

/// Viñeta de una batalla: [pre] antes de jugarla, [post] al ganarla.
class Scene {
  final String id;
  final List<Beat> beats;
  const Scene._(this.id, this.beats);

  static Scene? of(String stageId, {required bool post}) {
    final id = '$stageId.${post ? 'post' : 'pre'}';
    final beats = _script[id];
    return beats == null ? null : Scene._(id, beats);
  }

  static Iterable<String> get ids => _script.keys;

  String get stageId => id.substring(0, id.indexOf('.'));
  bool get isPost => id.endsWith('.post');

  String text(int i) => tr('story.$id.$i');

  /// Índices de los mensajes que abren un momento.
  List<int> get moments => [
    for (var i = 0; i < beats.length; i++)
      if (beats[i].kind == BeatKind.moment) i,
  ];
}
