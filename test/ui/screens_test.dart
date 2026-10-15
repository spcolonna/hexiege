import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/match/ladder.dart';
import 'package:hexiege/match/matchmaker.dart';
import 'package:hexiege/tutorial/lessons.dart';
import 'package:hexiege/ui/game_screen.dart';
import 'package:hexiege/ui/matchmaking_screen.dart';
import 'package:hexiege/ui/menu_screen.dart';
import 'package:hexiege/ui/onboarding_screen.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';
import 'package:hexiege/ui/theme/settings.dart';

/// Rival fijo y sin esperas: empezás vos, el bot es Fácil.
class _FakeMatchmaker implements Matchmaker {
  @override
  Stream<MatchmakingEvent> search(MatchRequest request) async* {
    yield const Searching(50);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    yield Found(
      MatchFound(
        opponent: const Opponent(
          nickname: 'KenjiAzul',
          avatar: '龍',
          faction: Faction.ninja,
          rating: 1012,
          bot: AiLevel.easy,
        ),
        yourFaction: request.faction,
        youFirst: true,
      ),
    );
  }
}

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

  testWidgets('bienvenida: 3 páginas hasta el nombre', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const OnboardingScreen(), ThemeMode.dark));
    await tester.pump();
    expect(find.text('Rodeá al Líder'), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('¿Cómo te llamamos?'), findsOneWidget);
    expect(find.text('Aprender a jugar · 2 min'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Seba');
    await tester.tap(find.text('Ya sé jugar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(AppSettings.instance.nickname, 'Seba');
    expect(AppSettings.instance.onboarded, isTrue);
    expect(find.text('HEXIEGE'), findsOneWidget);
  });

  testWidgets('tutorial: la primera lección se completa colocando el Dragón', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const GameScreen.tutorial(), ThemeMode.light));
    await tester.pump();
    expect(find.text('LECCIÓN 1 DE 7'), findsOneWidget);
    await tester.tap(find.text('Dragón Celestial'));
    await tester.pump();
    final board = tester.getCenter(find.byType(InteractiveViewer));
    await tester.tapAt(board + const Offset(0, 50));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('¡Bien hecho!'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('LECCIÓN 2 DE 7'), findsOneWidget);
  });

  group('tutorial: habilidad de facción', () {
    Future<Offset Function(int, int)> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(GameScreen.tutorial(lesson: lessons.length - 1), ThemeMode.dark));
      await tester.pump(const Duration(milliseconds: 600));
      final c = tester.getCenter(find.byType(InteractiveViewer)) + const Offset(0, 50);
      return (q, r) => c + Offset(34 * sqrt(3) * (q + r / 2), 51.0 * r);
    }

    Future<void> relocate(WidgetTester tester, Offset Function(int, int) at, (int, int) to) async {
      await tester.tap(find.text('Meditación de Jade ×3'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Reubicar ficha enemiga'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tapAt(at(1, 0)); // la Kunoichi pegada al Monje
      await tester.pump();
      await tester.tapAt(at(to.$1, to.$2));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    testWidgets('alejar la ficha completa la lección', (tester) async {
      final at = await open(tester);
      await relocate(tester, at, (2, -1));
      expect(find.text('¡Completaste el tutorial!'), findsOneWidget);
    });

    testWidgets('cerrar tu propio cerco pide reintentar y rearma la escena', (tester) async {
      final at = await open(tester);
      await relocate(tester, at, (0, 1)); // rodea a tu propio Monje: pierde
      expect(find.textContaining('sigue en peligro'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.textContaining('Usá la habilidad'), findsOneWidget);
    });
  });

  testWidgets('partida por puntos: buscar, encontrar rival, abandonar resta puntos', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    AppSettings.instance.ladder = const LadderRecord();
    await tester.pumpWidget(
      _app(MatchmakingScreen(faction: Faction.shaolin, matchmaker: _FakeMatchmaker()), ThemeMode.dark),
    );
    await tester.pump();
    expect(find.text('Buscando rival…'), findsOneWidget);
    expect(find.text('Rivales de 950–1050 pts'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('¡Rival encontrado!'), findsOneWidget);
    expect(find.text('KenjiAzul'), findsOneWidget);
    expect(find.text('Empezás vos · fichas claras'), findsOneWidget);

    // Cuenta regresiva 3-2-1 y arranca la partida.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('KenjiAzul'), findsOneWidget);
    expect(find.text('1012'), findsOneWidget);
    expect(find.text('IA'), findsNothing);

    await tester.tap(find.byTooltip('Abandonar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(FilledButton, 'Abandonar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final l = AppSettings.instance.ladder;
    expect(l.losses, 1);
    expect(l.rating, 980);
    expect(find.text('Derrota'), findsOneWidget);
    expect(find.text('Buscar otra'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3)); // timers de emotes
  });

  testWidgets('menú: búsqueda de partida en lugar de elegir dificultad', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    AppSettings.instance.ladder = const LadderRecord();
    await tester.pumpWidget(_app(const MenuScreen(), ThemeMode.light));
    await tester.pump();
    expect(find.text('Buscar partida'), findsOneWidget);
    expect(find.text('Discípulo'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    expect(find.text('Fácil'), findsNothing);
  });
}
