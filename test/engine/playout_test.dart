import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/pieces.dart';

/// Partidas aleatorias completas: verifican que las reglas nunca rompan invariantes.
void main() {
  test('300 partidas aleatorias mantienen la colmena conectada', () {
    final rng = Random(42);
    var finished = 0;
    for (var game = 0; game < 300; game++) {
      final g = GameState(Faction.values[rng.nextInt(2)], Faction.values[rng.nextInt(2)]);
      for (var ply = 0; ply < 200 && !g.isOver; ply++) {
        // A veces la habilidad es la acción del turno.
        var acted = false;
        if (g.abilityAvailable && rng.nextInt(4) == 0) {
          if (g.currentFaction == Faction.ninja) {
            final t = g.kawarimiTargets().toList();
            if (t.isNotEmpty) acted = g.kawarimi(t[rng.nextInt(t.length)]);
          } else {
            final src = g.jadeRelocateSources().toList();
            if (src.isNotEmpty) {
              final s = src[rng.nextInt(src.length)];
              final dst = g.jadeRelocateTargets(s).toList();
              if (dst.isNotEmpty) acted = g.jadeRelocate(s, dst[rng.nextInt(dst.length)]);
            }
          }
          expect(g.board.isConnected(), isTrue);
        }
        if (acted) continue;
        final ply0 = g.ply;
        final movable = g.movablePieces().toList();
        final types = g.placeableTypes();
        if (types.isNotEmpty && (movable.isEmpty || rng.nextBool())) {
          final targets = g.placementTargets().toList();
          expect(g.place(types[rng.nextInt(types.length)], targets[rng.nextInt(targets.length)]), isTrue);
        } else if (movable.isNotEmpty) {
          final from = movable[rng.nextInt(movable.length)];
          final swaps = g.shogunSwapTargets(from).toList();
          final dests = g.moveTargets(from).toList();
          if (swaps.isNotEmpty && (dests.isEmpty || rng.nextInt(5) == 0)) {
            expect(g.shogunSwap(from, swaps.first), isTrue);
          } else {
            final to = dests[rng.nextInt(dests.length)];
            final fx = g.effectOptions(from, to);
            final opts = [...fx.paralyze, ...fx.seal];
            final pick = opts.isEmpty ? null : opts[rng.nextInt(opts.length)];
            expect(
              g.move(
                from,
                to,
                paralyze: fx.paralyze.contains(pick) ? pick : null,
                seal: fx.seal.contains(pick) ? pick : null,
              ),
              isTrue,
            );
          }
        }
        expect(g.board.isConnected(), isTrue, reason: 'partida $game ply $ply');
        final total =
            g.board.occupied.fold<int>(0, (a, h) => a + g.board.height(h)) +
            g.hands.fold<int>(0, (a, hand) => a + hand.values.fold(0, (x, y) => x + y));
        expect(total, 22, reason: 'las fichas se conservan');
        if (g.ply == ply0 && !g.isOver) {
          // Sin acción principal: la habilidad si la hay, si no pasar.
          final ab = abilityActions(g);
          expect(ab.isEmpty ? g.pass() : ab.first.apply(g), isTrue);
        }
      }
      if (g.isOver) finished++;
    }
    // ignore: avoid_print
    print('Partidas terminadas por victoria/empate: $finished/300');
  });
}
