import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import '../ui/fx/sfx.dart';
import '../ui/theme/hex_theme.dart';
import '../ui/theme/settings.dart';
import '../ui/theme/ui_style.dart';
import '../ui/widgets/avatar_face.dart';
import '../ui/widgets/skin_kit.dart';
import 'director.dart';
import 'script.dart';

/// Muestra una viñeta a pantalla completa y la marca como vista al cerrarla.
/// [mine]: bandos que van a la izquierda (el tuyo). Con [replay] se relee
/// desde el Pergamino (sin la ayuda de "tocá para seguir").
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

/// La viñeta como un libro de tinta: cada toque es un golpe (la cámara recorre
/// el lugar, alguien entra, dice algo, se va) y cada momento da vuelta la
/// página. Lo que tiene texto espera un toque (el sello de abajo avisa); los
/// golpes mudos siguen solos al terminar. Mantener apretado lee de corrido.
class StoryScreen extends StatefulWidget {
  final Scene scene;
  final Set<Faction> mine;
  final String? title;
  final bool replay;

  /// Golpe desde el que arranca (para probar una escena a mitad).
  final int start;
  const StoryScreen({
    super.key,
    required this.scene,
    required this.mine,
    this.title,
    this.replay = false,
    this.start = 0,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with TickerProviderStateMixin {
  late final Who _hero = widget.mine.contains(Faction.shaolin) ? Who.ren : Who.aya;
  late final List<Frame> _frames = Director.run(widget.scene, hero: _hero);

  /// El golpe de cada toque (0..1): cámara, entradas, globos y efectos.
  late final AnimationController _beat = AnimationController(vsync: this)..addStatusListener(_settled);

  /// Vuelta de página entre momentos.
  late final AnimationController _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));

  /// Respiración de la cámara cuando nada se mueve.
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 16))
    ..repeat();

  int _at = -1;
  bool _auto = false;
  Timer? _autoTimer;

  /// El golpe terminó de entrar y espera un toque: aparece el sello para seguir
  /// (un golpe mudo que no es el último sigue solo).
  bool get _ready => _at >= 0 && !_beat.isAnimating && !_turn.isAnimating && (_last || widget.scene.beats[_at].hasText);
  bool get _last => _at == _frames.length - 1;
  bool get _done => _last && _ready;
  Frame get _frame => _frames[_at];
  Frame? get _prev => _at > 0 ? _frames[_at - 1] : null;

  @override
  void initState() {
    super.initState();
    StoryArt.load().then((_) {
      if (mounted) Future.delayed(const Duration(milliseconds: 250), () => _play(widget.start));
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _beat.dispose();
    _turn.dispose();
    _idle.dispose();
    super.dispose();
  }

  Duration _length(Frame f) {
    final b = widget.scene.beats[f.beat];
    final moves = f.from != f.shot;
    final opens = f.sheet.isNotEmpty && f.sheet.last.opened == f.beat;
    final ms = f.panels
        ? (opens && f.sheet.last.frame.slow
              ? 2200
              : f.fx.contains(Fx.flash) || f.fx.contains(Fx.smoke)
              ? 1100
              : opens
              ? 800
              : 600)
        : f.slow
        ? 2600
        : f.fx.contains(Fx.flash) || f.fx.contains(Fx.smoke) || f.leaving.isNotEmpty || moves
        ? 1100
        : b.kind == BeatKind.pause
        ? 900
        : 650;
    return Duration(milliseconds: _auto ? ms ~/ 2 : ms);
  }

  Future<void> _play(int i) async {
    if (!mounted || i >= _frames.length) return;
    setState(() => _at = i);
    final f = _frames[i];
    final turning = i > 0 && f.newPageFrom(_prev);
    _beat
      ..duration = _length(f)
      ..value = 0;
    if (turning) {
      SoundBoard.instance.play(Sfx.turn, volume: 0.6);
      await _turn.forward(from: 0);
      if (!mounted || _at != i) return;
    }
    _cue(f);
    _beat.forward(from: 0);
  }

  /// El sonido del golpe.
  void _cue(Frame f) {
    final b = widget.scene.beats[f.beat];
    final sfx = f.fx.contains(Fx.pulse)
        ? Sfx.heartbeat
        : f.onom != null || f.fx.contains(Fx.shake)
        ? Sfx.stamp
        : f.cast.any((a) => a.since == f.beat && a.style == 'humo') || f.leaving.values.contains('humo')
        ? Sfx.frost
        : b.kind == BeatKind.moment
        ? null
        : b.hasText
        ? Sfx.tick
        : null;
    if (sfx != null) SoundBoard.instance.play(sfx, volume: 0.5);
    if (f.fx.contains(Fx.shake)) Haptics.medium();
    if (f.fx.contains(Fx.pulse)) Haptics.light();
  }

  void _settled(AnimationStatus s) {
    if (s != AnimationStatus.completed || !mounted) return;
    setState(() {});
    // Un golpe mudo no tiene nada que leer: terminado el movimiento, sigue solo.
    if (!_done && !widget.scene.beats[_at].hasText) {
      _autoTimer = Timer(const Duration(milliseconds: 120), () => _next(felt: false));
      return;
    }
    if (_auto && !_done) {
      final b = widget.scene.beats[_at];
      final len = b.hasText ? widget.scene.text(_at).length : 0;
      _autoTimer = Timer(Duration(milliseconds: 500 + len * 25), _next);
    }
  }

  /// Tocar: si el golpe todavía entra, lo completa; si no, el siguiente.
  void _tap() {
    if (_at < 0) return;
    if (_turn.isAnimating || _beat.isAnimating) {
      if (_turn.isAnimating) {
        _turn.value = 1;
        _cue(_frame);
      }
      _beat.value = 1;
      setState(() {});
      return;
    }
    _next();
  }

  void _next({bool felt = true}) {
    _autoTimer?.cancel();
    if (_at >= _frames.length - 1) return;
    if (felt) Haptics.select();
    _play(_at + 1);
  }

  void _close() {
    _autoTimer?.cancel();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    return Scaffold(
      backgroundColor: _night,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: skin.display(20, color: _paper.withValues(alpha: 0.9)),
                    ),
                  ),
                  // Altura fija: el título no salta cuando se va "Saltar".
                  SizedBox(
                    height: 44,
                    child: _done ? null : SkinLink(label: tr('story.skip'), onPressed: _close, color: _paper),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _tap,
                onLongPressStart: (_) {
                  _auto = true;
                  _tap();
                },
                onLongPressEnd: (_) => _auto = false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: _at < 0 ? const SizedBox.expand() : _book(),
                ),
              ),
            ),
            SizedBox(
              height: 74,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _done
                      ? SkinPrimaryButton(
                          key: const ValueKey('go'),
                          label: tr('story.continue'),
                          color: t.gold,
                          onPressed: _close,
                        )
                      : Center(
                          key: const ValueKey('hint'),
                          child: Text(
                            widget.replay || _at > 3 ? '' : tr('story.hint'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: _paper.withValues(alpha: 0.55)),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// La hoja actual y, mientras se da vuelta, la anterior encima.
  Widget _book() {
    return AnimatedBuilder(
      animation: Listenable.merge([_beat, _turn, _idle]),
      builder: (context, _) {
        final f = _frame;
        final turning = _turn.isAnimating && f.newPageFrom(_prev);
        return Stack(
          fit: StackFit.expand,
          children: [
            _Sheet(
              scene: widget.scene,
              frame: f,
              prev: turning ? null : _prev,
              t: turning ? 0 : Curves.linear.transform(_beat.value),
              idle: _idle.value,
              hero: _hero,
              ready: _ready,
              done: _done,
            ),
            if (turning) _PageTurn(v: _turn.value, child: _sheetOf(_prev!)),
          ],
        );
      },
    );
  }

  Widget _sheetOf(Frame f) {
    final i = _frames.indexOf(f);
    return _Sheet(
      scene: widget.scene,
      frame: f,
      prev: i > 0 ? _frames[i - 1] : null,
      t: 1,
      idle: _idle.value,
      hero: _hero,
      ready: false,
      done: false,
    );
  }
}

/// La hoja que se da vuelta: gira sobre el lomo izquierdo y se oscurece; la
/// de abajo recibe su sombra.
class _PageTurn extends StatelessWidget {
  final double v;
  final Widget child;
  const _PageTurn({required this.v, required this.child});

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeInOutCubic.transform(v);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Sombra sobre la hoja nueva, que se va aclarando.
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _ink.withValues(alpha: 0.55 * (1 - e)),
                  _ink.withValues(alpha: 0),
                ],
                stops: [0, 0.3 + 0.7 * (1 - e)],
              ),
            ),
          ),
        ),
        if (e < 0.98)
          Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateY(-pi * 0.55 * e),
            child: Stack(
              fit: StackFit.expand,
              children: [
                child,
                // La hoja se oscurece al levantarse.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _ink.withValues(alpha: 0.05 * e),
                          _ink.withValues(alpha: 0.7 * e),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Una hoja del libro: el cuadro grande con su borde de tinta y, abajo, el
/// número de página y el sello para seguir.
class _Sheet extends StatelessWidget {
  final Scene scene;
  final Frame frame;
  final Frame? prev;
  final double t, idle;
  final Who hero;
  final bool ready, done;
  const _Sheet({
    required this.scene,
    required this.frame,
    required this.prev,
    required this.t,
    required this.idle,
    required this.hero,
    required this.ready,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final seed = scene.id.hashCode ^ frame.page * 7919;
    return Container(
      decoration: BoxDecoration(
        color: _paper,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          Expanded(
            child: frame.panels
                ? _PanelPage(scene: scene, frame: frame, t: t, idle: idle, hero: hero)
                : CustomPaint(
                    painter: _FrameInk(seed, shadow: true),
                    foregroundPainter: _FrameInk(seed),
                    child: ClipPath(
                      clipper: _FrameClip(seed),
                      child: _Stage(scene: scene, frame: frame, prev: prev, t: t, idle: idle, hero: hero),
                    ),
                  ),
          ),
          SizedBox(
            height: 34,
            child: Row(
              children: [
                const SizedBox(width: 30),
                Expanded(
                  child: Text(
                    '— ${frame.page + 1} —',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, letterSpacing: 2, color: _ink.withValues(alpha: 0.45)),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: _TapSeal(visible: ready && !done, idle: idle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Página de viñetas: las filas quedan marcadas desde el principio (papel en
/// blanco) y cada toque suma la viñeta siguiente con su entrada.
class _PanelPage extends StatelessWidget {
  final Scene scene;
  final Frame frame;
  final double t, idle;
  final Who hero;
  const _PanelPage({required this.scene, required this.frame, required this.t, required this.idle, required this.hero});

  static const gutter = 9.0;

  @override
  Widget build(BuildContext context) {
    final rows = frame.rows;
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: gutter),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < rows[r]; c++) ...[
                  if (c > 0) const SizedBox(width: gutter),
                  Expanded(child: _slot(r, c)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _slot(int r, int c) {
    final p = frame.sheet.where((p) => p.row == r && p.col == c).firstOrNull;
    if (p == null) return const SizedBox.expand();
    final seed = scene.id.hashCode ^ p.opened * 7919;
    final panel = CustomPaint(
      painter: _FrameInk(seed, shadow: true),
      foregroundPainter: _FrameInk(seed),
      child: ClipPath(
        clipper: _FrameClip(seed),
        child: _Stage(
          scene: scene,
          frame: p.frame,
          prev: null,
          t: p.frame.beat == frame.beat ? t : 1,
          idle: idle,
          hero: hero,
        ),
      ),
    );
    if (p.opened != frame.beat) return panel;
    return _PanelEntry(v: t, frame: p.frame, child: panel);
  }
}

/// Cómo entra una viñeta: el lugar se descubre de un trazo (barrido), el
/// primer plano llega desde el lado de quien habla y el grupo se acerca.
class _PanelEntry extends StatelessWidget {
  final double v;
  final Frame frame;
  final Widget child;
  const _PanelEntry({required this.v, required this.frame, required this.child});

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeOutCubic.transform((v * 1.5).clamp(0.0, 1.0));
    if (e >= 1) return child;
    final fade = (v * 3).clamp(0.0, 1.0);
    if (frame.closeUp) {
      final side = (frame.cast.firstOrNull?.x ?? 0.5) <= 0.5 ? -1 : 1;
      return Opacity(
        opacity: fade,
        child: Transform.translate(offset: Offset(side * 36 * (1 - e), 0), child: child),
      );
    }
    if (frame.cast.isEmpty) {
      return ClipRect(
        clipper: _Wipe(e),
        child: Opacity(opacity: fade, child: child),
      );
    }
    return Opacity(
      opacity: fade,
      child: Transform.scale(scale: 0.9 + 0.1 * e, child: child),
    );
  }
}

/// Barrido de izquierda a derecha, con el borde un poco por delante de la tinta.
class _Wipe extends CustomClipper<Rect> {
  final double e;
  _Wipe(this.e);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(-8, -8, (size.width + 16) * e, size.height + 16);

  @override
  bool shouldReclip(_Wipe old) => old.e != e;
}

/// Sello de tinta que late: "tocá para seguir".
class _TapSeal extends StatelessWidget {
  final bool visible;
  final double idle;
  const _TapSeal({required this.visible, required this.idle});

  @override
  Widget build(BuildContext context) {
    final beat = 0.5 + 0.5 * sin(idle * 2 * pi * 12);
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: Duration(milliseconds: visible ? 350 : 80),
      child: Transform.translate(
        offset: Offset(0, 2.5 * beat),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _seal.withValues(alpha: 0.75 + 0.25 * beat),
          ),
          child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _paper),
        ),
      ),
    );
  }
}

/// El cuadro: el fondo con la cámara, los personajes, los efectos y los textos.
class _Stage extends StatelessWidget {
  final Scene scene;
  final Frame frame;
  final Frame? prev;
  final double t, idle;
  final Who hero;
  const _Stage({
    required this.scene,
    required this.frame,
    required this.prev,
    required this.t,
    required this.idle,
    required this.hero,
  });

  @override
  Widget build(BuildContext context) {
    final f = frame;
    final camT = (f.slow ? Curves.easeInOutSine : Curves.easeOutCubic).transform(t);
    final drift = idle * 2 * pi;
    // Un respiro leve de la cámara mientras nadie toca.
    Shot sway(Shot s) => Shot(
      s.x + 0.004 * sin(drift),
      s.y + 0.003 * sin(drift * 2),
      s.zoom + 0.006 * (1 + sin(drift + 1)),
      s.span,
    );
    final cam = (from: sway(f.from), to: sway(f.shot), t: camT);
    final shake = f.fx.contains(Fx.shake) ? Offset(sin(t * 46) * 9 * (1 - t), cos(t * 39) * 5 * (1 - t)) : Offset.zero;
    final sameArt = prev != null && prev!.page == f.page && prev!.art == f.art && prev!.place == f.place;
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        return Transform.translate(
          offset: shake,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              if (!sameArt && prev != null && prev!.page == f.page)
                _Backdrop(art: prev!.art, place: prev!.place, cam: cam, size: size),
              Opacity(
                opacity: sameArt || prev == null || prev!.page != f.page ? 1 : Curves.easeOut.transform(t),
                child: _Backdrop(art: f.art, place: f.place, cam: cam, size: size),
              ),
              if (f.fx.contains(Fx.dark) || f.place.night) _Vignette(strength: f.fx.contains(Fx.dark) ? 0.85 : 0.5),
              if (f.fx.contains(Fx.fog)) _Fog(idle: idle),
              if (f.art == null) ..._cast(size),
              if (f.fx.contains(Fx.smoke)) _Smoke(t: t, at: _smokeAt(size), size: size),
              for (final a in f.cast)
                if (a.since == f.beat && a.style == 'humo' && f.art == null)
                  _Smoke(t: t, at: Offset(a.x * size.width, size.height * 0.72), size: size, small: true),
              if (prev != null && prev!.page == f.page)
                for (final MapEntry(key: who, value: style) in f.leaving.entries)
                  if (style == 'humo' && prev!.actor(who) != null)
                    _Smoke(
                      t: t,
                      at: Offset(prev!.actor(who)!.x * size.width, size.height * 0.72),
                      size: size,
                      small: true,
                    ),
              if (f.fx.contains(Fx.pulse)) _Pulse(t: t),
              if (f.fx.contains(Fx.flash))
                IgnorePointer(
                  child: ColoredBox(color: Colors.white.withValues(alpha: 0.9 * pow(1 - t, 2))),
                ),
              if (f.onom != null) _Onom(text: tr('onom.${f.onom}'), t: t),
              ..._texts(context, size),
            ],
          ),
        );
      },
    );
  }

  Offset _smokeAt(Size s) => Offset(s.width * 0.5, s.height * 0.55);

  double _enter(Actor a) => a.since == frame.beat && a.style != 'ya' ? Curves.easeOutCubic.transform(t) : 1;

  /// Los personajes parados abajo; quien no habla, un poco en sombra.
  List<Widget> _cast(Size size) {
    final f = frame;
    final (w, h) = _figureSize(size);
    Widget figure(Actor a, double v, {bool leaving = false}) {
      final style = leaving ? f.leaving[a.who] : a.style;
      final dx = switch (style) {
        'humo' || 'sombra' => 0.0,
        'corre' => (a.x < 0.5 ? -1 : 1) * size.width * 0.5,
        _ => (a.x < 0.5 ? -1 : 1) * size.width * 0.12,
      };
      final talking = f.speaker == a.who;
      final dim = f.speaker != null && !talking;
      Widget body = _Figure(who: a.who, faceLeft: a.x > 0.5, width: w, height: h);
      if (dim) {
        body = ColorFiltered(colorFilter: const ColorFilter.matrix(_shade), child: body);
      }
      if (style == 'sombra' && v < 1) {
        body = ColorFiltered(
          colorFilter: ColorFilter.mode(_ink.withValues(alpha: 1 - v), BlendMode.srcATop),
          child: body,
        );
      }
      if (style == 'humo' && v < 1) {
        body = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10 * (1 - v), sigmaY: 10 * (1 - v)),
          child: body,
        );
      }
      return Positioned(
        left: a.x * size.width - w / 2 + dx * (1 - v),
        bottom: f.closeUp ? -h * (size.width < size.height * 1.2 ? 0.46 : 0.4) : -h * 0.03,
        width: w,
        height: h,
        child: Opacity(
          opacity: style == 'sombra' ? v.clamp(0.0, 1.0) : (v * 1.6).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (talking ? 1.035 : 1) * (style == 'humo' ? 0.9 + 0.1 * v : 1),
            alignment: Alignment.bottomCenter,
            child: body,
          ),
        ),
      );
    }

    return [
      if (prev != null && prev!.page == f.page)
        for (final who in f.leaving.keys)
          if (prev!.actor(who) case final a?) figure(a, 1 - Curves.easeInCubic.transform(t), leaving: true),
      for (final a in [...f.cast]..sort((a, b) => (a.who == f.speaker ? 1 : 0) - (b.who == f.speaker ? 1 : 0)))
        figure(a, _enter(a)),
    ];
  }

  /// Medio cuerpo: alto según el cuadro; con más gente, más chicos (se
  /// superponen apenas, como en una viñeta).
  (double, double) _figureSize(Size size) {
    final f = frame;
    if (f.closeUp) {
      // Primer plano: más grande que la viñeta, recortado abajo.
      final h = size.height * (size.width < size.height * 1.2 ? 1.25 : 1.5);
      return (h / 1.5, h);
    }
    final crowd = f.cast.length + (prev?.page == f.page ? f.leaving.length : 0);
    final w = min(size.height * 0.6 * 2 / 3, size.width * (crowd > 2 ? 0.44 : (crowd > 1 ? 0.58 : 0.64)));
    return (w, w * 1.5);
  }

  /// Arriba, el cartel (momento o narración); los globos, sobre las cabezas.
  List<Widget> _texts(BuildContext context, Size size) {
    final f = frame;
    final cap = f.caption;
    final moment = cap != null && scene.beats[cap].kind == BeatKind.moment;
    Widget pop(int beat, Widget child, Alignment origin) {
      if (beat != f.beat) return child;
      final v = Curves.easeOutBack.transform((t * 1.6).clamp(0.0, 1.0));
      return Opacity(
        opacity: (t * 2.5).clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * v, alignment: origin, child: child),
      );
    }

    final figures = f.art == null && f.cast.isNotEmpty;
    if (f.closeUp) {
      final a = f.cast.first;
      final b = scene.beats[f.lines.first];
      final side = (a.x - 0.5).abs() < 0.1 ? 0.0 : (a.x < 0.5 ? -1.0 : 1.0);
      return [
        Positioned(
          top: 4,
          left: side < 0 ? size.width * 0.4 : 8,
          right: side > 0 ? size.width * 0.4 : 8,
          child: Align(
            alignment: side < 0 ? Alignment.topRight : (side > 0 ? Alignment.topLeft : Alignment.topCenter),
            child: pop(
              f.lines.first,
              _Balloon(
                text: scene.text(f.lines.first),
                who: b.who!,
                left: side >= 0,
                tail: side,
                thought: b.kind == BeatKind.think,
              ),
              side < 0 ? Alignment.bottomLeft : Alignment.bottomRight,
            ),
          ),
        ),
      ];
    }
    return [
      if (cap != null)
        Positioned(
          left: 10,
          right: 10,
          top: 10,
          child: Align(
            alignment: Alignment.topLeft,
            child: pop(
              cap,
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.width * 0.86),
                child: Transform.rotate(
                  angle: -0.012,
                  child: _CaptionBox(
                    child: Text.rich(
                      storySpans(
                        scene.text(cap),
                        moment
                            ? Skin.of(context).display(17, color: _ink, height: 1.2)
                            : const TextStyle(fontSize: 14.5, height: 1.38, fontStyle: FontStyle.italic, color: _ink),
                      ),
                    ),
                  ),
                ),
              ),
              Alignment.topLeft,
            ),
          ),
        ),
      Positioned(
        left: 10,
        right: 10,
        bottom: figures ? _figureSize(size).$2 * 0.86 : size.height * 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in f.lines) ...[const SizedBox(height: 14), _balloon(i, size, pop)],
          ],
        ),
      ),
    ];
  }

  Widget _balloon(int i, Size size, Widget Function(int, Widget, Alignment) pop) {
    final f = frame;
    final b = scene.beats[i];
    final a = f.actor(b.who!);
    // Sin figura (sobre una ilustración o fuera de cuadro), el globo no tiene cola.
    final tail = a == null
        ? null
        : (a.x - 0.5).abs() < 0.1
        ? 0.0
        : a.x < 0.5
        ? -1.0
        : 1.0;
    final left = a == null ? b.who == hero || (b.who!.side != null && b.who!.side == hero.side) : a.x <= 0.5;
    final balloon = _Balloon(
      text: scene.text(i),
      who: b.who!,
      left: left,
      tail: tail,
      thought: b.kind == BeatKind.think,
    );
    return Align(
      alignment: tail == 0 ? Alignment.center : (left ? Alignment.centerLeft : Alignment.centerRight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * 0.8),
        child: pop(i, balloon, left ? Alignment.bottomLeft : Alignment.bottomRight),
      ),
    );
  }
}

