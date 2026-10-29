import 'package:flutter/material.dart';

/// Límites globales de la interfaz, pensada para un teléfono en vertical:
/// - La letra del sistema crece hasta 1,3×; más allá desborda los botones.
/// - En tablet la app ocupa una columna centrada con proporción de teléfono.
class PhoneFrame extends StatelessWidget {
  static const maxTextScale = 1.3;
  static const maxAspect = 0.6; // ancho / alto

  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final tablet = size.shortestSide >= 600;
    final width = tablet && size.width > size.height * maxAspect ? size.height * maxAspect : size.width;
    final scaled = MediaQuery.withClampedTextScaling(maxScaleFactor: maxTextScale, child: child);
    if (width >= size.width) return scaled;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: width,
          child: ClipRect(
            child: MediaQuery(
              data: mq.copyWith(size: Size(width, size.height)),
              child: scaled,
            ),
          ),
        ),
      ),
    );
  }
}
