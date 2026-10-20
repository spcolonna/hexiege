import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import '../ui/fx/sfx.dart';
import '../ui/theme/hex_theme.dart';
import '../ui/theme/settings.dart';
import '../ui/theme/ui_style.dart';
import '../ui/widgets/arena_backdrop.dart';
import '../ui/widgets/avatar_face.dart';
import '../ui/widgets/skin_kit.dart';
import 'script.dart';

/// Muestra una viñeta a pantalla completa y la marca como vista al cerrarla.
/// [mine]: bandos que van a la izquierda (el tuyo). Con [replay] el texto
/// aparece entero, para releer desde el Pergamino.
Future<void> playScene(
  BuildContext context,
  Scene scene, {
  required Set<Faction> mine,
  String? title,
  bool replay = false,
}) async {
  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => StoryScreen(scene: scene, mine: mine, title: title, replay: replay),
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
    ),
  );
  AppSettings.instance.markSceneSeen(scene.id);
}

/// Viñeta tipo charla: los mensajes entran de a uno, con "escribiendo…" antes.
/// Tocar adelanta el próximo; mantener apretado acelera; arriba, la línea de
/// tiempo de los momentos permite saltar o volver.
class StoryScreen extends StatefulWidget {
  final Scene scene;
  final Set<Faction> mine;
  final String? title;
  final bool replay;
  const StoryScreen({super.key, required this.scene, required this.mine, this.title, this.replay = false});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final _scroll = ScrollController();
  late final List<GlobalKey> _keys = List.generate(widget.scene.beats.length, (_) => GlobalKey());
  Timer? _timer;

  /// Mensajes a la vista.
  int _shown = 0;

  /// El próximo mensaje se está "escribiendo".
  bool _typing = false;
  bool _fast = false;

  List<Beat> get _beats => widget.scene.beats;
  bool get _done => _shown >= _beats.length;

