// Balance del final de la historia: IA del jugador contra el Oni en F1–F3.
// Uso: dart run tool/oni_balance.dart [partidas] [nivelJugador] [nivelOni]
// ignore_for_file: avoid_print
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/stage.dart';

const _sh = Faction.shaolin, _nj = Faction.ninja, _oni = Faction.oni;

/// Mano mixta del Sello final: media mano de cada facción y los dos Líderes.
const sealHand = {
  PieceType.monk: 1,
  PieceType.dragon: 1,
  PieceType.wukong: 1,
  PieceType.tiger: 1,
  PieceType.crane: 1,
  PieceType.serpent: 1,
  PieceType.shogun: 1,
  PieceType.shinobi: 2,
  PieceType.kunoichi: 1,
  PieceType.tengu: 1,
  PieceType.kitsune: 1,
};

final sealRules = Rules.standard.copyWith(
  mixedSeal: true,
  dualAbility: {0},
  handsByOwner: () => [sealHand, startingHands[_oni]!],
);

GameState f1() => GameState(_sh, _oni);
GameState f2() => GameState(_nj, _oni);
GameState f3() => buildScene(
  you: _sh,
  opp: _oni,
  rules: sealRules,
  round: 2,
  yourAbility: true,
  oppAbility: true,
  pieces: const [(0, PieceType.monk, Hex(-1, 0)), (0, PieceType.shogun, Hex(-1, 1)), (1, PieceType.oni, Hex(0, 0))],
  yourHand: {...sealHand, PieceType.monk: 0, PieceType.shogun: 0},
  oppHand: {...startingHands[_oni]!, PieceType.oni: 0},
);

void main(List<String> args) {
  final n = args.isNotEmpty ? int.parse(args[0]) : 20;
  final me = args.length > 1 ? AiLevel.values.byName(args[1]) : AiLevel.normal;
  final oni = args.length > 2 ? AiLevel.values.byName(args[2]) : AiLevel.normal;
  print('Jugador ${me.name} vs Oni ${oni.name}, $n partidas por etapa');
  for (final (name, build) in [('F1 Shaolin', f1), ('F2 Ninja', f2), ('F3 Sello', f3)]) {
    var wins = 0, losses = 0, draws = 0, plies = 0;
    for (var i = 0; i < n; i++) {
      final g = build();
      final ais = [AiPlayer(me, seed: i), AiPlayer(oni, seed: 1000 + i)];
      while (!g.isOver) {
        g.play(ais[g.current].chooseTurn(g));
      }
      plies += g.ply;
      if (g.winner == 0) {
        wins++;
      } else if (g.winner == 1) {
        losses++;
      } else {
        draws++;
      }
    }
    print(
      '$name: jugador ${(100 * wins / n).round()}% · Oni ${(100 * losses / n).round()}% · '
      'empates $draws · ${plies ~/ n ~/ 2} rondas promedio',
    );
  }
}
