// ignore_for_file: avoid_print
// Audita los finales: toda victoria tiene que ser un cerco real sobre el tablero.
// (Al empezar el Asedio un Líder ya a 5 lados cae con la siguiente acción: no es anomalía.)
// Uso: dart run tool/win_audit.dart [partidas=60] [nivel=easy] [id...]   (por defecto, Acto I de ambas campañas)
import 'dart:isolate';

import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/solo/catalog.dart';

/// Problemas de [g] recién jugada: victoria sin cerco real.
List<String> check(GameState g) {
  final out = <String>[];
  for (var p = 0; p < 2; p++) {
    for (final h in g.board.locateLeaders(p)) {
      final n = g.board.occupiedNeighbors(h);
      final caught = g.leaderCapturedOn(g.board, p, h);
      if (g.winner == 1 - p && !g.draw && !caught && !g.board.locateLeaders(p).any((x) => x != h)) {
        out.add('gana ${1 - p} con el Líder $p en $h a $n/${g.captureThreshold}');
      }
    }
  }
  return out;
}

String run(String id, AiLevel player, int games) {
  final s = stageLists.expand((l) => l).firstWhere((x) => x.id == id);
  final bad = <String>[];
  var wins = 0;
  for (var i = 0; i < games; i++) {
    final g = s.build();
    final start = g.copy();
    final ais = [AiPlayer(player, seed: i * 11), AiPlayer(s.level, seed: i * 11 + 5)];
    for (var ply = 0; ply < 200 && s.verdict(start, g) == null; ply++) {
      final turn = ais[g.current].chooseTurn(g);
      for (final a in turn) {
        a.apply(g);
        for (final e in check(g)) {
          bad.add('#$i ply $ply ${a.runtimeType}: $e');
        }
        if (g.isOver) break;
      }
      if (turn.isEmpty) g.pass();
    }
    if (s.verdict(start, g) == true) {
      wins++;
      if (g.winner != 0) bad.add('#$i verdict ganada con winner=${g.winner}');
    }
  }
  return '$id: $wins/$games ganadas, ${bad.length} anomalías${bad.isEmpty ? '' : '\n  ${bad.take(8).join('\n  ')}'}';
}

Future<void> main(List<String> args) async {
  final games = args.isNotEmpty ? int.parse(args[0]) : 60;
  final player = AiLevel.values.byName(args.length > 1 ? args[1] : 'easy');
  final ids = args.length > 2 ? args.sublist(2) : [for (var i = 1; i <= 6; i++) ...['s$i', 'n$i']];
  final res = await Future.wait([for (final id in ids) Isolate.run(() => run(id, player, games))]);
  res.forEach(print);
}
