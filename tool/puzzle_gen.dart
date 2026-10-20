// ignore_for_file: avoid_print
// Busca problemas "cerco en 2" en partidas IA vs IA: posiciones sin cerco en 1
// y con una única primera jugada ganadora (sin manos ni habilidades).
// Uso: dart run tool/puzzle_gen.dart [partidas=200] [maxFichas=14]
import 'dart:io';
import 'dart:isolate';

import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/solver.dart';
import 'package:hexiege/solo/stage.dart';

List<String> search(int from, int to, int maxPieces) {
  final found = <String>[];
  for (var i = from; i < to; i++) {
    final g = GameState(playableFactions[i % 2], playableFactions[1 - i % 2]);
    final ais = [AiPlayer(AiLevel.easy, seed: i * 2), AiPlayer(AiLevel.easy, seed: i * 2 + 1)];
    for (var ply = 0; ply < 120 && !g.isOver; ply++) {
      final turn = ais[g.current].chooseTurn(g);
      for (final a in turn) {
        a.apply(g);
      }
      if (turn.isEmpty) g.pass();
      if (g.isOver || g.ply < 8) continue;
      final me = g.current;
      final cells = g.board.occupied.toList();
      final count = cells.fold(0, (n, h) => n + g.board.height(h));
      if (count > maxPieces || g.leaderPressure(1 - me) < 3) continue;
      // Reconstrucción como escenario: el que mueve pasa a ser el jugador 0.
      final pieces = <Placed>[
        for (final h in cells)
          for (final p in g.board.stackAt(h)) (p.owner == me ? 0 : 1, p.type, h),
      ];
      final s = buildScene(you: g.factions[me], opp: g.factions[1 - me], pieces: pieces, round: g.round);
      if (forcedWin(s, 1) != null) continue;
      final wins = allForcedWins(s, 2);
      if (wins.length != 1) continue;
      final lit = pieces.map((p) => '(${p.$1}, _${_short[p.$2]}, Hex(${p.$3.q}, ${p.$3.r}))').join(', ');
      found.add(
        '// juego $i ply ${g.ply} ${g.factions[me].name} round ${g.round} piezas $count: ${wins.first}\n[$lit]',
      );
      break; // una por partida
    }
  }
  return found;
}

const _short = {
  PieceType.monk: 'm',
  PieceType.dragon: 'd',
  PieceType.wukong: 'w',
  PieceType.tiger: 't',
  PieceType.crane: 'c',
  PieceType.serpent: 's',
  PieceType.shogun: 'g',
  PieceType.shinobi: 'n',
  PieceType.kunoichi: 'k',
  PieceType.tengu: 'u',
  PieceType.kitsune: 'f',
  PieceType.shadow: 'h',
};

Future<void> main(List<String> args) async {
  final games = args.isNotEmpty ? int.parse(args[0]) : 200;
  final maxPieces = args.length > 1 ? int.parse(args[1]) : 14;
  final workers = Platform.numberOfProcessors;
  final parts = await Future.wait([
    for (var w = 0; w < workers; w++)
      Isolate.run(() => search(games * w ~/ workers, games * (w + 1) ~/ workers, maxPieces)),
  ]);
  for (final p in parts.expand((x) => x)) {
    print(p);
  }
}
