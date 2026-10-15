import 'package:flutter/material.dart';

/// Emotes del juego. Son vectoriales (no emojis del sistema) para verse igual
/// en todos los dispositivos y poder convertirse en cosméticos desbloqueables.
enum Emote {
  hello('Hola', Icons.waving_hand_rounded, Color(0xFFF2B33D)),
  nice('Buena', Icons.thumb_up_alt_rounded, Color(0xFF3DBE7A)),
  wow('¡Wow!', Icons.bolt_rounded, Color(0xFFF5D547)),
  think('Hmm…', Icons.psychology_alt_rounded, Color(0xFF7FA8F0)),
  fire('¡Fuego!', Icons.local_fire_department_rounded, Color(0xFFF2703D)),
  smug('Je', Icons.sentiment_very_satisfied_rounded, Color(0xFFE05A8C)),
  oops('Uy', Icons.sentiment_dissatisfied_rounded, Color(0xFFB08CF0)),
  gg('GG', null, Color(0xFFE3BE5A));

  final String label;
  final IconData? icon;
  final Color color;
  const Emote(this.label, this.icon, this.color);
}

class EmoteGlyph extends StatelessWidget {
  final Emote emote;
  final double size;
  const EmoteGlyph(this.emote, {super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    if (emote.icon == null) {
      return Text(
        emote.label,
        style: TextStyle(fontSize: size * 0.72, fontWeight: FontWeight.w900, color: emote.color, height: 1),
      );
    }
    return Icon(
      emote.icon,
      size: size,
      color: emote.color,
      shadows: [Shadow(color: emote.color.withValues(alpha: 0.5), blurRadius: 8)],
    );
  }
}
