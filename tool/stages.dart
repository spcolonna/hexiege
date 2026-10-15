// ignore_for_file: avoid_print
// Calibra desafíos y batallas: un jugador IA contra cada etapa.
// Uso: dart run tool/stages.dart <nivelJugador> <partidas> <id>...   (ej: normal 12 c01 s6)
import 'dart:isolate';

import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/solo/catalog.dart';

/// Simula un jugador IA contra una etapa: ¿se puede ganar?
String run(String id, AiLevel player, int games) {
  final s = stageLists.expand((l) => l).firstWhere((x) => x.id == id);
  var win = 0, lose = 0, other = 0;
  for (var i = 0; i < games; i++) {
    final g = s.build();
    final start = g.copy();
    final ais = [AiPlayer(player, seed: i * 7), AiPlayer(s.level, seed: i * 7 + 3)];
    for (var ply = 0; ply < 200 && s.verdict(start, g) == null; ply++) {
      for (final a in ais[g.current].chooseTurn(g)) {
        a.apply(g);
      }
      if (!g.isOver) g.endTurn();
    }
    final v = s.verdict(start, g);
    if (v == true) {
      win++;
    } else if (g.winner == 1) {
      lose++;
    } else {
      other++;
    }
  }
  return '$id ${s.title} (${s.level.name}) con jugador ${player.name}: gana $win, pierde $lose, otro $other / $games';
}

Future<void> main(List<String> args) async {
  final player = AiLevel.values.byName(args[0]);
  final games = int.parse(args[1]);
  final ids = args.skip(2).toList();
  final res = await Future.wait([for (final id in ids) Isolate.run(() => run(id, player, games))]);
  res.forEach(print);
}