/// El fondo (o la ilustración) encuadrado por la cámara.
class _Backdrop extends StatelessWidget {
  final String? art;
  final Place place;

  /// La cámara va de `from` a `to`; `t` es cuánto avanzó.
  final ({Shot from, Shot to, double t}) cam;
  final Size size;
  const _Backdrop({required this.art, required this.place, required this.cam, required this.size});

  /// Todo el arte de las viñetas es 3:2.
  static const aspect = 1.5;

  /// Dónde queda el arte en el cuadro con el encuadre [s]: el punto de [s] al
  /// centro, sin dejar ver los bordes del arte salvo que [Shot.span] lo achique
  /// para que entre lo pedido; entonces queda centrado.
  static Rect frame(Shot s, Size size) {
    final base = max(size.width / aspect, size.height);
    var h = base * max(s.zoom, 1.0), w = h * aspect;
    if (s.span > 0 && w * s.span > size.width) {
      w = size.width / s.span;
      h = w / aspect;
    }
    final left = w <= size.width ? (size.width - w) / 2 : (size.width / 2 - s.x * w).clamp(size.width - w, 0.0);
    final top = h <= size.height ? (size.height - h) / 2 : (size.height / 2 - s.y * h).clamp(size.height - h, 0.0);
    return Rect.fromLTWH(left, top, w, h);
  }

