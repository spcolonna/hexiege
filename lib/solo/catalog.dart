import 'puzzles.dart';
import 'stage.dart';

export 'puzzles.dart';
export 'stage.dart';

/// Listas de contenido de un jugador, en orden de desbloqueo.
final List<List<Stage>> stageLists = [puzzles];

/// La etapa que sigue a [s] en su lista (null si es la última).
Stage? stageAfter(Stage s) {
  for (final list in stageLists) {
    final i = list.indexWhere((x) => x.id == s.id);
    if (i >= 0) return i + 1 < list.length ? list[i + 1] : null;
  }
  return null;
}

/// Una etapa está disponible si es la primera de su lista o si se superó la anterior.
bool isUnlocked(List<Stage> list, int index, bool Function(String id) cleared) =>
    index == 0 || cleared(list[index - 1].id);
