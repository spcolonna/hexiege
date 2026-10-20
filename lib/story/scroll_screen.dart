import 'package:flutter/material.dart';

import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import '../solo/catalog.dart';
import '../ui/theme/hex_theme.dart';
import '../ui/theme/settings.dart';
import '../ui/theme/ui_style.dart';
import '../ui/widgets/arena_backdrop.dart';
import '../ui/widgets/skin_kit.dart';
import 'script.dart';
import 'story_screen.dart';

/// Pergamino: las viñetas ya vistas, por campaña y acto, para releerlas.
class ScrollScreen extends StatelessWidget {
  const ScrollScreen({super.key});

  /// Viñetas vistas y totales.
  static (int, int) progress() {
    final s = AppSettings.instance;
    final all = Scene.ids.toList();
    return (all.where(s.isSceneSeen).length, all.length);
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    final s = AppSettings.instance;
    final (seen, total) = progress();
    return Scaffold(
      body: ArenaBackdrop(
        accent: t.gold,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            children: [
              SkinHeader(title: tr('story.scroll'), trailing: '$seen/$total', backTooltip: tr('common.back')),
              if (seen == 0)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    tr('story.scrollEmpty'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.textMuted),
                  ),
                ),
              for (final c in campaigns)
                for (var act = 0; act * 6 < c.stages.length; act++) ..._act(context, t, skin, c, act, s),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _act(BuildContext context, HexTheme t, Skin skin, Campaign c, int act, AppSettings s) {
    final stages = c.stages.skip(act * 6).take(6).toList();
    final scenes = [
      for (final st in stages)
        for (final post in [false, true])
          if (Scene.of(st.id, post: post) case final sc? when s.isSceneSeen(sc.id)) (st, sc),
    ];
    if (scenes.isEmpty) return const [];
    final heading = c.isFinale ? c.title : '${c.title} · ${tr('story.act.${c.id}.$act')}';
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Text(heading, style: skin.display(18, color: HexTheme.faction(c.faction))),
      ),
      for (final (st, sc) in scenes)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SkinTile(
            glyph: sc.isPost ? '後' : '前',
            color: HexTheme.faction(c.faction),
            title: st.title,
            text: tr(sc.isPost ? 'story.after' : 'story.before'),
            trailing: Icon(Icons.menu_book_rounded, color: t.textMuted),
            onTap: () => playScene(
              context,
              sc,
              title: st.title,
              replay: true,
              mine: st.id == finale.last.id ? const {Faction.shaolin, Faction.ninja} : {st.you},
            ),
          ),
        ),
    ];
  }
}
