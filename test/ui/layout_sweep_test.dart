import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/solo/campaign.dart';
import 'package:hexiege/story/credits_screen.dart';
import 'package:hexiege/story/script.dart';
import 'package:hexiege/story/scroll_screen.dart';
import 'package:hexiege/story/story_screen.dart';
import 'package:hexiege/ui/campaign_screen.dart';
import 'package:hexiege/ui/codex_screen.dart';
import 'package:hexiege/ui/gallery_screen.dart';
import 'package:hexiege/ui/game_screen.dart';
import 'package:hexiege/ui/initiation_screen.dart';
import 'package:hexiege/ui/menu_screen.dart';
import 'package:hexiege/ui/onboarding_screen.dart';
import 'package:hexiege/ui/solo_screen.dart';
import 'package:hexiege/ui/stage_list_screen.dart';
import 'package:hexiege/ui/theme/hex_theme.dart';
import 'package:hexiege/ui/widgets/phone_frame.dart';
import 'package:hexiege/ui/theme/ui_style.dart';

/// Barrido de pantallas: cada una en teléfono chico, grande y tablet, con la letra
/// normal y con la máxima que deja [PhoneFrame]. Ninguna puede desbordar.
void main() {
  final screens = <String, Widget Function()>{
    'menú': () => const MenuScreen(),
    'bienvenida': () => const OnboardingScreen(),
    'iniciación': () => const InitiationScreen(),
    'solo': () => const SoloScreen(),
    'campaña': () => const CampaignScreen(),
    'etapas': () => StageListScreen(title: 'Shaolin', subtitle: 'Acto I', stages: campaigns.first.stages),
    'códice': () => const CodexScreen(),
    'códice ficha': () => const CodexPieceScreen(initial: PieceType.dragon),
    'galería': () => const GalleryScreen(),
    'visor': () => const PieceViewerScreen(type: PieceType.dragon),
    'partida': () => const GameScreen(p0: Faction.shaolin, p1: Faction.ninja),
    'pergamino': () => const ScrollScreen(),
    'historieta': () => StoryScreen(scene: Scene.of('s1', post: false)!, mine: const {Faction.shaolin}),
    'créditos': () => const CreditsScreen(),
  };
  const sizes = {'iPhone SE': Size(750, 1334), 'iPhone Pro Max': Size(1320, 2868), 'iPad': Size(2048, 2732)};
  for (final MapEntry(key: name, value: build) in screens.entries) {
    for (final MapEntry(key: device, value: size) in sizes.entries) {
      for (final scale in [1.0, PhoneFrame.maxTextScale + 0.5]) {
        testWidgets('$name sin desbordes en $device con letra ×$scale', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 2;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpWidget(
            MaterialApp(
              theme: HexTheme.light.toThemeData(Skin.ema),
              builder: (context, child) => PhoneFrame(child: child!),
              home: build(),
            ),
          );
          for (var i = 0; i < 4; i++) {
            await tester.pump(const Duration(milliseconds: 400));
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 40));
        });
      }
    }
  }
}
