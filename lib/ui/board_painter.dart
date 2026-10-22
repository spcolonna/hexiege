import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import 'fx/board_fx.dart';
import 'fx/piece_renderer.dart';
import 'hex_layout.dart';
import 'theme/hex_theme.dart';

class BoardPainter extends CustomPainter {
  final GameState game;
  final HexLayout layout;
  final HexTheme theme;

  /// Color de la grilla si la mesa pide otro (tapetes); null = el del tema.
  final Color? grid;
  final BoardFx? fx;
  final Hex? selected;
  final Set<Hex> targets;
  final Color targetColor;
  final Set<Hex> lastMove;

  /// Shinobis con los que puede intercambiarse el Shogun (dorado, con ⇄).
  final Set<Hex> swapTargets;

  /// Color de la Serpiente de Jade y de las fichas que anula.
  static const jade = Color(0xFF3DBE8B);

  /// Casillas que el tutorial quiere señalar (onda dorada).
  final Set<Hex> spotlight;

  /// Jugador cuyas fichas se dibujan giradas 180° (cara a cara), o null.
  final int? flipOwner;

  /// Jugador local: los huecos que le quedan a su Líder laten en rojo y los
  /// del Líder rival en dorado (la oportunidad).
  final int viewer;

  /// Mostrar también los huecos del Líder rival (en los problemas no: sería
  /// regalar la solución).
  final bool opportunities;

  BoardPainter({
    required this.game,
    required this.layout,
    required this.theme,
    this.grid,
    required this.selected,
    required this.targets,
    required this.targetColor,
    required this.lastMove,
    this.swapTargets = const {},
    this.spotlight = const {},
    this.flipOwner,
    this.viewer = 0,
    this.opportunities = true,
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
    _paintDanger(canvas);
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
    _paintNullified(canvas);
    _paintImpacts(canvas);
    _paintTargets(canvas);
    _paintSpotlight(canvas);
    _paintFlights(canvas);
    _paintLeaderCount(canvas);
    _paintFinisher(canvas);
    canvas.restore();
  }

  void _paintGrid(Canvas canvas) {
    final grid = this.grid ?? theme.grid;
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
          grid.a *
          (d <= 1
              ? 1.0
              : d == 2
              ? 0.6
              : 0.3);
      canvas.drawPath(
        layout.hexPath(c, scale: 0.95),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = this.grid == null ? 1.2 : 1.5
          ..color = grid.withValues(alpha: alpha),
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

  /// Latido (lub-dub) para los avisos de peligro: dos picos por ciclo.
  static double heartbeat(double now, {double period = 1.1}) {
    final p = (now % period) / period;
    double peak(double at) => exp(-pow((p - at) / 0.05, 2).toDouble());
    return min(1, peak(0.02) + 0.75 * peak(0.2));
  }

  /// Huecos que le quedan a un Líder casi rodeado (2 o menos): laten.
  void _paintDanger(Canvas canvas) {
    if (game.isOver) return;
    for (var owner = 0; owner < 2; owner++) {
      if (owner != viewer && !opportunities) continue;
      final open = game.leaderOpenings(owner);
      if (open.isEmpty) continue;
      final last = game.leaderMargin(owner) == 1;
      final color = owner == viewer ? theme.danger : theme.gold;
      final beat = heartbeat(_now, period: last ? 0.8 : 1.15);
      for (final h in open) {
        final path = layout.hexPath(h, scale: 0.9);
        canvas.drawPath(path, Paint()..color = color.withValues(alpha: (last ? 0.16 : 0.1) + 0.22 * beat));
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 + 2.5 * beat
            ..color = color.withValues(alpha: 0.45 + 0.5 * beat),
        );
      }
    }
  }

  /// Marcador junto a cada Líder con 3 lados ocupados o más: «4/6» (o «/5»
  /// en Asedio), para que el cerco se lea antes de que se cierre.
  void _paintLeaderCount(Canvas canvas) {
    if (game.isOver || fx?.finisher != null) return;
    final need = game.captureThreshold;
    final step = layout.size * BoardFx.stackStep;
    for (var owner = 0; owner < 2; owner++) {
      for (final h in game.board.locateLeaders(owner)) {
        final n = game.board.occupiedNeighbors(h);
        if (n < 3) continue;
        final close = need - n <= 1;
        final color = !close ? theme.textMuted : (owner == viewer ? theme.danger : theme.gold);
        final c = layout.toPixel(h) +
            Offset(layout.size * 0.62, -layout.size * 0.78 - (game.board.height(h) - 1) * step);
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: layout.size * 0.98, height: layout.size * 0.5),
          Radius.circular(layout.size * 0.25),
        );
        canvas.drawRRect(r, Paint()..color = theme.surface.withValues(alpha: 0.92));
        canvas.drawRRect(
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = color,
        );
        PieceRenderer.text(canvas, '$n/$need', c, layout.size * 0.32, color);
      }
    }
  }

