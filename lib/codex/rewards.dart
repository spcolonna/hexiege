import '../engine/pieces.dart';
import '../solo/campaign.dart';
import '../solo/stage.dart';
import '../ui/theme/settings.dart';
import 'avatars.dart';
import 'cosmetics.dart';

enum RewardKind { avatar, frame, stone, table }

/// Cosméticos que se ganan avanzando en la campaña. Los iniciales (el avatar de
/// cada facción, sin marco, la piedra clásica y la mesa del tema) vienen abiertos.
class Reward {
  final RewardKind kind;
  final String id;

  /// Facción de la piedra (las demás no dependen de la facción).
  final Faction? faction;

  /// Clave i18n de la condición ("Superá la batalla 8 de cualquier campaña").
  final String hintKey;
  final Map<String, Object> hintArgs;
  final bool Function(AppSettings s) earned;

  const Reward._(this.kind, this.id, this.faction, this.hintKey, this.hintArgs, this.earned);

  /// Clave única: se guarda entre los regalos anunciados.
  String get key => faction == null ? '${kind.name}:$id' : '${kind.name}:${faction!.name}:$id';

  String get nameKey => switch (kind) {
    RewardKind.avatar => Avatars.byId(id)!.nameKey,
    RewardKind.frame => Cosmetics.frame(id)!.nameKey,
    RewardKind.stone => Cosmetics.stone(faction!, id)!.nameKey,
    RewardKind.table => Cosmetics.table(id)!.nameKey,
  };

  String get kindKey => 'reward.kind.${kind.name}';

  bool get isEarned => earned(AppSettings.instance);

  /// Lo pone en uso: avatar, marco, piedra o mesa.
  void equip() {
    final s = AppSettings.instance;
    switch (kind) {
      case RewardKind.avatar:
        s.avatar = id;
      case RewardKind.frame:
        s.frame = id;
      case RewardKind.stone:
        s.setStone(faction!, id);
      case RewardKind.table:
        s.table = id;
    }
  }

  static final List<Reward> all = [
    // Campaña Shaolin: retratos y piedras del templo.
    _stage(RewardKind.table, 'temple_wood', shaolinCampaign, 1),
    _stage(RewardKind.avatar, 'staff', shaolinCampaign, 3),
    _stage(RewardKind.stone, 'sandstone', shaolinCampaign, 5, Faction.shaolin),
    _stage(RewardKind.avatar, 'drunken', shaolinCampaign, 9),
    _stage(RewardKind.avatar, 'monkey', shaolinCampaign, 15),
    _stage(RewardKind.stone, 'imperial', shaolinCampaign, 16, Faction.shaolin),
    _stage(RewardKind.avatar, 'abbess', shaolinCampaign, 20),
    // Campaña Ninja: lo mismo del lado de las sombras.
    _stage(RewardKind.table, 'black_lacquer', ninjaCampaign, 1),
    _stage(RewardKind.avatar, 'fan', ninjaCampaign, 3),
    _stage(RewardKind.stone, 'vermilion', ninjaCampaign, 5, Faction.ninja),
    _stage(RewardKind.avatar, 'kitsune', ninjaCampaign, 9),
    _stage(RewardKind.avatar, 'ronin', ninjaCampaign, 15),
    _stage(RewardKind.stone, 'iron', ninjaCampaign, 16, Faction.ninja),
    _stage(RewardKind.avatar, 'oni', ninjaCampaign, 20),
    // Marcos y mesas neutrales: la misma batalla de cualquiera de las dos.
    _either(RewardKind.frame, 'bronze', 8),
    _either(RewardKind.table, 'tatami', 12),
    _either(RewardKind.frame, 'jade', 18),
    _either(RewardKind.table, 'red_silk', 22),
    // El Sello.
    _stage(RewardKind.table, 'river_slate', finale, 1, null, 'reward.hint.finale'),
    _stage(RewardKind.frame, 'gold', finale, 2, null, 'reward.hint.finale'),
    _stage(RewardKind.frame, 'obsidian', finale, finale.length, null, 'reward.hint.finale'),
  ];

  static Reward _stage(RewardKind k, String id, List<Stage> list, int n, [Faction? f, String? key]) {
    final i = n - 1;
    final hint = key ?? (identical(list, shaolinCampaign) ? 'gift.hint.shaolin' : 'gift.hint.ninja');
    return Reward._(k, id, f, hint, {'n': n}, (s) => s.isCleared(list[i].id));
  }

  static Reward _either(RewardKind k, String id, int n) => Reward._(k, id, null, 'reward.hint.either', {
    'n': n,
  }, (s) => s.isCleared(shaolinCampaign[n - 1].id) || s.isCleared(ninjaCampaign[n - 1].id));

  static Reward? of(RewardKind k, String? id, [Faction? f]) =>
      all.where((r) => r.kind == k && r.id == id && r.faction == f).firstOrNull;

  /// Abierto: inicial o ya ganado. Lo que no figura entre los premios viene abierto.
  static bool isOpen(RewardKind k, String? id, [Faction? f]) => of(k, id, f)?.isEarned ?? true;

  /// Ganados desde el último aviso. Los marca como avisados.
  static List<Reward> takeNew() {
    final s = AppSettings.instance;
    final fresh = all.where((r) => r.isEarned && !s.isGiftAnnounced(r.key)).toList();
    s.announceGifts(fresh.map((r) => r.key));
    return fresh;
  }
}
