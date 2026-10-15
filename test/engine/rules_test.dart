import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/board.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';

var _id = 1000;
Piece put(GameState g, PieceType t, int owner, Hex h) {
  final p = Piece(_id++, t, owner);
  g.board.push(h, p);
  // Las fichas puestas a mano salen de la mano para mantener consistencia.
  final hand = g.hands[owner];
  if ((hand[t] ?? 0) > 0) hand[t] = hand[t]! - 1;
  return p;
}

Hex h(int q, int r) => Hex(q, r);

void main() {
  group('Hex', () {
    test('distancia y vecinos comunes', () {
      expect(h(0, 0).distanceTo(h(2, -1)), 2);
      final cn = commonNeighbors(h(0, 0), h(1, 0));
      expect(cn.toSet(), {h(1, -1), h(0, 1)});
    });
  });

  group('Colocación', () {
    test('primera en el origen, segunda adyacente, luego no tocar enemigas', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      expect(g.placementTargets(), {Hex.origin});
      expect(g.place(PieceType.dragon, Hex.origin), isTrue);
      g.endTurn();
      expect(g.placementTargets(), Hex.origin.neighbors.toSet());
      expect(g.place(PieceType.shinobi, h(1, 0)), isTrue);
      g.endTurn();
      final targets = g.placementTargets();
      expect(targets.contains(h(-1, 0)), isTrue);
      expect(targets.contains(h(1, -1)), isFalse, reason: 'toca al Shinobi enemigo');
    });

    test('el Líder es obligatorio en el 4.º turno propio', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      g.place(PieceType.dragon, Hex.origin);
      g.endTurn();
      g.place(PieceType.shinobi, h(1, 0));
      g.endTurn();
      g.place(PieceType.dragon, h(-1, 0));
      g.endTurn();
      g.place(PieceType.shinobi, h(2, 0));
      g.endTurn();
      g.place(PieceType.crane, h(-2, 0));
      g.endTurn();
      g.place(PieceType.kitsune, h(3, 0));
      g.endTurn();
      expect(g.mustPlaceLeader, isTrue);
      expect(g.placeableTypes(), [PieceType.monk]);
      expect(g.place(PieceType.tiger, h(-3, 0)), isFalse);
    });

    test('no se puede mover sin el Líder en juego', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.dragon, 0, h(0, 0));
      put(g, PieceType.shogun, 1, h(1, 0));
      expect(g.moveTargets(h(0, 0)), isEmpty);
    });
  });

  group('Colmena y movimiento', () {
    test('One-Hive: una ficha puente no puede moverse', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.monk, 0, h(-1, 0));
      put(g, PieceType.serpent, 0, h(0, 0));
      put(g, PieceType.shogun, 1, h(1, 0));
      expect(g.board.canLift(h(0, 0)), isFalse);
      expect(g.moveTargets(h(0, 0)), isEmpty);
    });

    test('compuerta: no se desliza entre dos fichas; el Shinobi sí', () {
      // Hueco en (0,0) con 5 vecinas ocupadas; entrar desde (1,-1) pasa entre (1,0) y (0,-1).
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, -1));
      put(g, PieceType.tengu, 0, h(-1, 0));
      put(g, PieceType.tengu, 0, h(-1, 1));
      put(g, PieceType.kitsune, 0, h(0, 1));
      put(g, PieceType.kitsune, 0, h(1, 0));
      put(g, PieceType.shinobi, 0, h(2, -1));
      put(g, PieceType.monk, 1, h(2, 0));
      // (0,0) está vacío y rodeado: entrar requiere pasar por una compuerta.
      expect(g.moveTargets(h(2, -1)).contains(h(0, 0)), isTrue, reason: 'Shinobi ignora compuertas');
      g.board.pop(h(2, -1));
      put(g, PieceType.kunoichi, 0, h(2, -1));
      expect(g.moveTargets(h(2, -1)).contains(h(0, 0)), isFalse);
    });

    test('Dragón vuela sobre la línea; Grulla salta exactamente 2', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.dragon, 0, h(0, 0));
      put(g, PieceType.monk, 0, h(1, 0));
      put(g, PieceType.shogun, 1, h(2, 0));
      put(g, PieceType.shinobi, 1, h(3, 0));
      expect(g.moveTargets(h(0, 0)), contains(h(4, 0)));
      g.board.pop(h(0, 0));
      put(g, PieceType.crane, 0, h(0, 0));
      expect(g.moveTargets(h(0, 0)).contains(h(4, 0)), isFalse);
      g.board.pop(h(3, 0));
      expect(g.moveTargets(h(0, 0)), contains(h(3, 0)));
    });

    test('Rey Mono se sube encima y bloquea; en el suelo copia movimientos', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.monk, 0, h(0, 1));
      put(g, PieceType.wukong, 0, h(0, 0));
      put(g, PieceType.shinobi, 1, h(1, 0));
      put(g, PieceType.shogun, 1, h(2, 0));
      expect(g.moveTargets(h(0, 0)), contains(h(1, 0)));
      expect(g.move(h(0, 0), h(1, 0)), isTrue);
      expect(g.board.height(h(1, 0)), 2);
      // copia: junto al Dragón puede saltar
      final g2 = GameState(Faction.shaolin, Faction.ninja);
      put(g2, PieceType.monk, 0, h(-1, 0));
      put(g2, PieceType.wukong, 0, h(0, -1));
      put(g2, PieceType.dragon, 0, h(0, 0));
      put(g2, PieceType.shogun, 1, h(0, 1));
      // Desde (0,-1) en dirección (0,1): salta (0,0),(0,1) -> (0,2)
      expect(g2.moveTargets(h(0, -1)), contains(h(0, 2)));
    });

    test('Tigre empuja cuando queda frente a una enemiga', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.tiger, 0, h(-1, 0));
      put(g, PieceType.monk, 0, h(-1, 1));
      put(g, PieceType.serpent, 0, h(0, 1));
      put(g, PieceType.kitsune, 1, h(1, 0));
      put(g, PieceType.shogun, 1, h(1, 1));
      // tiger (-1,0) -> (0,0); delante (1,0) kitsune enemiga; detrás (2,0) libre.
      expect(g.move(h(-1, 0), h(0, 0)), isTrue);
      expect(g.board.isOccupied(h(1, 0)), isFalse);
      expect(g.board.top(h(2, 0))!.type, PieceType.kitsune);
      expect(g.board.isConnected(), isTrue);
    });

    test('Tengu se teletransporta a huecos que tocan 2 fichas', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.tengu, 0, h(-1, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.serpent, 1, h(2, 0));
      final t = g.moveTargets(h(-1, 0));
      expect(t, contains(h(1, -1))); // toca (0,0),(1,0)
      expect(t, contains(h(2, -1))); // toca (1,0),(2,0)
      expect(t.contains(h(3, 0)), isFalse); // solo toca 1
    });
  });

  group('Efectos', () {
    test('Kunoichi paraliza durante el próximo turno enemigo', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.kunoichi, 0, h(-1, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.dragon, 1, h(2, 0));
      final opts = g.effectOptions(h(-1, 0), h(0, 1));
      expect(opts.paralyze, contains(h(1, 0)));
      expect(g.move(h(-1, 0), h(0, 1), paralyze: h(1, 0)), isTrue);
      g.endTurn();
      expect(g.moveTargets(h(1, 0)), isEmpty, reason: 'Monje paralizado');
      expect(g.moveTargets(h(2, 0)), isNotEmpty);
      g.move(h(2, 0), g.moveTargets(h(2, 0)).first);
      g.endTurn();
      g.place(g.placeableTypes().first, g.placementTargets().first);
      g.endTurn();
      expect(g.isParalyzed(g.board.top(h(1, 0))!), isFalse);
    });

    test('Sello de Sombra paraliza a la enemiga que entra', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.shadow, 0, h(-1, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.serpent, 1, h(1, 1));
      final to = h(-1, 1);
      expect(g.effectOptions(h(-1, 0), to).seal, contains(h(-2, 1)));
      g.move(h(-1, 0), to, seal: h(0, 1));
      expect(g.seals[h(0, 1)], 0);
      g.endTurn();
      expect(g.moveTargets(h(1, 1)), contains(h(0, 1)));
      g.move(h(1, 1), h(0, 1));
      expect(g.seals.containsKey(h(0, 1)), isFalse);
      final serpent = g.board.top(h(0, 1))!;
      g.endTurn();
      g.mainActionDone = true;
      g.endTurn();
      expect(g.isParalyzed(serpent), isTrue);
      expect(g.moveTargets(h(0, 1)), isEmpty);
    });

    test('Serpiente anula efectos de enemigas adyacentes', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.kunoichi, 0, h(-1, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.serpent, 1, h(0, 1));
      // Kunoichi moviéndose a (-1,1) quedaría junto a la Serpiente en (0,1).
      expect(g.moveTargets(h(-1, 0)), contains(h(-1, 1)));
      expect(g.effectOptions(h(-1, 0), h(-1, 1)).paralyze, isEmpty);
    });

    test('Shogun intercambia con Shinobi una vez por partida', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.shinobi, 0, h(-1, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      expect(g.shogunSwap(h(0, 0), h(-1, 0)), isTrue);
      expect(g.board.top(h(-1, 0))!.type, PieceType.shogun);
      expect(g.shogunSwapUsed[0], isTrue);
    });
  });

  group('Habilidades de facción', () {
    test('Kawarimi devuelve a la mano y entra en cooldown', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.dragon, 1, h(2, 0));
      final before = g.hands[1][PieceType.dragon]!;
      expect(g.kawarimiTargets(), {h(2, 0)}, reason: 'Líderes excluidos');
      expect(g.kawarimi(h(2, 0)), isTrue);
      expect(g.hands[1][PieceType.dragon], before + 1);
      expect(g.cooldowns[0], abilityCooldown);
      expect(g.abilityAvailable, isFalse);
    });

    test('Cooldown: disponible de nuevo 3 turnos propios después', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      g.cooldowns[0] = abilityCooldown;
      for (var i = 0; i < 3; i++) {
        g.mainActionDone = true;
        g.endTurn();
        g.mainActionDone = true;
        g.endTurn();
      }
      expect(g.cooldowns[0], 0);
    });

    test('Meditación de Jade reubica enemigas e intercambia aliadas', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.monk, 0, h(0, 0));
      put(g, PieceType.tiger, 0, h(-1, 0));
      put(g, PieceType.shogun, 1, h(1, 0));
      put(g, PieceType.kitsune, 1, h(2, 0));
      expect(g.jadeRelocateSources(), {h(2, 0)});
      final g2 = g.copy();
      expect(g.jadeRelocate(h(2, 0), h(-2, 0)), isTrue);
      expect(g.board.top(h(-2, 0))!.type, PieceType.kitsune);
      expect(g2.jadeSwap(h(0, 0), h(-1, 0)), isTrue);
      expect(g2.board.top(h(-1, 0))!.type, PieceType.monk);
    });
  });

  group('Victoria', () {
    test('rodear al Líder enemigo gana', () {
      final g = GameState(Faction.shaolin, Faction.ninja);
      put(g, PieceType.shogun, 1, h(0, 0));
      final ring = h(0, 0).neighbors;
      put(g, PieceType.monk, 0, ring[0]);
      for (var i = 1; i < 5; i++) {
        put(g, PieceType.serpent, i.isEven ? 0 : 1, ring[i]);
      }
      put(g, PieceType.kitsune, 0, h(-1, 2));
      expect(g.winner, isNull);
      // La última ficha se desliza y cierra el anillo.
      expect(g.move(h(-1, 2), ring[5]), isTrue);
      expect(g.board.isSurrounded(h(0, 0)), isTrue);
      expect(g.winner, 0);
    });

    test('Board.isConnected', () {
      final b = Board();
      b.push(h(0, 0), const Piece(1, PieceType.monk, 0));
      b.push(h(2, 0), const Piece(2, PieceType.monk, 1));
      expect(b.isConnected(), isFalse);
    });
  });
}
