import '../engine/pieces.dart';
import '../i18n/i18n.dart';

part 'script.g.dart';
part 'staging.dart';

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

  /// Retrato del catálogo de avatares (vacío para el narrador).
  String get avatar => switch (this) {
    ren => 'novice',
    aya => 'fan',
    mei => 'abbess',
    tao => 'drunken',
    gon => 'staff',
    kuro => 'jonin',
    jubei => 'ronin',
    fox => 'kitsune',
    abbot => 'abbot',
    kage => 'shogun',
    oni => 'ashoni',
    ninja => 'ninja',
    scout => 'scout',
    novice => 'acolyte',
    guard => 'guard',
    kunoichi => 'kunoichi',
    narrator => '',
  };
}

/// [pause]: un golpe sin texto, solo puesta en escena (la cámara se mueve,
/// alguien entra o se va); igual espera un toque.
enum BeatKind { moment, say, think, narrate, pause }

/// Un golpe de la viñeta: un cambio de momento (lugar o tiempo), una línea
/// dicha o pensada, narración o una pausa muda. Cada uno espera un toque.
/// [cues] es la puesta en escena que lo acompaña.
class Beat {
  final BeatKind kind;
  final Who? who;
  final List<Cue> cues;
  const Beat.moment([this.cues = const []]) : kind = BeatKind.moment, who = null;
  const Beat.say(Who this.who, [this.cues = const []]) : kind = BeatKind.say;
  const Beat.think(Who this.who, [this.cues = const []]) : kind = BeatKind.think;
  const Beat.narrate(Who this.who, [this.cues = const []]) : kind = BeatKind.narrate;
  const Beat.pause([this.cues = const []]) : kind = BeatKind.pause, who = null;

  bool get talks => kind == BeatKind.say || kind == BeatKind.think;
  bool get hasText => kind != BeatKind.pause;
}

/// [voice]: quien habla lo hace fuera de cuadro (no entra solo).
enum CueKind { cam, enter, exit, clear, fx, onom, art, place, page, voice }

/// Efectos de un golpe. Los de [lasting] quedan hasta el próximo cambio de página.
enum Fx {
  shake,
  flash,
  smoke,
  pulse,
  dark,
  fog;

  bool get lasting => this == dark || this == fog;
}

/// Una indicación de puesta en escena (en `docs/lore.md`, entre corchetes).
class Cue {
  final CueKind kind;
  final Who? who;

  /// Cámara: centro (0..1 sobre el fondo) y acercamiento (1 = el fondo justo
  /// cubre el cuadro). Entrada: [x] es dónde se para (0..1 del cuadro).
  final double x, y, zoom;

  /// Cámara: cuánto del ancho del fondo se ve como mínimo (0 = sin mínimo).
  final double span;

  /// Cámara lenta (un paneo largo).
  final bool slow;

  /// Estilo de entrada o salida (`humo`, `sombra`, `corre`), arte o clave de onomatopeya.
  final String? name;
  final Fx? fx;
  final Place? place;

  const Cue.cam(this.x, this.y, this.zoom, {this.slow = false, this.span = 0})
    : kind = CueKind.cam,
      who = null,
      name = null,
      fx = null,
      place = null;
  const Cue.enter(Who this.who, this.x, [this.name])
    : kind = CueKind.enter,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      fx = null,
      place = null;
  const Cue.exit(Who this.who, [this.name])
    : kind = CueKind.exit,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      fx = null,
      place = null;
  const Cue.clear()
    : kind = CueKind.clear,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      name = null,
      fx = null,
      place = null;
  const Cue.fx(Fx this.fx)
    : kind = CueKind.fx,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      name = null,
      place = null;
  const Cue.onom(String this.name)
    : kind = CueKind.onom,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      fx = null,
      place = null;
  const Cue.art(String this.name)
    : kind = CueKind.art,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      fx = null,
      place = null;
  const Cue.place(Place this.place)
    : kind = CueKind.place,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      name = null,
      fx = null;
  const Cue.voice()
    : kind = CueKind.voice,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      name = null,
      fx = null,
      place = null;
  const Cue.page()
    : kind = CueKind.page,
      who = null,
      x = 0,
      y = 0,
      zoom = 0,
      span = 0,
      slow = false,
      name = null,
      fx = null,
      place = null;
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

  /// Personaje contra el que se juega la batalla [stageId] (null si no es de la historia).
  static Who? opponentOf(String stageId) => _opponents[stageId];

  String get stageId => id.substring(0, id.indexOf('.'));
  bool get isPost => id.endsWith('.post');

  String text(int i) => tr('story.$id.$i');

  /// Escenario donde se dice el mensaje [i].
  Place placeAt(int i) => _placeAt(id, i);

  /// Escenario fijado por el momento que abre el mensaje [i] (null si no abre uno).
  static Place? momentPlace(String sceneId, int i) => _momentPlaces['$sceneId.$i'];

  /// Retrato de cuerpo para los paneles (puede no existir todavía).
  static String figureAsset(Who w) => 'assets/story/char_${w.name}.webp';

  /// Golpes con texto, en orden (las pausas mudas no cuentan).
  Iterable<int> get lines sync* {
    for (var i = 0; i < beats.length; i++) {
      if (beats[i].hasText) yield i;
    }
  }

  /// Índices de los mensajes que abren un momento.
  List<int> get moments => [
    for (var i = 0; i < beats.length; i++)
      if (beats[i].kind == BeatKind.moment) i,
  ];
}
