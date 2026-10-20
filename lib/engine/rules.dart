import 'pieces.dart';

/// Huecos junto al Líder rival a los que puede teletransportarse el Tengu.
enum TenguNearLeader {
  allowed,

  /// Sí, salvo que con eso complete el cerco (el teletransporte no da el golpe final).
  notClosing,
  never,
}

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

  /// Si el Tengu puede teletransportarse a un hueco junto al Líder rival.
  final TenguNearLeader tenguNearLeader;

  /// El Shinobi puede cruzar compuertas para entrar a un hueco junto al Líder rival.
  final bool shinobiGateNextToLeader;

  /// Interruptores de efectos de unidad (para medir su peso con tool/balance.dart).
  final bool shogunSwap;
  final bool kunoichiParalysis;
  final bool shadowSeal;

  /// Manos por jugador que reemplazan a las de [hands] (null = por facción).
  /// Permiten manos mixtas, como en el final de la historia.
  final List<Map<PieceType, int>>? handsByOwner;

  /// El Líder Oni solo cae si entre las fichas que lo rodean hay al menos una
  /// Shaolin y una Ninja del rival.
  final bool mixedSeal;

  /// Jugadores que pueden usar las dos habilidades (Jade y Kawarimi), con
  /// recarga y usos compartidos.
  final Set<int> dualAbility;

  const Rules({
    this.abilityCooldown = 3,
    this.abilityCharges = 3,
    this.hands = startingHands,
    this.shinobiRange = 4,
    this.craneShortJump = true,
    this.tenguMinTouch = 3,
    this.siegeRound = 35,
    this.roundLimit = 50,
    this.tenguNearLeader = TenguNearLeader.notClosing,
    this.shinobiGateNextToLeader = true,
    this.shogunSwap = true,
    this.kunoichiParalysis = true,
    this.shadowSeal = true,
    this.handsByOwner,
    this.mixedSeal = false,
    this.dualAbility = const {},
  });

  /// Reglas oficiales, ajustadas con tool/balance.dart (ver README).
  static const standard = Rules();

  /// Las reglas del prototipo, sin límites: habilidades infinitas, Shinobi y
  /// Tengu sin restricción (el Tengu puede cerrar el cerco), Grulla de salto fijo y sin Asedio.
  static const classic = Rules(
    abilityCharges: null,
    shinobiRange: null,
    craneShortJump: false,
    tenguMinTouch: 2,
    tenguNearLeader: TenguNearLeader.allowed,
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
    TenguNearLeader? tenguNearLeader,
    bool? shinobiGateNextToLeader,
    bool? shogunSwap,
    bool? kunoichiParalysis,
    bool? shadowSeal,
    List<Map<PieceType, int>>? Function()? handsByOwner,
    bool? mixedSeal,
    Set<int>? dualAbility,
  }) => Rules(
    abilityCooldown: abilityCooldown ?? this.abilityCooldown,
    abilityCharges: abilityCharges != null ? abilityCharges() : this.abilityCharges,
    hands: hands ?? this.hands,
    shinobiRange: shinobiRange != null ? shinobiRange() : this.shinobiRange,
    craneShortJump: craneShortJump ?? this.craneShortJump,
    tenguMinTouch: tenguMinTouch ?? this.tenguMinTouch,
    siegeRound: siegeRound != null ? siegeRound() : this.siegeRound,
    roundLimit: roundLimit != null ? roundLimit() : this.roundLimit,
    tenguNearLeader: tenguNearLeader ?? this.tenguNearLeader,
    shinobiGateNextToLeader: shinobiGateNextToLeader ?? this.shinobiGateNextToLeader,
    shogunSwap: shogunSwap ?? this.shogunSwap,
    kunoichiParalysis: kunoichiParalysis ?? this.kunoichiParalysis,
    shadowSeal: shadowSeal ?? this.shadowSeal,
    handsByOwner: handsByOwner != null ? handsByOwner() : this.handsByOwner,
    mixedSeal: mixedSeal ?? this.mixedSeal,
    dualAbility: dualAbility ?? this.dualAbility,
  );

  @override
  String toString() =>
      'cd=$abilityCooldown cargas=${abilityCharges ?? '∞'} shinobi=${shinobiRange ?? '∞'} '
      'grulla=${craneShortJump ? '1-2' : '2'} tengu=$tenguMinTouch asedio=${siegeRound ?? '-'} rondas=${roundLimit ?? '∞'} '
      'tengu-lider=${tenguNearLeader.name} ${shinobiGateNextToLeader ? '' : 'shinobi-no-lider '}'
      '${mixedSeal ? 'sello-mixto ' : ''}${shogunSwap ? '' : 'sin-intercambio '}${kunoichiParalysis ? '' : 'sin-paralisis '}${shadowSeal ? '' : 'sin-sello '}'
      'manos=${hands.map((f, h) => MapEntry(f.name, h.map((t, n) => MapEntry(t.name, n))))}';
}
