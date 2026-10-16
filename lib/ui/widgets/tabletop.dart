import 'package:flutter/material.dart';

import '../theme/hex_theme.dart';

/// Bandeja apoyada sobre la mesa: canto con filete de metal (oro o latón),
/// biselado (luz arriba, sombra abajo) y sombra de objeto pesado.
class Tray extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const Tray({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    const radius = BorderRadius.all(Radius.circular(10));
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        // Canto: un tono más oscuro que la superficie, como el borde de una caja.
        color: Color.lerp(t.surfaceHigh, Colors.black, t.isDark ? 0.35 : 0.18),
        border: Border.all(color: t.gold.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withValues(alpha: t.shadow.a * 0.55),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: t.shadow.withValues(alpha: t.shadow.a * 0.4),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 5),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.surfaceHigh, t.surface],
          ),
        ),
        // Bisel: filo de luz arriba y sombra abajo.
        foregroundDecoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: t.isDark ? 0.07 : 0.6),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: t.isDark ? 0.35 : 0.08),
            ],
            stops: const [0, 0.03, 0.96, 1],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Botón principal como un sello (hanko) tallado: bloque del color de la
/// facción con marco interior. Al tocarlo "estampa" (baja y se oscurece).
class SealButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  const SealButton({super.key, required this.label, this.icon, this.onPressed, this.height = 58});

  @override
  State<SealButton> createState() => _SealButtonState();
}

class _SealButtonState extends State<SealButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final base = t.accent;
    final enabled = widget.onPressed != null;
    final ink = Colors.white.withValues(alpha: enabled ? 0.95 : 0.5);
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onPressed!();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: widget.height,
          transform: Matrix4.translationValues(0, _down ? 3 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(base, Colors.white, _down ? 0.0 : 0.12)!,
                Color.lerp(base, Colors.black, _down ? 0.35 : 0.22)!,
              ],
            ),
            boxShadow: [
              // Cuerpo del sello: el canto se ve debajo hasta que se aprieta.
              BoxShadow(color: Color.lerp(base, Colors.black, 0.55)!, offset: Offset(0, _down ? 1 : 4)),
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.5),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ink.withValues(alpha: 0.55), width: 1.4),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[Icon(widget.icon, color: ink, size: 24), const SizedBox(width: 10)],
                Flexible(
                  child: Text(
                    widget.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario como una placa de madera con filete de metal.
class PlaqueButton extends StatelessWidget {
  final Widget label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  const PlaqueButton({super.key, required this.label, this.icon, this.onPressed, this.height = 50});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.text,
          backgroundColor: t.surface.withValues(alpha: 0.7),
          side: BorderSide(color: t.gold, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          elevation: 2,
          shadowColor: t.shadow,
        ),
        icon: icon == null ? null : Icon(icon, color: t.gold),
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}
