import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/board.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/moves.dart';
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

    test('Tengu se teletransporta a huecos que tocan 3 fichas', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.tengu, 0, h(-1, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.serpent, 1, h(2, 0));
      put(g, PieceType.serpent, 1, h(1, -1));
      final t = g.moveTargets(h(-1, 0));
      expect(t, contains(h(2, -1))); // toca (1,-1),(1,0),(2,0)
      expect(t.contains(h(0, -1)), isFalse); // toca (0,0),(1,-1); (-1,0) es el propio Tengu
      expect(t.contains(h(3, -1)), isFalse); // solo toca 1
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
      expect(g.cooldowns[0], Rules.standard.abilityCooldown);
      expect(g.abilityAvailable, isFalse);
    });

    test('Cooldown: disponible de nuevo 3 turnos propios después', () {
      final g = GameState(Faction.ninja, Faction.shaolin);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      g.cooldowns[0] = Rules.standard.abilityCooldown;
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

  group('Parámetros de balance', () {
    test('la habilidad tiene usos limitados por partida', () {
      final g = GameState(Faction.ninja, Faction.shaolin, rules: const Rules(abilityCharges: 1));
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.monk, 1, h(1, 0));
      put(g, PieceType.dragon, 1, h(2, 0));
      expect(g.abilityChargesLeft(0), 1);
      expect(g.kawarimi(h(2, 0)), isTrue);
      expect(g.abilityChargesLeft(0), 0);
      g.cooldowns[0] = 0;
      g.abilityUsedThisTurn = false;
      expect(g.abilityAvailable, isFalse, reason: 'sin usos aunque no haya recarga');
    });

    test('Asedio: desde su ronda alcanzan 5 lados para capturar al Líder', () {
      final g = GameState(Faction.shaolin, Faction.ninja, rules: const Rules(siegeRound: 2, roundLimit: 9));
      put(g, PieceType.monk, 0, h(-3, 0));
      put(g, PieceType.shogun, 1, h(0, 0));
      final ring = h(0, 0).neighbors;
      for (var i = 0; i < 4; i++) {
        put(g, PieceType.serpent, i.isEven ? 0 : 1, ring[i]);
      }
      put(g, PieceType.dragon, 0, h(-2, 0));
      put(g, PieceType.tiger, 0, h(-2, 1)); // puede embestir a ring[4] = (-1,1)
      expect(g.inSiege, isFalse);
      expect(g.captureThreshold, 6);
      g.mainActionDone = true;
      g.endTurn();
      g.mainActionDone = true;
      g.endTurn();
      expect(g.round, 2);
      expect(g.inSiege, isTrue);
      expect(g.captureThreshold, 5);
      expect(g.move(h(-2, 1), ring[4]), isTrue);
      expect(g.leaderPressure(1), 5);
      expect(g.winner, 0);
    });

    test('al terminar la última ronda la partida es empate', () {
      final g = GameState(Faction.shaolin, Faction.ninja, rules: const Rules(siegeRound: null, roundLimit: 1));
      put(g, PieceType.monk, 0, h(0, 0));
      put(g, PieceType.shogun, 1, h(1, 0));
      g.mainActionDone = true;
      g.endTurn();
      expect(g.isOver, isFalse);
      g.mainActionDone = true;
      g.endTurn();
      expect(g.draw, isTrue);
      expect(g.endedByLimit, isTrue);
    });

    test('alcance del Shinobi, salto corto de la Grulla y contacto del Tengu', () {
      final b = Board();
      for (var q = 0; q < 8; q++) {
        b.push(h(q, 0), Piece(_id++, PieceType.serpent, 0));
      }
      final far = destinationsFor(PieceType.shinobi, b, h(-1, 0), Rules.classic);
      final near = destinationsFor(PieceType.shinobi, b, h(-1, 0), const Rules(shinobiRange: 2));
      expect(near.length, lessThan(far.length));
      expect(near.every((d) => d.distanceTo(h(-1, 0)) <= 2), isTrue);

      final line = Board()
        ..push(h(1, 0), Piece(_id++, PieceType.serpent, 0))
        ..push(h(3, 0), Piece(_id++, PieceType.serpent, 0));
      expect(destinationsFor(PieceType.crane, line, h(0, 0), Rules.classic).contains(h(2, 0)), isFalse);
      expect(
        destinationsFor(PieceType.crane, line, h(0, 0), const Rules(craneShortJump: true)).contains(h(2, 0)),
        isTrue,
      );

      // h(1,-1) toca 2 fichas (0,0)/(1,0); con contacto 3 deja de ser destino.
      final tri = Board()
        ..push(h(0, 0), Piece(_id++, PieceType.serpent, 0))
        ..push(h(1, 0), Piece(_id++, PieceType.serpent, 0))
        ..push(h(5, 0), Piece(_id++, PieceType.serpent, 0));
      expect(destinationsFor(PieceType.tengu, tri, h(5, 0), Rules.classic).contains(h(1, -1)), isTrue);
      expect(destinationsFor(PieceType.tengu, tri, h(5, 0), const Rules(tenguMinTouch: 3)).contains(h(1, -1)), isFalse);
    });

    test('Tengu y Shinobi junto al Líder rival, según las reglas', () {
      GameState tengu(Rules r) {
        final g = GameState(Faction.ninja, Faction.shaolin, rules: r);
        put(g, PieceType.shogun, 0, h(0, 0));
        put(g, PieceType.tengu, 0, h(-1, 0));
        put(g, PieceType.monk, 1, h(1, 0));
        put(g, PieceType.serpent, 1, h(2, 0));
        put(g, PieceType.serpent, 1, h(1, -1));
        put(g, PieceType.serpent, 1, h(2, -2));
        put(g, PieceType.kitsune, 0, h(0, -1));
        return g;
      }

      // (2,-1) toca al Monje; (1,-2) toca 3 fichas pero no al Monje.
      expect(tengu(Rules.standard).moveTargets(h(-1, 0)), contains(h(2, -1)));
      final far = tengu(const Rules(tenguNearLeader: TenguNearLeader.never)).moveTargets(h(-1, 0));
      expect(far.contains(h(2, -1)), isFalse);
      expect(far, contains(h(1, -2)));

      // Hueco (0,0) rodeado: el Shinobi entra por la compuerta (-1,0)/(0,1).
      GameState shinobi(Rules r) {
        final g = GameState(Faction.ninja, Faction.shaolin, rules: r);
        put(g, PieceType.shogun, 0, h(-1, 0));
        put(g, PieceType.kitsune, 0, h(0, 1));
        put(g, PieceType.shinobi, 0, h(-1, 1));
        put(g, PieceType.monk, 1, h(1, 0));
        put(g, PieceType.serpent, 1, h(0, -1));
        put(g, PieceType.serpent, 1, h(1, -1));
        return g;
      }

      expect(shinobi(Rules.standard).moveTargets(h(-1, 1)), contains(h(0, 0)));
      final gated = shinobi(const Rules(shinobiGateNextToLeader: false)).moveTargets(h(-1, 1));
      expect(gated.contains(h(0, 0)), isFalse);
      expect(gated, isNotEmpty);
    });

    test('Tengu notClosing: puede ir junto al Líder pero no cerrar el cerco', () {
      GameState g(bool fifth) {
        final g = GameState(Faction.ninja, Faction.shaolin, rules: const Rules(tenguNearLeader: TenguNearLeader.notClosing));
        put(g, PieceType.monk, 1, h(0, 0));
        put(g, PieceType.serpent, 1, h(1, 0));
        put(g, PieceType.serpent, 1, h(-1, 0));
        put(g, PieceType.shogun, 0, h(-1, 1));
        put(g, PieceType.kitsune, 0, h(0, -1));
        if (fifth) put(g, PieceType.kitsune, 0, h(0, 1));
        put(g, PieceType.tengu, 0, h(2, 0));
        return g;
      }

      // (1,-1) es el último hueco libre del Monje: con 5 vecinos, cerraría el cerco.
      expect(g(true).moveTargets(h(2, 0)).contains(h(1, -1)), isFalse);
      expect(g(false).moveTargets(h(2, 0)), contains(h(1, -1)));
      final free = GameState(Faction.ninja, Faction.shaolin, rules: const Rules(tenguNearLeader: TenguNearLeader.allowed));
      put(free, PieceType.monk, 1, h(0, 0));
      put(free, PieceType.serpent, 1, h(1, 0));
      put(free, PieceType.serpent, 1, h(-1, 0));
      put(free, PieceType.shogun, 0, h(-1, 1));
      put(free, PieceType.kitsune, 0, h(0, -1));
      put(free, PieceType.kitsune, 0, h(0, 1));
      put(free, PieceType.tengu, 0, h(2, 0));
      expect(free.moveTargets(h(2, 0)), contains(h(1, -1)));
    });

    test('los efectos de unidad se pueden apagar', () {
      final g = GameState(Faction.ninja, Faction.shaolin, rules: const Rules(kunoichiParalysis: false, shogunSwap: false));
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.kunoichi, 0, h(-1, 0));
      put(g, PieceType.shinobi, 0, h(0, -1));
      put(g, PieceType.monk, 1, h(1, 0));
      expect(g.effectOptions(h(-1, 0), h(0, 1)).paralyze, isEmpty);
      expect(g.shogunSwapTargets(h(0, 0)), isEmpty);
    });
  });
}
