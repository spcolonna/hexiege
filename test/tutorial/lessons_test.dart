import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/tutorial/lessons.dart';

void main() {
  for (final (i, l) in lessons.indexed) {
    test('lección ${i + 1} "${l.title}": se resuelve en una acción', () {
      final start = l.build();
      expect(start.isOver, isFalse);
      expect(start.current, 0);
      expect(l.done(start, start), isFalse, reason: 'no arranca resuelta');

      final actions = [
        ...mainActions(start).where((a) => a is! PlaceAction || l.hand == null || l.hand!.contains(a.type)),
        if (l.ability) ...abilityActions(start),
      ];
      final wins = actions.where((a) {
        final g = start.copy();
        return a.apply(g) && l.done(start, g);
      });
      expect(wins, isNotEmpty);
    });
  }

  test('en "Una sola colmena" y "Cada ficha" solo se mueve la ficha señalada', () {
    for (final l in lessons.where((l) => l.title == 'Una sola colmena' || l.title == 'Cada ficha es distinta')) {
      final g = l.build();
      expect(g.movablePieces().toSet(), {l.spotlight.first});
    }
  });

  test('el escenario es determinista (mismos ids para animar el reinicio)', () {
    for (final l in lessons) {
      final a = l.build(), b = l.build();
      expect(a.board.tops.map((e) => '${e.key}${e.value.id}'), b.board.tops.map((e) => '${e.key}${e.value.id}'));
    }
  });
}
