import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/stage.dart';

import 'rules_test.dart' show put, h;

/// Reglas del Sello final: mano mixta, dos Líderes, habilidades de las dos facciones.
final _seal = Rules.standard.copyWith(
  mixedSeal: true,
  dualAbility: {0},
  handsByOwner: () => [
    {...startingHands[Faction.shaolin]!, ...startingHands[Faction.ninja]!},
    startingHands[Faction.oni]!,
  ],
);

void main() {
  group('Facción Oni', () {
    test('las fichas del Oni no son jugables ni están en el códice', () {
      expect(playableFactions, isNot(contains(Faction.oni)));
      expect(playablePieces.any((t) => t.faction == Faction.oni), isFalse);
      expect(PieceType.oni.isLeader, isTrue);
      expect(PieceType.gaki.faction, Faction.oni);
    });

    test('el Gaki llega a cualquier borde y paraliza al llegar', () {
      final g = GameState(Faction.shaolin, Faction.oni);
      put(g, PieceType.monk, 0, h(0, 0));
      put(g, PieceType.oni, 1, h(1, 0));
      for (var q = 2; q <= 5; q++) {
        put(g, PieceType.dragon, 0, h(-q + 1, 0));
      }
      put(g, PieceType.gaki, 1, h(2, 0));
      g.current = 1;
      final reach = g.moveTargets(h(2, 0));
      expect(reach, contains(h(-4, 1)), reason: 'sin límite de alcance');
      expect(g.effectOptions(h(2, 0), h(-4, 1)).paralyze, isNotEmpty);
    });

    test('el Ojo del Oni anula efectos a 2 casillas y las habilidades no lo mueven', () {
      final g = GameState(Faction.ninja, Faction.oni);
      put(g, PieceType.shogun, 0, h(0, 0));
      put(g, PieceType.kunoichi, 0, h(-1, 0));
      put(g, PieceType.oni, 1, h(1, 0));
      put(g, PieceType.oniEye, 1, h(2, -1));
      put(g, PieceType.tiger, 1, h(1, 1));
      expect(g.isSuppressed(h(0, 0), 0), isTrue, reason: 'a 2 casillas del Ojo');
      expect(g.isSuppressed(h(-1, 0), 0), isFalse, reason: 'a 3 casillas');
      expect(g.kawarimiTargets(), isNot(contains(h(2, -1))));
      expect(g.kawarimiTargets(), contains(h(1, 1)));
    });
  });

  group('Sello final', () {
    /// Oni en el origen con 5 fichas del jugador alrededor y [last] cerrando el anillo.
    GameState ring(PieceType last) {
      final g = GameState(Faction.shaolin, Faction.oni, rules: _seal);
      put(g, PieceType.oni, 1, h(0, 0));
      final around = h(0, 0).neighbors;
      for (var i = 0; i < 5; i++) {
        put(g, PieceType.dragon, 0, around[i]);
      }
      put(g, last, 0, around[5]);
      g.setupSkipTurn();
      return g;
    }

    test('rodear al Oni solo con Shaolin no lo sella', () {
      expect(ring(PieceType.tiger).winner, isNull);
    });

    test('con una ficha Ninja en el cerco, el Oni cae', () {
      expect(ring(PieceType.shinobi).winner, 0);
    });

    test('sin el sello mixto, cualquier cerco gana', () {
      final g = GameState(Faction.shaolin, Faction.oni);
      put(g, PieceType.oni, 1, h(0, 0));
      for (final n in h(0, 0).neighbors) {
        put(g, PieceType.dragon, 0, n);
      }
      g.setupSkipTurn();
      expect(g.winner, 0);
    });

    test('con dos Líderes, perdés si rodean a cualquiera', () {
      final g = GameState(Faction.shaolin, Faction.oni, rules: _seal);
      put(g, PieceType.monk, 0, h(-5, 0));
      put(g, PieceType.shogun, 0, h(0, 0));
      for (final n in h(0, 0).neighbors) {
        put(g, PieceType.tiger, 1, n);
      }
      g.setupSkipTurn();
      expect(g.winner, 1);
    });

    test('habilidades de las dos facciones con recarga compartida', () {
      final g = GameState(Faction.shaolin, Faction.oni, rules: _seal);
      put(g, PieceType.monk, 0, h(0, 0));
      put(g, PieceType.shogun, 0, h(-1, 0));
      put(g, PieceType.oni, 1, h(1, 0));
      put(g, PieceType.tiger, 1, h(2, 0));
      expect(g.kawarimiTargets(), contains(h(2, 0)));
      expect(g.jadeRelocateSources(), contains(h(2, 0)));
      expect(abilityActions(g).whereType<KawarimiAction>(), isNotEmpty);
      expect(abilityActions(g).whereType<JadeRelocateAction>(), isNotEmpty);
      expect(g.kawarimi(h(2, 0)), isTrue);
      g.setupSkipTurn(); // turno del Oni
      expect(g.abilityAvailable, isFalse);
      expect(g.jadeRelocateSources(), isEmpty, reason: 'la recarga es una sola');
    });

    test('el Oni no tiene habilidad', () {
      final g = GameState(Faction.shaolin, Faction.oni, rules: _seal);
      put(g, PieceType.oni, 1, h(0, 0));
      put(g, PieceType.monk, 0, h(1, 0));
      g.current = 1;
      expect(g.abilityAvailable, isFalse);
      expect(abilityActions(g), isEmpty);
    });

    test('buildScene respeta manos con fichas de otra facción', () {
      final g = buildScene(
        you: Faction.shaolin,
        opp: Faction.oni,
        rules: _seal,
        pieces: const [
          (0, PieceType.monk, Hex(0, 0)),
          (0, PieceType.shogun, Hex(-1, 0)),
          (1, PieceType.oni, Hex(1, 0)),
        ],
        yourHand: const {PieceType.dragon: 2, PieceType.shinobi: 3},
        oppHand: const {PieceType.gaki: 2},
      );
      expect(g.hands[0][PieceType.shinobi], 3);
      expect(g.hands[0][PieceType.monk], 0);
      expect(g.hands[1][PieceType.gaki], 2);
      expect(g.placeableTypes(), containsAll([PieceType.dragon, PieceType.shinobi]));
    });

    test('la IA juega el Sello sin errores hasta el final', () {
      final g = buildScene(
        you: Faction.shaolin,
        opp: Faction.oni,
        rules: _seal,
        round: 2,
        yourAbility: true,
        oppAbility: true,
        pieces: const [
          (0, PieceType.monk, Hex(0, 0)),
          (0, PieceType.shogun, Hex(-1, 0)),
          (1, PieceType.oni, Hex(1, 0)),
        ],
        yourHand: {..._seal.handsByOwner![0], PieceType.monk: 0, PieceType.shogun: 0},
        oppHand: {..._seal.handsByOwner![1], PieceType.oni: 0},
      );
      final ais = [AiPlayer(AiLevel.easy, seed: 1), AiPlayer(AiLevel.easy, seed: 2)];
      for (var i = 0; i < 200 && !g.isOver; i++) {
        expect(g.play(ais[g.current].chooseTurn(g)), isTrue);
      }
    });
  });
}
