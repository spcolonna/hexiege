import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../engine/pieces.dart';
import '../theme/hex_theme.dart';

enum CoachState { doing, retry, done }

/// Tarjeta del Sensei en el tutorial: progreso, explicación y objetivo. Al
/// cumplirlo cambia a "¡Bien hecho!" con el botón para seguir.
class CoachCard extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String body;
  final String goal;
  final String retry;
  final CoachState state;
  final VoidCallback onNext;

  const CoachCard({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.body,
    required this.goal,
    required this.retry,
    required this.state,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final done = state == CoachState.done;
    final accent = done ? HexTheme.faction(Faction.shaolin) : t.gold;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withValues(alpha: t.shadow.a * 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 18, spreadRadius: -4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _SenseiAvatar(done: done),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('coach.lesson', {'step': step, 'total': total}),
                      style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: accent),
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: t.text),
                    ),
                  ],
                ),
              ),
              _Progress(step: step, total: total, color: accent, track: t.outline),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: done
                  ? Row(
                      key: const ValueKey('done'),
                      children: [
                        Expanded(
                          child: Text(
                            tr(step == total ? 'coach.finished' : 'coach.wellDone'),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.text),
                          ),
                        ),
                        _PopIn(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: t.gold, foregroundColor: Colors.black),
                            onPressed: onNext,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(tr(step == total ? 'coach.finish' : 'common.next')),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('doing'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(body, style: TextStyle(fontSize: 13.5, height: 1.3, color: t.textMuted)),
                        const SizedBox(height: 8),
                        _Goal(text: state == CoachState.retry ? retry : goal, retry: state == CoachState.retry),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Goal extends StatelessWidget {
  final String text;
  final bool retry;
  const _Goal({required this.text, required this.retry});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = retry ? t.danger : t.gold;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(text),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(retry ? Icons.refresh_rounded : Icons.flag_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: t.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SenseiAvatar extends StatelessWidget {
  final bool done;
  const _SenseiAvatar({required this.done});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return AnimatedScale(
      scale: done ? 1.12 : 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [Color.lerp(t.gold, Colors.white, 0.3)!, Color.lerp(t.gold, Colors.black, 0.3)!],
          ),
          border: Border.all(color: t.surfaceHigh, width: 2),
        ),
        child: done
            ? const Icon(Icons.check_rounded, color: Colors.black, size: 24)
            : const Text(
                '師',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black, height: 1),
              ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int step;
  final int total;
  final Color color;
  final Color track;
  const _Progress({required this.step, required this.total, required this.color, required this.track});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= total; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == step ? 14 : 6,
          height: 6,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(color: i <= step ? color : track, borderRadius: BorderRadius.circular(3)),
        ),
    ],
  );
}

class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.6, end: 1),
    duration: const Duration(milliseconds: 500),
    curve: Curves.elasticOut,
    builder: (_, s, c) => Transform.scale(scale: s, child: c),
    child: child,
  );
}
