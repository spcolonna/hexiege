import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';

var _id = 5000;
void put(GameState g, PieceType t, int owner, Hex h) {
  g.board.push(h, Piece(_id++, t, owner));
  final hand = g.hands[owner];
  if ((hand[t] ?? 0) > 0) hand[t] = hand[t]! - 1;
}

void main() {
  test('la IA remata cuando puede rodear al Líder', () {
    final g = GameState(Faction.shaolin, Faction.ninja);
    const c = Hex(0, 0);
    put(g, PieceType.shogun, 1, c);
    final ring = c.neighbors;
    put(g, PieceType.monk, 0, ring[0]);
    put(g, PieceType.serpent, 0, ring[1]);
    put(g, PieceType.shinobi, 1, ring[2]);
    put(g, PieceType.serpent, 0, ring[3]);
    put(g, PieceType.kitsune, 1, ring[4]);
    put(g, PieceType.tiger, 0, const Hex(-1, 2)); // puede deslizarse a ring[5] = (0,1)
    for (final level in AiLevel.values) {
      final s = g.copy();
      final turn = AiPlayer(level, seed: 1).chooseTurn(s);
      for (final a in turn) {
        expect(a.apply(s), isTrue);
      }
      expect(s.winner, 0, reason: level.name);
    }
  });

  test('la IA Normal evita dejar al Líder a un paso de ser rodeado', () {
    // Líder Shaolin con 4 vecinos y el rival con una pieza lista para cerrar.
    final g = GameState(Faction.ninja, Faction.shaolin);
    const c = Hex(0, 0);
    put(g, PieceType.monk, 1, c);
    final ring = c.neighbors;
    put(g, PieceType.shogun, 0, ring[0]);
    put(g, PieceType.kitsune, 0, ring[1]);
    put(g, PieceType.tengu, 0, ring[2]);
    put(g, PieceType.dragon, 1, ring[3]);
    put(g, PieceType.shinobi, 0, const Hex(1, 1)); // amenaza ring[5]=(0,1) y ring[4]
    put(g, PieceType.serpent, 1, const Hex(-2, 1));
    g.current = 1;
    g.turnsTaken[1] = 5;
    g.turnsTaken[0] = 5;
    final turn = AiPlayer(AiLevel.normal, seed: 3).chooseTurn(g);
    final s = g.copy();
    for (final a in turn) {
      a.apply(s);
    }
    s.endTurn();
    // Ninguna respuesta del rival debe ganar de inmediato.
    for (final r in mainActions(s)) {
      final t = s.copy();
      r.apply(t);
      expect(t.winner, isNot(0), reason: 'respuesta $r gana');
    }
  });

  test('partidas IA vs IA terminan sin acciones ilegales', () {
    for (var seed = 0; seed < 6; seed++) {
      final g = GameState(Faction.values[seed % 2], Faction.values[(seed + 1) % 2]);
      final ais = [AiPlayer(AiLevel.easy, seed: seed), AiPlayer(AiLevel.normal, seed: seed + 100)];
      for (var ply = 0; ply < 80 && !g.isOver; ply++) {
        for (final a in ais[g.current].chooseTurn(g)) {
          expect(a.apply(g), isTrue);
        }
        expect(g.board.isConnected(), isTrue);
        if (!g.isOver) expect(g.endTurn(), isTrue);
      }
    }
  });
}
