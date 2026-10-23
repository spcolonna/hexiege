import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../ui/theme/settings.dart';
import 'rivals.dart';

/// Partida casual a medias (local o contra un rival), guardada para retomarla
/// si se sale de la pantalla o el sistema cierra la app.
class SavedGame {
  final GameState state;
  final int? aiPlayer;
  final AiLevel aiLevel;
  final bool faceToFace;
  final Rival? rival;

  const SavedGame(this.state, {this.aiPlayer, this.aiLevel = AiLevel.normal, this.faceToFace = false, this.rival});

  /// La guardada en las preferencias, o null si no hay (o no se puede leer).
  static SavedGame? load() {
    final raw = AppSettings.instance.savedGame;
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, Object?>;
      final rival = j['rival'] as String?;
      final s = SavedGame(
        GameState.fromJson(j['state']! as Map<String, Object?>),
        aiPlayer: j['aiPlayer'] as int?,
        aiLevel: AiLevel.values.byName(j['aiLevel']! as String),
        faceToFace: j['faceToFace'] as bool? ?? false,
        rival: rival == null ? null : Rival.byId(rival),
      );
      return s.state.isOver ? null : s;
    } catch (e) {
      debugPrint('Partida guardada ilegible: $e');
      clear();
      return null;
    }
  }

  void save() => AppSettings.instance.savedGame = jsonEncode({
    'state': state.toJson(),
    'aiPlayer': aiPlayer,
    'aiLevel': aiLevel.name,
    'faceToFace': faceToFace,
    'rival': rival?.id,
  });

  static void clear() => AppSettings.instance.savedGame = null;
}
