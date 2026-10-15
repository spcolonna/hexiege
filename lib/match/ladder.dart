import '../engine/ai.dart';

enum MatchResult { win, loss, draw }

/// Rango visible según los puntos. Los cortes coinciden con los niveles de IA
/// que el emparejamiento asigna en cada franja.
enum Rank {
  novice('Novicio', 0),
  disciple('Discípulo', 900),
  warrior('Guerrero', 1050),
  veteran('Veterano', 1200),
  legend('Leyenda', 1350);

  final String displayName;
  final int minRating;
  const Rank(this.displayName, this.minRating);

  static Rank of(int rating) => values.lastWhere((r) => rating >= r.minRating);

  /// Nivel de IA "natural" de la franja.
  AiLevel get level => AiLevel.values[index];
}

/// Historial competitivo del jugador. Inmutable: [apply] devuelve uno nuevo.
class LadderRecord {
  static const startRating = 1000;
  static const minRating = 600;

  final int rating;
  final int wins;
  final int losses;
  final int draws;

  /// Racha actual: positiva = victorias seguidas, negativa = derrotas seguidas.
  final int streak;
  final int peak;

  const LadderRecord({
    this.rating = startRating,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.streak = 0,
    this.peak = startRating,
  });

  int get games => wins + losses + draws;
  Rank get rank => Rank.of(rating);

  /// Puntos que suma o resta un resultado, dada la racha previa. Ganar en
  /// racha suma un extra; perder resta menos que lo que suma ganar, para que
  /// el progreso se sienta.
  static int delta(MatchResult r, int streakBefore) => switch (r) {
    MatchResult.win => 25 + (streakBefore >= 2 ? (5 * (streakBefore - 1)).clamp(0, 15) : 0),
    MatchResult.loss => -20,
    MatchResult.draw => 0,
  };

  LadderRecord apply(MatchResult r) {
    final d = delta(r, streak);
    final next = (rating + d).clamp(minRating, 9999);
    return LadderRecord(
      rating: next,
      wins: wins + (r == MatchResult.win ? 1 : 0),
      losses: losses + (r == MatchResult.loss ? 1 : 0),
      draws: draws + (r == MatchResult.draw ? 1 : 0),
      streak: switch (r) {
        MatchResult.win => streak > 0 ? streak + 1 : 1,
        MatchResult.loss => streak < 0 ? streak - 1 : -1,
        MatchResult.draw => 0,
      },
      peak: next > peak ? next : peak,
    );
  }

  /// Nivel de IA para la próxima partida: el de la franja de puntos, corrido
  /// un escalón por rachas (3+ victorias seguidas → más difícil; 3+ derrotas
  /// seguidas → más fácil, para cortar la mala racha).
  AiLevel get targetLevel {
    var i = rank.index;
    if (streak >= 3) i++;
    if (streak <= -3) i--;
    if (streak <= -5) i--;
    return AiLevel.values[i.clamp(0, AiLevel.values.length - 1)];
  }

  Map<String, int> toJson() => {
    'rating': rating,
    'wins': wins,
    'losses': losses,
    'draws': draws,
    'streak': streak,
    'peak': peak,
  };

  factory LadderRecord.fromJson(Map<String, dynamic> j) => LadderRecord(
    rating: j['rating'] as int? ?? startRating,
    wins: j['wins'] as int? ?? 0,
    losses: j['losses'] as int? ?? 0,
    draws: j['draws'] as int? ?? 0,
    streak: j['streak'] as int? ?? 0,
    peak: j['peak'] as int? ?? startRating,
  );
}
