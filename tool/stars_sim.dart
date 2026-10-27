// ignore_for_file: avoid_print
// Mide las estrellas de cada batalla: un jugador IA contra cada etapa de campaña.
// Uso: dart run tool/stars_sim.dart <nivelJugador> <partidas> [id...]   (sin ids: todas)
import 'dart:isolate';

import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/solo/campaign.dart';
import 'package:hexiege/solo/stars.dart';

String run(String id, AiLevel player, int games) {
  final s = campaigns.expand((c) => c.stages).firstWhere((x) => x.id == id);
  var won = 0, fast = 0, safe = 0, three = 0, rounds = 0, peak = 0;
  for (var i = 0; i < games; i++) {
    final g = s.build();
    final start = g.copy();
    final states = <GameState>[start];
    final ais = [AiPlayer(player, seed: i * 7), AiPlayer(s.level, seed: i * 7 + 3)];
    for (var ply = 0; ply < 200 && s.verdict(start, g) == null; ply++) {
      final turn = ais[g.current].chooseTurn(g);
      for (final a in turn) {
        a.apply(g);
      }
      if (turn.isEmpty) g.pass();
      states.add(g.copy());
    }
    final goals = Stars.goals(start, states, g, par: Stars.parOf(s));
    if (goals[0]) {
      won++;
      rounds += g.round - start.round + 1;
      peak += states.map((x) => x.leaderPressure(0)).reduce((a, b) => a > b ? a : b);
    }
    if (goals[1]) fast++;
    if (goals[2]) safe++;
    if (Stars.count(goals) == 3) three++;
  }
  String pct(int n) => '${(100 * n / games).round()}%'.padLeft(4);
  final avgR = won == 0 ? '-' : (rounds / won).toStringAsFixed(1);
  final avgP = won == 0 ? '-' : (peak / won).toStringAsFixed(1);
  return '${id.padRight(4)} ${s.level.name.padRight(7)} gana ${pct(won)} rápido ${pct(fast)} '
      'a salvo ${pct(safe)} 3★ ${pct(three)}  rondas $avgR  presión máx $avgP';
}

Future<void> main(List<String> args) async {
  final player = AiLevel.values.byName(args[0]);
  final games = int.parse(args[1]);
  final ids = args.length > 2 ? args.skip(2).toList() : [for (final c in campaigns) ...c.stages.map((s) => s.id)];
  final res = await Future.wait([for (final id in ids) Isolate.run(() => run(id, player, games))]);
  res.forEach(print);
}
