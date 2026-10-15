import 'package:flutter/material.dart';

import '../../match/ladder.dart';
import '../theme/hex_theme.dart';
import 'rank_badge.dart';

/// Resultado de una partida por puntos: puntos que se suman/restan con un
/// contador animado, cambio de rango y racha.
class RankedResultDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final LadderRecord before;
  final LadderRecord after;
  final VoidCallback onMenu;
  final VoidCallback onAgain;

  const RankedResultDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.before,
    required this.after,
    required this.onMenu,
    required this.onAgain,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final delta = after.rating - before.rating;
    final up = after.rank.index > before.rank.index;
    final down = after.rank.index < before.rank.index;
    final deltaColor = delta > 0
        ? const Color(0xFF3FA58C)
        : delta < 0
        ? t.danger
        : t.textMuted;
    return AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.textMuted),
          ),
          const SizedBox(height: 18),
          // El contador cambia de ancho mientras anima: que nunca desborde.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: up || down ? 0.6 : 1, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, s, c) => Transform.scale(scale: s, child: c),
                  child: RankBadge(rank: after.rank, size: 52),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: before.rating.toDouble(), end: after.rating.toDouble()),
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => Text(
                        '${v.round()}',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: t.text, height: 1),
                      ),
                    ),
                    Text(
                      after.rank.displayName,
                      style: TextStyle(color: after.rank.textOn(t.isDark), fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deltaColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    delta > 0 ? '+$delta' : '$delta',
                    style: TextStyle(fontWeight: FontWeight.w900, color: deltaColor),
                  ),
                ),
              ],
            ),
          ),
          if (up || down) ...[
            const SizedBox(height: 12),
            Text(
              up ? '¡Subiste a ${after.rank.displayName}!' : 'Bajaste a ${after.rank.displayName}',
              style: TextStyle(fontWeight: FontWeight.w800, color: up ? t.gold : t.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            [
              '${after.wins}V · ${after.losses}D${after.draws > 0 ? ' · ${after.draws}E' : ''}',
              if (after.streak >= 2) '🔥 ${after.streak} seguidas',
            ].join('   '),
            style: TextStyle(fontSize: 13, color: t.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(onPressed: onMenu, child: const Text('Menú')),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: t.gold, foregroundColor: Colors.black),
          onPressed: onAgain,
          icon: const Icon(Icons.search_rounded),
          label: const Text('Buscar otra'),
        ),
      ],
    );
  }
}
