import '../codex/avatars.dart';
import '../engine/ai.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';

/// Rival de partida casual: un personaje de la historia con su nivel de IA,
/// al estilo "jugá contra…". Juega siempre con la escuela de su retrato.
class Rival {
  final String id;
  final String avatar;
  final AiLevel level;

  /// Puntos aproximados, solo para dar una idea de su fuerza.
  final int rating;

  const Rival(this.id, this.avatar, this.level, this.rating);

  Faction get faction => Avatars.byId(avatar)!.faction;
  String get name => tr('rival.$id');
  String get quote => tr('rival.$id.quote');

  /// Del más fácil al más fuerte.
  static const all = [
    Rival('ren', 'novice', AiLevel.novice, 400),
    Rival('fox', 'kitsune', AiLevel.easy, 800),
    Rival('tao', 'drunken', AiLevel.normal, 1100),
    Rival('jubei', 'ronin', AiLevel.hard, 1400),
    Rival('mei', 'abbess', AiLevel.master, 1700),
    Rival('kuro', 'jonin', AiLevel.master, 1800),
  ];

  static Rival byId(String id) => all.firstWhere((r) => r.id == id, orElse: () => all.first);
}
