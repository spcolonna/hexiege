import 'dart:math';

import 'package:flutter/foundation.dart' show setEquals;

import 'script.dart';

/// Encuadre de la cámara sobre el fondo: centro (0..1) y acercamiento
/// (1 = el fondo justo cubre el cuadro).
class Shot {
  final double x, y, zoom;
  const Shot(this.x, this.y, this.zoom);

  static const wide = Shot(0.5, 0.5, 1);

  Shot lerp(Shot o, double t) => Shot(x + (o.x - x) * t, y + (o.y - y) * t, zoom + (o.zoom - zoom) * t);

  @override
  bool operator ==(Object other) => other is Shot && other.x == x && other.y == y && other.zoom == zoom;

  @override
  int get hashCode => Object.hash(x, y, zoom);

  @override
  String toString() => 'Shot($x, $y, ×$zoom)';
}

/// Un personaje en escena: dónde se para (0..1 del cuadro), desde qué golpe y cómo entró.
class Actor {
  final Who who;
  final double x;
  final int since;
  final String? style;
  const Actor(this.who, this.x, this.since, [this.style]);
}

/// Cómo queda el escenario después de un golpe: lo que el reproductor dibuja
/// (y anima desde el cuadro anterior).
class Frame {
  final int beat;

  /// Número de página: cambia en cada momento, ilustración o `página`.
  final int page;
  final Place place;

  /// Ilustración a pantalla completa (tapa el escenario y a los personajes).
  final String? art;

  /// La cámara va de [from] a [shot] durante el golpe.
  final Shot from, shot;
  final bool slow;
  final List<Actor> cast;

  /// Quiénes se fueron en este golpe (se desvanecen) y con qué estilo.
  final Map<Who, String?> leaving;

  /// Globo a la vista: lo último dicho o pensado (índice de golpe).
  final List<int> lines;

  /// Cartel de arriba: el momento o la última narración de la página.
  final int? caption;
  final Set<Fx> fx;
  final String? onom;
  final Who? speaker;

  /// Primer plano de quien habla (en una viñeta): la figura grande y recortada.
  final bool closeUp;

  /// Página de viñetas: cuántas viñetas va en cada fila (vacío = un solo cuadro con cámara).
  final List<int> rows;

  /// Viñetas a la vista hasta este golpe; la de este golpe entra animada.
  final List<Panel> sheet;

  const Frame({
    required this.beat,
    required this.page,
    required this.place,
    required this.art,
    required this.from,
    required this.shot,
    required this.slow,
    required this.cast,
    required this.leaving,
    required this.lines,
    required this.caption,
    required this.fx,
    required this.onom,
    required this.speaker,
    this.closeUp = false,
    this.rows = const [],
    this.sheet = const [],
  });

  bool get panels => rows.isNotEmpty;

  Frame copyWith({
    int? beat,
    int? page,
    Shot? from,
    Shot? shot,
    bool? slow,
    List<Actor>? cast,
    List<int>? lines,
    int? caption,
    bool noCaption = false,
    Set<Fx>? fx,
    String? onom,
    bool? closeUp,
    List<int>? rows,
    List<Panel>? sheet,
  }) => Frame(
    beat: beat ?? this.beat,
    page: page ?? this.page,
    place: place,
    art: art,
    from: from ?? this.from,
    shot: shot ?? this.shot,
    slow: slow ?? this.slow,
    cast: cast ?? this.cast,
    leaving: cast != null ? const {} : leaving,
    lines: lines ?? this.lines,
    caption: noCaption ? null : caption ?? this.caption,
    fx: fx ?? this.fx,
    onom: onom ?? this.onom,
    speaker: speaker,
    closeUp: closeUp ?? this.closeUp,
    rows: rows ?? this.rows,
    sheet: sheet ?? this.sheet,
  );

  bool newPageFrom(Frame? prev) => prev == null || prev.page != page;
  Actor? actor(Who w) => cast.where((a) => a.who == w).firstOrNull;
}

/// Una viñeta de la página: su propio cuadro (encuadre, figura, globo o
/// cartel), dónde va y en qué golpe apareció.
class Panel {
  final Frame frame;
  final int row, col, opened;
  const Panel(this.frame, this.row, this.col, this.opened);
}

