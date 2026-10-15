import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/fx/sfx.dart';
import 'ui/menu_screen.dart';
import 'ui/theme/hex_theme.dart';
import 'ui/theme/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppSettings.instance.load();
  SoundBoard.instance.init(); // en segundo plano: no frena el arranque
  runApp(const HexiegeApp());
}

class HexiegeApp extends StatelessWidget {
  const HexiegeApp({super.key});

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
        home: const MenuScreen(),
      ),
    );
  }
}