  /// Los bordes de arriba y abajo se funden con el relleno difuso, más cuanto más sobra.
  static Widget _fadeEdges(Widget child, double gap) {
    final edge = 0.08 * min(1.0, gap * 4);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0x00000000), Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
        stops: [0, edge, 1 - edge, 1],
      ).createShader(r),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = art != null && StoryArt.has('assets/story/$art.webp') ? 'assets/story/$art.webp' : place.asset;
    final r = Rect.lerp(frame(cam.from, size), frame(cam.to, size), cam.t)!;
    final has = StoryArt.has(asset);
    final gap = ((size.height - r.height) / size.height).clamp(0.0, 1.0);
    final child = has
        ? Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium, gaplessPlayback: true)
        : CustomPaint(
            painter: _InkLandscape(place, (cam.from.x + (cam.to.x - cam.from.x) * cam.t - 0.5) * 2),
            child: Center(
              child: Text(place.glyph, style: Skin.of(context).glyph(96, color: Colors.white.withValues(alpha: 0.09))),
            ),
          );
    return Stack(
      fit: StackFit.expand,
      children: [
        // Si el arte se achicó para que entren todos, lo que sobra del alto es
        // el mismo arte, difuso y en penumbra.
        if (has && gap > 0.001) ...[
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22, tileMode: TileMode.mirror),
            child: Image.asset(asset, fit: BoxFit.cover, filterQuality: FilterQuality.low, gaplessPlayback: true),
          ),
          ColoredBox(color: _ink.withValues(alpha: 0.45)),
        ],
        Positioned.fromRect(rect: r, child: gap > 0 ? _fadeEdges(child, gap) : child),
      ],
    );
  }
}