/// El director: recorre los golpes de la escena y arma cada cuadro. Lo que
/// el guion no indica lo decide solo: cada momento abre página con un plano
/// general y quien habla y no está entra por su lado. En los diálogos la cámara
/// no se mueve sola; recorre el lugar en los momentos, las pausas y la narración.
abstract final class Director {
  /// Dónde se para cada uno: el protagonista ([hero]) a la izquierda, el resto enfrente.
  static const left = 0.27, right = 0.73, center = 0.5;

  /// Cuántos globos quedan a la vista: solo el de este golpe; el anterior se va al tocar.
  static const maxLines = 1;

  /// Filas de viñetas por página, como mucho.
  static const maxRows = 3;

  /// Una línea así de corta (o la mitad, en chino o japonés) entra en media fila.
  static const shortLine = 58;

  static List<Frame> run(Scene scene, {required Who hero}) => _paginate(scene, _shoot(scene, hero: hero), hero);

  static List<Frame> _shoot(Scene scene, {required Who hero}) {
    final frames = <Frame>[];
    final rnd = Random(scene.id.hashCode);
    var page = 0;
    var place = scene.placeAt(0);
    String? art;
    var shot = Shot.wide;
    var cast = <Actor>[];
    var lines = <int>[];
    int? caption;
    var lasting = <Fx>{};

    for (var i = 0; i < scene.beats.length; i++) {
      final b = scene.beats[i];
      final cues = b.cues;
      final has = cues.map((c) => c.kind).toSet();
      final turn = i > 0 && (b.kind == BeatKind.moment || has.contains(CueKind.page) || has.contains(CueKind.art));
      if (turn) page++;
      var from = shot;
      var slow = false;
      Shot? framed;
      final leaving = <Who, String?>{};
      final fx = <Fx>{};
      String? onom;

      // La página nueva arranca vacía.
      if (i == 0 || turn) {
        cast = [];
        lines = [];
        caption = null;
        lasting = {};
      }
      final momentPlace = Scene.momentPlace(scene.id, i);
      if (momentPlace != null) {
        place = momentPlace;
        art = null;
      }

      for (final c in cues) {
        switch (c.kind) {
          case CueKind.cam:
            framed = Shot(c.x, c.y, c.zoom);
            slow = c.slow;
          case CueKind.enter:
            cast = [
              for (final a in cast)
                if (a.who != c.who) a,
              Actor(c.who!, c.x, i, c.name),
            ];
          case CueKind.exit:
            if (cast.any((a) => a.who == c.who)) leaving[c.who!] = c.name;
            cast = [
              for (final a in cast)
                if (a.who != c.who) a,
            ];
          case CueKind.clear:
            for (final a in cast) {
              leaving[a.who] = null;
            }
            cast = [];
          case CueKind.fx:
            (c.fx!.lasting ? lasting : fx).add(c.fx!);
          case CueKind.onom:
            onom = c.name;
          case CueKind.art:
            art = c.name;
          case CueKind.place:
            // Otro lugar (o de vuelta de una ilustración): carteles y globos nuevos.
            place = c.place!;
            art = null;
            caption = null;
            lines = [];
          case CueKind.page || CueKind.voice:
            break;
        }
      }

      // Quien habla y no está, entra por su lado.
      final offscreen = has.contains(CueKind.voice) || leaving.containsKey(b.who);
      if (b.talks && art == null && !offscreen && cast.every((a) => a.who != b.who)) {
        cast = [...cast, Actor(b.who!, _slot(b.who!, hero, cast), i)];
      }

      // Cada toque se lleva el globo anterior.
      lines = b.talks ? [i] : [];
      if (b.kind == BeatKind.moment || b.kind == BeatKind.narrate) caption = i;

      if (framed != null) {
        shot = framed;
      } else if (i == 0 || turn) {
        // Plano de situación: la cámara se aleja despacio y recorre el lugar.
        final side = rnd.nextBool() ? -1 : 1;
        from = Shot(0.5 + 0.14 * side, 0.45, 1.3);
        shot = Shot(0.5 - 0.06 * side, 0.5, art == null ? 1.04 : 1.0);
        slow = true;
      } else if (b.talks) {
        // Mientras hablan, la cámara queda quieta: moverla marea más de lo que suma.
      } else if (b.kind == BeatKind.narrate) {
        shot = Shot(shot.x, shot.y, shot.zoom + 0.06);
      }
      if ((i == 0 || turn) && framed != null) from = Shot(framed.x, framed.y, framed.zoom + 0.25);

      frames.add(
        Frame(
          beat: i,
          page: page,
          place: place,
          art: art,
          from: from,
          shot: shot,
          slow: slow,
          cast: List.unmodifiable(cast),
          leaving: Map.unmodifiable(leaving),
          lines: List.unmodifiable(lines),
          caption: caption,
          fx: {...lasting, ...fx},
          onom: onom,
          speaker: b.talks ? b.who : null,
        ),
      );
    }
    return frames;
  }

