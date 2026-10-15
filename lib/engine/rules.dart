import 'pieces.dart';

/// Parámetros de balance. [Rules.standard] es el juego oficial; las variantes
/// sirven para simular ajustes (tool/balance.dart) o armar desafíos.
class Rules {
  /// Turnos propios de espera tras usar la habilidad de facción.
  final int abilityCooldown;

  /// Usos de la habilidad por partida (null = ilimitados).
  final int? abilityCharges;

  /// Mano inicial de cada facción.
  final Map<Faction, Map<PieceType, int>> hands;

  /// Pasos máximos del Shinobi por el perímetro (null = ilimitados).
  final int? shinobiRange;

  /// La Grulla salta sobre 1 o 2 fichas (false = exactamente 2).
  final bool craneShortJump;

  /// Fichas que debe tocar el hueco de destino del Tengu.
  final int tenguMinTouch;

  /// Ronda (un turno de cada jugador) en la que empieza el Asedio: desde ahí
  /// alcanza con ocupar 5 lados del Líder para ganar. null = sin Asedio.
  final int? siegeRound;

  /// Al terminar esta ronda, la partida es empate. null = sin límite.
  final int? roundLimit;

  const Rules({
    this.abilityCooldown = 3,
    this.abilityCharges = 3,
    this.hands = startingHands,
    this.shinobiRange = 4,
    this.craneShortJump = true,
    this.tenguMinTouch = 3,
    this.siegeRound = 35,
    this.roundLimit = 50,
  });

  /// Reglas oficiales, ajustadas con tool/balance.dart (ver README).
  static const standard = Rules();

  /// Las reglas del prototipo, sin límites: habilidades infinitas, Shinobi y
  /// Tengu sin restricción, Grulla de salto fijo y sin Asedio.
  static const classic = Rules(
    abilityCharges: null,
    shinobiRange: null,
    craneShortJump: false,
    tenguMinTouch: 2,
    siegeRound: null,
    roundLimit: null,
  );

  Rules copyWith({
    int? abilityCooldown,
    int? Function()? abilityCharges,
    Map<Faction, Map<PieceType, int>>? hands,
    int? Function()? shinobiRange,
    bool? craneShortJump,
    int? tenguMinTouch,
    int? Function()? siegeRound,
    int? Function()? roundLimit,
  }) => Rules(
    abilityCooldown: abilityCooldown ?? this.abilityCooldown,
    abilityCharges: abilityCharges != null ? abilityCharges() : this.abilityCharges,
    hands: hands ?? this.hands,
    shinobiRange: shinobiRange != null ? shinobiRange() : this.shinobiRange,
    craneShortJump: craneShortJump ?? this.craneShortJump,
    tenguMinTouch: tenguMinTouch ?? this.tenguMinTouch,
    siegeRound: siegeRound != null ? siegeRound() : this.siegeRound,
    roundLimit: roundLimit != null ? roundLimit() : this.roundLimit,
  );

  @override
  String toString() =>
      'cd=$abilityCooldown cargas=${abilityCharges ?? '∞'} shinobi=${shinobiRange ?? '∞'} '
      'grulla=${craneShortJump ? '1-2' : '2'} tengu=$tenguMinTouch asedio=${siegeRound ?? '-'} rondas=${roundLimit ?? '∞'} '
      'manos=${hands.map((f, h) => MapEntry(f.name, h.map((t, n) => MapEntry(t.name, n))))}';
}
