import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/catalog.dart';

void main() {
  for (final c in campaigns) {
    group(c.title, () {
      if (!c.isFinale) {
        test('24 batallas de ${c.faction.name} en 4 actos, la última contra un maestro', () {
          expect(c.stages, hasLength(24));
          expect(c.stages.every((s) => s.you == c.faction && s.kind == StageKind.campaign), isTrue);
          expect(c.stages.last.level, AiLevel.master);
          expect(c.stages.take(kFreeStagesPerCampaign).every((s) => s.level.index <= AiLevel.easy.index), isTrue);
        });
      }

      test('cada batalla tiene título, objetivo e intro', () {
        for (final s in c.stages) {
          expect(s.title, isNot('stage.${s.id}.title'));
          expect(s.goal, isNot('stage.${s.id}.goal'));
          expect(s.intro, isNot('stage.${s.id}.intro'));
        }
      });

      for (final s in c.stages) {
        test('${s.id} ${s.title}: arranca válida y se juega sin errores', () {
          final g = s.build();
          expect(g.current, 0);
          expect(g.isOver, isFalse);
          expect(g.board.isConnected(), isTrue);
          for (final h in g.hands) {
            expect(h.values.every((n) => n >= 0), isTrue);
          }
          final ais = [AiPlayer(AiLevel.easy, seed: 3), AiPlayer(AiLevel.easy, seed: 4)];
          for (var ply = 0; ply < 12 && !g.isOver; ply++) {
            final turn = ais[g.current].chooseTurn(g);
            expect(g.play(turn), isTrue, reason: '$turn');
          }
        });
      }
    });
  }

  test('emboscadas: el Líder indicado arranca con 3 fichas enemigas al lado', () {
    final mine = shaolinCampaign.firstWhere((s) => s.id == 's3').build();
    expect(mine.leaderPressure(0), 4); // 3 enemigas + 1 propia
    expect(mine.leaderPressure(1), 2);
    final theirs = ninjaCampaign.firstWhere((s) => s.id == 'n3').build();
    expect(theirs.leaderPressure(1), 4);
    // Fichas en mano + en tablero = mano inicial completa.
    for (final g in [mine, theirs]) {
      for (var p = 0; p < 2; p++) {
        final onBoard = g.board.tops.where((e) => e.value.owner == p).length;
        final inHand = g.hands[p].values.fold(0, (a, b) => a + b);
        expect(onBoard + inHand, 11);
      }
    }
  });

  group('El Sello', () {
    test('se abre recién con las dos campañas terminadas', () {
      expect(isUnlocked(finale, 0, (id) => id == 's24'), isFalse);
      expect(isUnlocked(finale, 0, (id) => id == 'n24'), isFalse);
      expect(isUnlocked(finale, 0, (id) => id == 's24' || id == 'n24'), isTrue);
      expect(isUnlocked(finale, 1, (id) => id == 'f1'), isTrue);
    });

    test('F1 y F2 contra el Oni con una sola facción; F3 con la mano mixta', () {
      expect([for (final s in finale) s.opp], everyElement(Faction.oni));
      final f1 = finale[0].build(), f2 = finale[1].build();
      expect(f1.factions, [Faction.shaolin, Faction.oni]);
      expect(f2.factions, [Faction.ninja, Faction.oni]);
      final f3 = finale[2].build();
      expect(f3.rules.mixedSeal, isTrue);
      expect(f3.board.locateLeaders(0), hasLength(2));
      expect(f3.hands[0].keys.map((t) => t.faction).toSet(), containsAll([Faction.shaolin, Faction.ninja]));
    });
  });
}
