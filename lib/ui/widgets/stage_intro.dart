import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../fx/sfx.dart';
import '../theme/hex_theme.dart';
import '../theme/ui_style.dart';
import 'avatar_face.dart';
import 'duel_scoreboard.dart';
import 'skin_kit.dart';
import 'star_row.dart';

/// Presentación de una etapa (campaña, desafío o problema) a pantalla
/// completa, antes de la partida. En la partida solo queda el objetivo.
/// Entra por partes: el título, el objetivo, los dos retratos desde los
/// costados y el 対 que cae como un sello.
class StageIntro extends StatefulWidget {
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

  /// Releer la viñeta de esta batalla, o null si no tiene.
  final VoidCallback? onReplay;

  /// Entrar ya; en false espera (una viñeta la tapa).
  final bool play;

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
    this.onReplay,
    this.play = true,
  });

  @override
  State<StageIntro> createState() => _StageIntroState();
}

class _StageIntroState extends State<StageIntro> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  var _stamped = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (!_stamped && _c.value >= 0.72) {
        _stamped = true;
        SoundBoard.instance.play(Sfx.stamp, volume: 0.7);
        Haptics.light();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.play) return;
      if (MediaQuery.of(context).disableAnimations) {
        _stamped = true;
        _c.value = 1;
      } else {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Aparece en el tramo [from]..[to] de la entrada, corrido [dx], [dy] px.
  Widget _in(double from, double to, Widget child, {double dx = 0, double dy = 18, Curve curve = Curves.easeOutCubic}) {
    final a = CurvedAnimation(parent: _c, curve: Interval(from, to, curve: curve));
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(dx * (1 - a.value), dy * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
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
                w.glyph,
                textAlign: TextAlign.center,
                style: s.glyph(190, color: t.accent.withValues(alpha: t.isDark ? 0.12 : 0.1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _in(
                    0,
                    0.4,
                    Column(
                      children: [
                        Text(
                          w.label,
                          style: TextStyle(color: t.gold, fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          w.title,
                          textAlign: TextAlign.center,
                          style: s.display(34, color: ink, height: 1.12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _in(
                    0.1,
                    0.5,
                    Column(
                      children: [
                        Text(
                          w.story,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: t.textMuted, fontSize: 15, height: 1.5),
                        ),
                        if (w.onReplay != null)
                          Pressable(
                            semanticLabel: tr('story.replay'),
                            onTap: w.onReplay!,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('巻', style: s.glyph(15, color: t.gold)),
                                  const SizedBox(width: 6),
                                  Text(
                                    tr('story.replay'),
                                    style: TextStyle(
                                      color: t.gold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                      decorationColor: t.gold.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _in(0.25, 0.6, Container(
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
                          w.goal,
                          textAlign: TextAlign.center,
                          style: s.display(20, color: ink, height: 1.25),
                        ),
                        if (w.stars != null) ...[
                          const SizedBox(height: 10),
                          StarRow(stars: w.stars!, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            starGoalsLine(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted, fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  )),
                  const SizedBox(height: 22),
                  _duel(t, s),
                  if (w.rivalLine != null) ...[
                    const SizedBox(height: 6),
                    _in(0.7, 0.9, Text(w.rivalLine!, style: TextStyle(color: t.textMuted, fontSize: 14))),
                  ],
                  const Spacer(flex: 4),
                  _in(0.78, 1, SkinPrimaryButton(label: tr('common.start'), glyph: '始', onPressed: w.onStart)),
                ],
              ),
            ),
            Positioned(
              top: 4,
              left: 8,
              child: IconButton(
                tooltip: w.backTooltip,
                onPressed: w.onBack,
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
    Widget who(PlayerProfile p, double dx) {
      final c = HexTheme.faction(p.faction);
      return Expanded(
        child: _in(0.35, 0.72, dx: dx, dy: 0, curve: Curves.easeOutBack, Column(
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
        )),
      );
    }

    // El 対 cae como un sello: grande y transparente, se aplasta en su lugar.
    final stamp = CurvedAnimation(parent: _c, curve: const Interval(0.6, 0.74, curve: Curves.easeInCubic));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        who(widget.me, -90),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: AnimatedBuilder(
            animation: stamp,
            builder: (_, c) => Opacity(
              opacity: stamp.value,
              child: Transform.scale(scale: 2.6 - 1.6 * stamp.value, child: c),
            ),
            child: Text('対', style: s.glyph(32, color: t.gold)),
          ),
        ),
        who(widget.rival, 90),
      ],
    );
  }
}
