import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/i18n/es.dart';
import 'package:hexiege/i18n/i18n.dart';

final _placeholder = RegExp(r'\{(\w+)\}');

void main() {
  tearDown(() => setLanguage('es'));

  test('todos los idiomas tienen las mismas claves y marcadores', () {
    final keys = es.keys.toSet();
    for (final MapEntry(key: lang, value: cat) in catalogs.entries) {
      expect(cat.keys.toSet(), keys, reason: lang);
      for (final k in keys) {
        Set<String> marks(String s) => _placeholder.allMatches(s).map((m) => m[1]!).toSet();
        expect(marks(cat[k]!), marks(es[k]!), reason: '$lang.$k');
        expect(cat[k]!.trim(), isNotEmpty, reason: '$lang.$k');
      }
    }
  });

  test('toda clave literal usada en lib/ existe', () {
    final used = RegExp(r"""\btrN?\(\s*'([a-zA-Z0-9_.]+)'""");
    final missing = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.contains('/i18n/')) continue;
      for (final m in used.allMatches(f.readAsStringSync())) {
        final k = m[1]!;
        final isPlural = f.readAsStringSync().contains("trN('$k'");
        final ok = isPlural ? es.containsKey('$k.one') && es.containsKey('$k.other') : es.containsKey(k);
        if (!ok) missing.add('${f.path}: $k');
      }
    }
    expect(missing, isEmpty);
  });

  test('nombres de fichas y facciones en cada idioma', () {
    for (final lang in supportedLanguages) {
      setLanguage(lang);
      for (final t in PieceType.values) {
        expect(t.displayName, isNot(startsWith('piece.')), reason: '$lang ${t.name}');
        expect(t.shortName, isNot(startsWith('piece.')));
        expect(t.rulesText, isNot(startsWith('piece.')));
      }
      for (final f in Faction.values) {
        expect(f.abilityName, isNot(startsWith('ability.')));
      }
    }
    setLanguage('en');
    expect(PieceType.dragon.displayName, 'Celestial Dragon');
    setLanguage('zh');
    expect(PieceType.dragon.shortName, '龙');
  });

  test('plural e idioma no soportado', () {
    expect(trN('stage.closedIn', 1), 'Cerco cerrado en 1 turno.');
    expect(trN('stage.closedIn', 2), 'Cerco cerrado en 2 turnos.');
    setLanguage('fr');
    expect(currentLanguage, 'en');
  });

  test('idioma del sistema: el primero soportado, si no inglés', () {
    expect(systemLanguage(['ja']), 'ja');
    expect(systemLanguage(['fr', 'es', 'en']), 'es');
    expect(systemLanguage(['fr', 'de']), 'en');
    expect(systemLanguage([]), 'en');
  });
}
