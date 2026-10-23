import 'package:flutter/material.dart';

import '../theme/hex_theme.dart';
import 'skin_kit.dart';

/// Una opción cosmética (mesa, piedra, marco): la muestra y su nombre debajo.
/// La elegida lleva borde dorado; la que falta ganar, apagada y con candado.
class CosmeticSwatch extends StatelessWidget {
  final Widget child;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double size;
  final bool round;
  final bool locked;
  const CosmeticSwatch({
    super.key,
    required this.child,
    required this.label,
    required this.selected,
    required this.onTap,
    this.size = 54,
    this.round = false,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Pressable(
      semanticLabel: label,
      onTap: () {
        skinTap();
        onTap();
      },
      child: SizedBox(
        width: size + 14,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              clipBehavior: round ? Clip.none : Clip.antiAlias,
              decoration: BoxDecoration(
                shape: round ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: round ? null : BorderRadius.circular(10),
                boxShadow: [if (selected) BoxShadow(color: t.gold.withValues(alpha: 0.5), blurRadius: 10)],
              ),
              foregroundDecoration: round
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? t.gold : t.outline, width: selected ? 3 : 1.2),
                    ),
              child: locked
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(opacity: 0.3, child: child),
                        Center(
                          child: Icon(Icons.lock_rounded, size: size * 0.38, color: t.textMuted),
                        ),
                      ],
                    )
                  : child,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.15,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? t.text : t.textMuted.withValues(alpha: locked ? 0.6 : 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
