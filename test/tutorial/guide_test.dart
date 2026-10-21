import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/solo/stage.dart';
import 'package:hexiege/solo/stars.dart';
import 'package:hexiege/tutorial/guide.dart';

void main() {
  setUp(() => setLanguage('es'));

  test('la Iniciación arranca dando la bienvenida y marca la sugerencia', () {
    final g = GameState(Faction.ninja, Faction.shaolin);
    final tip = guideTip(g, 0, suggestion: const PlaceAction(PieceType.shinobi, Hex.origin))!;
    expect(tip.id, 'welcome');
    expect(tip.spotlight, {Hex.origin});
    expect(tip.title, isNot(contains('guide.')));
    expect(guideTip(g, 1), isNull, reason: 'no le toca');
  });

  test('con el Líder rival a un lado de caer, el consejo es rematar', () {
    final g = buildScene(
      you: Faction.shaolin,
      opp: Faction.ninja,
      pieces: const [
        (1, PieceType.shogun, Hex(0, 0)),
        (0, PieceType.monk, Hex(1, 0)),
        (0, PieceType.dragon, Hex(1, -1)),
        (0, PieceType.tiger, Hex(0, -1)),
        (0, PieceType.crane, Hex(-1, 0)),
        (1, PieceType.shinobi, Hex(-1, 1)),
      ],
    );
    final tip = guideTip(g, 0)!;
    expect(tip.id, 'finish');
    expect(tip.spotlight, {const Hex(0, 1)});
  });

  test('con el Líder propio en peligro, el consejo es defender', () {
    final g = buildScene(
      you: Faction.shaolin,
      opp: Faction.ninja,
      pieces: const [
        (0, PieceType.monk, Hex(0, 0)),
        (1, PieceType.shogun, Hex(3, -1)),
        (1, PieceType.shinobi, Hex(1, 0)),
        (1, PieceType.kitsune, Hex(1, -1)),
        (1, PieceType.tengu, Hex(2, -1)),
        (0, PieceType.dragon, Hex(0, -1)),
        (0, PieceType.tiger, Hex(-1, 0)),
      ],
    );
    expect(g.leaderMargin(0), 2);
    expect(guideTip(g, 0)!.id, 'defend');
    expect(g.leaderOpenings(0), {const Hex(-1, 1), const Hex(0, 1)});
  });

  test('los consejos de una sola vez no se repiten', () {
    final g = buildScene(
      you: Faction.shaolin,
      opp: Faction.ninja,
      pieces: const [(0, PieceType.monk, Hex(0, 0)), (1, PieceType.shogun, Hex(1, 0))],
      yourHand: const {PieceType.dragon: 1},
    );
    expect(guideTip(g, 0)!.id, 'move');
    expect(guideTip(g, 0, seen: onceTips)!.id, 'press');
  });

  test('estrellas: ganar, rápido y con el Líder a salvo', () {
    final start = GameState(Faction.shaolin, Faction.ninja);
    final end = start.copy()..winner = 0;
    expect(Stars.goals(start, [start, end], end), [true, true, true]);
    final slow = start.copy()
      ..winner = 0
      ..ply = Stars.parRounds * 2;
    expect(Stars.goals(start, [start, slow], slow), [true, false, true]);
    final lost = start.copy()..winner = 1;
    expect(Stars.count(Stars.goals(start, [start, lost], lost)), 0);
  });
}
