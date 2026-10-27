import '../engine/ai.dart';
import '../engine/game_state.dart';
import 'stage.dart';

/// Estrellas de una batalla (campaña o desafío; los problemas no tienen):
/// ganar, ganar rápido y ganar con el Líder propio a salvo. Dan rejugabilidad
/// sin tocar la dificultad de la historia.
class Stars {
  /// Rondas jugadas como máximo para la estrella de rapidez, por defecto.
  static const parRounds = 26;

  /// Rondas para la estrella de rapidez en [s]: más margen contra rivales
  /// que defienden mejor (calibrado con tool/stars_sim.dart).
  static int parOf(Stage s) => switch (s.level) {
    AiLevel.novice || AiLevel.easy => parRounds,
    AiLevel.normal => 28,
    AiLevel.hard || AiLevel.master => 32,
  };

  /// Lados ocupados que puede llegar a tener tu Líder para la de defensa:
  /// nunca a menos de dos fichas de caer.
  static const safeSides = 4;

  static bool appliesTo(Stage s) => !s.isPuzzle;

  /// Qué objetivos se cumplieron, en orden: [ganó, rápido, a salvo].
  /// [states] son todos los estados de la partida, del primero al último.
  static List<bool> goals(GameState start, Iterable<GameState> states, GameState end, {int par = parRounds}) {
    final won = end.winner == 0;
    final fast = won && end.round - start.round + 1 <= par;
    final safe = won && states.every((g) => g.leaderPressure(0) <= safeSides);
    return [won, fast, safe];
  }

  static int count(List<bool> goals) => goals.where((g) => g).length;
}
