import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../engine/game_state.dart';
import '../../engine/hex.dart';
import '../../engine/pieces.dart';
import '../hex_layout.dart';
import 'sfx.dart';

enum FlightKind { drop, move, vanish }

enum ImpactKind { dust, frost, seal, ability }

/// Una ficha en el aire. Se deriva comparando el tablero antes/después de una
/// acción, así que cualquier acción (IA, habilidad, empuje) se anima sola.
class Flight {
  final Piece piece;
  final Offset from, to;
  final double fromElev, toElev; // elevación por altura de pila
  final FlightKind kind;
  final double start, duration;
  final double arc;
  bool lifted = false, landed = false;
  final void Function()? onLand;

  Flight({
    required this.piece,
    required this.from,
    required this.to,
    required this.fromElev,
    required this.toElev,
    required this.kind,
    required this.start,
    required this.duration,
    this.arc = 0,
    this.onLand,
    this.squeeze = false,
  });

  /// Al aterrizar aprieta el cerco del Líder rival (háptico más firme).
  final bool squeeze;

  double get end => start + duration;
}

class Impact {
  final Offset c;
  final double start;
  final ImpactKind kind;
  final double strength;
  final int seed;
  Impact(this.c, this.start, this.kind, this.strength, this.seed);

  double get duration => switch (kind) {
    ImpactKind.dust => 0.55,
    ImpactKind.frost => 0.7,
    ImpactKind.seal => 0.6,
    ImpactKind.ability => 0.8,
  };
}

/// Estado de la "física" visual del tablero. Lo repinta el [BoardPainter] vía
/// `repaint:` sin reconstruir widgets. Tiene su propio reloj a partir de un Ticker.
class BoardFx extends ChangeNotifier {
  BoardFx(TickerProvider vsync, this.layout) {
    _ticker = vsync.createTicker(_onTick);
  }

  final HexLayout layout;
  late final Ticker _ticker;
  final _clock = Stopwatch()..start();
  double now = 0;

  final flights = <Flight>[];

  /// Remate de la partida: el Líder capturado y las fichas que lo encierran,
  /// que se encienden de a una antes de que caiga el sello. [won] dice si el
  /// remate es del jugador local (dorado) o en su contra (rojo).
  ({Hex leader, List<Hex> ring, double start, bool won})? finisher;
  int _finisherLit = -1;
  bool _finisherStamped = false;

  /// Segundos entre que se enciende una ficha del cerco y la siguiente.
  static const finisherStep = 0.13;

  /// Duración del remate desde que aterriza la última ficha.
  static double finisherSeconds(int ring) => finisherStep * ring + 0.75;

  /// Momento (en el reloj de [now]) en que cae el sello del remate.
  double get finisherStampAt => finisher == null ? 0 : finisher!.start + finisherStep * finisher!.ring.length + 0.15;
  final impacts = <Impact>[];

  /// id de ficha → momento en que aterrizó (para el rebote de asentamiento).
  final settles = <int, double>{};

  /// casilla → (dirección, inicio): vecinas que "sienten" el golpe.
  final bumps = <Hex, (Offset, double)>{};

  double _shakeStart = -10, _shakeAmp = 0;

  /// Animaciones ambientales (selección, objetivos, asedio) piden frames continuos.
  bool ambient = false;

  static const stackStep = 0.2; // elevación por nivel, relativa al radio

  bool get busy => flights.any((f) => now < f.end);

  double get pendingSeconds => flights.isEmpty ? 0 : max(0, flights.map((f) => f.end).reduce(max) - now);

  Set<int> get hiddenIds => {for (final f in flights) f.piece.id};

  Offset get shake {
    final t = now - _shakeStart;
    if (t > 0.35) return Offset.zero;
    final a = _shakeAmp * exp(-t / 0.07);
    return Offset(sin(t * 83) * a, cos(t * 61) * a * 0.6);
  }

  double settleScale(int id) {
    final t0 = settles[id];
    if (t0 == null) return 1;
    final t = now - t0;
    if (t > 0.5) return 1;
    // Compresión al impacto y rebote amortiguado.
    return 1 + 0.07 * exp(-t / 0.09) * cos(t * 38);
  }

  Offset bumpOffset(Hex h) {
    final b = bumps[h];
    if (b == null) return Offset.zero;
    final t = now - b.$2;
    if (t < 0 || t > 0.45) return Offset.zero;
    return b.$1 * (layout.size * 0.09 * exp(-t / 0.08) * sin(t * 40 + 0.6));
  }

  void wake() {
    if (!_ticker.isActive) _ticker.start();
  }