  /// Remate: cada ficha del cerco se enciende en orden y cae el sello 封 sobre el Líder.
  void _paintFinisher(Canvas canvas) {
    final fin = fx?.finisher;
    if (fin == null) return;
    final color = fin.won ? theme.gold : theme.danger;
    final step = layout.size * BoardFx.stackStep;
    Offset top(Hex h) => layout.toPixel(h) - Offset(0, (game.board.height(h) - 1) * step);
    for (var i = 0; i < fin.ring.length; i++) {
      final t = _now - (fin.start + BoardFx.finisherStep * i);
      if (t < 0) continue;
      // Destello al encenderse que queda como brasa.
      final flash = exp(-t / 0.18);
      final c = top(fin.ring[i]);
      canvas.drawPath(
        PieceRenderer.hexAt(c, layout.size * (0.98 + 0.25 * flash)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layout.size * (0.1 + 0.12 * flash)
          ..color = color.withValues(alpha: 0.55 + 0.4 * flash)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, layout.size * 0.12),
      );
      // El borde interior lleva el color de quien ocupa ese lado: se ve que
      // también cuentan las fichas propias del Líder.
      final owner = game.board.top(fin.ring[i])?.owner;
      canvas.drawPath(
        PieceRenderer.hexAt(c, layout.size * 0.94),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = (owner == null ? color : HexTheme.faction(game.factions[owner])).withValues(alpha: 0.95),
      );
    }
    // En Asedio queda un lado libre: se marca para que no parezca un error.
    if (_now > fin.start + BoardFx.finisherStep * fin.ring.length) {
      for (final h in fin.leader.neighbors.where((n) => !game.board.isOccupied(n))) {
        canvas.drawPath(
          layout.hexPath(h, scale: 0.86),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = theme.textMuted.withValues(alpha: 0.8),
        );
        PieceRenderer.text(canvas, '圍', layout.toPixel(h), layout.size * 0.7, theme.textMuted.withValues(alpha: 0.75));
      }
    }
    final ts = _now - fx!.finisherStampAt;
    if (ts < -0.5) return;
    final c = top(fin.leader);
    // El Líder se oscurece mientras se cierra el cerco.
    final dim = ((ts + 0.5) / 0.5).clamp(0.0, 1.0);
    canvas.drawPath(
      PieceRenderer.hexAt(c, layout.size * 0.92),
      Paint()..color = Colors.black.withValues(alpha: 0.35 * dim),
    );
    if (ts < 0) return;
    // El sello baja de grande a su tamaño y rebota apenas.
    final e = Curves.easeInCubic.transform((ts / 0.18).clamp(0, 1));
    final scale = 2.4 - 1.4 * e + (ts > 0.18 ? 0.06 * exp(-(ts - 0.18) / 0.08) * sin((ts - 0.18) * 40) : 0);
    final r = layout.size * 0.78 * scale;
    final ink = theme.danger;
    canvas.drawCircle(c, r, Paint()..color = ink.withValues(alpha: 0.9 * e));
    canvas.drawCircle(
      c,
      r * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = Colors.white.withValues(alpha: 0.85 * e),
    );
    PieceRenderer.text(canvas, '封', c, r * 1.05, Colors.white.withValues(alpha: e));
    // Onda de tinta al estampar.
    if (ts > 0.18 && ts < 0.9) {
      final w = (ts - 0.18) / 0.72;
      canvas.drawCircle(
        c,
        layout.size * (0.9 + 1.6 * Curves.easeOutCubic.transform(w)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layout.size * 0.14 * (1 - w)
          ..color = ink.withValues(alpha: 0.5 * (1 - w)),
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
          mirror: game.factions[0] == game.factions[1],
          flip: p.owner == flipOwner,
          ash: game.factions[p.owner] == Faction.oni,
        );
      }
      if (stack.length > 1 && !hidden.contains(stack.last.id)) {
        final badge = base + Offset(layout.size * 0.6, -layout.size * 0.6 - (stack.length - 1) * step);
        canvas.drawCircle(badge, layout.size * 0.26, Paint()..color = theme.gold);
        PieceRenderer.text(canvas, '${stack.length}', badge, layout.size * 0.3, Colors.black);
      }
    }
  }

