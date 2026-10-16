import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../engine/ai.dart';
import '../engine/pieces.dart';
import '../solo/catalog.dart';
import 'game_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

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
              return Column(
                children: [
                  SkinHeader(
                    title: title,
                    subtitle: subtitle,
                    trailing: '$cleared/${stages.length}',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: open ? 1 : 0.5,
        child: SkinTile(
          leading: SizedBox(
            width: 30,
            child: Text('${i + 1}', textAlign: TextAlign.center, style: skin.display(22, color: t.textMuted)),
          ),
          title: st.title,
          text: _detail(st),
          highlight: done,
          trailing: Icon(
            done
                ? Icons.workspace_premium_rounded
                : open
                ? Icons.play_arrow_rounded
                : Icons.lock_rounded,
            color: done ? t.gold : t.textMuted,
          ),
          onTap: open
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreen.stage(stage: st, nextStage: stageAfter(st))),
                )
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
