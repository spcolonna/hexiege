import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/story/script.dart';
import 'package:hexiege/story/story_screen.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';
import 'package:hexiege/ui/theme/ui_style.dart';

void main() {
  group('Guion', () {
    test('cada batalla de la historia tiene viñeta antes y después', () {
      for (final c in campaigns) {
        for (final s in c.stages) {
          expect(Scene.of(s.id, post: false), isNotNull, reason: '${s.id}.pre');
          expect(Scene.of(s.id, post: true), isNotNull, reason: '${s.id}.post');
        }
      }
      expect(Scene.ids, hasLength(campaigns.fold<int>(0, (n, c) => n + c.stages.length * 2)));
    });

    test('todos los mensajes tienen texto y los diálogos, quién habla', () {
      for (final id in Scene.ids) {
        final sc = Scene.of(id.split('.').first, post: id.endsWith('post'))!;
        for (var i = 0; i < sc.beats.length; i++) {
          expect(sc.text(i), isNot('story.$id.$i'));
          final b = sc.beats[i];
          expect(b.who == null, b.kind == BeatKind.moment, reason: '$id.$i');
        }
      }
      for (final w in Who.values) {
        expect(w.displayName, isNot('who.${w.name}'));
      }
    });

    test('cada momento tiene escenario y toda escena sabe dónde transcurre', () {
      for (final id in Scene.ids) {
        final sc = Scene.of(id.split('.').first, post: id.endsWith('post'))!;
        for (final m in sc.moments) {
          expect(Scene.momentPlace(id, m), isNotNull, reason: '$id.$m');
        }
        final sp = sc.splash;
        if (sp != null) expect(sp.$1, lessThan(sc.beats.length), reason: id);
      }
      // Sin momento propio, sigue donde terminó la anterior.
      expect(Scene.of('s20', post: false)!.placeAt(0), Place.pagoda);
      expect(Scene.of('f3', post: true)!.placeAt(0), Place.ashCourtyard);
      expect(Scene.of('f3', post: true)!.placeAt(3), Place.epilogue);
    });

    test('el cruce de la batalla 12 es la misma charla desde los dos lados', () {
      final s = Scene.of('s12', post: false)!, n = Scene.of('n12', post: false)!;
      expect(
        [for (var i = 0; i < s.beats.length; i++) s.text(i)],
        [for (var i = 0; i < n.beats.length; i++) n.text(i)],
      );
    });
  });

  testWidgets('la viñeta entra de a un mensaje, se adelanta tocando y termina', (tester) async {
    setLanguage('es');
    final scene = Scene.of('s1', post: false)!;
    await tester.pumpWidget(
      MaterialApp(
        theme: HexTheme.light.toThemeData(Skin.box),
        home: StoryScreen(scene: scene, mine: const {Faction.shaolin}, title: 'Prueba'),
      ),
    );
    // Primero el momento (lugar y hora), después de una pausa.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(scene.text(0)), findsNothing);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text(scene.text(0)), findsOneWidget);
    expect(find.text(scene.text(2)), findsNothing);
    // Tocar adelanta: aparece lo que se estaba escribiendo.
    for (var i = 0; i < scene.beats.length; i++) {
      await tester.tap(find.byType(ListView));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Saltar'), findsNothing);
  });
}
