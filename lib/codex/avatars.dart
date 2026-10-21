import '../engine/pieces.dart';

/// Retrato pintado en tinta que identifica al jugador. Se guarda por [id]; un
/// avatar que no está en el catálogo se muestra como texto (un carácter).
class AvatarDef {
  final String id;
  final Faction faction;
  const AvatarDef(this.id, this.faction);

  String get asset => 'assets/avatars/avatar_$id.webp';
  String get nameKey => 'avatar.$id';
}

class Avatars {
  static const all = [
    AvatarDef('novice', Faction.shaolin),
    AvatarDef('abbess', Faction.shaolin),
    AvatarDef('drunken', Faction.shaolin),
    AvatarDef('staff', Faction.shaolin),
    AvatarDef('monkey', Faction.shaolin),
    AvatarDef('jonin', Faction.ninja),
    AvatarDef('fan', Faction.ninja),
    AvatarDef('ronin', Faction.ninja),
    AvatarDef('oni', Faction.ninja),
    AvatarDef('kitsune', Faction.ninja),
  ];

  /// Retratos de personajes de la historia: no se eligen como avatar.
  static const story = [
    AvatarDef('abbot', Faction.shaolin),
    AvatarDef('shogun', Faction.ninja),
    AvatarDef('ashoni', Faction.oni),
  ];

  static AvatarDef? byId(String id) {
    for (final a in [...all, ...story]) {
      if (a.id == id) return a;
    }
    return null;
  }

  static List<AvatarDef> of(Faction f) => all.where((a) => a.faction == f).toList();

  /// El que usa cada facción mientras el jugador no elija otro.
  static String defaultFor(Faction f) => f == Faction.shaolin ? 'novice' : 'jonin';
}
