import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/pieces.dart';

/// Juega [plies] acciones al azar (con habilidades incluidas cuando salen).
GameState randomGame(int seed, int plies) {
  final rng = Random(seed);
  final g = GameState(Faction.shaolin, Faction.ninja);
  for (var i = 0; i < plies && !g.isOver; i++) {
    final actions = mainActions(g);
    actions.isEmpty ? g.pass() : actions[rng.nextInt(actions.length)].apply(g);
  }
  return g;
}

void main() {
  test('la foto de la partida ida y vuelta por JSON da el mismo estado', () {
    for (var seed = 0; seed < 20; seed++) {
      final g = randomGame(seed, 10 + seed * 3);
      final back = GameState.fromJson(jsonDecode(jsonEncode(g.toJson())) as Map<String, Object?>);
      expect(back.toJson(), g.toJson(), reason: 'semilla $seed');
      expect(back.board.key, g.board.key);
      expect(back.round, g.round);
      expect(back.currentFaction, g.currentFaction);
      // La retomada sigue jugándose igual que la original.
      expect(mainActions(back).length, mainActions(g).length);
    }
  });
}
