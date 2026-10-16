import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../engine/pieces.dart';
import '../solo/catalog.dart';
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
    final leader = c.faction == Faction.shaolin ? PieceType.monk : PieceType.shogun;
    return SkinTile(
      leading: PieceChip(type: leader, owner: c.faction == Faction.shaolin ? 0 : 1, size: 24),
      title: c.title,
      text:
          '${c.blurb}\n${next == null ? tr('campaign.completed', {'done': done, 'total': c.stages.length}) : tr('campaign.next', {'done': done, 'total': c.stages.length, 'title': next.title})}',
      progress: done / c.stages.length,
      color: color,
      highlight: next == null,
      trailing: Icon(Icons.chevron_right_rounded, color: t.textMuted),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StageListScreen(title: c.title, subtitle: c.faction.displayName, stages: c.stages),
        ),
      ),
    );
  }
}