  /// Fichas cuyo efecto especial anula una Serpiente rival: anillo de jade y 蛇.
  void _paintNullified(Canvas canvas) {
    if (fx?.flights.isNotEmpty ?? false) return; // aparece cuando la Serpiente ya aterrizó
    final hidden = fx?.hiddenIds ?? const <int>{};
    final step = layout.size * BoardFx.stackStep;
    for (final e in game.board.tops) {
      if (hidden.contains(e.value.id) || !game.isNullified(e.key)) continue;
      final c = layout.toPixel(e.key) - Offset(0, (game.board.height(e.key) - 1) * step);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = jade.withValues(alpha: 0.85);
      // Anillo punteado: el efecto está "cortado".
      const dashes = 12;
      for (var k = 0; k < dashes; k++) {
        final a0 = k * 2 * pi / dashes;
        canvas.drawArc(Rect.fromCircle(center: c, radius: layout.size * 0.92), a0, pi / dashes, false, ring);
      }
      final badge = c + Offset(-layout.size * 0.6, -layout.size * 0.6);
      canvas.drawCircle(badge, layout.size * 0.26, Paint()..color = jade);
      PieceRenderer.text(canvas, '蛇', badge, layout.size * 0.3, Colors.white);
    }
  }

  void _paintTargets(Canvas canvas) {
    final pulse = 0.5 + 0.5 * sin(_now * 3.6);
    for (final t in swapTargets) {
      final c = layout.toPixel(t);
      final path = layout.hexPath(t, scale: 0.86);
      canvas.drawPath(path, Paint()..color = theme.gold.withValues(alpha: 0.22 + 0.1 * pulse));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = theme.gold.withValues(alpha: 0.6 + 0.35 * pulse),
      );
      final badge = c + Offset(layout.size * 0.6, layout.size * 0.55);
      canvas.drawCircle(badge, layout.size * 0.28, Paint()..color = theme.gold);
      PieceRenderer.text(canvas, '⇄', badge, layout.size * 0.36, Colors.black);
    }
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

  void _paintSpotlight(Canvas canvas) {
    for (final h in spotlight) {
      final c = layout.toPixel(h) - Offset(0, game.board.isOccupied(h) ? layout.size * 0.08 : 0);
      // Dos ondas desfasadas que se expanden y se apagan: "mirá acá".
      for (var k = 0; k < 2; k++) {
        final p = (_now * 0.7 + k * 0.5) % 1;
        canvas.drawPath(
          PieceRenderer.hexAt(c, layout.size * (0.95 + 0.55 * p)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 + 3 * (1 - p)
            ..color = theme.gold.withValues(alpha: 0.85 * (1 - p)),
        );
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
        mirror: game.factions[0] == game.factions[1],
        seed: fl.piece.id,
        flip: fl.piece.owner == flipOwner,
        ash: game.factions[fl.piece.owner] == Faction.oni,
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