  @override
  void initState() {
    super.initState();
    StoryArt.load().then((_) {
      if (mounted) setState(() {});
    });
    if (widget.replay) {
      _shown = _beats.length;
    } else {
      _timer = Timer(const Duration(milliseconds: 500), _queue);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// Cuánto tarda en "escribirse" el mensaje [i]: según el largo del texto.
  Duration _delay(int i) {
    final b = _beats[i];
    final len = widget.scene.text(i).length;
    final ms = switch (b.kind) {
      BeatKind.moment => 700,
      BeatKind.narrate => (500 + len * 18).clamp(700, 2000),
      _ => (350 + len * 22).clamp(600, 2200),
    };
    return Duration(milliseconds: _fast ? ms ~/ 5 : ms);
  }

  void _queue() {
    if (!mounted || _done) return;
    final i = _shown;
    setState(() => _typing = true);
    _timer = Timer(_delay(i), _reveal);
    _follow();
  }

  void _reveal() {
    _timer?.cancel();
    if (!mounted || _done) return;
    final b = _beats[_shown];
    setState(() {
      _shown++;
      _typing = false;
    });
    SoundBoard.instance.play(b.kind == BeatKind.moment ? Sfx.turn : Sfx.tick, volume: 0.5);
    _follow();
    // Una pausa breve para leer antes de que empiece el siguiente.
    if (!_done) _timer = Timer(Duration(milliseconds: _fast ? 60 : 380), _queue);
  }

  /// Tocar: el mensaje que se está escribiendo aparece ya.
  void _tap() {
    if (_done) return;
    Haptics.select();
    _reveal();
  }

  /// Saltar a un momento: muestra todo hasta ahí y lo lleva a la vista.
  void _jump(int index) {
    Haptics.select();
    if (index >= _shown) {
      _timer?.cancel();
      setState(() {
        _shown = index + 1;
        _typing = false;
      });
      _timer = Timer(const Duration(milliseconds: 500), _queue);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[index].currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), alignment: 0.05);
    });
  }

  void _skip() {
    _timer?.cancel();
    Navigator.of(context).maybePop();
  }

  void _follow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        accent: t.gold,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: skin.display(22, color: t.text),
                      ),
                    ),
                    // Altura fija: el título no salta cuando se va "Saltar".
                    SizedBox(
                      height: 44,
                      child: _done ? null : SkinLink(label: tr('story.skip'), onPressed: _skip),
                    ),
                  ],
                ),
              ),
              _Timeline(scene: widget.scene, shown: _shown, onTap: _jump),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _tap,
                  onLongPressStart: (_) {
                    _fast = true;
                    _reveal();
                  },
                  onLongPressEnd: (_) => _fast = false,
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                    children: _panels(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _done
                      ? SkinPrimaryButton(
                          key: const ValueKey('go'),
                          label: tr('story.continue'),
                          color: t.gold,
                          onPressed: _skip,
                        )
                      : Text(
                          tr('story.hint'),
                          key: const ValueKey('hint'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: t.textMuted),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quién se para a la izquierda: el protagonista de la campaña (Ren o Aya).
  /// Si no habla en la escena, el primero que hable; el resto, enfrente.
  late final Who _anchor = () {
    final hero = widget.mine.contains(Faction.shaolin) ? Who.ren : Who.aya;
    final talkers = [
      for (final b in _beats)
        if (b.kind == BeatKind.say || b.kind == BeatKind.think) b.who!,
    ];
    return talkers.contains(hero) || talkers.isEmpty ? hero : talkers.first;
  }();

  bool _left(Who w) => w == _anchor;

  bool _talks(int i) => _beats[i].kind == BeatKind.say || _beats[i].kind == BeatKind.think;

  /// Paneles en pantalla: los revelados y, si alguien está por hablar, el suyo
  /// con los puntos en el globo.
  int get _visible => _shown + (_typing && !_done && _talks(_shown) ? 1 : 0);

  /// De qué lado entra el panel [i]: -1 izquierda, 1 derecha, 0 en el lugar.
  double _from(int i) => _talks(i) ? (_left(_beats[i].who!) ? -1 : 1) : 0;

  int get _seed => widget.scene.id.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0xFFFFFF);

  List<Widget> _panels() {
    final splash = widget.scene.splash;
    final animate = !widget.replay;
    return [
      for (var i = 0; i < _visible; i++) ...[
        if (splash != null && splash.$1 == i && StoryArt.has('assets/story/${splash.$2}.webp'))
          _Enter(
            key: const ValueKey('splash'),
            animate: animate,
            wipe: true,
            child: _Splash(asset: 'assets/story/${splash.$2}.webp', seed: _seed),
          ),
        _Enter(
          key: _keys[i],
          animate: animate,
          from: _from(i),
          wipe: _beats[i].kind == BeatKind.moment,
          child: _beat(i),
        ),
      ],
    ];
  }

  Widget _beat(int i) {
    final b = _beats[i];
    final text = i < _shown ? widget.scene.text(i) : null;
    final place = widget.scene.placeAt(i);
    return switch (b.kind) {
      BeatKind.moment => _MomentPanel(text: text ?? '', place: place, seed: _seed + i),
      BeatKind.narrate => _Caption(text: text ?? ''),
      _ => _SpeechPanel(
        who: b.who!,
        text: text,
        place: place,
        left: _left(b.who!),
        thought: b.kind == BeatKind.think,
        seed: _seed + i * 13,
      ),
    };
  }
}

