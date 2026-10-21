import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../ui/fx/sfx.dart';
import '../ui/theme/hex_theme.dart';
import '../ui/theme/settings.dart';
import '../ui/theme/ui_style.dart';
import '../ui/widgets/skin_kit.dart';
import 'purchases.dart';

/// Hoja de desbloqueo de la historia. Devuelve true si quedó desbloqueada.
Future<bool> showPaywall(BuildContext context) async {
  if (AppSettings.instance.storyUnlocked) return true;
  Purchases.instance.init();
  await showSkinSheet<void>(context, title: tr('store.title'), builder: (ctx) => const _Paywall());
  return AppSettings.instance.storyUnlocked;
}

class _Paywall extends StatefulWidget {
  const _Paywall();

  @override
  State<_Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<_Paywall> {
  final _listen = Listenable.merge([Purchases.instance, AppSettings.instance]);
  bool _closing = false;

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    return ListenableBuilder(
      listenable: _listen,
      builder: (context, _) {
        final p = Purchases.instance;
        final owned = AppSettings.instance.storyUnlocked;
        if (owned && !_closing) {
          // Compra confirmada: festejo breve y se cierra.
          _closing = true;
          SoundBoard.instance.play(Sfx.victory);
          Haptics.heavy();
          Future.delayed(const Duration(milliseconds: 1400), () {
            if (context.mounted) Navigator.of(context).maybePop();
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StoryTeaser(),
            const SizedBox(height: 14),
            Text(tr('store.pitch'), style: TextStyle(fontSize: 15, height: 1.4, color: t.text)),
            const SizedBox(height: 14),
            for (final (glyph, key) in [('戦', 'store.item1'), ('鬼', 'store.item2'), ('巻', 'store.item3')])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    KanjiBadge(glyph, size: 32, color: t.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tr(key), style: TextStyle(fontSize: 14, color: t.text)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            if (owned)
              Text(
                tr('store.thanks'),
                textAlign: TextAlign.center,
                style: skin.display(20, color: t.gold),
              )
            else ...[
              SkinPrimaryButton(
                label: p.busy ? tr('store.wait') : tr('store.buy', {'price': p.price}),
                glyph: '解',
                color: t.gold,
                onPressed: p.busy ? null : p.buy,
              ),
              if (p.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    p.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: t.danger),
                  ),
                ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SkinLink(label: tr('store.restore'), onPressed: p.busy ? null : p.restore),
                  SkinLink(label: tr('store.notNow'), onPressed: () => Navigator.of(context).maybePop()),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Lo que falta ver: tres escenas de la historia veladas, con candado, y la
/// silueta del Oni delante, respirando. Vende la curiosidad, no una lista.
class StoryTeaser extends StatefulWidget {
  const StoryTeaser({super.key});

  @override
  State<StoryTeaser> createState() => _StoryTeaserState();
}

class _StoryTeaserState extends State<StoryTeaser> with SingleTickerProviderStateMixin {
  late final _breath = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

  static const _scenes = [
    ('assets/story/bg_crypt_stairs.webp', 'II', -0.11),
    ('assets/story/art_duel_shrine.webp', 'III', 0.0),
    ('assets/story/bg_pagoda_top.webp', 'IV', 0.11),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return SizedBox(
      height: 214,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = min(c.maxWidth / 3.1, 130.0);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              for (final (i, (img, act, tilt)) in _scenes.indexed)
                Positioned(
                  top: i == 1 ? 0 : 12,
                  left: c.maxWidth / 2 + (i - 1) * w * 0.98 - w / 2,
                  child: Transform.rotate(
                    angle: tilt,
                    child: _LockedScene(image: img, act: act, width: w),
                  ),
                ),
              Positioned(
                bottom: -6,
                child: AnimatedBuilder(
                  animation: _breath,
                  builder: (context, _) {
                    final b = 0.5 - 0.5 * cos(_breath.value * 2 * pi);
                    return Transform.scale(
                      scale: 1 + 0.025 * b,
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 104,
                        height: 124,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Resplandor de brasa detrás de la silueta.
                            ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  t.danger.withValues(alpha: 0.55 + 0.35 * b),
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset('assets/story/char_oni.webp', fit: BoxFit.contain),
                              ),
                            ),
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(Color(0xFF120C0C), BlendMode.srcIn),
                              child: Image.asset('assets/story/char_oni.webp', fit: BoxFit.contain),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Una escena de la historia velada: desenfocada, oscurecida y con candado.
class _LockedScene extends StatelessWidget {
  final String image;
  final String act;
  final double width;
  const _LockedScene({required this.image, required this.act, required this.width});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Container(
      width: width,
      height: width * 0.72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.gold.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [BoxShadow(color: t.shadow.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.clamp),
              child: Image.asset(image, fit: BoxFit.cover, cacheWidth: 320),
            ),
            ColoredBox(color: Colors.black.withValues(alpha: 0.38)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                const SizedBox(height: 2),
                Text(
                  tr('store.act', {'n': act}),
                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
