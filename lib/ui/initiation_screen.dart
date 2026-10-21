import 'package:flutter/material.dart';

import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

/// Antesala de la Iniciación: el jugador elige con qué escuela aprende y
/// entra a una partida guiada contra el Sensei. Las lecciones cortas quedan
/// como alternativa para quien prefiere ir regla por regla.
class InitiationScreen extends StatelessWidget {
  const InitiationScreen({super.key});

  void _start(BuildContext context, Faction f) {
    Haptics.medium();
    SoundBoard.instance.play(Sfx.select);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => GameScreen.initiation(faction: f),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  void _lessons(BuildContext context) {
    Haptics.select();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameScreen.tutorial()));
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: tr('common.back'),
                  icon: Icon(Icons.arrow_back_rounded, color: t.text),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      Text('入門', style: skin.glyph(40, color: t.gold)),
                      const SizedBox(height: 4),
                      Text(
                        tr('initiation.title'),
                        textAlign: TextAlign.center,
                        style: skin.display(30, color: t.text),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr('initiation.body'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, height: 1.35, color: t.textMuted),
                      ),
                      const SizedBox(height: 22),
                      for (final (i, f) in playableFactions.indexed) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _FactionDoor(faction: f, owner: i, onTap: () => _start(context, f)),
                      ],
                      const SizedBox(height: 18),
                      SkinLink(label: tr('initiation.lessons'), color: t.textMuted, onPressed: () => _lessons(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La puerta de una escuela: emblema, nombre, cómo juega y su Líder.
class _FactionDoor extends StatelessWidget {
  final Faction faction;
  final int owner;
  final VoidCallback onTap;
  const _FactionDoor({required this.faction, required this.owner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = HexTheme.faction(faction);
    final types = startingHands[faction]!.keys.toList();
    return Pressable(
      semanticLabel: faction.displayName,
      onTap: onTap,
      child: SkinPanel(
        highlight: color,
        child: Row(
          children: [
            Image.asset('assets/emblems/${faction.name}_emblem.webp', width: 72, height: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faction.displayName,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr('onboarding.${faction.name}'),
                    style: TextStyle(fontSize: 13.5, height: 1.3, color: t.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final ty in types) PieceChip(type: ty, owner: owner, size: 14)],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: color, size: 30),
          ],
        ),
      ),
    );
  }
}
