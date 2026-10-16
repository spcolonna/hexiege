import 'dart:math';

import 'package:flutter/material.dart';

import '../fx/sfx.dart';
import '../theme/hex_theme.dart';
import '../theme/ui_style.dart';
import 'tabletop.dart';

// Piezas de interfaz fuera del tablero. Cada una se dibuja según el estilo
// activo ([Skin]): caja de juego (madera tallada), ema (papel, pincel y sello)
// o panal (cortes hexagonales y filete dorado).

/// Madera oscura del interior de la caja (bandejas, tapa, huecos).
Color boxWood(HexTheme t) => Color.lerp(t.backdropBottom, Colors.black, t.isDark ? 0.45 : 0.68)!;

/// Tinta de pincel: el texto en su tono más profundo.
Color inkOf(HexTheme t) => t.isDark ? t.text : Color.lerp(t.text, Colors.black, 0.2)!;

/// Rojo del sello (hanko); igual en las dos facciones.
const hankoRed = Color(0xFFB8323F);

/// Corte de 45° en las esquinas: la forma base del estilo panal.
ShapeBorder combShape(double cut, {BorderSide side = BorderSide.none}) =>
    BeveledRectangleBorder(borderRadius: BorderRadius.circular(cut), side: side);

/// Hexágono de punta arriba inscrito en [r].
Path hexPath(Rect r) {
  final c = r.center;
  final rx = r.width / 2, ry = r.height / 2;
  final p = Path();
  for (var i = 0; i < 6; i++) {
    final a = -pi / 2 + pi / 3 * i;
    final v = Offset(c.dx + rx * cos(a), c.dy + ry * sin(a));
    i == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
  }
  return p..close();
}

class HexClipper extends CustomClipper<Path> {
  const HexClipper();
  @override
  Path getClip(Size size) => hexPath(Offset.zero & size);
  @override
  bool shouldReclip(HexClipper oldClipper) => false;
}

/// Toque con sonido y vibración suaves, igual en todos los botones.
void skinTap() {
  SoundBoard.instance.play(Sfx.tick);
  Haptics.select();
}

/// Escala levemente hacia abajo mientras se mantiene apretado.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double depth;
  const Pressable({super.key, required this.child, this.onTap, this.semanticLabel, this.depth = 0.97});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? widget.depth : 1,
          duration: const Duration(milliseconds: 90),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Canto de un compartimento de la caja: un labio de madera debajo y sombra.
List<BoxShadow> _boxLip(HexTheme t) => [
  BoxShadow(color: Color.lerp(t.surface, boxWood(t), t.isDark ? 0.5 : 0.35)!, offset: const Offset(0, 3)),
  BoxShadow(
    color: t.shadow.withValues(alpha: t.shadow.a * 0.35),
    blurRadius: 8,
    offset: const Offset(0, 5),
  ),
];

// ------------------------------------------------------------------ insignias

/// Kanji en su soporte: sello tallado (caja), hanko rojo (ema) o casilla
/// hexagonal (panal). Reemplaza a los íconos genéricos.
class KanjiBadge extends StatelessWidget {
  final String glyph;
  final double size;

  /// Color del soporte; por defecto el de la facción (o rojo hanko en ema).
  final Color? color;

  /// Sobre un fondo de color: la insignia va hueca con trazo claro.
  final bool onColor;
  const KanjiBadge(this.glyph, {super.key, this.size = 30, this.color, this.onColor = false});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final ink = Colors.white.withValues(alpha: 0.95);
    switch (s.style) {
      case UiStyle.box:
        final c = color ?? t.accent;
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onColor ? null : c,
            borderRadius: BorderRadius.circular(size * 0.14),
            border: Border.all(color: onColor ? ink.withValues(alpha: 0.7) : Colors.black26, width: 1.4),
          ),
          child: Text(glyph, style: s.glyph(size * 0.56, color: ink)),
        );
      case UiStyle.ema:
        final c = color ?? hankoRed;
        return Transform.rotate(
          angle: -0.06,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onColor ? null : c,
              borderRadius: BorderRadius.circular(size * 0.1),
              border: onColor ? Border.all(color: ink, width: 1.6) : null,
            ),
            child: Text(glyph, style: s.glyph(size * 0.66, color: ink)),
          ),
        );
      case UiStyle.comb:
        final c = color ?? t.accent;
        return SizedBox(
          width: size,
          height: size * 1.1547,
          child: CustomPaint(
            painter: _HexFill(onColor ? Colors.white.withValues(alpha: 0.18) : c, onColor ? ink : t.gold),
            child: Center(
              child: Text(glyph, style: s.glyph(size * 0.5, color: ink)),
            ),
          ),
        );
    }
  }
}