/// Un personaje de cuerpo entero (o su retrato, si falta el arte), mirando
/// hacia el centro.
class _Figure extends StatelessWidget {
  /// Figuras cuyo dibujo toca el borde izquierdo o derecho (ver bloque D de docs/prompts.md).
  static const _cut = <Who, (bool, bool)>{
    Who.gon: (true, true),
    Who.abbot: (true, true),
    Who.tao: (true, true),
    Who.kage: (true, true),
    Who.oni: (true, true),
    Who.guard: (true, true),
    Who.fox: (true, false),
    Who.jubei: (false, true),
    Who.ninja: (false, true),
    Who.kunoichi: (false, true),
  };

  final Who who;
  final bool faceLeft;
  final double width, height;
  const _Figure({required this.who, required this.faceLeft, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final art = Scene.figureAsset(who);
    if (StoryArt.has(art)) {
      final image = Image.asset(
        art,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      );
      // Si el dibujo llega al borde (un brazo, el bastón), ese costado se
      // disuelve en tinta en vez de terminar en un corte recto.
      final (cutLeft, cutRight) = _cut[who] ?? (false, false);
      // Las figuras miran a la derecha: las del lado derecho se espejan.
      return Transform.flip(
        flipX: faceLeft,
        child: !cutLeft && !cutRight
            ? image
            : ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => LinearGradient(
                  colors: [
                    Color(cutLeft ? 0x00000000 : 0xFF000000),
                    const Color(0xFF000000),
                    const Color(0xFF000000),
                    Color(cutRight ? 0x00000000 : 0xFF000000),
                  ],
                  stops: const [0, 0.1, 0.9, 1],
                ).createShader(r),
                child: image,
              ),
      );
    }
    final t = HexTheme.of(context);
    return Align(
      alignment: const Alignment(0, 0.6),
      child: AvatarFace(
        avatar: who.avatar,
        size: width * 0.62,
        color: who.side == null ? t.gold : HexTheme.faction(who.side!),
        borderColor: _ink,
        borderWidth: 2.5,
        shadow: [BoxShadow(color: _ink.withValues(alpha: 0.4), offset: const Offset(2, 3))],
      ),
    );
  }
}

