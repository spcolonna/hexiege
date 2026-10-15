import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/game_state.dart';
import '../engine/hex.dart';
import 'fx/board_fx.dart';
import 'fx/piece_renderer.dart';
import 'hex_layout.dart';
import 'theme/hex_theme.dart';

class BoardPainter extends CustomPainter {
  final GameState game;
  final HexLayout layout;
  final HexTheme theme;
  final BoardFx? fx;
  final Hex? selected;
  final Set<Hex> targets;
  final Color targetColor;
  final Set<Hex> lastMove;

  BoardPainter({
    required this.game,
    required this.layout,
    required this.theme,
    required this.selected,
    required this.targets,
    required this.targetColor,
    required this.lastMove,
    this.fx,
  }) : super(repaint: fx);

  double get _now => fx?.now ?? 0;

  @override
  void paint(Canvas canvas, Size size) {
    final shake = fx?.shake ?? Offset.zero;
    canvas.save();
    canvas.translate(shake.dx, shake.dy);

    _paintGrid(canvas);
    for (final m in lastMove) {
      canvas.drawPath(layout.hexPath(m, scale: 0.98), Paint()..color = theme.lastMove);
    }
    _paintSiege(canvas);
    _paintSeals(canvas);
    if (selected != null) {
      canvas.drawPath(
        layout.hexPath(selected!, scale: 0.97),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = theme.highlight.withValues(alpha: 0.7),
      );
    }
    _paintPieces(canvas);
    _paintImpacts(canvas);
    _paintTargets(canvas);
    _paintFlights(canvas);
    canvas.restore();
  }

  void _paintGrid(Canvas canvas) {
    final cells = <Hex>{};
    final occupied = game.board.occupied.toList();
    final seeds = occupied.isEmpty ? [Hex.origin] : occupied;
    for (final o in seeds) {
      for (var dq = -3; dq <= 3; dq++) {
        for (var dr = -3; dr <= 3; dr++) {
          final h = Hex(o.q + dq, o.r + dr);
          if (h.distanceTo(o) <= 3) cells.add(h);
        }
      }
    }
    // Las casillas cercanas a la colmena se ven más; las lejanas se desvanecen.
    for (final c in cells) {
      final d = seeds.map((s) => s.distanceTo(c)).reduce(min);
      final alpha =
          theme.grid.a *
          (d <= 1
              ? 1.0
              : d == 2
              ? 0.6
              : 0.3);
      canvas.drawPath(
        layout.hexPath(c, scale: 0.95),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = theme.grid.withValues(alpha: alpha),
      );
    }
  }

