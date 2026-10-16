import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../solo/catalog.dart';
import 'campaign_screen.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'stage_list_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';

/// Un jugador: campaña, desafíos y problemas, con el progreso de cada uno.
class SoloScreen extends StatelessWidget {
  const SoloScreen({super.key});

  /// Próxima etapa sin superar y ya disponible: campaña, luego desafíos y problemas.
  static Stage? nextUp(bool Function(String) cleared) {
    for (final list in [for (final c in campaigns) c.stages, challenges, puzzles]) {
      for (var i = 0; i < list.length; i++) {
        if (!cleared(list[i].id) && isUnlocked(list, i, cleared)) return list[i];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        accent: t.gold,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (context, _) {
              final s = AppSettings.instance;
              int done(List<Stage> l) => l.where((x) => s.isCleared(x.id)).length;
              final campaignStages = [for (final c in campaigns) ...c.stages];
              final all = [...campaignStages, ...challenges, ...puzzles];
              final next = nextUp(s.isCleared);
              return ListView(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: tr('common.back'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(
                          tr('solo.title'),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: t.text),
                        ),
                      ),
                      Text(
                        '${done(all)}/${all.length}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: t.gold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        if (next != null) _continue(context, t, next),
                        const SizedBox(height: 16),
                        _mode(
                          context,
                          t,
                          icon: Icons.auto_stories_rounded,
                          title: tr('solo.campaign'),
                          text: tr('solo.campaignText'),
                          done: done(campaignStages),
                          total: campaignStages.length,
                          open: () => const CampaignScreen(),
                        ),
                        _mode(
                          context,
                          t,
                          icon: Icons.emoji_events_rounded,
                          title: tr('solo.challenges'),
                          text: tr('solo.challengesText'),
                          done: done(challenges),
                          total: challenges.length,
                          open: () => StageListScreen(
                            title: tr('solo.challenges'),
                            subtitle: tr('solo.challengesSub'),
                            stages: challenges,
                          ),
                        ),
                        _mode(
                          context,
                          t,
                          icon: Icons.extension_rounded,
                          title: tr('solo.puzzles'),
                          text: tr('solo.puzzlesText'),
                          done: done(puzzles),
                          total: puzzles.length,
                          open: () => StageListScreen(
                            title: tr('solo.puzzles'),
                            subtitle: tr('solo.puzzlesSub'),
                            stages: puzzles,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _continue(BuildContext context, HexTheme t, Stage next) {
    final kind = switch (next.kind) {
      StageKind.campaign => tr('stageKind.campaign'),
      StageKind.challenge => tr('stageKind.challenge'),
      StageKind.puzzle => tr('stageKind.puzzle'),
    };
    return SizedBox(
      height: 64,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: t.gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          SoundBoard.instance.play(Sfx.place);
          Haptics.medium();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen.stage(stage: next, nextStage: stageAfter(next)),
            ),
          );
        },
        child: Row(
          children: [
            const Icon(Icons.play_arrow_rounded, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr('solo.continue'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(
                    '$kind · ${next.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mode(
    BuildContext context,
    HexTheme t, {
    required IconData icon,
    required String title,
    required String text,
    required int done,
    required int total,
    required Widget Function() open,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            SoundBoard.instance.play(Sfx.tick);
            Haptics.select();
            Navigator.push(context, MaterialPageRoute(builder: (_) => open()));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: done == total ? t.gold.withValues(alpha: 0.7) : t.outline),
            ),
            child: Row(
              children: [
                Icon(icon, color: t.gold, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: t.text),
                      ),
                      const SizedBox(height: 2),
                      Text(text, style: TextStyle(fontSize: 13, color: t.textMuted)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: done / total,
                          minHeight: 6,
                          color: t.gold,
                          backgroundColor: t.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$done/$total',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: t.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
