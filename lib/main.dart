import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'config.dart';

import 'i18n/i18n.dart';

import 'store/purchases.dart';
import 'engine/pieces.dart';
import 'services/games.dart';
import 'services/reminders.dart';
import 'story/script.dart';
import 'story/credits_screen.dart';
import 'story/story_screen.dart';
import 'ui/brand_intro.dart';
import 'ui/game_intro.dart';
import 'ui/widgets/phone_frame.dart';
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
  DailyReminder.init(); // reprograma los avisos del desafío
  // Game Center puede mostrar su pantalla de inicio de sesión: después de la intro.
  Future.delayed(const Duration(seconds: 4), Games.instance.init);
  final app = HexiegeApp(onboarding: !AppSettings.instance.onboarded);
  // Reporte de errores solo en builds de la tienda y con el DSN configurado.
  if (!kReleaseMode || kSentryDsn.isEmpty) return runApp(app);
  await SentryFlutter.init((o) {
    o.dsn = kSentryDsn;
    o.sendDefaultPii = false;
    o.tracesSampleRate = 0;
  }, appRunner: () => runApp(app));
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
        builder: (context, child) => PhoneFrame(child: child!),
        // Estudio → juego → bienvenida o menú. Para probar una viñeta:
        // flutter run --dart-define=STORY=s4.post [--dart-define=STORY_AT=9]
        // (STORY=credits muestra los créditos del final).
        home: _storyDemo == 'credits'
            ? const CreditsScreen()
            : _storyDemo.isNotEmpty
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
