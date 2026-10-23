import 'dart:math';

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

  /// Globos a la vista: los últimos dos dichos o pensados (índices de golpe).
  final List<int> lines;

  /// Cartel de arriba: el momento o la última narración de la página.
  final int? caption;
  final Set<Fx> fx;
  final String? onom;
  final Who? speaker;

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
  });

  bool newPageFrom(Frame? prev) => prev == null || prev.page != page;
  Actor? actor(Who w) => cast.where((a) => a.who == w).firstOrNull;
}

/// El director: recorre los golpes de la escena y arma cada cuadro. Lo que
/// el guion no indica lo decide solo: cada momento abre página con un plano
/// general, quien habla y no está entra por su lado, y la cámara mira hacia él.
abstract final class Director {
  /// Dónde se para cada uno: el protagonista ([hero]) a la izquierda, el resto enfrente.
  static const left = 0.27, right = 0.73, center = 0.5;

  /// Cuántos globos quedan a la vista.
  static const maxLines = 2;

  static List<Frame> run(Scene scene, {required Who hero}) {
    final frames = <Frame>[];
    final splash = scene.splash;
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
      final cues = [
        if (splash != null && splash.$1 == i) ...[const Cue.page(), Cue.art(splash.$2)],
        ...b.cues,
      ];
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

      switch (b.kind) {
        case BeatKind.moment:
          caption = i;
          lines = [];
        case BeatKind.narrate:
          caption = i;
        case BeatKind.say || BeatKind.think:
          lines = [...lines, i];
          if (lines.length > maxLines) lines = lines.sublist(lines.length - maxLines);
        case BeatKind.pause:
          break;
      }

      if (framed != null) {
        shot = framed;
      } else if (i == 0 || turn) {
        // Plano de situación: la cámara se aleja despacio y recorre el lugar.
        final side = rnd.nextBool() ? -1 : 1;
        from = Shot(0.5 + 0.14 * side, 0.45, 1.3);
        shot = Shot(0.5 - 0.06 * side, 0.5, art == null ? 1.04 : 1.0);
        slow = true;
      } else if (b.talks && art == null && cast.any((a) => a.who == b.who)) {
        // Plano y contraplano: el fondo se corre apenas hacia quien habla.
        final a = cast.firstWhere((a) => a.who == b.who);
        shot = Shot((0.5 + (a.x - 0.5) * 0.45).clamp(0.0, 1.0), shot.y, max(shot.zoom, 1.1));
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
