enum Faction { shaolin, ninja }

extension FactionInfo on Faction {
  String get displayName => switch (this) {
    Faction.shaolin => 'Templo Shaolin',
    Faction.ninja => 'Sombras Ninja',
  };
  String get abilityName => switch (this) {
    Faction.shaolin => 'Meditación de Jade',
    Faction.ninja => 'Kawarimi',
  };
  String get abilityDescription => switch (this) {
    Faction.shaolin => 'Reubicá una ficha enemiga perimetral (no Líder) o intercambiá dos fichas aliadas adyacentes.',
    Faction.ninja => 'Devolvé a la mano de su dueño una ficha perimetral (no Líder), propia o enemiga.',
  };
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

  String get displayName => switch (this) {
    PieceType.monk => 'Monje Superior',
    PieceType.dragon => 'Dragón Celestial',
    PieceType.wukong => 'Rey Mono',
    PieceType.tiger => 'Tigre de Mármol',
    PieceType.crane => 'Grulla de Viento',
    PieceType.serpent => 'Serpiente de Jade',
    PieceType.shogun => 'Gran Shogun',
    PieceType.shinobi => 'Shinobi',
    PieceType.kunoichi => 'Kunoichi',
    PieceType.tengu => 'Tengu',
    PieceType.kitsune => 'Kitsune',
    PieceType.shadow => 'Sombra Errante',
  };

  String get glyph => switch (this) {
    PieceType.monk => '僧',
    PieceType.dragon => '龍',
    PieceType.wukong => '猴',
    PieceType.tiger => '虎',
    PieceType.crane => '鶴',
    PieceType.serpent => '蛇',
    PieceType.shogun => '将',
    PieceType.shinobi => '忍',
    PieceType.kunoichi => '姫',
    PieceType.tengu => '天',
    PieceType.kitsune => '狐',
    PieceType.shadow => '影',
  };

  String get rulesText => switch (this) {
    PieceType.monk => 'Líder. Se desliza 1 casilla.',
    PieceType.dragon => 'Vuela en línea recta sobre fichas contiguas y aterriza en el primer hueco.',
    PieceType.wukong =>
      'Avanza 1 casilla y puede subirse encima de fichas (las bloquea). En el suelo, puede copiar el movimiento de una ficha adyacente.',
    PieceType.tiger => 'Embiste 1–3 casillas en línea recta. Si queda frente a una ficha enemiga, la empuja 1 casilla.',
    PieceType.crane => 'Salta en línea recta sobre 1 o 2 fichas.',
    PieceType.serpent => 'Se desliza 1 o 2 casillas. Las fichas enemigas adyacentes pierden sus efectos especiales.',
    PieceType.shogun => 'Líder. Se desliza 1 casilla. Una vez por partida, intercambia lugar con un Shinobi adyacente.',
    PieceType.shinobi => 'Se desliza hasta 4 casillas por el perímetro, incluso por huecos estrechos.',
    PieceType.kunoichi => 'Se desliza hasta 2 casillas y paraliza a una ficha enemiga adyacente por 1 turno.',
    PieceType.tengu => 'Se teletransporta a cualquier hueco que toque al menos 3 fichas.',
    PieceType.kitsune => 'Se desliza 1 o 2 casillas.',
    PieceType.shadow =>
      'Se desliza 1 casilla y puede dejar un Sello de Sombra adyacente: la ficha enemiga que caiga ahí queda paralizada.',
  };
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
