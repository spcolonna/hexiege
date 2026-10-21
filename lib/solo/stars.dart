import '../engine/game_state.dart';
import 'stage.dart';

/// Estrellas de una batalla (campaña o desafío; los problemas no tienen):
/// ganar, ganar rápido y ganar con el Líder propio a salvo. Dan rejugabilidad
/// sin tocar la dificultad de la historia.
class Stars {
  /// Rondas jugadas como máximo para la estrella de rapidez.
  static const parRounds = 22;

  /// Lados ocupados que puede llegar a tener tu Líder para la de defensa.
  static const safeSides = 3;

  static bool appliesTo(Stage s) => !s.isPuzzle;

  /// Qué objetivos se cumplieron, en orden: [ganó, rápido, a salvo].
  /// [states] son todos los estados de la partida, del primero al último.
  static List<bool> goals(GameState start, Iterable<GameState> states, GameState end) {
    final won = end.winner == 0;
    final fast = won && end.round - start.round + 1 <= parRounds;
    final safe = won && states.every((g) => g.leaderPressure(0) <= safeSides);
    return [won, fast, safe];
  }

  static int count(List<bool> goals) => goals.where((g) => g).length;
}
