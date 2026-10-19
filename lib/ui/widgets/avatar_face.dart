import 'package:flutter/material.dart';

import '../../codex/avatars.dart';
import '../../codex/cosmetics.dart';

/// Avatar redondo: el retrato si [avatar] está en el catálogo; si no, el
/// carácter sobre un disco del color de la facción. Con [frame], el aro va por
/// fuera del círculo sin cambiar el tamaño que ocupa en el layout.
class AvatarFace extends StatelessWidget {
  final String avatar;
  final double size;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadow;

  /// Id del marco (`Cosmetics.frames`); null = sin marco.
  final String? frame;

  const AvatarFace({
    super.key,
    required this.avatar,
    required this.size,
    required this.color,
    required this.borderColor,
    this.borderWidth = 1.6,
    this.shadow,
    this.frame,
  });

  /// El hueco del aro mide ~70% de la imagen: así cubre justo el borde del avatar.
  static const frameScale = 1.4;

  @override
  Widget build(BuildContext context) {
    final ring = Cosmetics.frame(frame);
    final face = _face();
    if (ring == null) return face;
    final f = size * frameScale;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          Positioned(
            left: (size - f) / 2,
            top: (size - f) / 2,
            width: f,
            height: f,
            child: IgnorePointer(
              child: Image.asset(ring.asset, width: f, height: f, filterQuality: FilterQuality.medium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _face() {
    final def = Avatars.byId(avatar);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: def != null
            ? null
            : RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [Color.lerp(color, Colors.white, 0.25)!, Color.lerp(color, Colors.black, 0.35)!],
              ),
        boxShadow: shadow,
      ),
      // El borde va encima, para que el retrato no lo tape.
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: def != null
          ? Image.asset(def.asset, width: size, height: size, fit: BoxFit.cover, filterQuality: FilterQuality.medium)
          : Text(
              avatar,
              style: TextStyle(fontSize: size * 0.48, color: Colors.white, fontWeight: FontWeight.w800, height: 1),
            ),
    );
  }
}
