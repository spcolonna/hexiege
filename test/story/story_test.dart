import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/codex/avatars.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/solo/campaign.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/story/director.dart';
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
          final b = sc.beats[i];
          if (b.hasText) expect(sc.text(i), isNot('story.$id.$i'));
          expect(b.who == null, b.kind == BeatKind.moment || b.kind == BeatKind.pause, reason: '$id.$i');
        }
      }
      for (final w in Who.values) {
        expect(w.displayName, isNot('who.${w.name}'));
      }
    });

    test('cada momento tiene escenario y toda escena sabe dónde transcurre', () {
      for (final id in Scene.ids) {
        final sc = Scene.of(id.split('.').first, post: id.endsWith('post'))!;
        // Cada momento dice dónde transcurre: en el mapa de escenarios o con «lugar».
        for (final m in sc.moments) {
          final placed = sc.beats[m].cues.any((c) => c.kind == CueKind.place);
          expect(placed || Scene.momentPlace(id, m) != null, isTrue, reason: '$id.$m');
        }
      }
      // Sin momento propio, sigue donde terminó la anterior.
      expect(Scene.of('s21', post: true)!.placeAt(0), Place.pagodaTop);
      expect(Scene.of('f3', post: true)!.placeAt(0), Place.ashCourtyard);
      expect(Scene.of('f3', post: true)!.placeAt(5), Place.epilogue);
    });

    test('el director arma un cuadro por golpe: páginas, elenco y globos coherentes', () {
      for (final id in Scene.ids) {
        final sc = Scene.of(id.split('.').first, post: id.endsWith('post'))!;
        final frames = Director.run(sc, hero: Who.ren);
        expect(frames, hasLength(sc.beats.length), reason: id);
        var page = 0;
        for (final f in frames) {
          final b = sc.beats[f.beat];
          // Las páginas avanzan de a una; cada momento abre una.
          expect(f.page - page, inInclusiveRange(0, 1), reason: '$id.${f.beat}');
          if (b.kind == BeatKind.moment && f.beat > 0) expect(f.page, page + 1, reason: '$id.${f.beat}');
          page = f.page;
          // Quien habla está en escena (salvo sobre una ilustración, en off o mientras se va).
          final off = b.cues.any((c) => c.kind == CueKind.voice);
          if (b.talks && f.art == null && !off && !f.leaving.containsKey(b.who)) {
            expect(f.actor(b.who!), isNotNull, reason: '$id.${f.beat}');
          }
          expect(f.lines.length, lessThanOrEqualTo(Director.maxLines));
          for (final l in f.lines) {
            expect(sc.beats[l].talks, isTrue);
          }
          expect(f.cast.map((a) => a.who).toSet(), hasLength(f.cast.length), reason: '$id.${f.beat}');
          final cue = f.caption;
          if (cue != null) expect(sc.beats[cue].kind, anyOf(BeatKind.moment, BeatKind.narrate));
        }
      }
    });

    test('la celda: paneo, el preso, la zorra y la celda vacía', () {
      final sc = Scene.of('s4', post: true)!;
      final f = Director.run(sc, hero: Who.ren);
      // Abre con un paneo lento antes de que nadie hable.
      expect(sc.beats[1].kind, BeatKind.pause);
      expect(f[1].slow, isTrue);
      expect(f[1].cast, isEmpty);
      // La zorra llega en una ilustración, en página nueva.
      final art = f.indexWhere((x) => x.art == 'art_fox_cell');
      expect(f[art].page, f[art - 1].page + 1);
      // Al final, Ren queda solo.
      expect(f.last.cast.map((a) => a.who), [Who.ren]);
      expect(sc.beats.last.kind, BeatKind.think);
    });

    test('el cruce de la batalla 12 es la misma charla desde los dos lados', () {
      final s = Scene.of('s12', post: false)!, n = Scene.of('n12', post: false)!;
      expect([for (final i in s.lines) s.text(i)], [for (final i in n.lines) n.text(i)]);
    });
  });

  testWidgets('la viñeta avanza de a un golpe por toque y termina', (tester) async {
    setLanguage('es');
    final scene = Scene.of('s1', post: false)!;
    await tester.pumpWidget(
      MaterialApp(
        theme: HexTheme.light.toThemeData(Skin.box),
        home: StoryScreen(scene: scene, mine: const {Faction.shaolin}, title: 'Prueba'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 3));
    // Sin tocar, no avanza: solo el momento.
    expect(find.text(scene.text(0)), findsOneWidget);
    expect(find.text(scene.text(2)), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text(scene.text(2)), findsNothing);
    // Cada toque completa el golpe o pasa al siguiente.
    for (var i = 0; i < scene.beats.length * 2; i++) {
      await tester.tapAt(const Offset(200, 300));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Saltar'), findsNothing);
  });

  test('cada batalla de la historia tiene un rival con nombre y retrato', () {
    for (final c in campaigns) {
      for (final st in c.stages) {
        final who = Scene.opponentOf(st.id);
        expect(who, isNotNull, reason: st.id);
        // Un retrato pintado del catálogo, nunca un carácter suelto.
        expect(Avatars.byId(who!.avatar), isNotNull, reason: '${st.id}: ${who.avatar}');
      }
    }
  });
}