/// Noche: los bordes del cuadro se cierran en tinta.
class _Vignette extends StatelessWidget {
  final double strength;
  const _Vignette({required this.strength});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.95,
          colors: [
            Colors.transparent,
            _ink.withValues(alpha: strength),
          ],
          stops: const [0.45, 1],
        ),
      ),
    ),
  );
}

/// Niebla que pasa despacio delante del lugar.
class _Fog extends StatelessWidget {
  final double idle;
  const _Fog({required this.idle});

  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _FogPainter(idle)));
}

class _FogPainter extends CustomPainter {
  final double idle;
  _FogPainter(this.idle);

  @override
  void paint(Canvas canvas, Size size) {
    for (var k = 0; k < 4; k++) {
      final u = (idle * (1 + k * 0.4) + k * 0.27) % 1;
      final c = Offset(size.width * (1.3 - 1.6 * u), size.height * (0.45 + 0.13 * k));
      canvas.drawOval(
        Rect.fromCenter(center: c, width: size.width * 1.1, height: size.height * 0.16),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
      );
    }
  }

  @override
  bool shouldRepaint(_FogPainter old) => old.idle != idle;
}

/// Bocanada de humo que se abre y se disipa.
class _Smoke extends StatelessWidget {
  final double t;
  final Offset at;
  final Size size;
  final bool small;
  const _Smoke({required this.t, required this.at, required this.size, this.small = false});

  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _SmokePainter(t, at, small)));
}

