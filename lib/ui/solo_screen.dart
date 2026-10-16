import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../solo/catalog.dart';
import 'campaign_screen.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'stage_list_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                children: [
                  SkinHeader(title: tr('solo.title'), trailing: '${done(all)}/${all.length}', backTooltip: tr('common.back')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        if (next != null) _continue(context, next),
                        const SizedBox(height: 18),
                        _mode(
                          glyph: '記',
                          title: tr('solo.campaign'),
                          text: tr('solo.campaignText'),
                          done: done(campaignStages),
                          total: campaignStages.length,
                          open: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CampaignScreen())),
                        ),
                        _mode(
                          glyph: '試',
                          title: tr('solo.challenges'),
                          text: tr('solo.challengesText'),
                          done: done(challenges),
                          total: challenges.length,
                          open: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StageListScreen(
                                title: tr('solo.challenges'),
                                subtitle: tr('solo.challengesSub'),
                                stages: challenges,
                              ),
                            ),
                          ),
                        ),
                        _mode(
                          glyph: '詰',
                          title: tr('solo.puzzles'),
                          text: tr('solo.puzzlesText'),
                          done: done(puzzles),
                          total: puzzles.length,
                          open: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StageListScreen(title: tr('solo.puzzles'), subtitle: tr('solo.puzzlesSub'), stages: puzzles),
                            ),
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

  Widget _continue(BuildContext context, Stage next) {
    final kind = switch (next.kind) {
      StageKind.campaign => tr('stageKind.campaign'),
      StageKind.challenge => tr('stageKind.challenge'),
      StageKind.puzzle => tr('stageKind.puzzle'),
    };
    return SkinPrimaryButton(
      height: 66,
      glyph: '進',
      label: tr('solo.continue'),
      sub: '$kind · ${next.title}',
      onPressed: () {
        SoundBoard.instance.play(Sfx.place);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GameScreen.stage(stage: next, nextStage: stageAfter(next))),
        );
      },
    );
  }

  Widget _mode({
    required String glyph,
    required String title,
    required String text,
    required int done,
    required int total,
    required VoidCallback open,
  }) => Builder(
    builder: (context) {
      final t = HexTheme.of(context);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkinTile(
          glyph: glyph,
          title: title,
          text: text,
          progress: done / total,
          highlight: done == total,
          trailing: Text('$done/$total', style: Skin.of(context).display(18, color: t.textMuted)),
          onTap: open,
        ),
      );
    },
  );
}
