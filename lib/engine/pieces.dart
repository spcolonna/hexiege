import '../i18n/i18n.dart';

/// [oni] es la facción del final de la historia: no se elige ni aparece en el
/// códice; solo la controla la IA.
enum Faction { shaolin, ninja, oni }

/// Facciones que puede elegir un jugador.
const playableFactions = [Faction.shaolin, Faction.ninja];

extension FactionInfo on Faction {
  String get displayName => tr('faction.$name');
  String get abilityName => tr('ability.$name');
  String get abilityDescription => tr('ability.$name.desc');
}

enum PieceType {
  // Shaolin
  monk,
  dragon,
  wukong,
  tiger,
  crane,
  serpent,
  // Ninja
  shogun,
  shinobi,
  kunoichi,
  tengu,
  kitsune,
  shadow,
  // Oni (final de la historia)
  oni,
  gaki,
  oniEye,
}

/// Fichas de las facciones jugables (sin las del Oni).
final playablePieces = PieceType.values.where((t) => t.faction != Faction.oni).toList();

extension PieceTypeInfo on PieceType {
  Faction get faction => index <= PieceType.serpent.index
      ? Faction.shaolin
      : index <= PieceType.shadow.index
      ? Faction.ninja
      : Faction.oni;
  bool get isLeader => this == PieceType.monk || this == PieceType.shogun || this == PieceType.oni;

  String get displayName => tr('piece.$name');

  /// Nombre corto para espacios chicos (la mano).
  String get shortName => tr('piece.$name.short');

  String get glyph => switch (this) {
    PieceType.monk => '僧',
    PieceType.dragon => '龙',
    PieceType.wukong => '猴',
    PieceType.tiger => '虎',
    PieceType.crane => '鹤',
    PieceType.serpent => '蛇',
    PieceType.shogun => '将',
    PieceType.shinobi => '忍',
    PieceType.kunoichi => '姬',
    PieceType.tengu => '天',
    PieceType.kitsune => '狐',
    PieceType.shadow => '影',
    PieceType.oni => '鬼',
    PieceType.gaki => '饿',
    PieceType.oniEye => '眼',
  };

  String get rulesText => tr('piece.$name.rules');
}

/// Mano inicial: 11 fichas por facción.
const Map<Faction, Map<PieceType, int>> startingHands = {
  Faction.shaolin: {
    PieceType.monk: 1,
    PieceType.dragon: 2,
    PieceType.wukong: 1,
    PieceType.tiger: 2,
    PieceType.crane: 2,
    PieceType.serpent: 3,
  },
  Faction.ninja: {
    PieceType.shogun: 1,
    PieceType.shinobi: 3,
    PieceType.kunoichi: 2,
    PieceType.tengu: 2,
    PieceType.kitsune: 2,
    PieceType.shadow: 1,
  },
  // El Oni: sus fichas propias y fichas comunes corrompidas por la ceniza.
  Faction.oni: {
    PieceType.oni: 1,
    PieceType.gaki: 2,
    PieceType.oniEye: 1,
    PieceType.dragon: 1,
    PieceType.tiger: 1,
    PieceType.shinobi: 2,
    PieceType.kunoichi: 1,
    PieceType.tengu: 1,
  },
};

class Piece {
  final int id;
  final PieceType type;
  final int owner;
  const Piece(this.id, this.type, this.owner);

  @override
  String toString() => '${type.name}#$id(p$owner)';
}
