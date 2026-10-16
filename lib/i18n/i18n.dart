import 'en.dart';
import 'es.dart';
import 'zh.dart';

/// Idiomas del juego: español (rioplatense), inglés y chino simplificado.
/// Dart puro: lo usan el motor, el contenido y las herramientas de `tool/`.
const supportedLanguages = ['es', 'en', 'zh'];

const Map<String, Map<String, String>> catalogs = {'es': es, 'en': en, 'zh': zh};

String _language = 'es';

/// Idioma activo (uno de [supportedLanguages]).
String get currentLanguage => _language;

void setLanguage(String code) => _language = supportedLanguages.contains(code) ? code : 'en';

/// El idioma del sistema si está soportado; si no, inglés.
String systemLanguage(String code) => supportedLanguages.contains(code) ? code : 'en';

/// Texto de [key] en el idioma activo, reemplazando `{nombre}` por [args].
/// Si falta en el idioma activo cae al español y, si tampoco está, a la clave.
String tr(String key, [Map<String, Object> args = const {}]) {
  var s = catalogs[_language]![key] ?? es[key] ?? key;
  for (final e in args.entries) {
    s = s.replaceAll('{${e.key}}', '${e.value}');
  }
  return s;
}

/// Singular/plural: usa `key.one` si [n] es 1 y `key.other` si no (con `{n}`).
String trN(String key, int n, [Map<String, Object> args = const {}]) =>
    tr(n == 1 ? '$key.one' : '$key.other', {'n': n, ...args});
