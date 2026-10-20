import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/ui/solo_screen.dart';
import 'package:hexiege/ui/stage_list_screen.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';
import 'package:hexiege/ui/theme/settings.dart';
import 'package:hexiege/ui/theme/ui_style.dart';

void main() {
  setUp(() => setLanguage('es'));
  tearDown(() => AppSettings.instance.storyUnlocked = false);

  test('el Acto I de cada campaña es gratis; desde la 7 y El Sello, pago', () {
    for (final c in campaigns.where((c) => !c.isFinale)) {
      expect(c.stages.take(kFreeStagesPerCampaign).any(isPaid), isFalse);
      expect(c.stages.skip(kFreeStagesPerCampaign).every(isPaid), isTrue);
    }
    expect(finale.every(isPaid), isTrue);
    expect([...puzzles, ...challenges].any(isPaid), isFalse);
  });

  test('"Continuar" no ofrece una batalla paga sin la compra', () {
    final firstSix = {for (final s in shaolinCampaign.take(6)) s.id};
    bool cleared(String id) => firstSix.contains(id);
    expect(SoloScreen.nextUp(cleared)?.id, 'n1');
    AppSettings.instance.storyUnlocked = true;
    expect(SoloScreen.nextUp(cleared)?.id, 's7');
  });

  test('reiniciar la historia borra campañas, viñetas y desbloqueo, pero no los problemas', () {
    final s = AppSettings.instance;
    s
      ..markCleared('s1')
      ..markCleared('f1')
      ..markCleared(puzzles.first.id)
      ..markSceneSeen('s1.pre')
      ..storyUnlocked = true;
    s.resetStory([
      for (final c in campaigns)
        for (final st in c.stages) st.id,
    ]);
    expect(s.isCleared('s1') || s.isCleared('f1') || s.isSceneSeen('s1.pre') || s.storyUnlocked, isFalse);
    expect(s.isCleared(puzzles.first.id), isTrue);
  });

  testWidgets('la batalla 7 aparece con candado y abre el desbloqueo', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    for (final s in shaolinCampaign.take(6)) {
      AppSettings.instance.markCleared(s.id);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: HexTheme.light.toThemeData(Skin.box),
        home: StageListScreen(title: 'Shaolin', subtitle: '', stages: shaolinCampaign),
      ),
    );
    await tester.pump();
    final s7 = shaolinCampaign[6];
    await tester.scrollUntilVisible(find.text(s7.title), 200);
    expect(find.text('Historia completa · USD 1,99'), findsOneWidget);
    await tester.tap(find.text(s7.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Seguí la historia'), findsOneWidget);
    expect(find.text('Restaurar compras'), findsOneWidget);
    await tester.ensureVisible(find.text('Ahora no'));
    await tester.tap(find.text('Ahora no'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Seguí la historia'), findsNothing);
  });
}
