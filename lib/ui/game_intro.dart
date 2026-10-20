import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'fx/sfx.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

/// Presentación del juego después de la del estudio: seis fichas, tres de cada
/// facción, caen de a una alrededor de una casilla vacía; al cerrarse el
/// anillo, el sello se enciende y aparece el nombre. Tocar la salta.
class GameIntro extends StatefulWidget {
  final Widget next;
  const GameIntro({super.key, required this.next});

  @override
  State<GameIntro> createState() => _GameIntroState();
}

/// Fichas del anillo en orden de caída: Templo y Sombra alternados, como el
/// Sello de los Seis.
const _ring = [
  (PieceType.dragon, 0),
  (PieceType.shinobi, 1),
  (PieceType.tiger, 0),
  (PieceType.kunoichi, 1),
  (PieceType.crane, 0),
  (PieceType.tengu, 1),
];

/// Tramos de la animación (fracciones de la duración total).
const _dropStart = 0.04, _dropGap = 0.075, _dropLen = 0.16;
const _seal = _dropStart + 5 * _dropGap + _dropLen; // la sexta ficha apoya
const _titleAt = _seal + 0.06;

class _GameIntroState extends State<GameIntro> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2900))
    ..addListener(_sounds)
    ..forward().whenComplete(_leave);
  int _landed = 0;
  bool _sealed = false;
  bool _left = false;

  /// Un golpe de piedra por ficha que apoya y el sello al cerrar el anillo.
  void _sounds() {
    final t = _c.value;
    while (_landed < _ring.length && t >= _dropStart + _landed * _dropGap + _dropLen * 0.7) {
      SoundBoard.instance.play(Sfx.place, volume: 0.55 + 0.07 * _landed);
      Haptics.light();
      _landed++;
    }
    if (!_sealed && t >= _seal) {
      _sealed = true;
      SoundBoard.instance.play(Sfx.stamp, volume: 0.8);
      Haptics.medium();
    }
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => widget.next,
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _span(double t, double from, double len) => ((t - from) / len).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final th = HexTheme.of(context);
    final skin = Skin.of(context);
    final size = (MediaQuery.sizeOf(context).width * 0.085).clamp(26.0, 40.0);
    final gap = size * sqrt(3) * 1.04;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: ArenaBackdrop(
          accent: th.gold,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final seal = Curves.easeOutBack.transform(_span(t, _seal, 0.14));
              final pulse = sin(_span(t, _seal, 0.22) * pi);
              final title = Curves.easeOutCubic.transform(_span(t, _titleAt, 0.18));
              final sub = Curves.easeOutCubic.transform(_span(t, _titleAt + 0.07, 0.18));
              final out = Curves.easeIn.transform(_span(t, 0.9, 0.1));
              return Opacity(
                opacity: 1 - out * 0.3,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: gap * 2 + size * 2.4,
                        height: gap * 2 + size * 2.4,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // La casilla del centro: vacía hasta que el anillo se cierra.
                            CustomPaint(
                              size: Size.square(size * 2),
                              painter: _SealPainter(seal: seal, pulse: pulse, gold: th.gold, ink: inkOf(th)),
                            ),
                            for (var i = 0; i < _ring.length; i++) _drop(i, t, size, gap),
                            Opacity(
                              opacity: seal.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.6 + 0.4 * seal,
                                child: Text('封', style: skin.glyph(size * 0.95, color: th.gold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Opacity(
                        opacity: title,
                        child: Transform.translate(
                          offset: Offset(0, 14 * (1 - title)),
                          child: Text('Hexiege', style: skin.display(54, color: th.text, height: 1)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: sub,
                        child: Text(
                          tr('menu.tagline'),
                          style: TextStyle(fontSize: 15, letterSpacing: 0.5, color: th.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// La ficha [i] cae desde arriba con un leve rebote hasta su lugar en el anillo.
  Widget _drop(int i, double t, double size, double gap) {
    final k = _span(t, _dropStart + i * _dropGap, _dropLen);
    if (k <= 0) return const SizedBox.shrink();
    final land = Curves.easeOutBack.transform(k);
    // Vecinos de un hexágono "pointy-top": cada 60°, empezando arriba a la derecha.
    final a = -pi / 3 + i * pi / 3;
    final at = Offset(cos(a), sin(a)) * gap;
    final (type, owner) = _ring[i];
    return Transform.translate(
      offset: at + Offset(0, -size * 2.2 * (1 - land)),
      child: Opacity(
        opacity: Curves.easeOut.transform((k * 2.5).clamp(0.0, 1.0)),
        child: Transform.scale(
          scale: 1.25 - 0.25 * land,
          child: PieceChip(type: type, owner: owner, size: size, lift: 0.25 * (1 - land)),
        ),
      ),
    );
  }
}

/// Hexágono del centro: contorno tenue; al sellar, se llena de oro y late una vez.
class _SealPainter extends CustomPainter {
  final double seal, pulse;
  final Color gold, ink;
  _SealPainter({required this.seal, required this.pulse, required this.gold, required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.46;
    final hex = Path();
    for (var k = 0; k < 6; k++) {
      final a = -pi / 2 + k * pi / 3;
      final p = c + Offset(cos(a), sin(a)) * r;
      k == 0 ? hex.moveTo(p.dx, p.dy) : hex.lineTo(p.dx, p.dy);
    }
    hex.close();
    if (pulse > 0) {
      canvas.drawCircle(
        c,
        r * (1.6 + 1.4 * pulse),
        Paint()
          ..shader = RadialGradient(
            colors: [
              gold.withValues(alpha: 0.35 * pulse),
              gold.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 3)),
      );
    }
    canvas.drawPath(hex, Paint()..color = gold.withValues(alpha: 0.18 * seal.clamp(0.0, 1.0)));
    canvas.drawPath(
      hex,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(ink.withValues(alpha: 0.25), gold, seal.clamp(0.0, 1.0))!,
    );
  }

  @override
  bool shouldRepaint(_SealPainter old) => old.seal != seal || old.pulse != pulse;
}
