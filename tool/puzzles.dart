// ignore_for_file: avoid_print
// Verifica los problemas: dibuja cada posición y lista las jugadas ganadoras.
// Uso: dart run tool/puzzles.dart [id]
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/board.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/puzzles.dart';
import 'package:hexiege/solo/solver.dart';

const _letters = {
  PieceType.monk: 'M',
  PieceType.dragon: 'D',
  PieceType.wukong: 'W',
  PieceType.tiger: 'T',
  PieceType.crane: 'C',
  PieceType.serpent: 'S',
  PieceType.shogun: 'G',
  PieceType.shinobi: 'N',
  PieceType.kunoichi: 'K',
  PieceType.tengu: 'U',
  PieceType.kitsune: 'F',
  PieceType.shadow: 'H',
};

/// Mayúscula = jugador 0 (vos), minúscula = rival. Fila r desplazada medio hex por fila.
String draw(Board b) {
  final cells = b.occupied.toList();
  if (cells.isEmpty) return '(vacío)';
  final rs = cells.map((h) => h.r);
  final minR = rs.reduce((a, b) => a < b ? a : b) - 1, maxR = rs.reduce((a, b) => a > b ? a : b) + 1;
  final xs = cells.map((h) => 2 * h.q + h.r);
  final minX = xs.reduce((a, b) => a < b ? a : b) - 2, maxX = xs.reduce((a, b) => a > b ? a : b) + 2;
  final out = StringBuffer();
  for (var r = minR; r <= maxR; r++) {
    final line = StringBuffer('${r.toString().padLeft(3)} ');
    for (var x = minX; x <= maxX; x++) {
      if ((x - r).isOdd) {
        line.write(' ');
        continue;
      }
      final h = Hex((x - r) ~/ 2, r);
      final p = b.top(h);
      line.write(p == null ? '·' : (p.owner == 0 ? _letters[p.type]! : _letters[p.type]!.toLowerCase()));
    }
    out.writeln(line);
  }
  return out.toString();
}

void main(List<String> args) {
  for (final s in puzzles) {
    if (args.isNotEmpty && !args.contains(s.id)) continue;
    final g = s.build();
    final sw = Stopwatch()..start();
    final n = s.puzzleTurns!;
    final wins = allForcedWins(g, n);
    final shorter = n > 1 ? allForcedWins(g, n - 1).length : 0;
    print(
      '== ${s.id} · ${s.title} (en $n) — ${wins.length} soluciones, $shorter más cortas, ${sw.elapsedMilliseconds} ms',
    );
    print(draw(g.board));
    for (final w in wins.take(8)) {
      print('   ${w.map(describe).join(' + ')}  [${w.whereType<MoveAction>().map((m) => g.board.top(m.from)!.type.name).join()}]');
    }
  }
}

String describe(AiAction a) => switch (a) {
  PlaceAction(:final type, :final at) => 'coloca ${type.name} $at',
  MoveAction(:final from, :final to, :final paralyze, :final seal) =>
    'mueve $from→$to${paralyze != null ? ' paraliza $paralyze' : ''}${seal != null ? ' sella $seal' : ''}',
  SwapAction(:final from, :final to) => 'intercambio $from↔$to',
  KawarimiAction(:final at) => 'kawarimi $at',
  JadeRelocateAction(:final from, :final to) => 'jade $from→$to',
  JadeSwapAction(:final a, :final b) => 'jade swap $a↔$b',
};
