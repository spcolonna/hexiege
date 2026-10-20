import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'i18n/i18n.dart';

import 'store/purchases.dart';
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
  SoundBoard.instance.init(); // en segundo plano: no frena el arranque
  Purchases.instance.init(); // compras pendientes y precio de la tienda
  await PieceArt.load();
  runApp(HexiegeApp(onboarding: !AppSettings.instance.onboarded));
}

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
        // Estudio → juego → bienvenida o menú.
        home: BrandIntro(next: GameIntro(next: onboarding ? const OnboardingScreen() : const MenuScreen())),
      ),
    );
  }
}