/// Línea de tiempo: un punto por momento; los alcanzados se pueden tocar.
class _Timeline extends StatelessWidget {
  final Scene scene;
  final int shown;
  final ValueChanged<int> onTap;
  const _Timeline({required this.scene, required this.shown, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final moments = scene.moments;
    if (moments.length < 2) return const SizedBox(height: 6);
    final t = HexTheme.of(context);
    final current = moments.lastIndexWhere((m) => m < shown);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      child: Row(
        children: [
          for (var k = 0; k < moments.length; k++) ...[
            if (k > 0)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  color: (k <= current ? t.gold : t.textMuted).withValues(alpha: k <= current ? 0.8 : 0.3),
                ),
              ),
            Tooltip(
              message: scene.text(moments[k]),
              child: GestureDetector(
                onTap: () => onTap(moments[k]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: k == current ? 16 : 11,
                  height: k == current ? 16 : 11,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: k <= current ? t.gold : Colors.transparent,
                    border: Border.all(color: k <= current ? t.gold : t.textMuted.withValues(alpha: 0.6), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Arte de las viñetas presente en el paquete (fondos, figuras e
/// ilustraciones llegan de a poco: lo que falta se dibuja con tinta).
abstract final class StoryArt {
  static Set<String>? _assets;

  static Future<void> load() async {
    if (_assets != null) return;
    try {
      final m = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assets = m.listAssets().where((a) => a.startsWith('assets/story/')).toSet();
    } catch (_) {
      _assets = {};
    }
  }

  static bool has(String asset) => _assets?.contains(asset) ?? false;
}

// Los paneles son papel y tinta en cualquier estilo: el cómic manda.
const _paper = Color(0xFFFBF6EA);
const _captionPaper = Color(0xFFF0E2B6);
const _ink = Color(0xFF1B1712);

/// Entrada de un panel: los diálogos llegan desde el lado de quien habla con
/// un rebote y un leve giro; los momentos se descubren como una pincelada.
class _Enter extends StatelessWidget {
  final Widget child;
  final bool animate;
  final double from;
  final bool wipe;
  const _Enter({super.key, required this.child, this.animate = true, this.from = 0, this.wipe = false});

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    final w = MediaQuery.sizeOf(context).width;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: wipe ? 650 : 520),
      curve: from == 0 ? Curves.easeOutCubic : Curves.easeOutBack,
      builder: (_, v, c) {
        if (wipe) return ClipRect(clipper: _Wipe(v), child: c);
        if (from == 0) {
          return Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.94 + 0.06 * v, child: c),
          );
        }
        return Opacity(
          opacity: (v * 1.8).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(from * w * 0.6 * (1 - v), 0),
            child: Transform.rotate(angle: from * 0.07 * (1 - v), child: c),
          ),
        );
      },
      child: child,
    );
  }
}

/// Recorte de izquierda a derecha: el pincel pasa y deja ver el panel.
class _Wipe extends CustomClipper<Rect> {
  final double v;
  _Wipe(this.v);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(-20, -40, (size.width + 40) * v.clamp(0.0, 1.0), size.height + 80);

  @override
  bool shouldReclip(_Wipe old) => old.v != v;
}

/// Forma de una pincelada horizontal: el arranque redondo y cargado de
/// tinta, los bordes apenas temblorosos y la cola seca que se abre en cerdas.
/// [flip] la espeja (la cola queda a la izquierda).
Path _brush(Size s, int seed, {bool flip = false}) {
  final r = Random(seed);
  final w = s.width, h = s.height;
  // Temblor suave del borde: dos senos con fase al azar.
  double Function(double) wobble(double amp) {
    final p1 = r.nextDouble() * 2 * pi, p2 = r.nextDouble() * 2 * pi;
    final f1 = 1 + r.nextDouble() * 1.5, f2 = 3 + r.nextDouble() * 3;
    return (t) => amp * (0.7 * sin(t * 2 * pi * f1 + p1) + 0.3 * sin(t * 2 * pi * f2 + p2));
  }

  final top = wobble(h * 0.025), bottom = wobble(h * 0.025);
  final x0 = w * 0.035, x1 = w * (0.86 + 0.03 * r.nextDouble());
  final y0 = h * 0.05, y1 = h * 0.95;
  final p = Path()..moveTo(x0, y0 + top(0));
  const steps = 24;
  for (var i = 1; i <= steps; i++) {
    final t = i / steps;
    // Hacia la cola el trazo se afina un poco.
    p.lineTo(x0 + (x1 - x0) * t, y0 + top(t) + h * 0.04 * t * t);
  }
  // Cola: cerdas de largo desparejo, de arriba hacia abajo.
  const bristles = 9;
  final tailTop = y0 + h * 0.04, tailBottom = y1 - h * 0.04;
  for (var j = 0; j < bristles; j++) {
    final a = tailTop + (tailBottom - tailTop) * j / bristles;
    final b = tailTop + (tailBottom - tailTop) * (j + 1) / bristles;
    final reach = w * (0.035 + 0.1 * r.nextDouble()) * (j == 0 || j == bristles - 1 ? 0.6 : 1);
    p
      ..lineTo(x1 + reach, a + (b - a) * (0.35 + 0.3 * r.nextDouble()))
      ..lineTo(x1 - w * 0.015 * r.nextDouble(), b);
  }
  for (var i = steps; i >= 0; i--) {
    final t = i / steps;
    p.lineTo(x0 + (x1 - x0) * t, y1 + bottom(t) - h * 0.04 * t * t);
  }
  // Arranque: la panza redonda donde el pincel apoyó.
  final bulge = w * (0.03 + 0.015 * r.nextDouble());
  p
    ..quadraticBezierTo(x0 - bulge, y1 - h * 0.05, x0 - bulge * 0.8, h * 0.5)
    ..quadraticBezierTo(x0 - bulge, y0 + h * 0.05, x0, y0 + top(0))
    ..close();
  // Un par de cerdas sueltas que se escapan de la cola.
  for (var k = 0; k < 2; k++) {
    final y = h * (k == 0 ? 0.12 + 0.1 * r.nextDouble() : 0.78 + 0.1 * r.nextDouble());
    final th = h * (0.025 + 0.02 * r.nextDouble());
    final from = x1 - w * 0.12, to = x1 + w * (0.06 + 0.06 * r.nextDouble());
    p
      ..moveTo(from, y - th)
      ..quadraticBezierTo((from + to) / 2, y - th * 1.4, to, y)
      ..quadraticBezierTo((from + to) / 2, y + th * 0.6, from, y + th)
      ..close();
  }
  if (!flip) return p;
  return p.transform(Float64List.fromList([-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, w, 0, 0, 1]));
}

class _BrushClip extends CustomClipper<Path> {
  final int seed;
  final bool flip;

  /// Margen libre arriba: la figura puede salirse del panel por ahí.
  final double overTop;
  _BrushClip(this.seed, this.flip, {this.overTop = 0});

  @override
  Path getClip(Size size) {
    final body = Size(size.width, size.height - overTop);
    final p = _brush(body, seed, flip: flip).shift(Offset(0, overTop));
    if (overTop == 0) return p;
    // Unión y no addRect: espejada, la pincelada gira al revés y se cancelaría.
    return Path.combine(
      PathOperation.union,
      p,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, overTop + body.height * 0.5)),
    );
  }

  @override
  bool shouldReclip(_BrushClip old) => old.seed != seed || old.flip != flip || old.overTop != overTop;
}

class _BrushShadow extends CustomPainter {
  final int seed;
  final bool flip;
  _BrushShadow(this.seed, this.flip);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _brush(size, seed, flip: flip).shift(const Offset(3, 4)),
      Paint()
        ..color = _ink.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_BrushShadow old) => old.seed != seed || old.flip != flip;
}

