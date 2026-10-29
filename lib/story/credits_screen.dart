import 'dart:math';

import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../ui/fx/sfx.dart';
import '../ui/theme/hex_theme.dart';
import '../ui/theme/ui_style.dart';
import '../ui/widgets/avatar_face.dart';
import 'script.dart';

/// Cierre de la historia, después del epílogo de El Sello: el sello cae, pasa
/// el reparto y queda el gancho de lo que viene («Continuará…» sobre un ojo
/// de fuego). Un toque salta al final; otro toque, al final, cierra.
Future<void> showCredits(BuildContext context) => Navigator.of(context).push(
  PageRouteBuilder<void>(
    opaque: true,
    transitionDuration: const Duration(milliseconds: 900),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, _, _) => const CreditsScreen(),
    transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
  ),
);

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

/// Reparto en orden de aparición en los créditos (Natsu va aparte: no tiene retrato).
const _cast = [Who.ren, Who.aya, Who.jubei, Who.abbot, Who.kage, Who.tao, Who.mei, Who.kuro, Who.gon, Who.fox];

class _CreditsScreenState extends State<CreditsScreen> with SingleTickerProviderStateMixin {
  static const _total = Duration(seconds: 34);

  // Tramos de la animación (fracciones de [_total]).
  static const _stampEnd = 0.12, _castEnd = 0.72, _thanksEnd = 0.8;

  late final _c = AnimationController(vsync: this, duration: _total);
  final _beats = <double>{};

  @override
  void initState() {
    super.initState();
    MusicBoard.instance.play(MusicTrack.menu);
    _c.addListener(_cues);
    _c.forward();
  }

