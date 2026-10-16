import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../codex/gifts.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'codex_screen.dart';
import 'fx/piece_art.dart';
import 'fx/piece_renderer.dart';
import 'fx/sfx.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

/// Galería: las fichas que el jugador fue ganando como regalo. Las ganadas sin
/// abrir aparecen envueltas; las que faltan, como silueta con su condición.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        accent: t.gold,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (context, _) => Column(
              children: [
                SkinHeader(
                  title: tr('gallery.title'),
                  subtitle: tr('gallery.subtitle'),
                  trailing: '${Gift.collected}/${Gift.all.length}',
                  backTooltip: tr('common.back'),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      for (final f in Faction.values) ...[
                        _FactionLabel(f),
                        LayoutBuilder(
                          builder: (context, c) {
                            final w = (c.maxWidth - 2 * 10) / 3;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final g in Gift.all.where((g) => g.type.faction == f))
                                  SizedBox(width: w, child: _GiftCell(g)),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                    ],
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

class _FactionLabel extends StatelessWidget {
  final Faction f;
  const _FactionLabel(this.f);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
    child: Row(
      children: [
        Image.asset(
          'assets/emblems/${f.name}_emblem.webp',
          width: 36,
          height: 36,
          errorBuilder: (_, _, _) => const SizedBox(width: 36),
        ),
        const SizedBox(width: 10),
        Text(f.displayName, style: Skin.of(context).display(20, color: HexTheme.faction(f))),
      ],
    ),
  );
}

/// Una casilla de la galería: ficha, regalo envuelto o silueta.
class _GiftCell extends StatelessWidget {
  final Gift gift;
  const _GiftCell(this.gift);

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final type = gift.type;
    final color = HexTheme.faction(type.faction);
    final opened = gift.isOpened, earned = gift.isEarned;

    final Widget art;
    final String label;
    if (opened) {
      art = PieceChip(type: type, owner: 0, size: 34, lift: 0.15);
      label = type.displayName;
    } else if (earned) {
      art = _WrappedGift(color: color, size: 72);
      label = tr('gallery.open');
    } else {
      art = Stack(
        alignment: Alignment.center,
        children: [
          // Silueta: la ficha en gris muy oscuro, apenas se adivina la figura.
          Opacity(
            opacity: 0.55,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.07, 0.07, 0.07, 0, 10, //
                0.07, 0.07, 0.07, 0, 10, //
                0.07, 0.07, 0.07, 0, 10, //
                0, 0, 0, 1, 0,
              ]),
              child: PieceChip(type: type, owner: 0, size: 34),
            ),
          ),
          Icon(Icons.lock_rounded, size: 20, color: Colors.white.withValues(alpha: 0.85)),
        ],
      );
      label = '?';
    }

    return Pressable(
      semanticLabel: opened ? type.displayName : (earned ? tr('gallery.open') : tr('gallery.locked')),
      onTap: () {
        if (opened) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PieceViewerScreen(type: type)));
        } else if (earned) {
          GiftOpening.show(context, type);
        } else {
          Haptics.select();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(tr(gift.hintKey, gift.hintArgs))));
        }
      },
      child: SkinPanel(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
        highlight: earned && !opened ? color : null,
        child: Column(
          children: [
            SizedBox(height: 80, child: Center(child: art)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: earned && !opened ? color : (opened ? t.text : t.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regalo envuelto en tela (furoshiki) que se balancea pidiendo ser abierto.
class _WrappedGift extends StatefulWidget {
  final Color color;
  final double size;
  const _WrappedGift({required this.color, required this.size});

  @override
  State<_WrappedGift> createState() => _WrappedGiftState();
}

class _WrappedGiftState extends State<_WrappedGift> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) {
      // Quieto casi todo el tiempo; cada tanto un sacudón corto.
      final v = _c.value;
      final wiggle = v > 0.7 ? sin((v - 0.7) / 0.3 * pi * 4) * (1 - (v - 0.7) / 0.3) * 0.12 : 0.0;
      return Transform.rotate(
        angle: wiggle,
        alignment: Alignment.bottomCenter,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: GiftBoxPainter(color: widget.color, gold: HexTheme.of(context).gold),
        ),
      );
    },
  );
}

/// Caja envuelta: tela del color de la facción, cinta dorada y moño.
class GiftBoxPainter extends CustomPainter {
  final Color color;
  final Color gold;

  /// 0 = cerrada; 1 = la tapa ya salió volando.
  final double open;
  const GiftBoxPainter({required this.color, required this.gold, this.open = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Rect.fromLTWH(w * 0.16, h * 0.42, w * 0.68, h * 0.5);
    final dark = Color.lerp(color, Colors.black, 0.35)!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(body.shift(Offset(0, h * 0.04)), Radius.circular(w * 0.06)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * 0.06)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, dark],
        ).createShader(body),
    );
    final ribbon = Paint()..color = gold;
    canvas.drawRect(Rect.fromCenter(center: body.center, width: w * 0.12, height: body.height), ribbon);

    // Tapa: sube y gira al abrirse.
    final lid = Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.16);
    canvas.save();
    canvas.translate(lid.center.dx + open * w * 0.35, lid.center.dy - open * h * 0.6);
    canvas.rotate(open * 0.9);
    final l = lid.shift(-lid.center);
    canvas.drawRRect(
      RRect.fromRectAndRadius(l, Radius.circular(w * 0.05)),
      Paint()..color = Color.lerp(color, Colors.white, 0.08)!,
    );
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w * 0.12, height: l.height), ribbon);
    // Moño
    final bow = Paint()..color = Color.lerp(gold, Colors.white, 0.15)!;
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s * w * 0.12, -l.height * 0.75), width: w * 0.24, height: h * 0.14),
        bow,
      );
    }
    canvas.drawCircle(Offset(0, -l.height * 0.6), w * 0.06, ribbon);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GiftBoxPainter o) => o.open != open || o.color != color || o.gold != gold;
}