  void _onTick(Duration _) {
    now = _clock.elapsedMicroseconds / 1e6;
    for (final f in flights) {
      if (!f.lifted && now >= f.start) {
        f.lifted = true;
        if (f.kind == FlightKind.move) SoundBoard.instance.play(Sfx.lift, volume: 0.7);
      }
      if (!f.landed && now >= f.end) {
        f.landed = true;
        _land(f);
      }
    }
    flights.removeWhere((f) => f.landed);
    _tickFinisher();
    impacts.removeWhere((i) => now > i.start + i.duration);
    settles.removeWhere((_, t) => now - t > 0.5);
    bumps.removeWhere((_, b) => now - b.$2 > 0.45);
    final idle =
        flights.isEmpty &&
        impacts.isEmpty &&
        settles.isEmpty &&
        bumps.isEmpty &&
        now - _shakeStart > 0.35 &&
        (finisher == null || now > finisherStampAt + 0.8);
    notifyListeners();
    if (idle && !ambient) _ticker.stop();
  }

  void _land(Flight f) {
    f.onLand?.call();
    if (f.kind == FlightKind.vanish) return;
    final heavy = f.kind == FlightKind.drop;
    final onStack = f.toElev > 0;
    settles[f.piece.id] = now;
    impacts.add(Impact(f.to - Offset(0, f.toElev), now, ImpactKind.dust, heavy ? 1.0 : 0.7, f.piece.id));
    _shakeStart = now;
    _shakeAmp = layout.size * (heavy ? 0.11 : 0.065);
    final hex = layout.fromPixel(f.to);
    for (final n in hex.neighbors) {
      final dir = layout.toPixel(n) - layout.toPixel(hex);
      bumps[n] = (dir / dir.distance, now);
    }
    SoundBoard.instance.play(
      onStack
          ? Sfx.stack
          : heavy
          ? Sfx.place
          : Sfx.land,
    );
    // Apoyar es un toque suave; cerrar el cerco sobre el Líder rival, uno firme.
    f.squeeze ? Haptics.medium() : Haptics.light();
  }

  /// Enciende el cerco ficha por ficha y estampa el sello sobre el Líder.
  void _tickFinisher() {
    final fin = finisher;
    if (fin == null) return;
    final lit = ((now - fin.start) / finisherStep).floor().clamp(-1, fin.ring.length - 1);
    while (_finisherLit < lit) {
      _finisherLit++;
      SoundBoard.instance.play(Sfx.tick, volume: 0.5 + 0.08 * _finisherLit);
      Haptics.select();
    }
    if (!_finisherStamped && now >= finisherStampAt) {
      _finisherStamped = true;
      SoundBoard.instance.play(Sfx.stamp);
      _shakeStart = now;
      _shakeAmp = layout.size * 0.16;
      fin.won ? Haptics.heavy() : Haptics.double();
    }
  }

  void clear() {
    finisher = null;
    flights.clear();
    impacts.clear();
    settles.clear();
    bumps.clear();
    _shakeAmp = 0;
    notifyListeners();
  }

  void addImpact(Hex h, ImpactKind kind, {double delay = 0}) {
    impacts.add(Impact(layout.toPixel(h), now + delay, kind, 1, h.hashCode));
    wake();
  }

  // ------------------------------------------------------------- diff → animación

  static Map<int, (Hex, int, Piece)> _positions(GameState g) {
    final out = <int, (Hex, int, Piece)>{};
    for (final h in g.board.occupied) {
      final stack = g.board.stackAt(h);
      for (var i = 0; i < stack.length; i++) {
        out[stack[i].id] = (h, i, stack[i]);
      }
    }
    return out;
  }