class _HexFill extends CustomPainter {
  final Color fill;
  final Color rim;
  _HexFill(this.fill, this.rim);

  @override
  void paint(Canvas canvas, Size size) {
    final p = hexPath(Offset.zero & size);
    canvas.drawPath(p, Paint()..color = fill);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = rim,
    );
  }

  @override
  bool shouldRepaint(_HexFill old) => old.fill != fill || old.rim != rim;
}

// ------------------------------------------------------------------ paneles

/// Superficie para agrupar contenido.
class SkinPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Borde resaltado (por ejemplo, algo completado o recomendado).
  final Color? highlight;
  const SkinPanel({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.highlight});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    switch (Skin.of(context).style) {
      case UiStyle.box:
        return Tray(padding: padding, child: child);
      case UiStyle.ema:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: t.surfaceHigh,
            border: Border(
              top: BorderSide(color: highlight ?? inkOf(t).withValues(alpha: 0.5), width: 1.2),
              bottom: BorderSide(color: highlight ?? inkOf(t).withValues(alpha: 0.5), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      case UiStyle.comb:
        return Container(
          padding: padding,
          decoration: ShapeDecoration(
            shape: combShape(12, side: BorderSide(color: highlight ?? t.gold.withValues(alpha: 0.75), width: 1.3)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [t.surfaceHigh, t.surface],
            ),
            shadows: [
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
    }
  }
}

/// Superficie fina que flota sobre el tablero (marcador, mano, chips): menos
/// peso que [SkinPanel] para no tapar la partida.
class SkinBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? highlight;
  const SkinBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(6),
    this.radius = 16,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final shadow = BoxShadow(
      color: t.shadow.withValues(alpha: t.shadow.a * 0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );
    return switch (Skin.of(context).style) {
      UiStyle.box => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: highlight ?? t.outline),
          boxShadow: _boxLip(t),
        ),
        child: child,
      ),
      UiStyle.ema => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          border: Border(
            top: BorderSide(color: highlight ?? inkOf(t).withValues(alpha: 0.55), width: 1.2),
            bottom: BorderSide(color: highlight ?? inkOf(t).withValues(alpha: 0.55), width: 1.2),
          ),
          boxShadow: [shadow],
        ),
        child: child,
      ),
      UiStyle.comb => Container(
        padding: padding,
        decoration: ShapeDecoration(
          shape: combShape(
            radius * 0.6,
            side: BorderSide(color: highlight ?? t.gold.withValues(alpha: 0.75), width: 1.2),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.surfaceHigh, t.surface],
          ),
          shadows: [shadow],
        ),
        child: child,
      ),
    };
  }
}

// ------------------------------------------------------------------ botones

/// Acción principal de una pantalla o popup.
class SkinPrimaryButton extends StatelessWidget {
  final String label;
  final String? glyph;
  final String? sub;
  final VoidCallback? onPressed;
  final double height;

