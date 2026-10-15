import 'package:flutter/material.dart';

import '../engine/pieces.dart';
import '../solo/catalog.dart';
import 'fx/sfx.dart';
import 'piece_chip.dart';
import 'stage_list_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';

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
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Volver',
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    Text(
                      'Campaña',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: t.text),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final c in campaigns)
                  Padding(padding: const EdgeInsets.only(left: 12, bottom: 12), child: _card(context, t, c)),
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
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          SoundBoard.instance.play(Sfx.tick);
          Haptics.select();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StageListScreen(title: c.title, subtitle: c.faction.displayName, stages: c.stages),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Row(
            children: [
              PieceChip(type: leader, owner: c.faction == Faction.shaolin ? 0 : 1, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: t.text),
                    ),
                    const SizedBox(height: 2),
                    Text(c.blurb, style: TextStyle(fontSize: 13, color: t.textMuted)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: done / c.stages.length,
                        minHeight: 6,
                        color: color,
                        backgroundColor: t.outline,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      next == null
                          ? '¡Completada! $done/${c.stages.length}'
                          : '$done/${c.stages.length} · Sigue: ${next.title}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: t.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
