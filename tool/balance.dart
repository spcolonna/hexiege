// ignore_for_file: avoid_print
// Simulación de balance IA vs IA.
// Uso: dart run tool/balance.dart [partidas por orden=20] [nivel=easy|normal] [maxTurnos=120] [--sin-habilidades]
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/pieces.dart';

void main(List<String> allArgs) {
  final noAbilities = allArgs.contains('--sin-habilidades');
  final args = allArgs.where((a) => !a.startsWith('--')).toList();
  final games = args.isNotEmpty ? int.parse(args[0]) : 20;
  final level = args.length > 1 ? AiLevel.values.byName(args[1]) : AiLevel.easy;
  final maxPlies = args.length > 2 ? int.parse(args[2]) : 120;

  final wins = {for (final f in Faction.values) f: 0};
  var draws = 0, timeouts = 0, firstPlayerWins = 0, totalPlies = 0, decided = 0;
  final sw = Stopwatch()..start();

  for (final order in [
    [Faction.shaolin, Faction.ninja],
    [Faction.ninja, Faction.shaolin],
  ]) {
    for (var i = 0; i < games; i++) {
      final g = GameState(order[0], order[1]);
      final ais = [
        AiPlayer(level, seed: i * 2, useAbilities: !noAbilities),
        AiPlayer(level, seed: i * 2 + 1, useAbilities: !noAbilities),
      ];
      var ply = 0;
      for (; ply < maxPlies && !g.isOver; ply++) {
        for (final a in ais[g.current].chooseTurn(g)) {
          a.apply(g);
        }
        if (!g.isOver) g.endTurn();
      }
      if (g.winner != null) {
        wins[g.factions[g.winner!]] = wins[g.factions[g.winner!]]! + 1;
        if (g.winner == 0) firstPlayerWins++;
        totalPlies += ply;
        decided++;
      } else if (g.draw) {
        draws++;
      } else {
        timeouts++;
      }
    }
  }

  final total = games * 2;
  String pct(int n) => '${(100 * n / total).toStringAsFixed(1)}%';
  print('Nivel ${level.name}${noAbilities ? ' (sin habilidades)' : ''}, $total partidas (${sw.elapsed.inSeconds}s)');
  for (final f in Faction.values) {
    print('  ${f.displayName.padRight(16)} ${wins[f]} victorias (${pct(wins[f]!)})');
  }
  print('  Empates: $draws (${pct(draws)})  Sin terminar en $maxPlies turnos: $timeouts (${pct(timeouts)})');
  print('  Gana quien empieza: $firstPlayerWins/$decided');
  if (decided > 0) print('  Duración media de partidas decididas: ${(totalPlies / decided).toStringAsFixed(1)} turnos');
}