  /// Color del bloque; por defecto el de la facción.
  final Color? color;
  const SkinPrimaryButton({
    super.key,
    required this.label,
    this.glyph,
    this.sub,
    this.onPressed,
    this.height = 58,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final base = color ?? t.accent;
    final enabled = onPressed != null;
    final ink = Colors.white.withValues(alpha: enabled ? 0.97 : 0.55);
    final compact = height < 52;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: glyph == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: s.style == UiStyle.ema
              ? s.display(compact ? 20 : 26, color: ink, height: 1.05)
              : TextStyle(color: ink, fontSize: compact ? 15 : 19, fontWeight: FontWeight.w900, height: 1.15),
        ),
        if (sub != null)
          Text(
            sub!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ink.withValues(alpha: 0.82), fontSize: 12, fontWeight: FontWeight.w500),
          ),
      ],
    );
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
      child: Row(
        mainAxisAlignment: glyph == null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (glyph != null) ...[KanjiBadge(glyph!, size: compact ? 24 : 32, onColor: true), const SizedBox(width: 12)],
          Flexible(child: text),
        ],
      ),
    );
    Widget body;
    switch (s.style) {
      case UiStyle.box:
        body = Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.lerp(base, Colors.white, 0.1)!, Color.lerp(base, Colors.black, 0.2)!],
            ),
            boxShadow: [
              BoxShadow(color: Color.lerp(base, Colors.black, 0.55)!, offset: const Offset(0, 4)),
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.5),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: content,
        );
      case UiStyle.ema:
        body = Container(
          height: height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Color.lerp(base, Colors.black, 0.35)!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.45),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        );
      case UiStyle.comb:
        body = Container(
          height: height,
          decoration: ShapeDecoration(
            shape: combShape(height * 0.32, side: BorderSide(color: t.gold, width: 1.5)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(base, Colors.white, 0.1)!, Color.lerp(base, Colors.black, 0.22)!],
            ),
            shadows: [
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: content,
        );
    }
    return Pressable(
      semanticLabel: label,
      onTap: onPressed == null
          ? null
          : () {
              Haptics.medium();
              onPressed!();
            },
      child: Opacity(opacity: enabled ? 1 : 0.6, child: body),
    );
  }
}

/// Acción secundaria: un compartimento (caja), papel con trazo (ema) o
/// placa con cortes (panal).
class SkinButton extends StatelessWidget {
  final String label;
  final String? glyph;
  final Widget? leading;
  final String? sub;
  final VoidCallback? onPressed;
  final double height;
  final Color? color;
  const SkinButton({
    super.key,
    required this.label,
    this.glyph,
    this.leading,
    this.sub,
    this.onPressed,
    this.height = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final fg = color ?? t.text;
    final lead = leading ?? (glyph == null ? null : KanjiBadge(glyph!, size: 24, color: color));
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: lead == null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (lead != null) ...[lead, const SizedBox(width: 10)],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: lead == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 15, height: 1.2),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: t.textMuted, fontSize: 11.5),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    final Decoration deco = switch (s.style) {
      UiStyle.box => BoxDecoration(color: t.surfaceHigh, borderRadius: BorderRadius.circular(7), boxShadow: _boxLip(t)),
      UiStyle.ema => BoxDecoration(
        color: t.surfaceHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: (color ?? inkOf(t)).withValues(alpha: 0.55), width: 1.1),
      ),
      UiStyle.comb => ShapeDecoration(
        shape: combShape(height * 0.28, side: BorderSide(color: color ?? t.gold, width: 1.3)),
        color: t.surfaceHigh.withValues(alpha: 0.85),
      ),
    };
    return Pressable(
      semanticLabel: label,
      onTap: onPressed == null
          ? null
          : () {
              skinTap();
              onPressed!();
            },
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Container(height: height, decoration: deco, child: content),
      ),
    );
  }
}