class _SmokePainter extends CustomPainter {
  final double t;
  final Offset at;
  final bool small;
  _SmokePainter(this.t, this.at, this.small);

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final r = Random(7);
    final reach = size.width * (small ? 0.22 : 0.55);
    final fade = t < 0.25 ? t / 0.25 : 1 - (t - 0.25) / 0.75;
    for (var k = 0; k < 11; k++) {
      final a = r.nextDouble() * 2 * pi;
      final d = reach * (0.2 + 0.8 * r.nextDouble()) * Curves.easeOutCubic.transform(t);
      final rad = reach * (0.25 + 0.25 * r.nextDouble()) * (0.5 + t);
      canvas.drawCircle(
        at + Offset(cos(a) * d, sin(a) * d * 0.6 - t * reach * 0.3),
        rad,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFE8E2D6),
            const Color(0xFF8A847A),
            r.nextDouble(),
          )!.withValues(alpha: 0.75 * fade)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, rad * 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_SmokePainter old) => old.t != t;
}

/// Latido: el cuadro se cierra en rojo oscuro dos veces.
class _Pulse extends StatelessWidget {
  final double t;
  const _Pulse({required this.t});

  @override
  Widget build(BuildContext context) {
    final p = max(0.0, sin(t * pi * 2)) * (1 - t * 0.5);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.9,
            colors: [
              Colors.transparent,
              const Color(0xFF5A0F0A).withValues(alpha: 0.75 * p),
            ],
            stops: const [0.35, 1],
          ),
        ),
      ),
    );
  }
}

