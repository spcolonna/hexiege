import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/solo/solver.dart';

void main() {
  group('Problemas', () {
    test('ids únicos', () {
      final ids = [for (final l in stageLists) ...l.map((s) => s.id)];
      expect(ids.toSet().length, ids.length);
    });

    for (final p in puzzles) {
      test('${p.id} ${p.title}: cerco forzado en ${p.puzzleTurns} y no antes', () {
        final g = p.build();
        expect(g.current, 0);
        expect(g.board.isConnected(), isTrue);
        expect(forcedWin(g, p.puzzleTurns!), isNotNull, reason: 'sin solución');
        if (p.puzzleTurns! > 1) expect(forcedWin(g, p.puzzleTurns! - 1), isNull, reason: 'se resuelve antes');
      });
    }
  });

  test('la solución gana contra la defensa del solver', () {
    for (final p in puzzles) {
      final start = p.build();
      final g = start.copy();
      for (var turn = 0; turn < p.puzzleTurns! && !g.isOver; turn++) {
        expect(g.play(forcedWin(g, p.puzzleTurns! - turn)!), isTrue);
        if (g.isOver) break;
        g.play(defend(g, p.turnsLeft(start, g)!));
      }
      expect(p.verdict(start, g), isTrue, reason: p.id);
    }
  });

  test('la defensa refuta una primera jugada equivocada', () {
    final p = puzzles.firstWhere((s) => s.id == 'p12');
    final start = p.build();
    final g = start.copy();
    // Ocupar el hueco sin paralizar al Tigre: deja que se aparte.
    expect(const MoveAction(Hex(-1, -1), Hex(-1, 0)).apply(g), isTrue);
    g.play(defend(g, p.turnsLeft(start, g)!));
    expect(forcedWin(g, p.turnsLeft(start, g)!), isNull);
  });
}
