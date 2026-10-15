import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/ui/game_screen.dart';
import 'package:hexiege/ui/menu_screen.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';

Widget _app(Widget home, ThemeMode mode) => MaterialApp(
  theme: HexTheme.light.toThemeData(),
  darkTheme: HexTheme.dark.toThemeData(),
  themeMode: mode,
  home: home,
);

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('menú renderiza en $mode', (tester) async {
      await tester.pumpWidget(_app(const MenuScreen(), mode));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('HEXIEGE'), findsOneWidget);
    });

    testWidgets('partida: colocar una ficha anima y no rompe ($mode)', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const GameScreen(p0: Faction.shaolin, p1: Faction.ninja), mode));
      await tester.pump();
      await tester.tap(find.text('Dragón Celestial'));
      await tester.pump();
      expect(find.textContaining('Tocá una casilla'), findsOneWidget);
      // La primera ficha va al origen = centro del lienzo.
      await tester.tapAt(tester.getCenter(find.byType(InteractiveViewer)) + const Offset(0, -20));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('Terminar turno'), findsOneWidget);
    });
  }
}