/// Onomatopeya de tinta: cae grande sobre el cuadro y se asienta.
class _Onom extends StatelessWidget {
  final String text;
  final double t;
  const _Onom({required this.text, required this.t});

  @override
  Widget build(BuildContext context) {
    final v = Curves.easeOutBack.transform((t * 2.2).clamp(0.0, 1.0));
    final style = Skin.of(context).display(54, height: 1);
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0.3, -0.55),
        child: Opacity(
          opacity: (t * 4).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: -0.16,
            child: Transform.scale(
              scale: 1.8 - 0.8 * v,
              child: Stack(
                children: [
                  Text(
                    text,
                    style: style.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 9
                        ..strokeJoin = StrokeJoin.round
                        ..color = _ink,
                    ),
                  ),
                  Text(text, style: style.copyWith(color: _paper)),
                ],
              ),
            ),
          ),
        ),
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
const _night = Color(0xFF15120E);
const _seal = Color(0xFFB0302A);

/// Quien no habla queda en penumbra: más oscuro y algo desaturado.
const _shade = <double>[
  0.5, 0.1, 0.02, 0, 0, //
  0.06, 0.52, 0.04, 0, 0, //
  0.06, 0.1, 0.46, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Contorno del cuadro con el pulso de un trazo a mano: cada borde tiembla
/// apenas. [inset] lo achica (negativo, lo agranda).
Path _framePath(Size s, int seed, double inset) {
  final r = Random(seed);
  final pts = [
    Offset(inset, inset),
    Offset(s.width - inset, inset),
    Offset(s.width - inset, s.height - inset),
    Offset(inset, s.height - inset),
  ];
  final p = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var e = 0; e < 4; e++) {
    final a = pts[e], b = pts[(e + 1) % 4];
    final d = b - a;
    final n = Offset(-d.dy, d.dx) / d.distance;
    final phase = r.nextDouble() * 2 * pi, freq = 2 + r.nextDouble() * 3;
    const steps = 20;
    for (var k = 1; k <= steps; k++) {
      final t = k / steps;
      p.lineTo(
        a.dx + d.dx * t + n.dx * 1.6 * sin(t * pi) * sin(t * pi * freq + phase),
        a.dy + d.dy * t + n.dy * 1.6 * sin(t * pi) * sin(t * pi * freq + phase),
      );
    }
  }
  return p..close();
}

