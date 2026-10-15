import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../theme/settings.dart';

/// Sonidos del juego (generados por `tool/gen_sfx.py`). Los golpes tienen 3
/// variantes que se alternan al azar para que no suenen repetidos.
enum Sfx {
  place(3),
  land(3),
  stack(3),
  lift(3),
  select(1),
  tick(1),
  ability(1),
  frost(1),
  stamp(1),
  victory(1),
  defeat(1),
  emote(1),
  turn(1);

  final int variants;
  const Sfx(this.variants);
}

class SoundBoard {
  SoundBoard._();
  static final instance = SoundBoard._();

  final _pools = <String, AudioPool>{};
  final _rng = Random();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      // Mezclar con la música del usuario. En iOS la categoría "ambient" además
      // respeta el modo silencio (la combinación genérica no está permitida).
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build().copy(iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient)),
      );
      for (final s in Sfx.values) {
        for (var i = 0; i < s.variants; i++) {
          final name = s.variants > 1 ? '${s.name}_$i' : s.name;
          _pools[name] = await AudioPool.createFromAsset(
            path: 'sfx/$name.wav',
            maxPlayers: 3,
            playerMode: PlayerMode.lowLatency,
          );
        }
      }
      _ready = true;
    } catch (e) {
      debugPrint('Audio no disponible: $e');
    }
  }

  void play(Sfx s, {double volume = 1}) {
    if (!_ready || !AppSettings.instance.sound) return;
    final name = s.variants > 1 ? '${s.name}_${_rng.nextInt(s.variants)}' : s.name;
    final v = (volume * (0.9 + _rng.nextDouble() * 0.1)).clamp(0.0, 1.0);
    _pools[name]?.start(volume: v).ignore();
  }
}

/// Hápticos centralizados (respetan la preferencia del usuario).
class Haptics {
  static void light() => _run(HapticFeedback.lightImpact);
  static void medium() => _run(HapticFeedback.mediumImpact);
  static void heavy() => _run(HapticFeedback.heavyImpact);
  static void select() => _run(HapticFeedback.selectionClick);

  static void _run(Future<void> Function() f) {
    if (AppSettings.instance.haptics) f();
  }
}