  /// Sonidos y vibraciones en momentos fijos: el sello y los latidos del ojo.
  void _cues() {
    void at(double v, VoidCallback f) {
      if (_c.value >= v && _beats.add(v)) f();
    }

    at(0.03, () {
      SoundBoard.instance.play(Sfx.stamp);
      Haptics.heavy();
    });
    at(0.07, () => SoundBoard.instance.play(Sfx.victory, volume: 0.7));
    for (final v in [0.84, 0.89, 0.94]) {
      at(v, () {
        SoundBoard.instance.play(Sfx.heartbeat);
        Haptics.medium();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _tap() {
    if (_c.value < _thanksEnd) {
      _c.forward(from: _thanksEnd);
    } else if (_c.isCompleted) {
      Navigator.of(context).maybePop();
    }
  }

  /// Avance 0..1 de [v] dentro del tramo [a]..[b].
  static double _seg(double v, double a, double b) => ((v - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final skin = Skin.of(context);
    return Scaffold(
      backgroundColor: _night,
      body: Semantics(
        button: true,
        label: tr('common.next'),
        onTap: _tap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final v = _c.value;
              return LayoutBuilder(
                builder: (context, box) => Stack(
                  fit: StackFit.expand,
                  children: [
                    // El sello del final, casi apagado, detrás de todo.
                    Opacity(
                      opacity: 0.22 * (1 - _seg(v, _castEnd, _thanksEnd)),
                      child: Image.asset('assets/story/art_seal.webp', fit: BoxFit.cover),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_night, Color(0x0015120E), Color(0x0015120E), _night],
                          stops: [0, 0.2, 0.8, 1],
                        ),
                      ),
                    ),
                    if (v < _castEnd + 0.02) _stamp(skin, v),
                    if (v > _stampEnd - 0.02 && v < _castEnd + 0.02) _castRoll(skin, v, box.maxHeight),
                    if (v > _castEnd) _ending(skin, v),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 封: cae como un sello de tinta roja y se queda arriba mientras pasa el reparto.
  Widget _stamp(Skin skin, double v) {
    final drop = Curves.easeOutBack.transform(_seg(v, 0.0, 0.04));
    final out = _seg(v, _castEnd - 0.04, _castEnd);
    final up = Curves.easeInOut.transform(_seg(v, 0.09, _stampEnd));
    final flash = (1 - _seg(v, 0.03, 0.07)) * (v >= 0.03 ? 1 : 0);
    return Opacity(
      opacity: (1 - out) * _seg(v, 0, 0.015),
      child: Align(
        alignment: Alignment(0, -0.15 - 0.7 * up),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: (2.6 - 1.6 * drop) * (1 - 0.45 * up),
              child: Container(
                width: 110,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _seal,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _seal.withValues(alpha: 0.6 * flash), blurRadius: 60, spreadRadius: 20)],
                ),
                child: Text('封', style: skin.display(72, color: _paper)),
              ),
            ),
            SizedBox(height: 18 * (1 - up)),
            Opacity(
              opacity: _seg(v, 0.05, 0.08) * (1 - up),
              child: Text(
                tr('credits.sealed'),
                textAlign: TextAlign.center,
                style: skin.display(24, color: _paper),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// El reparto sube despacio, como un rollo que se desenrolla.
  Widget _castRoll(Skin skin, double v, double h) {
    final p = _seg(v, _stampEnd, _castEnd);
    const row = 92.0;
    final rows = [
      Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Text(
          tr('credits.cast'),
          textAlign: TextAlign.center,
          style: skin.display(22, color: _gold),
        ),
      ),
      for (final w in _cast) _member(skin, w.displayName, tr('credits.who.${w.name}'), face: w),
      _member(skin, tr('credits.natsu'), tr('credits.natsuLine')),
      _member(skin, Who.oni.displayName, tr('credits.who.oni'), face: Who.oni),
    ];
    final length = rows.length * row + 40;
    final y = h - (h + length) * p;
    final fade = 1 - _seg(v, _castEnd - 0.03, _castEnd);
    return Opacity(
      opacity: fade,
      child: ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: [0.18, 0.3, 0.85, 1],
        ).createShader(r),
        blendMode: BlendMode.dstIn,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: Offset(0, y),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(mainAxisSize: MainAxisSize.min, children: rows),
            ),
          ),
        ),
      ),
    );
  }

  Widget _member(Skin skin, String name, String line, {Who? face}) {
    final color = face?.side == null ? _gold : HexTheme.faction(face!.side!);
    return SizedBox(
      height: 92,
      child: Row(
        children: [
          face == null
              ? Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8A8580),
                    border: Border.all(color: _paper.withValues(alpha: 0.7), width: 1.6),
                  ),
                  child: Text('灰', style: skin.display(28, color: _paper)),
                )
              : AvatarFace(avatar: face.avatar, size: 58, color: color, borderColor: _paper.withValues(alpha: 0.7)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: skin.display(20, color: _paper)),
                const SizedBox(height: 2),
                Text(line, style: TextStyle(color: _paper.withValues(alpha: 0.7), fontSize: 13.5, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// «Gracias por jugar», y debajo de la niebla se abre el ojo de fuego.
  Widget _ending(Skin skin, double v) {
    final thanks = _seg(v, _castEnd, _castEnd + 0.04);
    final eye = Curves.easeOut.transform(_seg(v, 0.82, 0.96));
    final beat = v < 0.84 ? 0.0 : (sin((v - 0.84) * 2 * pi / 0.05) * 0.5 + 0.5);
    final tbc = _seg(v, 0.9, 0.95);
    final tap = _c.isCompleted ? 1.0 : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: thanks * (1 - 0.55 * eye),
          child: Text(tr('credits.thanks'), style: skin.display(28, color: _paper)),
        ),
        const SizedBox(height: 46),
        SizedBox(
          width: 220,
          height: 120,
          child: Opacity(
            opacity: eye,
            child: CustomPaint(
              painter: _FireEye(open: eye, glow: beat),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Opacity(
          opacity: tbc,
          child: Column(
            children: [
              Text(tr('credits.tbc'), style: skin.display(30, color: _ember)),
              const SizedBox(height: 6),
              Text(
                tr('credits.next'),
                style: TextStyle(color: _paper.withValues(alpha: 0.75), fontSize: 15, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        AnimatedOpacity(
          opacity: tap,
          duration: const Duration(milliseconds: 600),
          child: Text(tr('credits.tap'), style: TextStyle(color: _paper.withValues(alpha: 0.5), fontSize: 12)),
        ),
      ],
    );
  }
}

/// Un ojo de fuego que se abre entre la niebla: almendra roja, pupila de brasa.
class _FireEye extends CustomPainter {
  final double open;
  final double glow;
  const _FireEye({required this.open, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = size.width * 0.42, h = size.height * 0.34 * open;
    canvas.drawCircle(
      c,
      size.width * (0.35 + 0.1 * glow),
      Paint()
        ..color = _ember.withValues(alpha: 0.18 + 0.2 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
    final lid = Path()
      ..moveTo(c.dx - w, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - 2 * h, c.dx + w, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + 2 * h, c.dx - w, c.dy)
      ..close();
    canvas.drawPath(
      lid,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFD27A), _ember, const Color(0xFF3A0A06)],
          stops: const [0, 0.5, 1],
        ).createShader(Rect.fromCircle(center: c, radius: w)),
    );
    if (open > 0.3) {
      canvas.drawOval(Rect.fromCenter(center: c, width: 10, height: h * 1.7), Paint()..color = const Color(0xFF120403));
    }
    canvas.drawPath(
      lid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF120403),
    );
  }

  @override
  bool shouldRepaint(_FireEye old) => old.open != open || old.glow != glow;
}

const _paper = Color(0xFFFBF6EA);
const _night = Color(0xFF15120E);
const _seal = Color(0xFFB0302A);
const _gold = Color(0xFFD9B45A);
const _ember = Color(0xFFE2532B);
