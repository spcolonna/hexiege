import 'dart:async';

import 'package:flutter/material.dart';

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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      for (var i = 0; i < _shown; i++) _Enter(key: _keys[i], animate: !widget.replay, child: _beat(i)),
                      if (_typing && !_done) _Enter(key: ValueKey('typing$_shown'), child: _typingRow(_shown)),
                    ],
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

  bool _left(Who w) => w.side == null ? false : widget.mine.contains(w.side);

  Widget _beat(int i) {
    final b = _beats[i];
    final text = widget.scene.text(i);
    return switch (b.kind) {
      BeatKind.moment => _MomentLine(text: text),
      BeatKind.narrate => _Narration(text: text),
      _ => _Bubble(who: b.who!, text: text, left: _left(b.who!), thought: b.kind == BeatKind.think),
    };
  }

  Widget _typingRow(int i) {
    final b = _beats[i];
    if (b.kind == BeatKind.moment || b.kind == BeatKind.narrate) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: _Dots()),
      );
    }
    return _Bubble(who: b.who!, left: _left(b.who!), thought: b.kind == BeatKind.think);
  }
}

/// Entrada de un mensaje: sube y aparece con un leve rebote.
class _Enter extends StatelessWidget {
  final Widget child;
  final bool animate;
  const _Enter({super.key, required this.child, this.animate = true});

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: c),
      ),
      child: child,
    );
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

/// Separador de momento: lugar o tiempo, en tinta, entre dos rayas.
class _MomentLine extends StatelessWidget {
  final String text;
  const _MomentLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final line = Expanded(child: Container(height: 1, color: t.gold.withValues(alpha: 0.45)));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          line,
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Skin.of(context).display(16, color: t.gold, height: 1.2),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _Narration extends StatelessWidget {
  final String text;
  const _Narration({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Text.rich(
        storySpans(text, TextStyle(fontSize: 15, height: 1.4, fontStyle: FontStyle.italic, color: inkOf(t))),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Globo de un personaje. Sin [text], muestra los puntos de "escribiendo…".
class _Bubble extends StatelessWidget {
  final Who who;
  final String? text;
  final bool left;
  final bool thought;
  const _Bubble({required this.who, this.text, required this.left, this.thought = false});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final side = who.side;
    final color = side == null ? t.gold : HexTheme.faction(side);
    final face = AvatarFace(
      avatar: who.avatar,
      size: 42,
      color: color,
      borderColor: color.withValues(alpha: 0.9),
      borderWidth: 2,
    );
    final r = const Radius.circular(16);
    final bubble = Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
      decoration: BoxDecoration(
        color: thought ? t.surface.withValues(alpha: 0.55) : t.surfaceHigh.withValues(alpha: 0.95),
        borderRadius: BorderRadius.only(
          topLeft: left ? const Radius.circular(4) : r,
          topRight: left ? r : const Radius.circular(4),
          bottomLeft: r,
          bottomRight: r,
        ),
        border: Border.all(
          color: color.withValues(alpha: thought ? 0.35 : 0.6),
          width: thought ? 1 : 1.3,
        ),
        boxShadow: thought
            ? null
            : [
                BoxShadow(
                  color: t.shadow.withValues(alpha: t.shadow.a * 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: text == null
          ? const _Dots()
          : Text.rich(
              storySpans(
                text!,
                TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: t.text,
                  fontStyle: thought ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
    );
    final column = Flexible(
      child: Column(
        crossAxisAlignment: left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 3),
            child: Text(
              thought ? '${who.displayName} · ${tr('story.thinks')}' : who.displayName,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          bubble,
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: left ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: left
            ? [face, const SizedBox(width: 10), column, const SizedBox(width: 40)]
            : [const SizedBox(width: 40), column, const SizedBox(width: 10), face],
      ),
    );
  }
}

/// Tres puntos que laten: alguien está escribiendo.
class _Dots extends StatefulWidget {
  const _Dots();

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
                color: t.textMuted.withValues(alpha: 0.35 + 0.65 * _pulse((_c.value - i * 0.18) % 1)),
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
