import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/codex/codex_scenes.dart';
import 'package:hexiege/engine/pieces.dart';

void main() {
  test('cada ficha del códice tiene adónde moverse y la colmena está conectada', () {
    for (final t in PieceType.values) {
      final s = CodexScene.of(t);
      // ignore: avoid_print
      print('${t.name}: ${s.tour.map((h) => '(${h.q},${h.r})').join(' ')} swaps=${s.swapTargets.length}');
      expect(s.targets, isNotEmpty, reason: t.name);
      expect(s.game.board.isConnected(), isTrue, reason: t.name);
    }
  });
}