  /// Anima la transición [before] → [after]. Devuelve los segundos que dura.
  /// [viewer] es el jugador local: el remate se ve dorado si gana él y rojo si
  /// pierde (null = Pass & Play, siempre dorado).
  double animate(GameState before, GameState after, {int? viewer}) {
    now = _clock.elapsedMicroseconds / 1e6;
    final a = _positions(before), b = _positions(after);
    final actor = before.current;
    // La jugada que cierra la partida va en cámara lenta.
    final slow = after.winner != null && !before.isOver ? 2.0 : 1.0;
    final squeeze = after.leaderPressure(1 - actor) > before.leaderPressure(1 - actor);
    final step = layout.size * stackStep;
    final mine = <Flight>[], others = <Flight>[];

    for (final e in b.entries) {
      final (hex, level, piece) = e.value;
      final prev = a[e.key];
      if (prev == null) {
        mine.add(
          Flight(
            piece: piece,
            from: layout.toPixel(hex),
            to: layout.toPixel(hex),
            fromElev: level * step,
            toElev: level * step,
            kind: FlightKind.drop,
            start: now,
            duration: 0.34 * slow,
            squeeze: squeeze,
          ),
        );
      } else if (prev.$1 != hex || prev.$2 != level) {
        final from = layout.toPixel(prev.$1), to = layout.toPixel(hex);
        final dist = (to - from).distance;
        final f = Flight(
          piece: piece,
          from: from,
          to: to,
          fromElev: prev.$2 * step,
          toElev: level * step,
          kind: FlightKind.move,
          start: now,
          duration: (0.36 + dist / 1400).clamp(0.36, 0.75) * slow,
          arc: min(layout.size * 1.2, dist * 0.18),
          squeeze: squeeze && piece.owner == actor,
        );
        (piece.owner == actor ? mine : others).add(f);
      }
    }
    for (final e in a.entries) {
      if (b.containsKey(e.key)) continue;
      final (hex, level, piece) = e.value;
      mine.add(
        Flight(
          piece: piece,
          from: layout.toPixel(hex),
          to: layout.toPixel(hex),
          fromElev: level * step,
          toElev: level * step,
          kind: FlightKind.vanish,
          start: now,
          duration: 0.45 * slow,
        ),
      );
    }

    // Lo que empuja el actor (Tigre) o la habilidad sale cuando el actor aterriza.
    final lead = mine.isEmpty ? <Flight>[] : mine;
    final delay = lead.isEmpty ? 0.0 : lead.map((f) => f.duration).reduce(max) * 0.92;
    final all = [
      ...mine,
      for (final f in others)
        Flight(
          piece: f.piece,
          from: f.from,
          to: f.to,
          fromElev: f.fromElev,
          toElev: f.toElev,
          kind: f.kind,
          start: f.start + delay,
          duration: f.duration * 0.8,
          arc: f.arc * 0.3,
        ),
    ];
    flights.addAll(all);
    final landAt = mine.isEmpty ? 0.0 : mine.map((f) => f.duration).reduce(max);

    // Efectos de estado: parálisis y sellos nuevos aparecen al aterrizar.
    for (final e in b.entries) {
      final piece = e.value.$3;
      final was = a[e.key];
      final wasParalyzed = was != null && before.isParalyzed(was.$3);
      if (after.isParalyzed(piece) && !wasParalyzed) {
        addImpact(e.value.$1, ImpactKind.frost, delay: landAt);
        Future.delayed(Duration(milliseconds: (landAt * 1000).round()), () => SoundBoard.instance.play(Sfx.frost));
      }
    }
    for (final s in after.seals.entries) {
      if (before.seals[s.key] != s.value) {
        addImpact(s.key, ImpactKind.seal, delay: landAt);
        Future.delayed(Duration(milliseconds: (landAt * 1000).round()), () => SoundBoard.instance.play(Sfx.stamp));
      }
    }
    if (after.abilityUses[before.current] > before.abilityUses[before.current]) {
      SoundBoard.instance.play(Sfx.ability, volume: 0.8);
      Haptics.light();
      for (final f in all) {
        impacts.add(Impact(f.from, now, ImpactKind.ability, 1, f.piece.id));
      }
    }
    var end = all.isEmpty ? now : all.map((f) => f.end).reduce(max);
    final fin = slow > 1 ? _finisherFor(after, viewer) : null;
    if (fin != null) {
      finisher = (leader: fin.leader, ring: fin.ring, start: end + 0.1, won: fin.won);
      _finisherLit = -1;
      _finisherStamped = false;
      end = finisherStampAt + 0.45;
    }
    wake();
    return end - now;
  }

  /// El Líder que cayó y las fichas que lo rodean, en orden de reloj.
  static ({Hex leader, List<Hex> ring, bool won})? _finisherFor(GameState g, int? viewer) {
    final w = g.winner;
    if (w == null) return null;
    for (final h in g.board.locateLeaders(1 - w)) {
      if (!g.leaderCapturedOn(g.board, 1 - w, h)) continue;
      return (leader: h, ring: h.neighbors.where(g.board.isOccupied).toList(), won: viewer == null || viewer == w);
    }
    return null;
  }

  /// Posición/altura/escala/opacidad de una ficha en vuelo en el instante actual.
  ({Offset c, double z, double scale, double opacity}) sample(Flight f) {
    final p = ((now - f.start) / f.duration).clamp(0.0, 1.0);
    final notStarted = now < f.start;
    switch (f.kind) {
      case FlightKind.drop:
        // Cae desde arriba con gravedad (aceleración), apareciendo en el aire.
        final z0 = layout.size * 2.2;
        final z = z0 * (1 - p * p) + f.toElev;
        return (c: f.to, z: z, scale: 1, opacity: Curves.easeOut.transform((p / 0.25).clamp(0, 1)));
      case FlightKind.vanish:
        final e = Curves.easeIn.transform(p);
        return (c: f.from, z: f.fromElev + layout.size * 1.4 * e, scale: 1 + 0.1 * e, opacity: 1 - e);
      case FlightKind.move:
        if (notStarted) return (c: f.from, z: f.fromElev, scale: 1, opacity: 1);
        const liftEnd = 0.2, dropStart = 0.72;
        final hover = layout.size * 0.5;
        if (p < liftEnd) {
          final e = Curves.easeOutCubic.transform(p / liftEnd);
          return (c: f.from, z: f.fromElev + (hover) * e, scale: 1, opacity: 1);
        }
        if (p < dropStart) {
          final q = (p - liftEnd) / (dropStart - liftEnd);
          final e = Curves.easeInOutCubic.transform(q);
          final elev = f.fromElev + (f.toElev - f.fromElev) * e;
          return (c: Offset.lerp(f.from, f.to, e)!, z: elev + hover + f.arc * sin(pi * q), scale: 1, opacity: 1);
        }
        final q = (p - dropStart) / (1 - dropStart);
        return (c: f.to, z: f.toElev + hover * (1 - q * q), scale: 1, opacity: 1);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