class _FrameClip extends CustomClipper<Path> {
  final int seed;
  _FrameClip(this.seed);

  @override
  Path getClip(Size size) => _framePath(size, seed + 1, 2);

  @override
  bool shouldReclip(_FrameClip old) => old.seed != seed;
}

/// Tinta del cuadro: detrás, la sombra dura; delante, el borde de grosor
/// desparejo (dos contornos que tiemblan distinto).
class _FrameInk extends CustomPainter {
  final int seed;
  final bool shadow;
  _FrameInk(this.seed, {this.shadow = false});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _framePath(size, seed, -1);
    if (shadow) {
      canvas.drawPath(outer.shift(const Offset(3, 4)), Paint()..color = _ink.withValues(alpha: 0.3));
      return;
    }
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, _framePath(size, seed + 1, 2)),
      Paint()..color = _ink,
    );
  }

  @override
  bool shouldRepaint(_FrameInk old) => old.seed != seed;
}

/// Paisaje de tinta provisorio: cielo en degradé y tres capas de colinas que
/// se corren con el encuadre.
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

/// Globo de cómic con el nombre de quien habla en la solapa: papel con borde
/// de tinta y la cola hacia abajo, de su lado. El pensamiento es más redondo
/// y suelta burbujitas en vez de cola.
class _Balloon extends StatelessWidget {
  final String text;
  final Who who;
  final bool left;

  /// Hacia dónde apunta la cola: -1 izquierda, 0 centro, 1 derecha, null sin cola.
  final double? tail;
  final bool thought;
  const _Balloon({required this.text, required this.who, required this.left, this.tail, this.thought = false});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = who.side == null ? t.gold : HexTheme.faction(who.side!);
    final body = Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(thought ? 26 : 16),
        border: Border.all(color: _ink, width: thought ? 1.5 : 2),
        boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.25), offset: const Offset(2, 3))],
      ),
      child: Text.rich(
        storySpans(
          text,
          TextStyle(fontSize: 15.5, height: 1.3, color: _ink, fontStyle: thought ? FontStyle.italic : FontStyle.normal),
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
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          body,
          Positioned(
            left: left ? 12 : null,
            right: left ? null : 12,
            top: -11,
            child: _NameTag(label: who.displayName, color: color),
          ),
          if (tail != null && thought) ...[
            Positioned.fill(
              bottom: -21,
              child: Align(
                alignment: Alignment(tail! * 0.85, 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [bubble(10), const SizedBox(height: 2), bubble(6)],
                ),
              ),
            ),
          ] else if (tail != null)
            Positioned.fill(
              bottom: -13,
              child: Align(
                alignment: Alignment(tail! * 0.85, 1),
                child: CustomPaint(size: const Size(16, 14), painter: _Tail(tail! <= 0)),
              ),
            ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 3),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: _ink, width: 1.4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: Colors.white),
      ),
    ),
  );
}

/// Cola del globo: tapa el borde de abajo y apunta hacia abajo y afuera.
class _Tail extends CustomPainter {
  final bool left;
  _Tail(this.left);

  @override
  void paint(Canvas canvas, Size s) {
    if (!left) {
      canvas.translate(s.width, 0);
      canvas.scale(-1, 1);
    }
    final fill = Path()
      ..moveTo(3, -3)
      ..lineTo(0, s.height)
      ..lineTo(s.width, -3)
      ..close();
    canvas.drawPath(fill, Paint()..color = _paper);
    canvas.drawPath(
      Path()
        ..moveTo(3, -1)
        ..lineTo(0, s.height)
        ..lineTo(s.width, -1),
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