/// La pincelada como máscara: deja ver [child] (el escenario) con su sombra.
class _BrushFrame extends StatelessWidget {
  final int seed;
  final bool flip;
  final Widget child;
  const _BrushFrame({required this.seed, this.flip = false, required this.child});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BrushShadow(seed, flip),
    child: ClipPath(clipper: _BrushClip(seed, flip), child: child),
  );
}

/// Fondo del escenario. [alignX] corre el encuadre: quien habla a la
/// izquierda ve un lado del lugar y quien responde, el otro (plano y contraplano).
class _PlaceBackdrop extends StatelessWidget {
  final Place place;
  final double alignX;
  const _PlaceBackdrop({required this.place, this.alignX = 0});

  @override
  Widget build(BuildContext context) {
    if (StoryArt.has(place.asset)) {
      return Image.asset(
        place.asset,
        fit: BoxFit.cover,
        alignment: Alignment(alignX, -0.2),
        filterQuality: FilterQuality.medium,
      );
    }
    return CustomPaint(
      painter: _InkLandscape(place, alignX),
      child: Center(
        child: Text(place.glyph, style: Skin.of(context).glyph(96, color: Colors.white.withValues(alpha: 0.09))),
      ),
    );
  }
}

/// Paisaje de tinta provisorio: cielo en degradé, una luna y tres capas de
/// colinas que se corren con el encuadre.
class _InkLandscape extends CustomPainter {
  final Place place;
  final double alignX;
  _InkLandscape(this.place, this.alignX);

