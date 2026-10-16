import '../i18n/i18n.dart';

enum Faction { shaolin, ninja }

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
}

extension PieceTypeInfo on PieceType {
  Faction get faction => index <= PieceType.serpent.index ? Faction.shaolin : Faction.ninja;
  bool get isLeader => this == PieceType.monk || this == PieceType.shogun;

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
};

class Piece {
  final int id;
  final PieceType type;
  final int owner;
  const Piece(this.id, this.type, this.owner);

  @override
  String toString() => '${type.name}#$id(p$owner)';
}
