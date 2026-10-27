import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../solo/stars.dart';
import '../fx/sfx.dart';
import '../theme/hex_theme.dart';

/// Tres estrellas chicas: las ganadas en oro y las que faltan en contorno.
class StarRow extends StatelessWidget {
  final int stars;
  final double size;
  const StarRow({super.key, required this.stars, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Semantics(
      label: tr('stars.count', {'n': stars}),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i < stars ? t.gold : t.textMuted.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }
}

/// Los tres objetivos de estrella en una línea (presentación de la batalla).
String starGoalsLine({int par = Stars.parRounds}) => [
  tr('stars.win'),
  tr('stars.fast', {'n': par}),
  tr('stars.safe', {'n': Stars.safeSides}),
].join('  ·  ');

/// Resultado: las estrellas caen de a una, con su objetivo al lado.
class StarsReveal extends StatefulWidget {
  final List<bool> goals;

  /// Estrellas que ya tenía antes de esta partida (para marcar el récord).
  final int previous;

  /// Rondas de la estrella de rapidez en esta batalla.
  final int par;
  const StarsReveal({super.key, required this.goals, this.previous = 0, this.par = Stars.parRounds});

  @override
  State<StarsReveal> createState() => _StarsRevealState();
}

class _StarsRevealState extends State<StarsReveal> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  int _played = 0;

  static const _step = 0.25;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      final n = (_c.value / _step).floor().clamp(0, 3);
      while (_played < n) {
        if (widget.goals[_played]) {
          SoundBoard.instance.play(Sfx.tick, volume: 0.6 + 0.15 * _played);
          Haptics.light();
        }
        _played++;
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final labels = [
      tr('stars.win'),
      tr('stars.fast', {'n': widget.par}),
      tr('stars.safe', {'n': Stars.safeSides}),
    ];
    final best = Stars.count(widget.goals) > widget.previous && widget.previous > 0;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: _star(t, i)),
            ],
          ),
          if (best)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tr('stars.record'),
                style: TextStyle(color: t.gold, fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.goals[i] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 15,
                    color: widget.goals[i] ? t.gold : t.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        color: widget.goals[i] ? t.text : t.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _star(HexTheme t, int i) {
    final got = widget.goals[i];
    // Cada estrella entra grande y se asienta con un rebote.
    final p = ((_c.value - i * _step) / 0.3).clamp(0.0, 1.0);
    final scale = got ? (p == 0 ? 0.0 : Curves.elasticOut.transform(p)) : 1.0;
    final size = i == 1 ? 46.0 : 38.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.star_rounded, size: size, color: t.textMuted.withValues(alpha: 0.25)),
          if (got)
            Transform.scale(
              scale: scale,
              child: Icon(
                Icons.star_rounded,
                size: size,
                color: t.gold,
                shadows: [Shadow(color: t.gold.withValues(alpha: 0.6), blurRadius: 12)],
              ),
            ),
        ],
      ),
    );
  }
}
