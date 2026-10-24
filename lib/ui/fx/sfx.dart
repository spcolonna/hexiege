import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  final _pools = <String, List<_Voice>>{};
  final _rng = Random();
  bool _ready = false;

  /// En segundo plano no se dispara nada (timers pendientes, la IA que termina).
  bool _hidden = false;
  AppLifecycleListener? _lifecycle;

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
          // Reproductores propios y fijos. El AudioPool del paquete encola cada
          // golpe detrás de un candado: si iOS se traba unos segundos, los
          // golpes se acumulan y suenan todos juntos después.
          _pools[name] = [
            for (var v = 0; v < voices; v++) await _Voice.load('sfx/$name.wav'),
          ];
        }
      }
      _lifecycle ??= AppLifecycleListener(
        onHide: () => _hidden = true,
        onShow: () => _hidden = false,
      );
      _ready = true;
    } catch (e) {
      debugPrint('Audio no disponible: $e');
    }
  }

  void play(Sfx s, {double volume = 1}) {
    if (!_ready || _hidden || !AppSettings.instance.sound) return;
    final name = s.variants > 1 ? '${s.name}_${_rng.nextInt(s.variants)}' : s.name;
    final v = (volume * (0.9 + _rng.nextDouble() * 0.1)).clamp(0.0, 1.0);
    final pool = _pools[name];
    if (pool == null) return;
    // Uno libre (sin una llamada nativa pendiente); si no hay, el golpe se pierde.
    final voice = pool.where((x) => !x.busy).fold<_Voice?>(null, (a, x) => a == null || x.used < a.used ? x : a);
    voice?.play(v).ignore();
  }

  /// Reproductores por sonido: hasta 3 golpes iguales superpuestos.
  static const voices = 3;
}

/// Un reproductor precargado. Un golpe que llega tarde (el teléfono se trabó)
/// se descarta: un efecto fuera de tiempo es peor que ninguno.
class _Voice {
  final AudioPlayer player;
  _Voice(this.player);

  static const late = Duration(milliseconds: 250);

  bool busy = false;
  int used = 0;

  static Future<_Voice> load(String path) async {
    final p = AudioPlayer();
    await p.setReleaseMode(ReleaseMode.stop);
    await p.setSource(AssetSource(path));
    return _Voice(p);
  }

  Future<void> play(double volume) async {
    busy = true;
    used = DateTime.now().microsecondsSinceEpoch;
    final asked = Stopwatch()..start();
    try {
      await player.stop();
      if (asked.elapsed > late) return;
      await player.setVolume(volume);
      if (asked.elapsed > late) return;
      await player.resume();
      // Si la llamada quedó colgada y volvió tarde, se corta.
      if (asked.elapsed > late) await player.stop();
    } catch (_) {
      // Sin audio no se juega peor.
    } finally {
      busy = false;
    }
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
  AppLifecycleListener? _lifecycle;

  /// La app la habilita al arrancar (en los tests queda muda y sin timers).
  /// En segundo plano se pausa y al volver sigue donde estaba.
  void enable() {
    _enabled = true;
    _lifecycle ??= AppLifecycleListener(
      onHide: () => _player?.pause().ignore(),
      onShow: () {
        if (_playing != null) _player?.resume().ignore();
      },
    );
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
