import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../engine/pieces.dart';
import '../theme/hex_theme.dart';
import 'avatar_face.dart';
import 'emotes.dart';
import 'skin_kit.dart';

/// Identidad de un jugador en pantalla. Hoy es local; mañana vendrá del perfil
/// online (avatar desbloqueado, marco, título…), sin cambiar la UI.
class PlayerProfile {
  final String nickname;
  final Faction faction;
  final bool isAi;

  /// Avatar: id del catálogo (`Avatars`) o, si no está, un carácter.
  final String avatar;

  /// Puntos de la partida por puntos (null = partida casual).
  final int? rating;

  /// Marco del avatar (`Cosmetics.frames`), null = sin marco.
  final String? frame;

  const PlayerProfile({
    required this.nickname,
    required this.faction,
    this.isAi = false,
    String? avatar,
    this.rating,
    this.frame,
  }) : avatar = avatar ?? (faction == Faction.shaolin ? '僧' : '将');
}

/// Estado de un jugador para el marcador.
class DuelSide {
  final PlayerProfile profile;
  final bool active;
  final int handCount;
  final int cooldown;

  /// Usos de habilidad restantes (null = ilimitados).
  final int? charges;
  final Emote? emote;
  final int emoteKey;
  final VoidCallback? onEmote;

  const DuelSide({
    required this.profile,
    required this.active,
    required this.handCount,
    required this.cooldown,
    this.charges,
    this.emote,
    this.emoteKey = 0,
    this.onEmote,
  });
}

/// Marcador de duelo: vos a la izquierda, el rival a la derecha y la ronda en
/// el medio. Una línea del color de la facción marca de quién es el turno y
/// el que espera queda atenuado. Los emotes salen como globo debajo.
class DuelScoreboard extends StatelessWidget {
  final DuelSide me;
  final DuelSide rival;
  final Widget center;
  const DuelScoreboard({super.key, required this.me, required this.rival, required this.center});

  @override
  Widget build(BuildContext context) {
    final active = me.active ? me : (rival.active ? rival : null);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SkinBar(
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
                child: Row(
                  children: [
                    Expanded(child: _Side(me, mirror: false)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 52),
                      child: Center(child: center),
                    ),
                    Expanded(child: _Side(rival, mirror: true)),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: active == rival ? Alignment.bottomRight : Alignment.bottomLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.4,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      height: 3,
                      color: active == null
                          ? Colors.transparent
                          : HexTheme.faction(active.profile.faction).withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final (side, left) in [(me, true), (rival, false)])
          if (side.emote != null)
            Positioned(
              top: 58,
              left: left ? 8 : null,
              right: left ? null : 8,
              child: EmoteBubble(
                key: ValueKey(side.emoteKey),
                emote: side.emote!,
                faction: side.profile.faction,
                pointUp: true,
                fromRight: !left,
              ),
            ),
      ],
    );
  }
}

class _Side extends StatelessWidget {
  final DuelSide s;
  final bool mirror;
  const _Side(this.s, {required this.mirror});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = HexTheme.faction(s.profile.faction);
    final p = s.profile;
    // Los puntos sí; la etiqueta de IA no entra (el nivel ya va en el nombre).
    final tag = p.rating != null ? '${p.rating}' : null;
    final info = Column(
      crossAxisAlignment: mirror ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: mirror ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Nombres largos («Sensei · Aprendiz») se achican antes de cortarse.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: mirror ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  p.nickname,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: t.text, height: 1.15),
                ),
              ),
            ),
            if (tag != null) ...[const SizedBox(width: 4), _tag(tag, t)],
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: mirror ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Tooltip(
                message: tr('banner.inHand'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hexagon_outlined, size: 16, color: t.textMuted),
                    const SizedBox(width: 2),
                    Text(
                      '${s.handCount}',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: t.textMuted, height: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _cooldown(t, color),
            ],
          ),
        ),
      ],
    );
    final avatar = _Avatar(profile: p, color: color, active: s.active, onTap: s.onEmote);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: s.active ? 1 : 0.55,
      child: Row(
        textDirection: mirror ? TextDirection.rtl : TextDirection.ltr,
        children: [
          avatar,
          const SizedBox(width: 8),
          Flexible(child: info),
        ],
      ),
    );
  }

  Widget _tag(String s, HexTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(color: t.outline, borderRadius: BorderRadius.circular(5)),
    child: Text(
      s,
      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: t.textMuted),
    ),
  );

  /// Tres pips de recarga de la habilidad; brillan cuando está lista.
  Widget _cooldown(HexTheme t, Color color) {
    final spent = s.charges == 0;
    final ready = s.cooldown == 0 && !spent;
    final uses = s.charges == null ? '' : tr('banner.uses', {'n': s.charges!});
    return Tooltip(
      message: spent
          ? tr('banner.spent', {'ability': s.profile.faction.abilityName})
          : ready
          ? tr('banner.ready', {'ability': s.profile.faction.abilityName, 'uses': uses})
          : tr('banner.cooldown', {'n': s.cooldown, 'uses': uses}),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: spent
                    ? t.outline
                    : ready
                    ? t.gold
                    : i >= s.cooldown
                    ? color
                    : t.outline,
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final PlayerProfile profile;
  final Color color;
  final bool active;
  final VoidCallback? onTap;
  const _Avatar({required this.profile, required this.color, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    const size = 46.0;
    final face = AvatarFace(
      avatar: profile.avatar,
      frame: profile.frame,
      size: size,
      color: color,
      borderColor: active ? t.gold : t.surfaceHigh,
      shadow: [if (active) BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 8, spreadRadius: 1)],
    );
    if (onTap == null) return face;
    return Tooltip(
      message: tr('banner.emote'),
      child: Pressable(onTap: onTap, child: face),
    );
  }
}

/// Globo de emote que sale del avatar.
class EmoteBubble extends StatefulWidget {
  final Emote emote;
  final Faction faction;
  final bool pointUp;

  /// El globo cuelga desde la derecha (rival en el marcador).
  final bool fromRight;
  const EmoteBubble({
    super.key,
    required this.emote,
    required this.faction,
    required this.pointUp,
    this.fromRight = false,
  });

  @override
  State<EmoteBubble> createState() => _EmoteBubbleState();
}

class _EmoteBubbleState extends State<EmoteBubble> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final up = widget.pointUp;
    final right = widget.fromRight;
    const tip = Radius.circular(4), round = Radius.circular(16);
    return ScaleTransition(
      alignment: up
          ? (right ? Alignment.topRight : Alignment.topLeft)
          : (right ? Alignment.bottomRight : Alignment.bottomLeft),
      scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: up && !right ? tip : round,
            topRight: up && right ? tip : round,
            bottomLeft: !up && !right ? tip : round,
            bottomRight: !up && right ? tip : round,
          ),
          boxShadow: [BoxShadow(color: t.shadow, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmoteGlyph(widget.emote, faction: widget.faction, size: 54),
            const SizedBox(width: 4),
            Text(
              widget.emote.label,
              style: TextStyle(fontWeight: FontWeight.w800, color: t.text),
            ),
          ],
        ),
      ),
    );
  }
}
