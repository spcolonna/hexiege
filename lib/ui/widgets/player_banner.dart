import 'dart:math';

import 'package:flutter/material.dart';

import '../../engine/pieces.dart';
import '../theme/hex_theme.dart';
import 'emotes.dart';

/// Identidad de un jugador en pantalla. Hoy es local; mañana vendrá del perfil
/// online (avatar desbloqueado, marco, título…), sin cambiar la UI.
class PlayerProfile {
  final String nickname;
  final Faction faction;
  final bool isAi;

  /// Avatar: por ahora un glifo/emoji; luego una imagen o un cosmético.
  final String avatar;

  /// Puntos de la partida por puntos (null = partida casual).
  final int? rating;

  const PlayerProfile({required this.nickname, required this.faction, this.isAi = false, String? avatar, this.rating})
    : avatar = avatar ?? (faction == Faction.shaolin ? '僧' : '将');
}

/// Barra de jugador: avatar, nick, facción, fichas en mano, recarga de la
/// habilidad y globo de emote. [top] = oponente (el globo sale hacia abajo).
class PlayerBanner extends StatefulWidget {
  final PlayerProfile profile;
  final int owner;
  final bool active;
  final bool top;
  final int handCount;
  final int cooldown;
  final Emote? emote;
  final int emoteKey;
  final VoidCallback? onEmote;
  final Widget? trailing;

  const PlayerBanner({
    super.key,
    required this.profile,
    required this.owner,
    required this.active,
    required this.top,
    required this.handCount,
    required this.cooldown,
    this.emote,
    this.emoteKey = 0,
    this.onEmote,
    this.trailing,
  });

  @override
  State<PlayerBanner> createState() => _PlayerBannerState();
}

class _PlayerBannerState extends State<PlayerBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    if (widget.active) _spin.repeat();
  }

  @override
  void didUpdateWidget(PlayerBanner old) {
    super.didUpdateWidget(old);
    if (widget.active && !_spin.isAnimating) _spin.repeat();
    if (!widget.active && _spin.isAnimating) _spin.stop();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = HexTheme.faction(widget.profile.faction);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.active ? color.withValues(alpha: 0.8) : t.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withValues(alpha: t.shadow.a * 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (widget.active) BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: -2),
        ],
      ),
      child: Row(
        children: [
          _avatar(t, color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.profile.nickname,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: t.text),
                      ),
                    ),
                    if (widget.profile.isAi) ...[const SizedBox(width: 6), _tag('IA', t)],
                    if (widget.profile.rating != null) ...[
                      const SizedBox(width: 6),
                      _tag('${widget.profile.rating}', t),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.profile.faction.displayName,
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _stat(t, Icons.hexagon_outlined, '${widget.handCount}', 'Fichas en mano'),
          const SizedBox(width: 6),
          _cooldown(t, color),
          if (widget.onEmote != null) ...[
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Emote',
              onPressed: widget.onEmote,
              icon: Icon(Icons.add_reaction_outlined, color: t.textMuted),
            ),
          ],
          ?widget.trailing,
        ],
      ),
    );
  }

  Widget _avatar(HexTheme t, Color color) {
    const size = 46.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (widget.active)
            AnimatedBuilder(
              animation: _spin,
              builder: (_, _) => Transform.rotate(
                angle: _spin.value * 2 * pi,
                child: Container(
                  width: size + 6,
                  height: size + 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [color, t.gold, color.withValues(alpha: 0.1), color]),
                  ),
                ),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [Color.lerp(color, Colors.white, 0.25)!, Color.lerp(color, Colors.black, 0.35)!],
              ),
              border: Border.all(color: t.surfaceHigh, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.profile.avatar,
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800, height: 1),
            ),
          ),
          if (widget.emote != null)
            Positioned(
              left: size - 6,
              top: widget.top ? size - 8 : null,
              bottom: widget.top ? null : size - 8,
              child: _EmoteBubble(key: ValueKey(widget.emoteKey), emote: widget.emote!, pointUp: widget.top),
            ),
        ],
      ),
    );
  }

  Widget _tag(String s, HexTheme t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(color: t.outline, borderRadius: BorderRadius.circular(6)),
    child: Text(
      s,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: t.textMuted),
    ),
  );

  Widget _stat(HexTheme t, IconData icon, String value, String tip) => Tooltip(
    message: tip,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: t.textMuted),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w800, color: t.text),
        ),
      ],
    ),
  );

  /// Tres pips de recarga de la habilidad; brillan cuando está lista.
  Widget _cooldown(HexTheme t, Color color) {
    final ready = widget.cooldown == 0;
    return Tooltip(
      message: ready ? '${widget.profile.faction.abilityName}: lista' : 'Recarga: ${widget.cooldown}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 15, color: ready ? t.gold : t.textMuted),
          const SizedBox(width: 3),
          for (var i = 0; i < 3; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ready || i >= widget.cooldown ? (ready ? t.gold : color) : t.outline,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmoteBubble extends StatefulWidget {
  final Emote emote;
  final bool pointUp;
  const _EmoteBubble({super.key, required this.emote, required this.pointUp});

  @override
  State<_EmoteBubble> createState() => _EmoteBubbleState();
}

class _EmoteBubbleState extends State<_EmoteBubble> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return ScaleTransition(
      alignment: widget.pointUp ? Alignment.topLeft : Alignment.bottomLeft,
      scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.pointUp ? 4 : 16),
            bottomLeft: Radius.circular(widget.pointUp ? 16 : 4),
            topRight: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          boxShadow: [BoxShadow(color: t.shadow, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmoteGlyph(widget.emote, size: 26),
            if (widget.emote.icon != null) ...[
              const SizedBox(width: 6),
              Text(
                widget.emote.label,
                style: TextStyle(fontWeight: FontWeight.w800, color: t.text),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
