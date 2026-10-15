// ignore_for_file: avoid_print
// Enfrenta dos niveles de IA para medir fuerza relativa y tiempo por jugada.
// Uso: dart run tool/arena.dart <nivelA> <nivelB> [partidas=20] [maxTurnos=160]
// Alterna quién empieza y las facciones para no sesgar el resultado.
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/pieces.dart';

void main(List<String> args) {
  final a = AiLevel.values.byName(args[0]);
  final b = AiLevel.values.byName(args[1]);
  final games = args.length > 2 ? int.parse(args[2]) : 20;
  final maxPlies = args.length > 3 ? int.parse(args[3]) : 160;

  final wins = {a.name: 0, b.name: 0};
  final ms = {a.name: <int>[], b.name: <int>[]};
  var draws = 0, timeouts = 0;
  final sw = Stopwatch()..start();

  for (var i = 0; i < games; i++) {
    // i par: A empieza; i impar: B empieza. Facciones rotan cada 2 partidas.
    final aFirst = i.isEven;
    final factions = (i ~/ 2).isEven ? [Faction.shaolin, Faction.ninja] : [Faction.ninja, Faction.shaolin];
    final g = GameState(factions[0], factions[1]);
    final levels = aFirst ? [a, b] : [b, a];
    final ais = [AiPlayer(levels[0], seed: i * 7), AiPlayer(levels[1], seed: i * 7 + 3)];
    var ply = 0;
    for (; ply < maxPlies && !g.isOver; ply++) {
      final t = Stopwatch()..start();
      final turn = ais[g.current].chooseTurn(g);
      ms[levels[g.current].name]!.add(t.elapsedMilliseconds);
      for (final act in turn) {
        act.apply(g);
      }
      if (!g.isOver) g.endTurn();
    }
    final tag = '#${i + 1} ${levels[0].name}(${factions[0].name}) vs ${levels[1].name}(${factions[1].name})';
    if (g.winner != null) {
      final w = levels[g.winner!].name;
      wins[w] = wins[w]! + 1;
      print('$tag → gana $w en $ply turnos');
    } else if (g.draw) {
      draws++;
      print('$tag → empate');
    } else {
      timeouts++;
      print('$tag → sin terminar');
    }
  }

  String stats(List<int> l) {
    if (l.isEmpty) return '-';
    l.sort();
    final avg = l.reduce((x, y) => x + y) / l.length;
    return 'media ${avg.toStringAsFixed(0)}ms, p95 ${l[(l.length * 0.95).floor().clamp(0, l.length - 1)]}ms';
  }

  print('\n${a.name} vs ${b.name}: $games partidas (${sw.elapsed.inSeconds}s)');
  print('  ${a.name}: ${wins[a.name]} victorias  (${stats(ms[a.name]!)})');
  if (a != b) print('  ${b.name}: ${wins[b.name]} victorias  (${stats(ms[b.name]!)})');
  print('  Empates: $draws  Sin terminar: $timeouts');
}
