import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/fx/sfx.dart';
import 'ui/menu_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/theme/hex_theme.dart';
import 'ui/theme/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppSettings.instance.load();
  SoundBoard.instance.init(); // en segundo plano: no frena el arranque
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
        debugShowCheckedModeBanner: false,
        theme: HexTheme.light.toThemeData(),
        darkTheme: HexTheme.dark.toThemeData(),
        themeMode: settings.themeMode,
        // Fundido lento: el cambio de tema en plena partida se siente intencional.
        themeAnimationDuration: const Duration(milliseconds: 450),
        themeAnimationCurve: Curves.easeInOut,
        home: onboarding ? const OnboardingScreen() : const MenuScreen(),
      ),
    );
  }
}