/// Acción terciaria: texto solo (subrayado a pincel en ema).
class SkinLink extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  const SkinLink({super.key, required this.label, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final ema = Skin.of(context).style == UiStyle.ema;
    final c = color ?? t.text;
    return Pressable(
      semanticLabel: label,
      onTap: onPressed == null
          ? null
          : () {
              skinTap();
              onPressed!();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: ema
              ? BoxDecoration(
                  border: Border(bottom: BorderSide(color: c.withValues(alpha: 0.5))),
                )
              : null,
          child: Text(
            label,
            style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ progreso

class SkinProgress extends StatelessWidget {
  final double value;
  final Color? color;
  const SkinProgress(this.value, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context).style;
    final c = color ?? t.accent;
    final v = value.clamp(0.0, 1.0);
    if (s == UiStyle.comb) {
      // Una hilera de celdas: cada una se llena al avanzar.
      const n = 10;
      return Row(
        children: [
          for (var i = 0; i < n; i++)
            Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: ShapeDecoration(
                  shape: combShape(3),
                  color: (i + 0.5) / n <= v || (v > 0 && i == 0) ? c : t.outline,
                ),
              ),
            ),
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(s == UiStyle.ema ? 0 : 3),
      child: LinearProgressIndicator(
        value: v,
        minHeight: s == UiStyle.ema ? 3 : 6,
        color: c,
        backgroundColor: t.outline,
      ),
    );
  }
}

// ------------------------------------------------------------------ filas

/// Fila navegable: modos, campañas, etapas.
class SkinTile extends StatelessWidget {
  final String title;
  final String? text;
  final String? glyph;
  final Widget? leading;
  final Widget? trailing;
  final double? progress;
  final Color? color;
  final bool highlight;
  final VoidCallback? onTap;
  const SkinTile({
    super.key,
    required this.title,
    this.text,
    this.glyph,
    this.leading,
    this.trailing,
    this.progress,
    this.color,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final lead = leading ?? (glyph == null ? null : KanjiBadge(glyph!, size: 36, color: color));
    final body = Row(
      children: [
        if (lead != null) ...[lead, const SizedBox(width: 14)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: s.style == UiStyle.ema
                    ? s.display(22, color: t.text)
                    : TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: t.text, height: 1.2),
              ),
              if (text != null) ...[
                const SizedBox(height: 2),
                Text(text!, style: TextStyle(fontSize: 13, color: t.textMuted, height: 1.35)),
              ],
              if (progress != null) ...[const SizedBox(height: 8), SkinProgress(progress!, color: color)],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
    final hl = highlight ? (color ?? t.gold) : null;
    final Widget framed = switch (s.style) {
      UiStyle.box => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          borderRadius: BorderRadius.circular(9),
          border: hl == null ? null : Border.all(color: hl, width: 1.5),
          boxShadow: _boxLip(t),
        ),
        child: body,
      ),
      UiStyle.ema => SkinPanel(padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), highlight: hl, child: body),
      UiStyle.comb => SkinPanel(padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), highlight: hl, child: body),
    };
    return Pressable(
      semanticLabel: title,
      depth: 0.985,
      onTap: onTap == null
          ? null
          : () {
              skinTap();
              onTap!();
            },
      child: framed,
    );
  }
}

// ------------------------------------------------------------------ encabezado

/// Encabezado de pantalla: volver, título y un dato a la derecha.
class SkinHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final String backTooltip;
  const SkinHeader({super.key, required this.title, this.subtitle, this.trailing, required this.backTooltip});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: backTooltip,
            icon: Icon(Icons.arrow_back_rounded, color: t.text),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: s.display(s.style == UiStyle.ema ? 32 : 26, color: t.text)),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(subtitle!, style: TextStyle(fontSize: 13, color: t.textMuted)),
              ],
            ),
          ),
          if (trailing != null) Text(trailing!, style: s.display(20, color: t.gold)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ selectores

class SkinOption<T> {
  final T value;
  final String label;
  const SkinOption(this.value, this.label);
}

/// Elegir una opción entre pocas (tema, idioma…).
class SkinChoice<T> extends StatelessWidget {
  final List<SkinOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  const SkinChoice({super.key, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context).style;
    Widget option(SkinOption<T> o) {
      final on = o.value == selected;
      final label = Text(
        o.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: on ? FontWeight.w900 : FontWeight.w500,
          color: on ? (s == UiStyle.ema ? t.text : (s == UiStyle.comb ? Colors.white : t.text)) : t.textMuted,
        ),
      );
      final Decoration? deco = switch (s) {
        UiStyle.box =>
          on
              ? BoxDecoration(
                  color: t.surfaceHigh,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 3, offset: const Offset(0, 2)),
                  ],
                )
              : null,
        UiStyle.ema =>
          on
              ? BoxDecoration(
                  border: Border(bottom: BorderSide(color: hankoRed, width: 2)),
                )
              : null,
        UiStyle.comb => ShapeDecoration(
          shape: combShape(8, side: BorderSide(color: on ? t.gold : t.outline)),
          color: on ? t.accent : Colors.transparent,
        ),
      };
      return Expanded(
        child: Pressable(
          semanticLabel: o.label,
          onTap: () {
            if (on) return;
            skinTap();
            onChanged(o.value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 38,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            margin: EdgeInsets.symmetric(horizontal: s == UiStyle.comb ? 3 : 0),
            decoration: deco,
            child: label,
          ),
        ),
      );
    }

    final row = Row(children: [for (final o in options) option(o)]);
    return switch (s) {
      UiStyle.box => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: boxWood(t).withValues(alpha: t.isDark ? 0.8 : 0.16),
          borderRadius: BorderRadius.circular(8),
        ),
        child: row,
      ),
      UiStyle.ema => Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.outline)),
        ),
        child: row,
      ),
      UiStyle.comb => row,
    };
  }
}

