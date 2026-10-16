import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/codex/codex_scenes.dart';
import 'package:hexiege/codex/gifts.dart';
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

  test('el ejemplo del Tigre incluye un empujón', () {
    expect(CodexScene.of(PieceType.tiger).pushes, isNotEmpty);
  });

  test('cada ficha se gana con exactamente un regalo', () {
    expect(Gift.all.map((g) => g.type).toSet(), PieceType.values.toSet());
    expect(Gift.all.length, PieceType.values.length);
  });
}
