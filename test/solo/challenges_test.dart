import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/catalog.dart';

void main() {
  group('Desafíos', () {
    for (final c in challenges) {
      test('${c.id} ${c.title}: arranca válido y se juega sin errores', () {
        final g = c.build();
        expect(g.current, 0);
        expect(g.isOver, isFalse);
        expect(g.board.isConnected(), isTrue);
        expect(g.factions, [c.you, c.opp]);
        for (final h in g.hands) {
          expect(h.values.every((n) => n >= 0), isTrue);
        }
        final ais = [AiPlayer(AiLevel.easy, seed: 1), AiPlayer(AiLevel.easy, seed: 2)];
        for (var ply = 0; ply < 12 && !g.isOver; ply++) {
          for (final a in ais[g.current].chooseTurn(g)) {
            expect(a.apply(g), isTrue, reason: '$a');
          }
          if (!g.isOver) g.endTurn();
        }
      });
    }

    test('ganar supera el desafío; empatar por el límite no', () {
      final c = challenges.firstWhere((s) => s.id == 'c01');
      final start = c.build();
      final won = start.copy()..winner = 0;
      expect(c.verdict(start, won), isTrue);
      final limit = start.copy()
        ..draw = true
        ..endedByLimit = true;
      expect(c.verdict(start, limit), isFalse);
      expect(c.verdict(start, start), isNull);
    });

    test('sin habilidad: el jugador no la tiene, el rival sí', () {
      final g = challenges.firstWhere((s) => s.id == 'c02').build();
      expect(g.abilityChargesLeft(0), 0);
      expect(g.abilityChargesLeft(1), Rules.standard.abilityCharges);
    });

    test('última resistencia: el Monje arranca con 4 vecinos', () {
      final g = challenges.firstWhere((s) => s.id == 'c09').build();
      expect(g.leaderPressure(0), 4);
      expect(g.hands[1][PieceType.shogun], 0);
    });

    test('cielo de Tengus: la mano rival trae 3', () {
      final g = challenges.firstWhere((s) => s.id == 'c06').build();
      expect(g.hands[1][PieceType.tengu], 3);
      expect(g.hands[0][PieceType.dragon], 2);
    });
  });

  test('cada etapa conoce a la siguiente de su lista', () {
    for (final list in stageLists) {
      for (var i = 0; i < list.length; i++) {
        expect(stageAfter(list[i])?.id, i + 1 < list.length ? list[i + 1].id : null);
      }
    }
  });
}