/// Interruptor con su etiqueta.
class SkinToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SkinToggle({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.text),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: t.accent,
            onChanged: (v) {
              skinTap();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

/// Rótulo de una sección dentro de una hoja o popup.
class SkinLabel extends StatelessWidget {
  final String text;
  const SkinLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.textMuted),
      ),
    );
  }
}

// ------------------------------------------------------------------ popups

class SkinAction {
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool danger;
  final String? glyph;
  const SkinAction(this.label, this.onPressed, {this.primary = false, this.danger = false, this.glyph});
}

/// Popup con el marco del estilo: la tapa de la caja, un rollo de papel con
/// sello o una placa con medalla hexagonal.
class SkinDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? body;

  /// Kanji del emblema (medalla, sello o insignia del título).
  final String? glyph;
  final Color? glyphColor;
  final List<SkinAction> actions;
  final CrossAxisAlignment align;
  const SkinDialog({
    super.key,
    required this.title,
    this.message,
    this.body,
    this.glyph,
    this.glyphColor,
    this.actions = const [],
    this.align = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final ema = s.style == UiStyle.ema;
    final center = align == CrossAxisAlignment.center && !ema;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: ema ? CrossAxisAlignment.start : align,
      children: [
        if (glyph != null && s.style == UiStyle.box) ...[
          KanjiBadge(glyph!, size: 40, color: glyphColor),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: EdgeInsets.only(right: ema && glyph != null ? 64 : 0),
          child: Text(
            title,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: s.display(ema ? 40 : 30, color: t.text),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: 15, color: t.textMuted, height: 1.4),
          ),
        ],
        if (body != null) ...[const SizedBox(height: 14), body!],
        if (actions.isNotEmpty) ...[const SizedBox(height: 20), _actions(context)],
      ],
    );
    final scroll = Flexible(child: SingleChildScrollView(child: content));
    final framed = switch (s.style) {
      UiStyle.box => _BoxLid(child: scroll),
      UiStyle.ema => _EmaScroll(glyph: glyph, child: scroll),
      UiStyle.comb => _CombPlate(glyph: glyph, glyphColor: glyphColor, child: scroll),
    };
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: framed),
    );
  }

  Widget _actions(BuildContext context) {
    final links = [
      for (final a in actions)
        if (!a.primary) a,
    ];
    final main = actions.where((a) => a.primary).firstOrNull;
    final t = HexTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (main != null)
          SkinPrimaryButton(
            label: main.label,
            glyph: main.glyph,
            height: 50,
            color: main.danger ? t.danger : null,
            onPressed: main.onPressed,
          ),
        if (links.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: main == null ? 0 : 6),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (final a in links)
                  SkinLink(label: a.label, onPressed: a.onPressed, color: a.danger ? t.danger : null),
              ],
            ),
          ),
      ],
    );
  }
}

