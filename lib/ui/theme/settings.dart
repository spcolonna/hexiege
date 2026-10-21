import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../codex/avatars.dart';
import '../../codex/cosmetics.dart';
import '../../engine/pieces.dart';
import '../../i18n/i18n.dart';
import '../../match/ladder.dart';
import 'ui_style.dart';

/// Cómo se dibujan las fichas: ilustraciones o caracteres chinos. Los caracteres
/// solo se ofrecen en chino; en otros idiomas siempre van las ilustraciones.
enum PieceStyle { images, glyphs }

/// Preferencias del usuario (persistidas). Un único notifier global que la app
/// escucha: cambiar el tema acá lo cambia en vivo en cualquier pantalla.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();

  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String? _language; // null = idioma del sistema
  PieceStyle _pieceStyle = PieceStyle.images;
  Faction _faction = Faction.shaolin;
  bool _sound = true;
  bool _music = true;
  bool _haptics = true;
  bool _storyUnlocked = false;
  bool _faceToFace = false;
  String? _nickname; // null = el nombre por defecto del idioma
  String? _avatar; // null = el de la facción con que se juega
  String? _frame; // null = sin marco
  String? _table; // null = la mesa del tema
  final Map<Faction, String> _stones = {};
  bool _onboarded = false;
  bool _tutorialDone = false;
  LadderRecord _ladder = const LadderRecord();
  Set<String> _cleared = {};
  Map<String, int> _stars = {};
  Set<String> _seenScenes = {};
  Set<String> _seenPieces = {};
  Set<String> _giftsAnnounced = {};
  Set<String> _giftsOpened = {};
  int _wins = 0;
  int _dailyLast = -1;
  int _dailyStreak = 0;
  int _dailyBest = 0;
  UiStyle _uiStyle = StyleUnlocks.base;
  Set<String> _ownedStyles = {};

  ThemeMode get themeMode => _themeMode;

  /// Idioma elegido a mano (null = el del sistema).
  String? get language => _language;
  Locale get locale => Locale(currentLanguage);
  PieceStyle get pieceStyle => _pieceStyle;

  /// Facción elegida en el menú: define también la mesa (el tema) de la app.
  Faction get faction => _faction;

  /// Las fichas muestran el carácter en lugar de la ilustración.
  bool get useGlyphs => currentLanguage == 'zh' && _pieceStyle == PieceStyle.glyphs;
  bool get sound => _sound;
  bool get music => _music;
  bool get haptics => _haptics;

  /// Partida local cara a cara: el dispositivo en la mesa, la parte de arriba
  /// gira hacia el Jugador 2.
  bool get faceToFace => _faceToFace;
  String get nickname => _nickname ?? tr('common.defaultNick');

  /// Avatar elegido a mano (null = el inicial de cada facción).
  String? get avatar => _avatar;

  /// Avatar con que se muestra al jugador cuando juega con [f].
  String avatarFor(Faction f) => _avatar ?? Avatars.defaultFor(f);

  /// Marco del avatar (null = sin marco).
  String? get frame => _frame;

  set frame(String? id) {
    _frame = Cosmetics.frame(id)?.id;
    _setOrRemove('frame', _frame);
  }

  /// Tapete debajo del tablero (null = la mesa del tema de la facción).
  String? get table => _table;

  set table(String? id) {
    _table = Cosmetics.table(id)?.id;
    _setOrRemove('table', _table);
  }

  /// Piedra elegida para las fichas de [f].
  String stoneFor(Faction f) => _stones[f] ?? Cosmetics.classic;

  void setStone(Faction f, String id) {
    if (Cosmetics.stone(f, id) == null) return;
    _stones[f] = id;
    _setOrRemove('stone_${f.name}', id == Cosmetics.classic ? null : id);
  }

  void _setOrRemove(String key, String? value) {
    if (value == null) {
      _prefs?.remove(key);
    } else {
      _prefs?.setString(key, value);
    }
    notifyListeners();
  }

  /// Ya vio la bienvenida del primer arranque.
  bool get onboarded => _onboarded;
  bool get tutorialDone => _tutorialDone;

  /// Puntos, récord y racha en partidas por puntos.
  LadderRecord get ladder => _ladder;

  /// Estilo de la interfaz fuera del tablero (cosmético).
  UiStyle get uiStyle => _uiStyle;

  /// Si [s] se puede elegir (hoy todos; a futuro, los comprados).
  bool isStyleUnlocked(UiStyle s) => StyleUnlocks.isUnlocked(s, _ownedStyles);

  set uiStyle(UiStyle s) {
    if (!isStyleUnlocked(s) || s == _uiStyle) return;
    _uiStyle = s;
    _prefs?.setString('uiStyle', s.name);
    notifyListeners();
  }

  /// Registra un estilo comprado.
  void unlockStyle(UiStyle s) {
    if (!_ownedStyles.add(s.name)) return;
    _prefs?.setStringList('ownedStyles', _ownedStyles.toList());
    notifyListeners();
  }

  /// Problemas, desafíos y batallas de campaña superados (por id).
  bool isCleared(String stageId) => _cleared.contains(stageId);

  void markCleared(String stageId) {
    if (!_cleared.add(stageId)) return;
    _prefs?.setStringList('cleared', _cleared.toList());
    notifyListeners();
  }

  /// Mejores estrellas (0 a 3) de una batalla.
  int starsOf(String stageId) => _stars[stageId] ?? 0;

  /// Guarda [n] estrellas si mejoran las que había. Devuelve true si mejoró.
  bool recordStars(String stageId, int n) {
    if (n <= starsOf(stageId)) return false;
    _stars[stageId] = n;
    _prefs?.setStringList('stars', [for (final e in _stars.entries) '${e.key}:${e.value}']);
    notifyListeners();
    return true;
  }

  /// Borra el avance de la historia: las batallas [stageIds] vuelven a estar
  /// sin superar, las viñetas sin ver y el desbloqueo sin comprar.
  void resetStory(Iterable<String> stageIds) {
    _cleared.removeAll(stageIds);
    _stars.removeWhere((id, _) => stageIds.contains(id));
    _prefs?.setStringList('stars', [for (final e in _stars.entries) '${e.key}:${e.value}']);
    _seenScenes.clear();
    _storyUnlocked = false;
    _prefs?.setStringList('cleared', _cleared.toList());
    _prefs?.setStringList('seenScenes', const []);
    _prefs?.setBool('storyUnlocked', false);
    notifyListeners();
  }

  /// Viñetas de la historia ya vistas (por id de escena, p. ej. "s1.pre").
  bool isSceneSeen(String sceneId) => _seenScenes.contains(sceneId);

  void markSceneSeen(String sceneId) {
    if (!_seenScenes.add(sceneId)) return;
    _prefs?.setStringList('seenScenes', _seenScenes.toList());
    notifyListeners();
  }

  /// Fichas que el jugador ya abrió en el códice (por nombre de tipo).
  bool isPieceSeen(String type) => _seenPieces.contains(type);

  void markPieceSeen(String type) {
    if (!_seenPieces.add(type)) return;
    _prefs?.setStringList('seenPieces', _seenPieces.toList());
    notifyListeners();
  }

  /// Desafío del día: último día resuelto, racha y mejor racha.
  bool dailySolved(int day) => _dailyLast == day;

  /// Racha vigente: se corta si ayer no se resolvió (hoy todavía se puede).
  int dailyStreakOn(int day) => _dailyLast >= day - 1 ? _dailyStreak : 0;
  int get dailyBest => _dailyBest;

  void solveDaily(int day) {
    if (_dailyLast == day) return;
    _dailyStreak = _dailyLast == day - 1 ? _dailyStreak + 1 : 1;
    _dailyLast = day;
    if (_dailyStreak > _dailyBest) _dailyBest = _dailyStreak;
    _prefs?.setInt('dailyLast', _dailyLast);
    _prefs?.setInt('dailyStreak', _dailyStreak);
    _prefs?.setInt('dailyBest', _dailyBest);
    notifyListeners();
  }

  /// Victorias fuera de las partidas por puntos (contra la IA).
  int get wins => _wins;

  void recordWin() {
    _wins++;
    _prefs?.setInt('wins', _wins);
    notifyListeners();
  }

  /// Fichas regalo que ya se le avisaron al jugador.
  bool isGiftAnnounced(String type) => _giftsAnnounced.contains(type);

  void announceGifts(Iterable<String> types) {
    if (!types.any(_giftsAnnounced.add)) return;
    _prefs?.setStringList('giftsAnnounced', _giftsAnnounced.toList());
    notifyListeners();
  }

  /// Fichas regalo que ya desenvolvió en la galería.
  bool isGiftOpened(String type) => _giftsOpened.contains(type);

  void openGift(String type) {
    if (!_giftsOpened.add(type)) return;
    _prefs?.setStringList('giftsOpened', _giftsOpened.toList());
    notifyListeners();
  }

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return; // sin persistencia (tests): valores por defecto
    }
    final p = _prefs!;
    _language = p.getString('language');
    setLanguage(_language ?? systemLanguage(PlatformDispatcher.instance.locale.languageCode));
    _pieceStyle = PieceStyle.values.asNameMap()[p.getString('pieceStyle')] ?? PieceStyle.images;
    _faction = Faction.values.asNameMap()[p.getString('faction')] ?? Faction.shaolin;
    final mode = p.getInt('themeMode');
    _themeMode = mode != null && mode >= 0 && mode < ThemeMode.values.length
        ? ThemeMode.values[mode]
        : ThemeMode.system;
    _sound = p.getBool('sound') ?? true;
    _music = p.getBool('music') ?? true;
    _haptics = p.getBool('haptics') ?? true;
    _storyUnlocked = p.getBool('storyUnlocked') ?? false;
    _faceToFace = p.getBool('faceToFace') ?? false;
    _nickname = p.getString('nickname');
    final avatar = p.getString('avatar');
    _avatar = avatar != null && Avatars.byId(avatar) != null ? avatar : null;
    _frame = Cosmetics.frame(p.getString('frame'))?.id;
    _table = Cosmetics.table(p.getString('table'))?.id;
    for (final f in playableFactions) {
      final id = Cosmetics.stone(f, p.getString('stone_${f.name}'))?.id;
      if (id != null) _stones[f] = id;
    }
    _onboarded = p.getBool('onboarded') ?? false;
    _tutorialDone = p.getBool('tutorialDone') ?? false;
    _cleared = (p.getStringList('cleared') ?? const []).toSet();
    _stars = {
      for (final e in p.getStringList('stars') ?? const <String>[])
        if (e.split(':') case [final id, final n] when int.tryParse(n) != null) id: int.parse(n),
    };
    _seenScenes = (p.getStringList('seenScenes') ?? const []).toSet();
    _seenPieces = (p.getStringList('seenPieces') ?? const []).toSet();
    _giftsAnnounced = (p.getStringList('giftsAnnounced') ?? const []).toSet();
    _giftsOpened = (p.getStringList('giftsOpened') ?? const []).toSet();
    _wins = p.getInt('wins') ?? 0;
    _dailyLast = p.getInt('dailyLast') ?? -1;
    _dailyStreak = p.getInt('dailyStreak') ?? 0;
    _dailyBest = p.getInt('dailyBest') ?? 0;
    _ownedStyles = (p.getStringList('ownedStyles') ?? const []).toSet();
    final style = UiStyle.values.asNameMap()[p.getString('uiStyle')];
    _uiStyle = style != null && isStyleUnlocked(style) ? style : StyleUnlocks.base;
    final ladder = p.getString('ladder');
    if (ladder != null) {
      try {
        _ladder = LadderRecord.fromJson(jsonDecode(ladder) as Map<String, dynamic>);
      } catch (_) {
        // Dato corrupto: se arranca de cero.
      }
    }
  }

  set themeMode(ThemeMode m) {
    _themeMode = m;
    _prefs?.setInt('themeMode', m.index);
    notifyListeners();
  }

  /// Alterna claro/oscuro partiendo del brillo que se ve ahora (resuelve "sistema").
  void toggleBrightness(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    themeMode = dark ? ThemeMode.light : ThemeMode.dark;
  }

  set language(String? code) {
    _language = code;
    setLanguage(code ?? systemLanguage(PlatformDispatcher.instance.locale.languageCode));
    if (code == null) {
      _prefs?.remove('language');
    } else {
      _prefs?.setString('language', code);
    }
    notifyListeners();
  }

  set pieceStyle(PieceStyle v) {
    _pieceStyle = v;
    _prefs?.setString('pieceStyle', v.name);
    notifyListeners();
  }

  set faction(Faction f) {
    _faction = f;
    _prefs?.setString('faction', f.name);
    notifyListeners();
  }

  set music(bool v) {
    _music = v;
    _prefs?.setBool('music', v);
    notifyListeners();
  }

  set sound(bool v) {
    _sound = v;
    _prefs?.setBool('sound', v);
    notifyListeners();
  }

  set faceToFace(bool v) {
    _faceToFace = v;
    _prefs?.setBool('faceToFace', v);
    notifyListeners();
  }

  /// Compró la historia completa (USD 1,99): batallas 7–24 y El Sello.
  bool get storyUnlocked => _storyUnlocked;

  set storyUnlocked(bool v) {
    if (_storyUnlocked == v) return;
    _storyUnlocked = v;
    _prefs?.setBool('storyUnlocked', v);
    notifyListeners();
  }

  set haptics(bool v) {
    _haptics = v;
    _prefs?.setBool('haptics', v);
    notifyListeners();
  }

  set avatar(String? id) {
    _avatar = id;
    if (id == null) {
      _prefs?.remove('avatar');
    } else {
      _prefs?.setString('avatar', id);
    }
    notifyListeners();
  }

  set nickname(String v) {
    final clean = v.trim();
    _nickname = clean.isEmpty ? null : (clean.length > 16 ? clean.substring(0, 16) : clean);
    if (_nickname == null) {
      _prefs?.remove('nickname');
    } else {
      _prefs?.setString('nickname', _nickname!);
    }
    notifyListeners();
  }

  set onboarded(bool v) {
    _onboarded = v;
    _prefs?.setBool('onboarded', v);
    notifyListeners();
  }

  set tutorialDone(bool v) {
    _tutorialDone = v;
    _prefs?.setBool('tutorialDone', v);
    notifyListeners();
  }

  set ladder(LadderRecord v) {
    _ladder = v;
    _prefs?.setString('ladder', jsonEncode(v.toJson()));
    notifyListeners();
  }
}
