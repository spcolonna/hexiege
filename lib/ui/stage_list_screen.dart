import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../engine/ai.dart';
import '../engine/pieces.dart';
import '../solo/catalog.dart';
import '../solo/stars.dart';
import '../store/paywall.dart';
import '../store/purchases.dart';
import 'game_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';
import 'widgets/star_row.dart';

/// Lista de problemas, desafíos o batallas: se desbloquean de a una.
class StageListScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Stage> stages;

  const StageListScreen({super.key, required this.title, required this.subtitle, required this.stages});

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
              final cleared = stages.where((x) => s.isCleared(x.id)).length;
              final starred = stages.where(Stars.appliesTo).toList();
              final stars = starred.fold(0, (a, x) => a + s.starsOf(x.id));
              return Column(
                children: [
                  SkinHeader(
                    title: title,
                    subtitle: subtitle,
                    trailing: starred.isEmpty ? '$cleared/${stages.length}' : '★ $stars/${starred.length * 3}',
                    backTooltip: tr('common.back'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: stages.length,
                      itemBuilder: (context, i) => _tile(
                        context,
                        t,
                        i,
                        done: s.isCleared(stages[i].id),
                        open: isUnlocked(stages, i, s.isCleared),
                      ),
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

  Widget _tile(BuildContext context, HexTheme t, int i, {required bool done, required bool open}) {
    final st = stages[i];
    final skin = Skin.of(context);
    // Historia sin comprar: se ve con candado dorado y abre el desbloqueo.
    final paywalled = open && !done && isPaid(st) && !AppSettings.instance.storyUnlocked;
    void play() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen.stage(stage: st, nextStage: stageAfter(st)),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: open ? 1 : 0.5,
        child: SkinTile(
          leading: SizedBox(
            width: 30,
            child: Text(
              '${i + 1}',
              textAlign: TextAlign.center,
              style: skin.display(22, color: t.textMuted),
            ),
          ),
          title: st.title,
          text: paywalled ? tr('store.locked', {'price': Purchases.instance.price}) : _detail(st),
          highlight: done,
          trailing: done && Stars.appliesTo(st)
              ? StarRow(stars: AppSettings.instance.starsOf(st.id), size: 15)
              : Icon(
                  done
                      ? Icons.workspace_premium_rounded
                      : paywalled || !open
                      ? Icons.lock_rounded
                      : Icons.play_arrow_rounded,
                  color: done || paywalled ? t.gold : t.textMuted,
                ),
          onTap: paywalled
              ? () async {
                  if (await showPaywall(context)) play();
                }
              : open
              ? play
              : null,
        ),
      ),
    );
  }

  String _detail(Stage st) => switch (st.kind) {
    StageKind.puzzle => tr('stages.puzzleDetail', {'n': st.puzzleTurns!, 'faction': st.you.displayName}),
    _ => tr('stages.versus', {'you': st.you.displayName, 'opp': st.opp.displayName, 'level': st.level.displayName}),
  };
}
