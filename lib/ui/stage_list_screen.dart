import 'package:flutter/material.dart';

import '../engine/ai.dart';
import '../engine/pieces.dart';
import '../solo/catalog.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';

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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Volver',
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: t.text),
                              ),
                              Text(subtitle, style: TextStyle(fontSize: 13, color: t.textMuted)),
                            ],
                          ),
                        ),
                        Text(
                          '$cleared/${stages.length}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: t.gold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
    final color = HexTheme.faction(st.you);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: open
              ? () {
                  SoundBoard.instance.play(Sfx.tick);
                  Haptics.select();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen.stage(stage: st, nextStage: stageAfter(st)),
                    ),
                  );
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: done ? t.gold.withValues(alpha: 0.7) : t.outline),
            ),
            child: Opacity(
              opacity: open ? 1 : 0.45,
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: t.textMuted),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          st.title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.text),
                        ),
                        Text(
                          _detail(st),
                          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    done
                        ? Icons.workspace_premium_rounded
                        : open
                        ? Icons.play_arrow_rounded
                        : Icons.lock_rounded,
                    color: done ? t.gold : t.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _detail(Stage st) => switch (st.kind) {
    StageKind.puzzle => 'Cerco en ${st.puzzleTurns} · ${st.you.displayName}',
    _ => '${st.you.displayName} vs ${st.opp.displayName} · ${st.level.displayName}',
  };
}