  /// Resplandor de peligro bajo un Líder casi rodeado: la tensión se ve.
  void _paintSiege(Canvas canvas) {
    for (var owner = 0; owner < 2; owner++) {
      final h = game.board.locateLeader(owner);
      if (h == null) continue;
      final n = game.board.occupiedNeighbors(h);
      if (n < 4) continue;
      final pulse = 0.5 + 0.5 * sin(_now * (n == 5 ? 7 : 4));
      final strength = n == 5
          ? 0.55
          : n == 6
          ? 0.7
          : 0.25;
      canvas.drawCircle(
        layout.toPixel(h),
        layout.size * (1.5 + 0.15 * pulse),
        Paint()
          ..color = theme.danger.withValues(alpha: strength * (0.6 + 0.4 * pulse))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, layout.size * 0.5),
      );
    }
  }

  void _paintSeals(Canvas canvas) {
    for (final e in game.seals.entries) {
      if (game.board.isOccupied(e.key)) continue;
      final c = layout.toPixel(e.key);
      final color = HexTheme.faction(game.factions[e.value]);
      canvas.drawCircle(
        c,
        layout.size * 0.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = color.withValues(alpha: 0.8),
      );
      PieceRenderer.text(canvas, '封', c, layout.size * 0.55, color.withValues(alpha: 0.9));
    }
  }

  void _paintPieces(Canvas canvas) {
    final hidden = fx?.hiddenIds ?? const <int>{};
    final step = layout.size * BoardFx.stackStep;
    // De arriba hacia abajo en pantalla: el canto de una ficha queda sobre la de atrás.
    final cells = game.board.occupied.toList()..sort((a, b) => layout.toPixel(a).dy.compareTo(layout.toPixel(b).dy));
    for (final h in cells) {
      final stack = game.board.stackAt(h);
      final base = layout.toPixel(h) + (fx?.bumpOffset(h) ?? Offset.zero);
      for (var i = 0; i < stack.length; i++) {
        final p = stack[i];
        if (hidden.contains(p.id)) continue;
        final isTop = i == stack.length - 1;
        var z = i * step;
        var scale = fx?.settleScale(p.id) ?? 1;
        if (isTop && h == selected) {
          // Ficha seleccionada: levantada y flotando.
          z += layout.size * 0.32 + sin(_now * 4.2) * layout.size * 0.05;
          scale *= 1.04;
        }
        PieceRenderer.draw(
          canvas,
          theme: theme,
          type: p.type,
          owner: p.owner,
          c: base,
          radius: layout.size,
          z: z,
          scale: scale,
          shadow: i == 0 || (isTop && h == selected),
          paralyzed: isTop && game.isParalyzed(p),
          seed: p.id,
        );
      }
      if (stack.length > 1 && !hidden.contains(stack.last.id)) {
        final badge = base + Offset(layout.size * 0.6, -layout.size * 0.6 - (stack.length - 1) * step);
        canvas.drawCircle(badge, layout.size * 0.26, Paint()..color = theme.gold);
        PieceRenderer.text(canvas, '${stack.length}', badge, layout.size * 0.3, Colors.black);
      }
    }
  }

  void _paintTargets(Canvas canvas) {
    final pulse = 0.5 + 0.5 * sin(_now * 3.6);
    for (final t in targets) {
      final occupied = game.board.isOccupied(t);
      final c = layout.toPixel(t);
      final path = layout.hexPath(t, scale: 0.86);
      canvas.drawPath(path, Paint()..color = targetColor.withValues(alpha: (occupied ? 0.22 : 0.12) + 0.1 * pulse));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = targetColor.withValues(alpha: 0.55 + 0.35 * pulse),
      );
      if (!occupied) {
        canvas.drawCircle(c, layout.size * (0.12 + 0.03 * pulse), Paint()..color = targetColor);
      }
    }
  }

  void _paintFlights(Canvas canvas) {
    final f = fx;
    if (f == null) return;
    final samples = [for (final fl in f.flights) (fl, f.sample(fl))]..sort((a, b) => a.$2.z.compareTo(b.$2.z));
    for (final (fl, s) in samples) {
      PieceRenderer.draw(
        canvas,
        theme: theme,
        type: fl.piece.type,
        owner: fl.piece.owner,
        c: s.c,
        radius: layout.size,
        z: s.z,
        scale: s.scale,
        opacity: s.opacity,
        paralyzed: game.isParalyzed(fl.piece),
        seed: fl.piece.id,
      );
    }
  }

  void _paintImpacts(Canvas canvas) {
    final f = fx;
    if (f == null) return;
    final s = layout.size;
    for (final i in f.impacts) {
      final t = (f.now - i.start) / i.duration;
      if (t < 0 || t > 1) continue;
      final fade = 1 - t;
      switch (i.kind) {
        case ImpactKind.dust:
          final dust = theme.isDark ? const Color(0xFFD9CBB0) : const Color(0xFF8A7556);
          // Onda de choque
          final ring = Curves.easeOutCubic.transform(t);
          canvas.drawPath(
            PieceRenderer.hexAt(i.c, s * (0.95 + 0.75 * ring * i.strength)),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * 0.12 * fade
              ..color = dust.withValues(alpha: 0.45 * fade * fade),
          );
          // Partículas de polvo que salen desde los bordes y frenan
          final rng = Random(i.seed);
          final n = (8 + 6 * i.strength).round();
          for (var k = 0; k < n; k++) {
            final ang = (k / n) * 2 * pi + rng.nextDouble() * 0.5;
            final speed = (0.5 + rng.nextDouble() * 0.7) * i.strength;
            final dist = s * (0.9 + speed * Curves.easeOutQuart.transform(t));
            final p = i.c + Offset(cos(ang), sin(ang) * 0.75) * dist + Offset(0, -s * 0.25 * sin(pi * t) * speed);
            canvas.drawCircle(
              p,
              s * (0.05 + 0.06 * rng.nextDouble()) * (1 + t),
              Paint()..color = dust.withValues(alpha: 0.55 * fade),
            );
          }
        case ImpactKind.frost:
          final e = Curves.easeOutBack.transform(t.clamp(0, 1));
          for (var k = 0; k < 6; k++) {
            final ang = k * pi / 3 + pi / 6;
            final a = i.c + Offset(cos(ang), sin(ang)) * s * 0.3;
            final b = i.c + Offset(cos(ang), sin(ang)) * s * (0.3 + 0.9 * e);
            canvas.drawLine(
              a,
              b,
              Paint()
                ..strokeWidth = s * 0.07
                ..strokeCap = StrokeCap.round
                ..color = theme.frost.withValues(alpha: 0.85 * fade),
            );
          }
          canvas.drawCircle(i.c, s * (0.6 + 0.6 * e), Paint()..color = theme.frost.withValues(alpha: 0.25 * fade));
        case ImpactKind.seal:
          // Sello que "estampa": baja de grande a su tamaño.
          final e = Curves.easeInCubic.transform((t / 0.4).clamp(0, 1));
          final scale = 2.2 - 1.2 * e;
          canvas.drawCircle(
            i.c,
            s * 0.6 * scale,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = theme.danger.withValues(alpha: 0.8 * fade),
          );
        case ImpactKind.ability:
          final e = Curves.easeOutCubic.transform(t);
          canvas.drawCircle(
            i.c,
            s * (0.6 + 1.1 * e),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * 0.1 * fade
              ..color = theme.gold.withValues(alpha: 0.8 * fade),
          );
          canvas.drawCircle(
            i.c,
            s * 0.9,
            Paint()
              ..color = theme.gold.withValues(alpha: 0.3 * fade)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.4),
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) => true;
}