Future<T?> showSkinDialog<T>(BuildContext context, {required WidgetBuilder builder, bool dismissible = true}) =>
    showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: builder,
    );

class _BoxLid extends StatelessWidget {
  final Widget child;
  const _BoxLid({required this.child});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: boxWood(t),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.gold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 18))],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
      ),
    );
  }
}

class _EmaScroll extends StatelessWidget {
  final Widget child;
  final String? glyph;
  const _EmaScroll({required this.child, this.glyph});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    Widget roller() => Container(
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A2326), Color(0xFF1A0B0C)],
        ),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        roller(),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: t.surfaceHigh,
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 14))],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
                ),
                if (glyph != null)
                  Positioned(
                    right: 18,
                    top: 18,
                    child: Transform.rotate(
                      angle: 0.14,
                      child: Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: hankoRed.withValues(alpha: 0.85), width: 2.6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(glyph!, style: s.glyph(30, color: hankoRed.withValues(alpha: 0.9))),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        roller(),
      ],
    );
  }
}

class _CombPlate extends StatelessWidget {
  final Widget child;
  final String? glyph;
  final Color? glyphColor;
  const _CombPlate({required this.child, this.glyph, this.glyphColor});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    const medal = 64.0;
    final plate = Container(
      padding: EdgeInsets.fromLTRB(20, glyph == null ? 22 : medal * 0.62, 20, 14),
      decoration: ShapeDecoration(
        shape: combShape(20, side: BorderSide(color: t.gold, width: 1.5)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.surfaceHigh, Color.lerp(t.surfaceHigh, t.surface, 0.8)!],
        ),
        shadows: const [BoxShadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 18))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
    );
    if (glyph == null) return plate;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: medal * 0.55),
          child: plate,
        ),
        SizedBox(
          width: medal,
          height: medal * 1.1547,
          child: CustomPaint(
            painter: _HexFill(glyphColor ?? boxWood(t), t.gold),
            child: Center(
              child: Text(glyph!, style: s.glyph(30, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ hojas

/// Hoja inferior con el marco del estilo. [child] puede ser largo: se desplaza.
Future<T?> showSkinSheet<T>(BuildContext context, {String? title, required WidgetBuilder builder}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      builder: (ctx) => _SkinSheet(title: title, child: builder(ctx)),
    );

class _SkinSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  const _SkinSheet({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final inner = SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _handle(t, s.style)),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: Text(title!, style: s.display(s.style == UiStyle.ema ? 36 : 26, color: t.text)),
            ),
          Flexible(
            child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 6, 22, 18), child: child),
          ),
        ],
      ),
    );
    return switch (s.style) {
      UiStyle.box => Container(
        decoration: BoxDecoration(
          color: boxWood(t),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(top: BorderSide(color: t.gold.withValues(alpha: 0.6), width: 1.2)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Container(
          decoration: BoxDecoration(
            color: t.surfaceHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
          ),
          child: inner,
        ),
      ),
      UiStyle.ema => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 14,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A2326), Color(0xFF1A0B0C)],
              ),
            ),
          ),
          Flexible(
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 6), color: t.surfaceHigh, child: inner),
          ),
        ],
      ),
      UiStyle.comb => Container(
        decoration: ShapeDecoration(
          color: t.surfaceHigh,
          shape: BeveledRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            side: BorderSide(color: t.gold, width: 1.5),
          ),
        ),
        child: inner,
      ),
    };
  }

  Widget _handle(HexTheme t, UiStyle s) => Container(
    margin: const EdgeInsets.only(top: 10, bottom: 4),
    width: s == UiStyle.comb ? 22 : 40,
    height: s == UiStyle.comb ? 12 : 5,
    decoration: s == UiStyle.comb
        ? ShapeDecoration(shape: combShape(5), color: t.gold.withValues(alpha: 0.7))
        : BoxDecoration(
            color: s == UiStyle.box ? boxWood(t).withValues(alpha: 0.35) : hankoRed.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(3),
          ),
  );
}
