import 'dart:async';
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
  turn(1),
  heartbeat(1);

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

/// Loops de música (generados por `tool/gen_music.py`).
enum MusicTrack { menu, shaolin, ninja, oni }

/// Música de fondo: un solo loop a la vez, con fundido al cambiar. Suena
/// bajo, debajo de los efectos, y respeta la preferencia de música.
class MusicBoard {
  MusicBoard._();
  static final instance = MusicBoard._();

  static const volume = 0.32;
  AudioPlayer? _player;
  MusicTrack? _want, _playing;
  Timer? _fade;
  double _level = 0;
  bool _listening = false;
  bool _enabled = false;

  /// La app la habilita al arrancar (en los tests queda muda y sin timers).
  void enable() {
    _enabled = true;
    if (_want != null) play(_want!);
  }

  /// Pide [t]; si ya suena, no hace nada. Con la música apagada solo la recuerda.
  void play(MusicTrack t) {
    _want = t;
    if (!_enabled) return;
    if (!_listening) {
      _listening = true;
      AppSettings.instance.addListener(_sync);
    }
    _sync();
  }

  void _sync() {
    final on = AppSettings.instance.music && _want != null;
    if (!on) {
      if (_playing != null) _fadeTo(0, then: _stop);
      return;
    }
    if (_playing == _want) {
      if (_level < volume) _fadeTo(volume);
      return;
    }
    if (_playing == null) {
      _start(_want!);
    } else {
      _fadeTo(0, ms: 500, then: () => _start(_want!));
    }
  }

  Future<void> _start(MusicTrack t) async {
    try {
      final p = _player ??= AudioPlayer(playerId: 'music');
      _playing = t;
      _level = 0;
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(0);
      await p.play(AssetSource('music/${t.name}.m4a'));
      _fadeTo(volume, ms: 1600);
    } catch (e) {
      debugPrint('Música no disponible: $e');
    }
  }

  void _stop() {
    _playing = null;
    _player?.stop().ignore();
  }

  void _fadeTo(double target, {int ms = 700, VoidCallback? then}) {
    _fade?.cancel();
    final from = _level;
    final steps = max(1, ms ~/ 40);
    var i = 0;
    _fade = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      i++;
      _level = from + (target - from) * (i / steps);
      _player?.setVolume(_level).ignore();
      if (i >= steps) {
        timer.cancel();
        then?.call();
      }
    });
  }
}

/// Hápticos centralizados (respetan la preferencia del usuario).
class Haptics {
  static void light() => _run(HapticFeedback.lightImpact);
  static void medium() => _run(HapticFeedback.mediumImpact);
  static void heavy() => _run(HapticFeedback.heavyImpact);
  static void select() => _run(HapticFeedback.selectionClick);

  /// Dos golpes secos seguidos: el Líder propio cayó (o casi).
  static void double() {
    heavy();
    Future.delayed(const Duration(milliseconds: 140), heavy);
  }

  static void _run(Future<void> Function() f) {
    if (AppSettings.instance.haptics) f();
  }
}
