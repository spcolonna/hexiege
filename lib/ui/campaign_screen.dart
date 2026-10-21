import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../engine/pieces.dart';
import '../solo/catalog.dart';
import '../story/scroll_screen.dart';
import 'piece_chip.dart';
import 'stage_list_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

/// Elegir campaña: una historia por facción.
class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        accent: t.gold,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              children: [
                SkinHeader(title: tr('solo.campaign'), backTooltip: tr('common.back')),
                const SizedBox(height: 8),
                for (final c in campaigns)
                  Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: _card(context, t, c)),
                Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: _scroll(context, t)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, HexTheme t, Campaign c) {
    final s = AppSettings.instance;
    final done = c.stages.where((x) => s.isCleared(x.id)).length;
    final next = c.stages.where((x) => !s.isCleared(x.id)).firstOrNull;
    final color = HexTheme.faction(c.faction);
    final leader = switch (c.faction) {
      Faction.shaolin => PieceType.monk,
      Faction.ninja => PieceType.shogun,
      Faction.oni => PieceType.oni,
    };
    // El Sello se abre recién con las dos campañas terminadas.
    final open = isUnlocked(c.stages, 0, s.isCleared);
    final stars = c.stages.fold(0, (a, x) => a + s.starsOf(x.id));
    final status = !open
        ? tr('campaign.finaleLocked')
        : next == null
        ? tr('campaign.completed', {'done': done, 'total': c.stages.length})
        : tr('campaign.next', {'done': done, 'total': c.stages.length, 'title': next.title});
    final tile = SkinTile(
      leading: PieceChip(type: leader, owner: c.faction == Faction.shaolin ? 0 : 1, size: 24, ash: c.isFinale),
      title: c.title,
      text: '${c.blurb}\n$status${stars > 0 ? '  ·  ★ $stars/${c.stages.length * 3}' : ''}',
      progress: done / c.stages.length,
      color: color,
      highlight: next == null,
      trailing: Icon(open ? Icons.chevron_right_rounded : Icons.lock_rounded, color: t.textMuted),
      onTap: !open
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StageListScreen(
                  title: c.title,
                  subtitle: c.isFinale ? tr('campaign.finale.sub') : c.faction.displayName,
                  stages: c.stages,
                ),
              ),
            ),
    );
    return open ? tile : Opacity(opacity: 0.6, child: tile);
  }

  /// Pergamino: releer las viñetas ya vistas.
  Widget _scroll(BuildContext context, HexTheme t) {
    final (seen, total) = ScrollScreen.progress();
    return SkinTile(
      glyph: '巻',
      color: t.gold,
      title: tr('story.scroll'),
      text: tr('story.scrollText', {'seen': seen, 'total': total}),
      trailing: Icon(Icons.chevron_right_rounded, color: t.textMuted),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScrollScreen())),
    );
  }
}
