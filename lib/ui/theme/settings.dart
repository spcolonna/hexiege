import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias del usuario (persistidas). Un único notifier global que la app
/// escucha: cambiar el tema acá lo cambia en vivo en cualquier pantalla.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();

  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _sound = true;
  bool _haptics = true;
  String _nickname = 'Vos';
  bool _onboarded = false;
  bool _tutorialDone = false;

  ThemeMode get themeMode => _themeMode;
  bool get sound => _sound;
  bool get haptics => _haptics;
  String get nickname => _nickname;

  /// Ya vio la bienvenida del primer arranque.
  bool get onboarded => _onboarded;
  bool get tutorialDone => _tutorialDone;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return; // sin persistencia (tests): valores por defecto
    }
    final p = _prefs!;
    final mode = p.getInt('themeMode');
    _themeMode = mode != null && mode >= 0 && mode < ThemeMode.values.length
        ? ThemeMode.values[mode]
        : ThemeMode.system;
    _sound = p.getBool('sound') ?? true;
    _haptics = p.getBool('haptics') ?? true;
    _nickname = p.getString('nickname') ?? 'Vos';
    _onboarded = p.getBool('onboarded') ?? false;
    _tutorialDone = p.getBool('tutorialDone') ?? false;
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

  set sound(bool v) {
    _sound = v;
    _prefs?.setBool('sound', v);
    notifyListeners();
  }

  set haptics(bool v) {
    _haptics = v;
    _prefs?.setBool('haptics', v);
    notifyListeners();
  }

  set nickname(String v) {
    final clean = v.trim();
    _nickname = clean.isEmpty ? 'Vos' : (clean.length > 16 ? clean.substring(0, 16) : clean);
    _prefs?.setString('nickname', _nickname);
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
}
