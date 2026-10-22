import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/stage.dart';

void main() {
  const sh = Faction.shaolin, nj = Faction.ninja;
  // Shogun en el centro con [n] vecinos: los dos primeros son suyos.
  GameState ringed(int n, {int round = 6}) {
    final around = Hex.origin.neighbors.take(n).toList();
    return buildScene(
      you: sh,
      opp: nj,
      round: round,
      pieces: [
        (1, PieceType.shogun, Hex.origin),
        for (final (i, h) in around.indexed)
          i < 2 ? (1, PieceType.kitsune, h) : (0, PieceType.serpent, h),
        (0, PieceType.monk, const Hex(0, 3)),
      ],
    );
  }

  test('captureBreakdown cuenta lados y de quién son', () {
    final b = ringed(6).captureBreakdown(1)!;
    expect(b.leader, Hex.origin);
    expect((b.sides, b.enemy, b.own), (6, 4, 2));
  });

  test('sin cerco no hay desglose', () {
    expect(ringed(5).captureBreakdown(1), isNull);
  });

  test('en Asedio alcanzan 5 lados y queda uno libre', () {
    final g = ringed(5, round: 36);
    expect(g.inSiege, isTrue);
    final b = g.captureBreakdown(1)!;
    expect((b.sides, b.enemy, b.own), (5, 3, 2));
  });
}
