import 'package:flutter/material.dart';

import '../theme/hex_theme.dart';

/// Tarjeta superior en problemas, desafíos y campaña: título, objetivo y,
/// en los problemas, los turnos que quedan.
class StageCard extends StatelessWidget {
  final String label;
  final String title;
  final String goal;
  final String? hint;
  final int? turnsLeft;

  const StageCard({super.key, required this.label, required this.title, required this.goal, this.hint, this.turnsLeft});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.gold.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withValues(alpha: t.shadow.a * 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(color: t.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                Text(
                  title,
                  style: TextStyle(color: t.text, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  goal,
                  style: TextStyle(color: t.text, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(hint!, style: TextStyle(color: t.textMuted, fontSize: 12)),
                  ),
              ],
            ),
          ),
          if (turnsLeft != null) ...[
            const SizedBox(width: 10),
            _TurnsBadge(turnsLeft!),
          ],
        ],
      ),
    );
  }
}

class _TurnsBadge extends StatelessWidget {
  final int turns;
  const _TurnsBadge(this.turns);

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = turns <= 1 ? t.danger : t.gold;
    return Tooltip(
      message: 'Turnos que te quedan',
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(
              '${turns.clamp(0, 99)}',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, height: 1),
            ),
            Text(
              turns == 1 ? 'turno' : 'turnos',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
