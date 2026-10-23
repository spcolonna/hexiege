import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'i18n/i18n.dart';

import 'store/purchases.dart';
import 'engine/pieces.dart';
import 'story/script.dart';
import 'story/story_screen.dart';
import 'ui/brand_intro.dart';
import 'ui/game_intro.dart';
import 'ui/fx/piece_art.dart';
import 'ui/fx/sfx.dart';
import 'ui/menu_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/theme/hex_theme.dart';
import 'ui/theme/settings.dart';
import 'ui/theme/ui_style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppSettings.instance.load();
  SoundBoard.instance.init().then((_) => MusicBoard.instance.enable()); // en segundo plano
  Purchases.instance.init(); // compras pendientes y precio de la tienda
  StoryArt.load(); // qué arte de las viñetas ya está en el paquete
  await PieceArt.load();
  runApp(HexiegeApp(onboarding: !AppSettings.instance.onboarded));
}

const _storyDemo = String.fromEnvironment('STORY');

class HexiegeApp extends StatelessWidget {
  /// Primer arranque: bienvenida antes del menú. Se decide una sola vez para que
  /// guardar la preferencia no reemplace la pantalla raíz en caliente.
  final bool onboarding;
  const HexiegeApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Hexiege',
        locale: settings.locale,
        supportedLocales: [for (final l in supportedLanguages) Locale(l)],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        theme: HexTheme.forFaction(settings.faction, Brightness.light).toThemeData(Skin.forStyle(settings.uiStyle)),
        darkTheme: HexTheme.forFaction(settings.faction, Brightness.dark).toThemeData(Skin.forStyle(settings.uiStyle)),
        themeMode: settings.themeMode,
        // Fundido lento: el cambio de tema en plena partida se siente intencional.
        themeAnimationDuration: const Duration(milliseconds: 450),
        themeAnimationCurve: Curves.easeInOut,
        builder: (context, child) => _PhoneFrame(child: child!),
        // Estudio → juego → bienvenida o menú. Para probar una viñeta:
        // flutter run --dart-define=STORY=s4.post [--dart-define=STORY_AT=9]
        home: _storyDemo.isNotEmpty
            ? StoryScreen(
                scene: Scene.of(_storyDemo.split('.').first, post: _storyDemo.endsWith('post'))!,
                mine: {_storyDemo.startsWith('n') ? Faction.ninja : Faction.shaolin},
                title: _storyDemo,
                start: const int.fromEnvironment('STORY_AT'),
              )
            : BrandIntro(next: GameIntro(next: onboarding ? const OnboardingScreen() : const MenuScreen())),
      ),
    );
  }
}

/// Límites globales de la interfaz, pensada para un teléfono en vertical:
/// - La letra del sistema crece hasta 1,3×; más allá desborda los botones.
/// - En tablet la app ocupa una columna centrada con proporción de teléfono.
class _PhoneFrame extends StatelessWidget {
  static const maxTextScale = 1.3;
  static const maxAspect = 0.6; // ancho / alto

  final Widget child;
  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final tablet = size.shortestSide >= 600;
    final width = tablet && size.width > size.height * maxAspect ? size.height * maxAspect : size.width;
    final scaled = MediaQuery.withClampedTextScaling(maxScaleFactor: maxTextScale, child: child);
    if (width >= size.width) return scaled;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: width,
          child: ClipRect(
            child: MediaQuery(
              data: mq.copyWith(size: Size(width, size.height)),
              child: scaled,
            ),
          ),
        ),
      ),
    );
  }
}