  /// El paneo (un cuadro grande que la cámara recorre) es un recurso, no la
  /// regla: queda para las ilustraciones y para la página que abre la escena
  /// con un recorrido lento antes de que nadie hable. El resto de las páginas
  /// se arma en viñetas que entran de a una con cada toque.
  static bool _cinematic(Scene scene, List<Frame> chapter) {
    if (chapter.any((f) => f.art != null)) return true;
    if (chapter.first.page != 0) return false;
    for (final f in chapter) {
      final b = scene.beats[f.beat];
      if (b.talks) return false;
      if (b.cues.any((c) => c.kind == CueKind.cam && c.slow)) return true;
    }
    return false;
  }

  /// Golpes que abren una viñeta: todo lo que tiene texto y los planos mudos.
  static bool _opens(Beat b) => b.hasText || b.cues.any((c) => c.kind == CueKind.cam);

  static bool _short(Scene scene, int i) {
    final s = scene.text(i);
    final wide = s.runes.any((r) => r >= 0x2E80);
    return s.length * (wide ? 2 : 1) <= shortLine;
  }

  static List<Frame> _paginate(Scene scene, List<Frame> shot, Who hero) {
    final out = <Frame>[];
    final rnd = Random(scene.id.hashCode ^ 0x5eed);
    var page = -1;
    for (var at = 0; at < shot.length;) {
      var end = at;
      while (end < shot.length && shot[end].page == shot[at].page) {
        end++;
      }
      final chapter = shot.sublist(at, end);
      at = end;
      final openers = [
        for (final f in chapter)
          if (_opens(scene.beats[f.beat])) f.beat,
      ];
      if (openers.isEmpty || _cinematic(scene, chapter)) {
        page++;
        out.addAll(chapter.map((f) => f.copyWith(page: page)));
        continue;
      }

      // Qué viñeta abre cada golpe. Quien habla va en primer plano, salvo la
      // primera línea o cuando cambia quién está: ahí, un plano con todos.
      final byBeat = {for (final f in chapter) f.beat: f};
      final closeUp = <int, bool>{};
      Set<Who>? seen;
      for (final i in openers) {
        final f = byBeat[i]!, b = scene.beats[i];
        final who = f.cast.map((a) => a.who).toSet();
        final group = who.length > 1 && (seen == null || !setEquals(seen, who));
        closeUp[i] = b.talks && !group && !b.cues.any((c) => c.kind == CueKind.cam);
        if (b.talks) seen = who;
      }

      // Filas: dos primeros planos cortos y seguidos, de distinta gente, comparten fila.
      final rows = <List<int>>[];
      for (var k = 0; k < openers.length; k++) {
        final i = openers[k];
        if (k + 1 < openers.length) {
          final j = openers[k + 1];
          final pair =
              closeUp[i]! &&
              closeUp[j]! &&
              scene.beats[i].who != scene.beats[j].who &&
              _short(scene, i) &&
              _short(scene, j);
          if (pair) {
            rows.add([i, j]);
            k++;
            continue;
          }
        }
        rows.add([i]);
      }

      // Páginas parejas de hasta [maxRows] filas.
      final pages = (rows.length / maxRows).ceil();
      final where = <int, (int, int, int)>{}; // golpe → (página, fila, columna)
      final layouts = <List<int>>[];
      var r = 0;
      for (var p = 0; p < pages; p++) {
        final n = (rows.length - r) ~/ (pages - p) + ((rows.length - r) % (pages - p) > 0 ? 1 : 0);
        layouts.add([for (var k = 0; k < n; k++) rows[r + k].length]);
        for (var k = 0; k < n; k++) {
          for (var c = 0; c < rows[r + k].length; c++) {
            where[rows[r + k][c]] = (p, k, c);
          }
        }
        r += n;
      }

      final first = page + 1;
      var sheet = <Panel>[];
      var current = 0;
      page = first;
      for (final f in chapter) {
        final b = scene.beats[f.beat];
        final slot = where[f.beat];
        if (slot != null) {
          final (p, row, col) = slot;
          if (p != current) {
            current = p;
            sheet = [];
          }
          page = first + p;
          final half = layouts[p][row] > 1;
          sheet = [...sheet, Panel(_panel(scene, f, b, closeUp[f.beat]!, half, hero, rnd), row, col, f.beat)];
        } else if (sheet.isNotEmpty && (f.onom != null || f.fx.any((x) => !x.lasting))) {
          // Un golpe mudo con efecto sacude la última viñeta.
          final last = sheet.last;
          sheet = [
            ...sheet.take(sheet.length - 1),
            Panel(last.frame.copyWith(beat: f.beat, fx: f.fx, onom: f.onom), last.row, last.col, last.opened),
          ];
        }
        out.add(f.copyWith(page: page, rows: layouts[current], sheet: List.unmodifiable(sheet)));
      }
      page = first + pages - 1;
    }
    return out;
  }

