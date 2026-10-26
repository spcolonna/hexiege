import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../solo/campaign.dart';
import '../ui/theme/settings.dart';

/// Logros del juego. El id de Game Center es `hexiege.<nombre>`; el de Play
/// Juegos lo inventa Play Console y va en [_androidIds].
enum Feat { initiation, firstWin, firstBoss, shaolinDone, ninjaDone, seal, streak7, streak30 }

/// Clasificaciones: mejor racha del desafío del día y victorias contra la IA.
enum Board { dailyBest, wins }

/// Game Center (iOS) y Play Juegos (Android). Todo es opcional: si el jugador
/// no inicia sesión, o el servicio no está configurado, no pasa nada.
///
/// Los logros y puntajes se derivan del avance guardado en [AppSettings], así
/// que quien ya jugaba antes de esta versión los recibe al iniciar sesión.
class Games extends ChangeNotifier {
  Games._();
  static final instance = Games._();

  /// Ids de Play Console (vacíos hasta crear el juego allá; sin id, no se envía).
  static const _androidIds = <Object, String>{};

  bool _signedIn = false;
  bool get signedIn => _signedIn;

  SharedPreferences? _prefs;
  Set<String> _reported = {};
  final Set<String> _failed = {};
  final Map<Board, int> _scores = {};

  static bool get _supported => Platform.isIOS || (Platform.isAndroid && kPlayGames);

  Future<void> init() async {
    if (!_supported) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _reported = (_prefs!.getStringList('gamesReported') ?? const []).toSet();
      await GameAuth.signIn();
      _signedIn = await GameAuth.isSignedIn;
    } catch (e) {
      debugPrint('Games: $e'); // sin sesión o sin servicio
    }
    if (!_signedIn) return;
    notifyListeners();
    AppSettings.instance.addListener(_sync);
    _sync();
  }

  static String _iosId(Enum e) => switch (e) {
    Board.dailyBest => 'hexiege.daily_best',
    Board.wins => 'hexiege.wins',
    _ => 'hexiege.${e.name}',
  };

  /// Logros ganados según el avance guardado.
  static Set<Feat> earned(AppSettings s) {
    bool any(Iterable<String> ids) => ids.any(s.isCleared);
    final bosses = [
      for (final c in campaigns)
        if (!c.isFinale)
          for (var i = 5; i < c.stages.length; i += 6) c.stages[i].id,
    ];
    return {
      if (s.tutorialDone) Feat.initiation,
      if (s.wins > 0 || any([for (final c in campaigns) ...c.stages.map((x) => x.id)])) Feat.firstWin,
      if (any(bosses)) Feat.firstBoss,
      if (s.isCleared(shaolinCampaign.last.id)) Feat.shaolinDone,
      if (s.isCleared(ninjaCampaign.last.id)) Feat.ninjaDone,
      if (s.isCleared(finale.last.id)) Feat.seal,
      if (s.dailyBest >= 7) Feat.streak7,
      if (s.dailyBest >= 30) Feat.streak30,
    };
  }

  /// Manda lo nuevo: logros todavía no reportados y puntajes que subieron.
  void _sync() {
    final s = AppSettings.instance;
    for (final f in earned(s)) {
      if (_reported.contains(f.name) || _failed.contains(f.name)) continue;
      final android = _androidIds[f];
      if (Platform.isAndroid && android == null) continue;
      // Se guarda solo si llegó; si falla (logro sin crear en la tienda), se
      // reintenta en la próxima sesión.
      _reported.add(f.name);
      Achievements.unlock(
        achievement: Achievement(iOSID: _iosId(f), androidID: android ?? ''),
      ).then(
        (_) {
          _prefs?.setStringList('gamesReported', _reported.toList());
        },
        onError: (Object e) {
          _reported.remove(f.name);
          _failed.add(f.name);
          debugPrint('Games: $e');
        },
      );
    }
    for (final (b, value) in [(Board.dailyBest, s.dailyBest), (Board.wins, s.wins)]) {
      if (value <= 0 || value <= (_scores[b] ?? 0)) continue;
      final android = _androidIds[b];
      if (Platform.isAndroid && android == null) continue;
      _scores[b] = value;
      Leaderboards.submitScore(
        score: Score(iOSLeaderboardID: _iosId(b), androidLeaderboardID: android, value: value),
      ).catchError(_ignore);
    }
  }

  static String? _ignore(Object e) {
    debugPrint('Games: $e');
    return null;
  }

  Future<void> showAchievements() async {
    try {
      await Achievements.showAchievements();
    } catch (e) {
      debugPrint('Games: $e');
    }
  }

  Future<void> showLeaderboards() async {
    try {
      await Leaderboards.showLeaderboards();
    } catch (e) {
      debugPrint('Games: $e');
    }
  }
}
