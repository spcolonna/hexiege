import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../match/ladder.dart';
import '../theme/hex_theme.dart';
import '../theme/ui_style.dart';
import 'rank_badge.dart';
import 'skin_kit.dart';

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
        ? t.highlight
        : delta < 0
        ? t.danger
        : t.textMuted;
    final s = Skin.of(context);
    return SkinDialog(
      glyph: delta > 0 ? '勝' : (delta < 0 ? '敗' : '和'),
      glyphColor: delta > 0 ? t.gold : null,
      title: title,
      message: subtitle,
      body: Column(
        children: [
          // El contador cambia de ancho mientras anima: que nunca desborde.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: up || down ? 0.6 : 1, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, sc, c) => Transform.scale(scale: sc, child: c),
                  child: RankBadge(rank: after.rank, size: 48),
                ),
                const SizedBox(width: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: before.rating.toDouble(), end: after.rating.toDouble()),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Text('${v.round()}', style: s.display(44, color: t.text, height: 1)),
                ),
                const SizedBox(width: 10),
                Text(
                  delta > 0 ? '+$delta' : '$delta',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: deltaColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            after.rank.displayName,
            style: TextStyle(color: after.rank.textOn(t.isDark), fontWeight: FontWeight.w800),
          ),
          if (up || down) ...[
            const SizedBox(height: 10),
            Text(
              tr(up ? 'ranked.rankUp' : 'ranked.rankDown', {'rank': after.rank.displayName}),
              style: TextStyle(fontWeight: FontWeight.w800, color: up ? t.gold : t.textMuted),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            [
              '${after.wins}V · ${after.losses}D${after.draws > 0 ? ' · ${after.draws}E' : ''}',
              if (after.streak >= 2) '🔥 ${after.streak} seguidas',
            ].join('   '),
            style: TextStyle(fontSize: 13, color: t.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        SkinAction(tr('ranked.again'), onAgain, primary: true, glyph: '戦'),
        SkinAction(tr('common.menu'), onMenu),
      ],
    );
  }
}
