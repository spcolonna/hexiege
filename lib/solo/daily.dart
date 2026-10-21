import '../engine/ai.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import 'daily_pool.dart';
import 'stage.dart';

/// Desafío del día: un "cerco en 2" igual para todos ese día. Sale de un
/// banco de posiciones generadas con tool/puzzle_gen.dart, girado 60° cada
/// vez que el banco da la vuelta, así tarda mucho en repetirse.
class Daily {
  static const id = 'daily';
  static const turns = 2;

  /// Número de día local desde el 1/1/2026 (cambia a medianoche).
  static int dayOf(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2026)).inDays;

  static int get today => dayOf(DateTime.now());

  static Hex _rotate(Hex h, int times) {
    var x = h;
    for (var i = 0; i < times; i++) {
      x = Hex(-x.r, x.q + x.r);
    }
    return x;
  }

  /// El desafío de [day].
  static Stage forDay(int day) {
    final n = dailyPool.length;
    final (you, round, pieces) = dailyPool[day % n];
    final turn = (day ~/ n) % 6;
    final opp = you == Faction.shaolin ? Faction.ninja : Faction.shaolin;
    final placed = [for (final (o, t, h) in pieces) (o, t, _rotate(h, turn))];
    return Stage(
      id: id,
      kind: StageKind.puzzle,
      you: you,
      opp: opp,
      level: AiLevel.hard,
      puzzleTurns: turns,
      build: () => buildScene(you: you, opp: opp, pieces: placed, round: round),
    );
  }
}
