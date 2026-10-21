import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../theme/hex_theme.dart';
import '../theme/ui_style.dart';
import 'avatar_face.dart';
import 'duel_scoreboard.dart';
import 'skin_kit.dart';
import 'star_row.dart';

/// Presentación de una etapa (campaña, desafío o problema) a pantalla
/// completa, antes de la partida. En la partida solo queda el objetivo.
class StageIntro extends StatelessWidget {
  /// Kanji de fondo: 記 (campaña) o 試 (desafíos y problemas).
  final String glyph;
  final String label;
  final String title;
  final String story;
  final String goal;
  final PlayerProfile me;
  final PlayerProfile rival;

  /// Línea chica bajo el duelo (facción y nivel del rival).
  final String? rivalLine;
  final VoidCallback onStart;
  final VoidCallback onBack;

  /// Texto del botón de volver (salir de la etapa o cerrar la presentación).
  final String backTooltip;

  /// Estrellas ganadas en esta batalla, o null si no tiene (problemas).
  final int? stars;

  const StageIntro({
    super.key,
    required this.glyph,
    required this.label,
    required this.title,
    required this.story,
    required this.goal,
    required this.me,
    required this.rival,
    this.rivalLine,
    required this.onStart,
    required this.onBack,
    required this.backTooltip,
    this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final ink = inkOf(t);
    final rule = s.style == UiStyle.comb ? t.gold.withValues(alpha: 0.6) : ink.withValues(alpha: 0.25);
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            // Kanji de fondo, grande y apenas visible.
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Text(
                glyph,
                textAlign: TextAlign.center,
                style: s.glyph(190, color: t.accent.withValues(alpha: t.isDark ? 0.12 : 0.1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Text(
                    label,
                    style: TextStyle(color: t.gold, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: s.display(34, color: ink, height: 1.12),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    story,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.textMuted, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: rule),
                        bottom: BorderSide(color: rule),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tr('stage.goal'),
                          style: TextStyle(color: t.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal,
                          textAlign: TextAlign.center,
                          style: s.display(20, color: ink, height: 1.25),
                        ),
                        if (stars != null) ...[
                          const SizedBox(height: 10),
                          StarRow(stars: stars!, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            starGoalsLine(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted, fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _duel(t, s),
                  if (rivalLine != null) ...[
                    const SizedBox(height: 6),
                    Text(rivalLine!, style: TextStyle(color: t.textMuted, fontSize: 14)),
                  ],
                  const Spacer(flex: 4),
                  SkinPrimaryButton(label: tr('common.start'), glyph: '始', onPressed: onStart),
                ],
              ),
            ),
            Positioned(
              top: 4,
              left: 8,
              child: IconButton(
                tooltip: backTooltip,
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_rounded, color: t.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vos contra el rival: retratos grandes con el nombre debajo.
  Widget _duel(HexTheme t, Skin s) {
    Widget who(PlayerProfile p) {
      final c = HexTheme.faction(p.faction);
      return Expanded(
        child: Column(
          children: [
            AvatarFace(
              avatar: p.avatar,
              frame: p.frame,
              size: 84,
              color: c,
              borderColor: c,
              borderWidth: 2.5,
              shadow: [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 14, spreadRadius: 1)],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                p.nickname,
                maxLines: 1,
                style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        who(me),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text('対', style: s.glyph(32, color: t.gold)),
        ),
        who(rival),
      ],
    );
  }
}
