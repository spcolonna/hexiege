import 'script.dart';

/// Diagramación de una viñeta como página de cómic: los mensajes se agrupan
/// en cuadros (una o dos líneas, con la narración como cartel arriba) y los
/// cuadros en tiras de uno o dos, de anchos desparejos.
sealed class Strip {
  const Strip();

  /// Mensajes de la tira, en orden.
  List<int> get beats;
  int get first => beats.first;
}

/// Momento: tira ancha con el escenario y el cartel de lugar y hora.
class MomentStrip extends Strip {
  final int beat;
  const MomentStrip(this.beat);
  @override
  List<int> get beats => [beat];
}

/// Narración suelta, sin diálogo después que la cuelgue de un cuadro.
class CaptionStrip extends Strip {
  final int beat;
  const CaptionStrip(this.beat);
  @override
  List<int> get beats => [beat];
}

/// Uno o dos cuadros lado a lado; [flex] reparte el ancho.
class FrameStrip extends Strip {
  final List<Frame> frames;
  final List<int> flex;
  const FrameStrip(this.frames, this.flex);
  @override
  List<int> get beats => [for (final f in frames) ...f.beats];
}

/// Un cuadro: carteles de narración y después uno o dos globos.
class Frame {
  final List<int> beats;
  const Frame(this.beats);
  int get first => beats.first;
}

/// Líneas cortas que pueden compartir cuadro; cuánto texto entra en medio
/// ancho con uno o con dos personajes.
const _shortLine = 75, _halfText = 130, _halfPair = 90;

List<Strip> layoutPage(Scene scene) {
  final beats = scene.beats;
  final splashAt = scene.splash?.$1;
  bool talks(int i) => beats[i].kind == BeatKind.say || beats[i].kind == BeatKind.think;
  int len(int i) => scene.text(i).length;
  int speech(Frame f) => f.beats.where(talks).fold(0, (n, i) => n + len(i));

  final strips = <Strip>[];
  final frames = <Frame>[];
  var caps = <int>[];
  List<int>? cur;

  void close() {
    if (cur != null) frames.add(Frame(cur!));
    cur = null;
  }

  // Un cuadro va solo en la tira si tiene mucho texto para medio ancho.
  bool wide(Frame f) =>
      speech(f) > (f.beats.where(talks).map((i) => beats[i].who).toSet().length > 1 ? _halfPair : _halfText);

  void flush() {
    close();
    for (var k = 0; k < frames.length; k++) {
      final f = frames[k];
      if (!wide(f) && k + 1 < frames.length && !wide(frames[k + 1])) {
        final g = frames[++k];
        final a = speech(f), b = speech(g);
        // El cuadro con más texto se lleva más ancho; si van parejos, alterna.
        final big = a > b * 1.5 ? 0 : (b > a * 1.5 ? 1 : strips.length % 2);
        strips.add(FrameStrip([f, g], big == 0 ? const [7, 5] : const [5, 7]));
      } else {
        strips.add(FrameStrip([f], const [1]));
      }
    }
    frames.clear();
    strips.addAll(caps.map(CaptionStrip.new));
    caps = [];
  }

  for (var i = 0; i < beats.length; i++) {
    // La ilustración clave corta la página: lo que sigue arranca tira nueva.
    if (i == splashAt) flush();
    if (beats[i].kind == BeatKind.moment) {
      flush();
      strips.add(MomentStrip(i));
    } else if (!talks(i)) {
      close();
      caps.add(i);
    } else if (cur != null &&
        cur!.where(talks).length == 1 &&
        len(cur!.last) <= _shortLine &&
        len(i) <= _shortLine &&
        // Para que no todo sea plano de dos: se juntan uno sí y uno no.
        (frames.length + strips.length).isEven) {
      cur!.add(i);
    } else {
      close();
      cur = [...caps, i];
      caps = [];
    }
  }
  flush();
  return strips;
}