  @override
  void paint(Canvas canvas, Size size) {
    final top = Color(place.top), bottom = Color(place.bottom);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    final r = Random(place.index * 17 + 3);
    for (var layer = 0; layer < 3; layer++) {
      final base = size.height * (0.5 + 0.17 * layer);
      final amp = size.height * (0.12 - 0.025 * layer);
      final phase = r.nextDouble() * pi * 2;
      final freq = 1.6 + r.nextDouble() * 1.4;
      final shift = -alignX * size.width * 0.12 * (layer + 1);
      final p = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width; x += 6) {
        final u = (x + shift) / size.width;
        p.lineTo(x, base - amp * (sin(u * pi * freq + phase) * 0.7 + sin(u * pi * freq * 2.7 + phase) * 0.3));
      }
      p
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        p,
        Paint()..color = Color.lerp(bottom, _ink, 0.35 + 0.2 * layer)!.withValues(alpha: 0.45 + 0.18 * layer),
      );
    }
  }

  @override
  bool shouldRepaint(_InkLandscape old) => old.place != place || old.alignX != alignX;
}

/// Panel de un momento: el escenario entero y el cartel de lugar y hora.
class _MomentPanel extends StatelessWidget {
  final String text;
  final Place place;
  final int seed;
  const _MomentPanel({required this.text, required this.place, required this.seed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 170,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: _BrushFrame(
                seed: seed,
                child: _PlaceBackdrop(place: place),
              ),
            ),
            Positioned(
              left: 6,
              top: -4,
              right: 70,
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.rotate(
                  angle: -0.015,
                  child: _CaptionBox(
                    child: Text(text, style: Skin.of(context).display(16, color: _ink, height: 1.2)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartel de cómic: papel amarillento, borde de tinta y sombra dura.
class _CaptionBox extends StatelessWidget {
  final Widget child;
  const _CaptionBox({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
    decoration: BoxDecoration(
      color: _captionPaper,
      border: Border.all(color: _ink, width: 1.6),
      boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.35), offset: const Offset(3, 3))],
    ),
    child: child,
  );
}

/// Narración: un cartel suelto entre paneles.
class _Caption extends StatelessWidget {
  final String text;
  const _Caption({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
      child: Transform.rotate(
        angle: -0.01,
        child: _CaptionBox(
          child: Text.rich(
            storySpans(text, const TextStyle(fontSize: 15, height: 1.4, fontStyle: FontStyle.italic, color: _ink)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Ilustración de un momento clave, a todo el ancho.
class _Splash extends StatelessWidget {
  final String asset;
  final int seed;
  const _Splash({required this.asset, required this.seed});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: AspectRatio(
      aspectRatio: 3 / 2,
      child: _BrushFrame(
        seed: seed ^ 0x5A5A,
        child: Image.asset(asset, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
      ),
    ),
  );
}

/// Panel de diálogo: la pincelada deja ver el escenario, el personaje se
/// para de su lado (y se sale del cuadro por arriba) y el globo ocupa el resto.
/// Sin [text], el globo muestra los puntos de "por hablar".
class _SpeechPanel extends StatelessWidget {
  final Who who;
  final String? text;
  final Place place;
  final bool left;
  final bool thought;
  final int seed;
  const _SpeechPanel({
    required this.who,
    this.text,
    required this.place,
    required this.left,
    this.thought = false,
    required this.seed,
  });

  static const _over = 26.0;

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = who.side == null ? t.gold : HexTheme.faction(who.side!);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final figW = w * 0.36;
        final art = Scene.figureAsset(who);
        final hasArt = StoryArt.has(art);
        final figure = hasArt
            ? Transform.flip(
                flipX: !left,
                child: Image.asset(
                  art,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  filterQuality: FilterQuality.medium,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: _over + 8, bottom: 22),
                child: Center(
                  child: AvatarFace(
                    avatar: who.avatar,
                    size: min(figW * 0.74, 92),
                    color: color,
                    borderColor: _ink,
                    borderWidth: 3,
                    shadow: [BoxShadow(color: _ink.withValues(alpha: 0.4), offset: const Offset(2, 3))],
                  ),
                ),
              );
        final side = left ? 6.0 : null, other = left ? null : 6.0;
        return Padding(
          padding: const EdgeInsets.only(top: _over, bottom: 12),
          child: Transform.rotate(
            angle: left ? -0.008 : 0.008,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _BrushFrame(
                    seed: seed,
                    flip: !left,
                    child: _PlaceBackdrop(place: place, alignX: left ? -0.8 : 0.8),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 150, minWidth: w),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(left ? figW + 6 : 18, 16, left ? 18 : figW + 6, 30),
                    child: Align(
                      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
                      widthFactor: 1,
                      heightFactor: 1,
                      child: _Balloon(text: text, left: left, thought: thought),
                    ),
                  ),
                ),
                // La figura se recorta con la misma pincelada, salvo arriba.
                Positioned.fill(
                  top: -_over,
                  child: ClipPath(
                    clipper: _BrushClip(seed, !left, overTop: _over),
                    child: Stack(
                      children: [Positioned(left: side, right: other, top: 0, bottom: 0, width: figW, child: figure)],
                    ),
                  ),
                ),
                Positioned(
                  left: left ? 14 : null,
                  right: left ? null : 14,
                  bottom: -8,
                  child: _NameTag(
                    label: thought ? '${who.displayName} · ${tr('story.thinks')}' : who.displayName,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Cartelito con el nombre de quien habla, en el color de su bando.
class _NameTag extends StatelessWidget {
  final String label;
  final Color color;
  const _NameTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.03,
    child: Container(
      padding: const EdgeInsets.fromLTRB(9, 3, 9, 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: _ink, width: 1.5),
        boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.35), offset: const Offset(2, 2))],
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: Colors.white),
      ),
    ),
  );
}

/// Globo de cómic: papel con borde de tinta y la cola hacia quien habla. El
/// pensamiento es más redondo y suelta burbujitas en vez de cola.
class _Balloon extends StatelessWidget {
  final String? text;
  final bool left;
  final bool thought;
  const _Balloon({this.text, required this.left, this.thought = false});

  @override
  Widget build(BuildContext context) {
    final body = Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(thought ? 28 : 18),
        border: Border.all(color: _ink, width: thought ? 1.5 : 2),
      ),
      child: text == null
          ? const _Dots(color: _ink)
          : Text.rich(
              storySpans(
                text!,
                TextStyle(
                  fontSize: 15.5,
                  height: 1.35,
                  color: _ink,
                  fontStyle: thought ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
    );
    Widget bubble(double d) => Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: _paper,
        shape: BoxShape.circle,
        border: Border.all(color: _ink, width: 1.4),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        body,
        if (thought) ...[
          Positioned(left: left ? -12 : null, right: left ? null : -12, bottom: 2, child: bubble(10)),
          Positioned(left: left ? -22 : null, right: left ? null : -22, bottom: -6, child: bubble(6)),
        ] else
          Positioned(
            left: left ? -15 : null,
            right: left ? null : -15,
            bottom: 10,
            child: CustomPaint(size: const Size(18, 18), painter: _Tail(left)),
          ),
      ],
    );
  }
}

/// Cola del globo: tapa el borde y apunta hacia abajo, al personaje.
class _Tail extends CustomPainter {
  final bool left;
  _Tail(this.left);

  @override
  void paint(Canvas canvas, Size s) {
    if (!left) {
      canvas.translate(s.width, 0);
      canvas.scale(-1, 1);
    }
    final edge = s.width + 3;
    final fill = Path()
      ..moveTo(edge, 1)
      ..lineTo(0, s.height)
      ..lineTo(edge, 11)
      ..close();
    canvas.drawPath(fill, Paint()..color = _paper);
    canvas.drawPath(
      Path()
        ..moveTo(s.width + 1, 1)
        ..lineTo(0, s.height)
        ..lineTo(s.width + 1, 11),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Tail old) => old.left != left;
}

/// Tres puntos que laten: alguien está escribiendo.
class _Dots extends StatefulWidget {
  final Color? color;
  const _Dots({this.color});

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (widget.color ?? t.textMuted).withValues(alpha: 0.35 + 0.65 * _pulse((_c.value - i * 0.18) % 1)),
              ),
            ),
        ],
      ),
    );
  }

  static double _pulse(double x) => x < 0.5 ? x * 2 : (1 - x) * 2;
}

/// Texto del guion con **negrita** y *cursiva* (acotaciones, *hip*).
TextSpan storySpans(String text, TextStyle base) {
  final spans = <TextSpan>[];
  final re = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
  var at = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
    if (m.group(1) != null) {
      spans.add(
        TextSpan(
          text: m.group(1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: m.group(2),
          style: TextStyle(fontStyle: FontStyle.italic, color: base.color?.withValues(alpha: 0.7)),
        ),
      );
    }
    at = m.end;
  }
  if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
  return TextSpan(style: base, children: spans);
}
