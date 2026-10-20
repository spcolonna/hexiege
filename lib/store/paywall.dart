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