  /// El cuadro de una viñeta: el encuadre según lo que pasa y, si habla
  /// alguien, su figura (sola en primer plano o con todos los presentes).
  static Frame _panel(Scene scene, Frame f, Beat b, bool closeUp, bool half, Who hero, Random rnd) {
    final cam = b.cues.where((c) => c.kind == CueKind.cam).firstOrNull;
    final framed = cam == null ? null : Shot(cam.x, cam.y, cam.zoom);
    Frame make(Shot from, Shot to, {bool slow = false, List<Actor> cast = const [], bool close = false}) => f.copyWith(
      from: from,
      shot: to,
      slow: slow,
      cast: cast,
      lines: b.talks ? [f.beat] : const [],
      caption: b.kind == BeatKind.moment || b.kind == BeatKind.narrate ? f.beat : null,
      noCaption: !(b.kind == BeatKind.moment || b.kind == BeatKind.narrate),
      closeUp: close,
    );

    if (!b.talks) {
      if (framed != null) return make(Shot(framed.x, framed.y, framed.zoom + 0.18), framed, slow: cam!.slow);
      if (b.kind == BeatKind.moment) {
        // El lugar, de lejos: un recorrido corto dentro de la viñeta.
        final side = rnd.nextBool() ? -1 : 1;
        return make(Shot(0.5 + 0.12 * side, 0.45, 1.3), Shot(0.5 - 0.04 * side, 0.5, 1.08), slow: true);
      }
      final x = 0.25 + 0.5 * rnd.nextDouble();
      return make(Shot(x, 0.45, 1.42), Shot(x, 0.45, 1.32));
    }

    final speaker = f.actor(b.who!);
    if (!closeUp || speaker == null) {
      // Todos los presentes, como en el escenario; o la voz en off sobre el lugar.
      final to = framed ?? Shot(0.5, 0.55, speaker == null ? 1.25 : 1.0);
      return make(
        Shot(to.x, to.y, to.zoom + 0.08),
        to,
        cast: [for (final a in f.cast) Actor(a.who, a.x, a.since == f.beat ? f.beat : -1, a.style)],
      );
    }
    final left = speaker.x <= 0.5;
    final x = half ? 0.5 : (left ? 0.24 : 0.76);
    final to = Shot(left ? 0.3 : 0.7, 0.4, 1.7);
    return make(Shot(to.x, to.y, to.zoom + 0.1), to, cast: [Actor(speaker.who, x, f.beat)], close: true);
  }

  /// Lugar libre para quien entra solo: el protagonista a la izquierda, el resto
  /// a la derecha; si ya está ocupado, en el medio.
  static double _slot(Who w, Who hero, List<Actor> cast) {
    bool free(double x) => cast.every((a) => (a.x - x).abs() > 0.15);
    final preferred = w == hero || w.side == hero.side && cast.every((a) => a.who != hero) ? left : right;
    for (final x in [preferred, preferred == left ? right : left, center]) {
      if (free(x)) return x;
    }
    return center;
  }
}
