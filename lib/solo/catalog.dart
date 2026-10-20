import 'campaign.dart';
import 'challenges.dart';
import 'puzzles.dart';
import 'stage.dart';

export 'campaign.dart';
export 'challenges.dart';
export 'puzzles.dart';
export 'stage.dart';

/// Listas de contenido de un jugador, en orden de desbloqueo.
final List<List<Stage>> stageLists = [puzzles, challenges, shaolinCampaign, ninjaCampaign, finale];

/// La etapa que sigue a [s] en su lista (null si es la última).
Stage? stageAfter(Stage s) {
  for (final list in stageLists) {
    final i = list.indexWhere((x) => x.id == s.id);
    if (i >= 0) return i + 1 < list.length ? list[i + 1] : null;
  }
  return null;
}

/// Batallas de la historia que necesitan la compra: desde la 7 de cada
/// campaña (el Acto I es gratis) y todo El Sello.
bool isPaid(Stage s) {
  for (final c in campaigns) {
    final i = c.stages.indexWhere((x) => x.id == s.id);
    if (i >= 0) return c.isFinale || i >= kFreeStagesPerCampaign;
  }
  return false;
}

/// Una etapa está disponible si es la primera de su lista o si se superó la
/// anterior, y además se superaron las que pide (El Sello pide las dos campañas).
bool isUnlocked(List<Stage> list, int index, bool Function(String id) cleared) =>
    (index == 0 || cleared(list[index - 1].id)) && list[index].requires.every(cleared);
