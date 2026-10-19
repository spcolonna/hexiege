import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/config.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/match/ladder.dart';
import 'package:hexiege/match/matchmaker.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/tutorial/lessons.dart';
import 'package:hexiege/ui/game_screen.dart';
import 'package:hexiege/ui/matchmaking_screen.dart';
import 'package:hexiege/ui/menu_screen.dart';
import 'package:hexiege/ui/onboarding_screen.dart';
import 'package:hexiege/ui/solo_screen.dart';
import 'package:hexiege/ui/stage_list_screen.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';
import 'package:hexiege/ui/theme/settings.dart';
import 'package:hexiege/ui/theme/ui_style.dart';
import 'package:hexiege/ui/widgets/duel_scoreboard.dart';
import 'package:hexiege/ui/widgets/skin_kit.dart';

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

Widget _app(Widget home, ThemeMode mode, [Skin skin = Skin.box]) => MaterialApp(
  theme: HexTheme.light.toThemeData(skin),
  darkTheme: HexTheme.dark.toThemeData(skin),
  themeMode: mode,
  home: home,
);

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('menú renderiza en $mode', (tester) async {
      await tester.pumpWidget(_app(const MenuScreen(), mode));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Hexiege'), findsOneWidget);
    });

    testWidgets('partida: colocar una ficha anima y no rompe ($mode)', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const GameScreen(p0: Faction.shaolin, p1: Faction.ninja), mode));
      await tester.pump();
      await tester.tap(find.byTooltip('Dragón Celestial'));
      await tester.pump();
      expect(find.textContaining('Tocá una casilla'), findsOneWidget);
      // La primera ficha va al origen = centro del lienzo.
      await tester.tapAt(tester.getCenter(find.byType(InteractiveViewer)) + const Offset(0, -20));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      // El turno pasa solo al rival.
      expect(find.text('Terminar turno'), findsNothing);
      expect(find.text('Colocá una ficha o mové una del tablero'), findsOneWidget);
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
    expect(find.text('Hexiege'), findsOneWidget);
  });

  testWidgets('tutorial: la primera lección se completa colocando el Dragón', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const GameScreen.tutorial(), ThemeMode.light));
    await tester.pump();
    expect(find.text('LECCIÓN 1 DE 7'), findsOneWidget);
    await tester.tap(find.byTooltip('Dragón Celestial'));
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
      return (q, r) => c + Offset(40 * sqrt(3) * (q + r / 2), 60.0 * r);
    }

    Future<void> relocate(WidgetTester tester, Offset Function(int, int) at, (int, int) to) async {
      await tester.tap(find.byTooltip('Meditación de Jade ×3'));
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
      // Aviso del efecto y registro de la jugada.
      expect(find.textContaining('Meditación de Jade: reubicó Kunoichi (rival)'), findsOneWidget);
    });

    testWidgets('solo deja hacer la jugada que pide la lección', (tester) async {
      final at = await open(tester);
      // Mover una ficha propia no está permitido: el Tigre no se selecciona.
      await tester.tapAt(at(-1, 0));
      await tester.pump();
      expect(find.textContaining('Elegí destino'), findsNothing);
      // Dejar la Kunoichi pegada al Monje tampoco: el toque no hace nada.
      await relocate(tester, at, (0, 1));
      expect(find.textContaining('sigue en peligro'), findsNothing);
      expect(find.text('¡Completaste el tutorial!'), findsNothing);
      // Sigue esperando el destino: alejarla completa la lección.
      await tester.tapAt(at(2, -1));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('¡Completaste el tutorial!'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Abandonar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(SkinPrimaryButton, 'Abandonar'));
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
    if (kOnlineMatches) {
      expect(find.text('Buscar partida'), findsOneWidget);
      expect(find.text('Discípulo'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
    } else {
      // Sin online: la opción se ve apagada y no hay rango ni puntos.
      expect(find.text('Online · Próximamente'), findsOneWidget);
      expect(find.text('Buscar partida'), findsNothing);
      expect(find.text('1000'), findsNothing);
    }
    expect(find.text('Fácil'), findsNothing);
  });

  group('problemas', () {
    Future<Offset Function(int, int)> open(WidgetTester tester, Stage stage) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(GameScreen.stage(stage: stage, nextStage: stageAfter(stage)), ThemeMode.dark));
      await tester.pump();
      // Primero la presentación: título y objetivo, y recién ahí la partida.
      expect(find.text(stage.title), findsOneWidget);
      await tester.tap(find.text('Comenzar'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(stage.title), findsNothing);
      final c = tester.getCenter(find.byType(InteractiveViewer)) + const Offset(0, 35);
      return (q, r) => c + Offset(40 * sqrt(3) * (q + r / 2), 60.0 * r);
    }

    testWidgets('resolver el problema lo marca como superado', (tester) async {
      final p = puzzles.firstWhere((s) => s.id == 'p02');
      expect(p.title, 'Vuelo del Dragón');
      final at = await open(tester, p);
      expect(find.text('turno'), findsOneWidget);
      await tester.tapAt(at(0, -2));
      await tester.pump();
      await tester.tapAt(at(0, 1));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('¡Superado!'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      expect(AppSettings.instance.isCleared('p02'), isTrue);
    });

    testWidgets('gastar el último turno sin cercar es fallar', (tester) async {
      final p = puzzles.firstWhere((s) => s.id == 'p01');
      final at = await open(tester, p);
      await tester.tapAt(at(-1, 1)); // la Grulla, lejos del hueco
      await tester.pump();
      await tester.tapAt(at(2, -2));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Esta vez no'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Esta vez no'), findsNothing);
      expect(find.text('turno'), findsOneWidget);
    });

    testWidgets('cerco en 2: el rival defiende y la jugada correcta igual gana', (tester) async {
      final p = puzzles.firstWhere((s) => s.id == 'p12');
      final at = await open(tester, p);
      expect(find.text('turnos'), findsOneWidget);
      // Kunoichi al hueco paralizando al Tigre.
      await tester.tapAt(at(-1, -1));
      await tester.pump();
      await tester.tapAt(at(-1, 0));
      await tester.pump(const Duration(seconds: 1));
      await tester.tapAt(at(0, -1));
      await tester.pump(const Duration(seconds: 1));
      // La defensa corre en un isolate: hay que dejar pasar tiempo real.
      await tester.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 40 && find.textContaining('está pensando').evaluate().isNotEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 500));
      }
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.text('turno'), findsOneWidget);
      // La Kitsune cierra el cerco.
      await tester.tapAt(at(0, 2));
      await tester.pump();
      await tester.tapAt(at(-1, 1));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('¡Superado!'), findsOneWidget);
    });

    testWidgets('la lista bloquea los que siguen al primero sin resolver', (tester) async {
      await tester.pumpWidget(
        _app(StageListScreen(title: 'Problemas', subtitle: '', stages: puzzles), ThemeMode.light),
      );
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
      expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    });
  });

  testWidgets('menú → Un jugador muestra los tres modos y Continuar', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const MenuScreen(), ThemeMode.light));
    await tester.pump(const Duration(seconds: 2));
    await tester.ensureVisible(find.textContaining('Un jugador'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.textContaining('Un jugador'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(SoloScreen), findsOneWidget);
    for (final m in ['Campaña', 'Desafíos', 'Problemas', 'Continuar']) {
      expect(find.text(m), findsOneWidget);
    }
  });

  group('estilos de interfaz', () {
    for (final style in UiStyle.values) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets('menú y popups en ${style.name} ($mode)', (tester) async {
          tester.view.physicalSize = const Size(1170, 2532);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(_app(const MenuScreen(), mode, Skin.forStyle(style)));
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text('Hexiege'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Reglas: hoja con el marco del estilo.
          await tester.ensureVisible(find.text('Reglas'));
          await tester.pump();
          await tester.tap(find.text('Reglas'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text('Reglas básicas'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('partida de campaña en ${style.name} ($mode)', (tester) async {
          tester.view.physicalSize = const Size(1170, 2532);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          AppSettings.instance.uiStyle = style;
          addTearDown(() => AppSettings.instance.uiStyle = UiStyle.box);
          final stage = shaolinCampaign.first;
          await tester.pumpWidget(_app(GameScreen.stage(stage: stage, nextStage: stageAfter(stage)), mode));
          await tester.pump(const Duration(milliseconds: 400));
          // Presentación a pantalla completa con el objetivo.
          expect(find.text(stage.title), findsOneWidget);
          expect(find.text('Objetivo'), findsOneWidget);
          await tester.tap(find.text('Comenzar'));
          await tester.pump(const Duration(seconds: 2));
          await tester.pump(const Duration(milliseconds: 500));
          // En la partida: marcador, objetivo en un chip y la mano en el dock.
          expect(find.byType(DuelScoreboard), findsOneWidget);
          expect(find.text(stage.goal), findsOneWidget);
          expect(find.byTooltip('Dragón Celestial'), findsOneWidget);
          expect(tester.takeException(), isNull);
          // Tocar el objetivo vuelve a abrir la presentación.
          await tester.tap(find.text(stage.goal));
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text(stage.title), findsOneWidget);
          await tester.tap(find.byTooltip('Cerrar'));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text(stage.title), findsNothing);
        });
      }
    }

    testWidgets('Ajustes cambia el estilo y lo recuerda', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      addTearDown(() => AppSettings.instance.uiStyle = UiStyle.box);
      await tester.pumpWidget(_app(const MenuScreen(), ThemeMode.light));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (final s in UiStyle.values) {
        expect(find.text(s.displayName), findsOneWidget);
        expect(AppSettings.instance.isStyleUnlocked(s), isTrue);
      }
      await tester.tap(find.text('Panal'));
      await tester.pump();
      expect(AppSettings.instance.uiStyle, UiStyle.comb);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el nombre se cambia desde el menú', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const MenuScreen(), ThemeMode.dark, Skin.ema));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField), 'Grulla');
      await tester.tap(find.text('Guardar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(AppSettings.instance.nickname, 'Grulla');
      expect(find.text('Grulla'), findsOneWidget);
    });
  });

  test('Continuar sigue la campaña Shaolin y después la Ninja', () {
    expect(SoloScreen.nextUp((_) => false)?.id, 's1');
    expect(SoloScreen.nextUp((id) => id == 's1')?.id, 's2');
    expect(SoloScreen.nextUp((id) => id.startsWith('s'))?.id, 'n1');
    expect(SoloScreen.nextUp((_) => true), isNull);
  });
}