// ------------------------------------------------------------ abrir regalo

/// La primera vez: la caja tiembla, se abre y la ficha sube entre rayos de luz.
class GiftOpening extends StatefulWidget {
  final PieceType type;
  const GiftOpening({super.key, required this.type});

  static Future<void> show(BuildContext context, PieceType type) {
    AppSettings.instance.openGift(type.name);
    return Navigator.push(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.88),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => GiftOpening(type: type),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  State<GiftOpening> createState() => _GiftOpeningState();
}

class _GiftOpeningState extends State<GiftOpening> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
  var _burst = false;

  @override
  void initState() {
    super.initState();
    Haptics.light();
    _c.addListener(() {
      if (!_burst && _c.value >= 0.38) {
        _burst = true;
        SoundBoard.instance.play(Sfx.victory);
        Haptics.heavy();
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final type = widget.type;
    final color = HexTheme.faction(type.faction);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_c.value < 1) _c.value = 1;
      },
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final d = min(box.maxWidth, box.maxHeight) * 0.5;
              return AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final v = _c.value;
                  // 0–0.38: la caja tiembla cada vez más.
                  final shake = v < 0.38 ? sin(v * 90) * (v / 0.38) * 0.14 : 0.0;
                  final lid = ((v - 0.36) / 0.18).clamp(0.0, 1.0);
                  final boxFade = 1 - ((v - 0.42) / 0.16).clamp(0.0, 1.0);
                  final rise = Curves.easeOutBack.transform(((v - 0.4) / 0.32).clamp(0.0, 1.0));
                  final rays = Curves.easeOut.transform(((v - 0.36) / 0.3).clamp(0.0, 1.0));
                  final text = ((v - 0.7) / 0.2).clamp(0.0, 1.0);
                  final center = Offset(box.maxWidth / 2, box.maxHeight * 0.42);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RaysPainter(center: center, color: color, gold: t.gold, t: rays, spin: v),
                        ),
                      ),
                      if (boxFade > 0)
                        Positioned(
                          left: center.dx - d * 0.6,
                          top: center.dy - d * 0.45,
                          child: Opacity(
                            opacity: boxFade,
                            child: Transform.rotate(
                              angle: shake,
                              alignment: Alignment.bottomCenter,
                              child: Transform.scale(
                                scale: 1 + (v < 0.38 ? v * 0.25 : 0.1),
                                child: CustomPaint(
                                  size: Size.square(d * 1.2),
                                  painter: GiftBoxPainter(color: color, gold: t.gold, open: lid),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (rise > 0)
                        Positioned(
                          left: center.dx - d / 2,
                          top: center.dy - d / 2 + (1 - rise) * d * 0.5,
                          child: Transform.scale(
                            scale: 0.3 + 0.7 * rise,
                            child: SizedBox.square(
                              dimension: d,
                              child: Center(
                                child: PieceChip(type: type, owner: 0, size: d * 0.42, lift: 0.4),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: center.dy + d * 0.62,
                        child: Opacity(
                          opacity: text,
                          child: Column(
                            children: [
                              Text(
                                tr('gallery.newPiece').toUpperCase(),
                                style: TextStyle(
                                  color: t.gold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(type.displayName, style: Skin.of(context).display(34, color: Colors.white)),
                              Text(
                                type.faction.displayName,
                                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 22),
                              IgnorePointer(
                                ignoring: text < 1,
                                child: Column(
                                  children: [
                                    SkinPrimaryButton(
                                      label: tr('gallery.inspect'),
                                      glyph: '鑑',
                                      onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => PieceViewerScreen(type: type)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SkinLink(
                                      label: tr('gallery.continue'),
                                      color: Colors.white,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Rayos de luz girando detrás de la ficha, más destellos sueltos.
class _RaysPainter extends CustomPainter {
  final Offset center;
  final Color color, gold;
  final double t, spin;
  _RaysPainter({required this.center, required this.color, required this.gold, required this.t, required this.spin});

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final reach = size.longestSide * 0.7 * t;
    canvas.drawCircle(
      center,
      reach * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gold.withValues(alpha: 0.55 * t),
            color.withValues(alpha: 0.18 * t),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: reach * 0.45)),
    );
    const n = 14;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          gold.withValues(alpha: 0.35 * t),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: reach));
    for (var i = 0; i < n; i++) {
      final a = i * 2 * pi / n + spin * 0.8;
      final p = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + cos(a - 0.07) * reach, center.dy + sin(a - 0.07) * reach)
        ..lineTo(center.dx + cos(a + 0.07) * reach, center.dy + sin(a + 0.07) * reach)
        ..close();
      canvas.drawPath(p, paint);
    }
    // Destellos que salen despedidos.
    final rnd = Random(7);
    for (var i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * 2 * pi;
      final dist = (0.2 + rnd.nextDouble() * 0.8) * reach * 0.6;
      final fade = (1 - t * 0.7).clamp(0.0, 1.0);
      canvas.drawCircle(
        center + Offset(cos(a), sin(a)) * dist,
        1.5 + rnd.nextDouble() * 2.5,
        Paint()..color = Colors.white.withValues(alpha: 0.8 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter o) => o.t != t || o.spin != spin;
}

// ------------------------------------------------------------ visor 3D

/// La ficha de piedra sola, para girarla y acercarla.
class PieceViewerScreen extends StatelessWidget {
  final PieceType type;
  const PieceViewerScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = HexTheme.faction(type.faction);
    const muted = Color(0xB3FFFFFF);
    return Scaffold(
      backgroundColor: const Color(0xFF0E0C0B),
      body: Stack(
        children: [
          // Luz cenital sobre la ficha.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.25),
                  radius: 0.9,
                  colors: [Color.lerp(color, const Color(0xFF3A3530), 0.75)!, const Color(0xFF0E0C0B)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: tr('common.back'),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(child: PieceToken3D(type: type)),
                Text(type.displayName, style: Skin.of(context).display(30, color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  type.faction.displayName,
                  style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  tr('gallery.gestures'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SkinLink(
                  label: tr('gallery.howItMoves'),
                  color: Colors.white,
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CodexPieceScreen(initial: type))),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ficha en 3D: un dedo la gira, dos dedos la acercan, doble toque la centra.
/// Al soltarla sigue girando con inercia y queda donde la dejaron.
class PieceToken3D extends StatefulWidget {
  final PieceType type;
  const PieceToken3D({super.key, required this.type});

  @override
  State<PieceToken3D> createState() => _PieceToken3DState();
}

class _PieceToken3DState extends State<PieceToken3D> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _time = 0;

  double _rx = -0.25, _ry = 0.5; // arranca en tres cuartos para que se note el canto
  double _vx = 0, _vy = 0; // velocidad angular (rad/s)
  double _zoom = 1, _zoomStart = 1, _zoomTarget = 1;
  bool _touching = false;
  bool _handled = false; // una vez que el jugador la giró, queda donde la deja

  ui.Image? _art, _emblem;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    PieceArt.full(widget.type).then((i) => mounted ? setState(() => _art = i) : null);
    PieceArt.emblem(widget.type.faction).then((i) => mounted ? setState(() => _emblem = i) : null);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = now;
    _time += dt;
    if (_touching) return;
    setState(() {
      _ry += _vy * dt;
      _rx += _vx * dt;
      final damp = exp(-2.6 * dt);
      _vx *= damp;
      _vy *= damp;
      if (!_handled) {
        // Mientras nadie la toca, se mece sola para mostrar el canto.
        final rest = sin(_time * 0.7) * 0.45;
        _ry += (rest - _ry) * (1 - exp(-1.8 * dt));
        final restX = -0.2 + sin(_time * 0.9) * 0.08;
        _rx += (restX - _rx) * (1 - exp(-1.8 * dt));
      }
      _rx = _rx.clamp(-1.3, 1.3);
      if (!_touching) _zoom += (_zoomTarget - _zoom) * (1 - exp(-8 * dt));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = HexTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final d = min(box.maxWidth, box.maxHeight) * 0.66;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (_) {
            _touching = _handled = true;
            _zoomStart = _zoom;
            _vx = _vy = 0;
          },
          onScaleUpdate: (e) => setState(() {
            _ry += e.focalPointDelta.dx * 0.011;
            _rx = (_rx - e.focalPointDelta.dy * 0.011).clamp(-1.3, 1.3);
            if (e.pointerCount > 1) _zoom = _zoomTarget = (_zoomStart * e.scale).clamp(0.8, 2.6);
          }),
          onScaleEnd: (e) {
            _touching = false;
            final v = e.velocity.pixelsPerSecond;
            _vy = (v.dx * 0.011).clamp(-14.0, 14.0);
            _vx = (-v.dy * 0.011).clamp(-6.0, 6.0);
          },
          onDoubleTap: () {
            Haptics.select();
            _zoomTarget = _zoomTarget > 1.2 ? 1 : 2;
            _handled = false; // vuelve a mecerse de frente
          },
          child: Center(child: _token(theme, d)),
        );
      },
    );
  }

  Widget _token(HexTheme theme, double d) {
    final type = widget.type;
    final tone = type.faction == Faction.shaolin ? 0 : 1;
    final r = d / 2 * 0.92;
    final thick = d * 0.13;
    const layers = 14;

    Matrix4 at(double z, {bool flip = false}) {
      final m = Matrix4.identity()
        ..setEntry(3, 2, 0.0011)
        ..rotateX(_rx)
        ..rotateY(_ry)
        ..scaleByDouble(_zoom, _zoom, _zoom, 1)
        ..translateByDouble(0, 0, z, 1);
      if (flip) m.rotateY(pi);
      return m;
    }

    Widget layer(Matrix4 m, CustomPainter p) => Transform(
      transform: m,
      alignment: Alignment.center,
      child: CustomPaint(size: Size.square(d), painter: p),
    );

    final front = layer(
      at(-thick / 2),
      _FacePainter(theme: theme, type: type, tone: tone, r: r, art: _art, sheen: _ry, sheenY: _rx),
    );
    final back = layer(
      at(thick / 2, flip: true),
      _BackPainter(theme: theme, faction: type.faction, tone: tone, r: r, emblem: _emblem),
    );
    final side = theme.stoneSide[tone];
    final edges = [
      for (var i = 0; i < layers; i++)
        layer(
          at(-thick / 2 + thick * (i + 0.5) / layers),
          _EdgePainter(
            r: r * 1.045, // llega al borde exterior del filo de facción
            // Canto con un poco de volumen: más claro hacia el centro del espesor.
            color: Color.lerp(side, theme.stone[tone][1], 0.25 * sin(pi * (i + 0.5) / layers))!,
          ),
        ),
    ];

    // Se pinta de atrás hacia adelante según hacia dónde mira la ficha.
    final facingFront = cos(_rx) * cos(_ry) > 0;
    final stack = facingFront ? [back, ...edges.reversed, front] : [front, ...edges, back];
    return SizedBox(
      width: d * 1.6,
      height: d * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sombra en el piso.
          Positioned(
            bottom: d * 0.04,
            child: Container(
              width: d * 0.75 * _zoom,
              height: d * 0.12 * _zoom,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(d, d * 0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: d * 0.08)],
              ),
            ),
          ),
          ...stack,
        ],
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  final HexTheme theme;
  final PieceType type;
  final int tone;
  final double r;
  final ui.Image? art;
  final double sheen, sheenY;
  _FacePainter({
    required this.theme,
    required this.type,
    required this.tone,
    required this.r,
    required this.art,
    required this.sheen,
    required this.sheenY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    PieceRenderer.drawFace(canvas, theme: theme, type: type, tone: tone, face: c, r: r, seed: type.index, art: art);
    // Reflejo que recorre la piedra al girarla.
    final s = sin(sheen) * 1.6, sy = sin(sheenY) * 1.2;
    canvas.save();
    canvas.clipPath(PieceRenderer.hexAt(c, r));
    canvas.drawRect(
      Rect.fromCircle(center: c, radius: r),
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          begin: Alignment(-1 - s, -1 - sy),
          end: Alignment(1 - s, 1 - sy),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: tone == 0 ? 0.16 : 0.10),
            Colors.transparent,
          ],
          stops: const [0.35, 0.5, 0.65],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FacePainter o) =>
      o.art != art || o.sheen != sheen || o.sheenY != sheenY || o.theme != theme;
}

class _BackPainter extends CustomPainter {
  final HexTheme theme;
  final Faction faction;
  final int tone;
  final double r;
  final ui.Image? emblem;
  _BackPainter({required this.theme, required this.faction, required this.tone, required this.r, this.emblem});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // El dorso: misma piedra, con el emblema de la facción tallado.
    final leader = faction == Faction.shaolin ? PieceType.monk : PieceType.shogun;
    final img = emblem;
    if (img != null) {
      PieceRenderer.drawFace(canvas, theme: theme, type: _plain(faction), tone: tone, face: c, r: r, art: img);
    } else {
      PieceRenderer.drawFace(canvas, theme: theme, type: leader, tone: tone, face: c, r: r);
    }
    canvas.drawPath(PieceRenderer.hexAt(c, r), Paint()..color = Colors.black.withValues(alpha: 0.12));
  }

  /// Una ficha cualquiera que no sea líder (para que no lleve el anillo dorado).
  static PieceType _plain(Faction f) => PieceType.values.firstWhere((t) => t.faction == f && !t.isLeader);

  @override
  bool shouldRepaint(covariant _BackPainter o) => o.emblem != emblem || o.theme != theme;
}

class _EdgePainter extends CustomPainter {
  final double r;
  final Color color;
  _EdgePainter({required this.r, required this.color});

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(PieceRenderer.hexAt(size.center(Offset.zero), r), Paint()..color = color);

  @override
  bool shouldRepaint(covariant _EdgePainter o) => o.color != color || o.r != r;
}

// ------------------------------------------------------------ aviso de regalo

/// Cartel que baja desde arriba cuando el jugador gana fichas nuevas.
/// Tocarlo abre la galería.
class GiftToast {
  static OverlayEntry? _current;

  /// Revisa si hay regalos nuevos y, si los hay, los anuncia.
  static void check(BuildContext context, {Duration delay = const Duration(milliseconds: 700)}) {
    final fresh = Gift.takeNew();
    if (fresh.isEmpty) return;
    Future.delayed(delay, () {
      if (!context.mounted) return;
      final overlay = Overlay.of(context, rootOverlay: true);
      _current?.remove();
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (ctx) => _GiftToastView(
          gifts: fresh,
          onDone: () {
            if (entry.mounted) entry.remove();
            if (_current == entry) _current = null;
          },
          onOpen: () =>
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const GalleryScreen())),
        ),
      );
      _current = entry;
      overlay.insert(entry);
      SoundBoard.instance.play(Sfx.stamp);
      Haptics.medium();
    });
  }
}

class _GiftToastView extends StatefulWidget {
  final List<Gift> gifts;
  final VoidCallback onDone;
  final VoidCallback onOpen;
  const _GiftToastView({required this.gifts, required this.onDone, required this.onOpen});

  @override
  State<_GiftToastView> createState() => _GiftToastViewState();
}

class _GiftToastViewState extends State<_GiftToastView> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 380))..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 4200), _close);
  }

  Future<void> _close() async {
    _timer?.cancel();
    if (!mounted) return;
    await _c.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final g = widget.gifts;
    final color = HexTheme.faction(g.first.type.faction);
    final title = g.length == 1
        ? tr('gallery.toast.one', {'name': g.first.type.displayName})
        : tr('gallery.toast.many', {'n': g.length});
    return Positioned(
      left: 12,
      right: 12,
      top: MediaQuery.paddingOf(context).top + 8,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, -1.4),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
        child: Material(
          type: MaterialType.transparency,
          child: Pressable(
            onTap: () {
              _close();
              widget.onOpen();
            },
            child: SkinPanel(
              highlight: t.gold,
              padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
              child: Row(
                children: [
                  CustomPaint(
                    size: const Size.square(46),
                    painter: GiftBoxPainter(color: color, gold: t.gold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr('gallery.toast.title').toUpperCase(),
                          style: TextStyle(
                            color: t.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(color: t.text, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(tr('gallery.toast.tap'), style: TextStyle(color: t.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
