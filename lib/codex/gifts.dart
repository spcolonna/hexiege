import '../engine/pieces.dart';
import '../solo/campaign.dart';
import '../solo/challenges.dart';
import '../solo/puzzles.dart';
import '../solo/stage.dart';
import '../ui/theme/settings.dart';

/// Las fichas de la galería se ganan como regalo al alcanzar hitos. Todas se
/// pueden jugar desde el principio: el regalo es poder verlas de cerca.
class Gift {
  final PieceType type;

  /// Clave i18n de la condición ("Superá la batalla 4 de la campaña Shaolin").
  final String hintKey;
  final Map<String, Object> hintArgs;
  final bool Function(AppSettings s) earned;

  const Gift._(this.type, this.hintKey, this.hintArgs, this.earned);

  static final List<Gift> all = [
    Gift._(PieceType.monk, 'gift.hint.tutorial', const {}, (s) => s.tutorialDone),
    Gift._(PieceType.shogun, 'gift.hint.firstWin', const {}, (s) => s.wins > 0 || s.ladder.wins > 0),
    _stage(PieceType.crane, shaolinCampaign, 2, 'gift.hint.shaolin'),
    _stage(PieceType.serpent, shaolinCampaign, 4, 'gift.hint.shaolin'),
    _stage(PieceType.tiger, shaolinCampaign, 6, 'gift.hint.shaolin'),
    _stage(PieceType.dragon, shaolinCampaign, shaolinCampaign.length, 'gift.hint.shaolin'),
    _stage(PieceType.kitsune, ninjaCampaign, 2, 'gift.hint.ninja'),
    _stage(PieceType.kunoichi, ninjaCampaign, 4, 'gift.hint.ninja'),
    _stage(PieceType.shadow, ninjaCampaign, 5, 'gift.hint.ninja'),
    _stage(PieceType.tengu, ninjaCampaign, ninjaCampaign.length, 'gift.hint.ninja'),
    _count(PieceType.wukong, puzzles, 6, 'gift.hint.puzzles'),
    _count(PieceType.shinobi, challenges, 3, 'gift.hint.challenges'),
  ];

  static Gift of(PieceType t) => all.firstWhere((g) => g.type == t);

  /// Ganada al superar la batalla número [n] (desde 1) de [list].
  static Gift _stage(PieceType t, List<Stage> list, int n, String key) {
    final i = (n.clamp(1, list.length)) - 1;
    return Gift._(t, key, {'n': i + 1}, (s) => s.isCleared(list[i].id));
  }

  /// Ganada al superar [n] etapas cualesquiera de [list].
  static Gift _count(PieceType t, List<Stage> list, int n, String key) =>
      Gift._(t, key, {'n': n}, (s) => list.where((x) => s.isCleared(x.id)).length >= n);

  bool get isEarned => earned(AppSettings.instance);
  bool get isOpened => AppSettings.instance.isGiftOpened(type.name);

  /// Ganadas y todavía sin desenvolver.
  static List<Gift> get pending => all.where((g) => g.isEarned && !g.isOpened).toList();

  static int get collected => all.where((g) => g.isOpened).length;

  /// Ganadas desde el último aviso. Las marca como avisadas.
  static List<Gift> takeNew() {
    final s = AppSettings.instance;
    final fresh = all.where((g) => g.isEarned && !s.isGiftAnnounced(g.type.name)).toList();
    s.announceGifts(fresh.map((g) => g.type.name));
    return fresh;
  }
}
