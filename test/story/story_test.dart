import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/story/page.dart';
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

    test('la página reparte todos los mensajes en orden, de a uno o dos globos por cuadro', () {
      var pairs = 0, frames = 0;
      for (final id in Scene.ids) {
        final sc = Scene.of(id.split('.').first, post: id.endsWith('post'))!;
        final strips = layoutPage(sc);
        expect([for (final s in strips) ...s.beats], List.generate(sc.beats.length, (i) => i), reason: id);
        for (final s in strips.whereType<FrameStrip>()) {
          expect(s.frames.length, s.flex.length);
          if (s.frames.length == 2) pairs++;
          for (final f in s.frames) {
            frames++;
            final talk = f.beats.where((i) => sc.beats[i].kind == BeatKind.say || sc.beats[i].kind == BeatKind.think);
            expect(talk.length, inInclusiveRange(1, 2), reason: '$id ${f.beats}');
          }
        }
        final splash = sc.splash?.$1;
        if (splash != null) expect(strips.any((s) => s.first == splash), isTrue, reason: id);
      }
      // Que la página mezcle tiras de un cuadro y de dos.
      expect(pairs * 2, greaterThan(frames ~/ 3));
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
    // Lo que todavía no se dijo ya ocupa su lugar, pero no se ve.
    bool seen(int i) => find.text(scene.text(i)).evaluate().any((e) {
      var visible = true;
      e.visitAncestorElements((a) {
        final w = a.widget;
        if (w is Visibility && !w.visible) visible = false;
        return visible;
      });
      return visible;
    });
    // Primero el momento (lugar y hora), después de una pausa.
    await tester.pump(const Duration(milliseconds: 300));
    expect(seen(0), isFalse);
    await tester.pump(const Duration(milliseconds: 400));
    expect(seen(0), isTrue);
    expect(seen(2), isFalse);
    // Tocar adelanta: aparece el próximo mensaje, ya escrito.
    for (var i = 0; i < scene.beats.length; i++) {
      await tester.tap(find.byType(ListView));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Saltar'), findsNothing);
  });
}
