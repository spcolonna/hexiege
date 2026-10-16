import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/solo/catalog.dart';

void main() {
  for (final c in campaigns) {
    group(c.title, () {
      test('8 batallas de ${c.faction.name}, de menor a mayor nivel', () {
        expect(c.stages, hasLength(8));
        expect(c.stages.every((s) => s.you == c.faction && s.kind == StageKind.campaign), isTrue);
        expect(c.stages.every((s) => s.intro != 'stage.${s.id}.intro'), isTrue);
        expect(c.stages.last.level, AiLevel.master);
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
}
