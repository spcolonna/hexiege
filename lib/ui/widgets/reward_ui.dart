import 'package:flutter/material.dart';

import '../../codex/avatars.dart';
import '../../codex/cosmetics.dart';
import '../../codex/rewards.dart';
import '../../i18n/i18n.dart';
import '../fx/sfx.dart';
import '../theme/hex_theme.dart';
import '../theme/settings.dart';
import 'avatar_face.dart';
import 'skin_kit.dart';

/// Cómo se ve un premio: el retrato, el marco sobre tu avatar, la piedra o la mesa.
class RewardPreview extends StatelessWidget {
  final Reward reward;
  final double size;
  const RewardPreview(this.reward, {super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = AppSettings.instance;
    switch (reward.kind) {
      case RewardKind.avatar:
        final a = Avatars.byId(reward.id)!;
        return AvatarFace(avatar: a.id, size: size, color: HexTheme.faction(a.faction), borderColor: t.gold);
      case RewardKind.frame:
        final mine = s.avatarFor(s.faction);
        return SizedBox.square(
          dimension: size,
          child: Center(
            child: AvatarFace(
              avatar: mine,
              frame: reward.id,
              size: size / AvatarFace.frameScale,
              color: HexTheme.faction(Avatars.byId(mine)?.faction ?? s.faction),
              borderColor: t.outline,
            ),
          ),
        );
      case RewardKind.stone:
        return _tile(Cosmetics.stone(reward.faction!, reward.id)!.asset, t, round: true);
      case RewardKind.table:
        return _tile(Cosmetics.table(reward.id)!.asset, t);
    }
  }

  Widget _tile(String asset, HexTheme t, {bool round = false}) => Container(
    width: size,
    height: size,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      shape: round ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: round ? null : BorderRadius.circular(size * 0.18),
      border: Border.all(color: t.gold, width: 1.6),
    ),
    child: Image.asset(asset, fit: BoxFit.cover, cacheWidth: 160),
  );
}

/// Al tocar un cosmético con candado: qué hay que hacer para ganarlo.
Future<void> showLockedReward(BuildContext context, Reward r) {
  Haptics.select();
  return showSkinDialog<void>(
    context,
    builder: (ctx) => SkinDialog(
      title: tr(r.nameKey),
      glyph: '封',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Opacity(opacity: 0.45, child: RewardPreview(r, size: 72))),
          const SizedBox(height: 12),
          Text(tr(r.hintKey, r.hintArgs), textAlign: TextAlign.center),
        ],
      ),
      actions: [SkinAction(tr('common.close'), () => Navigator.pop(ctx), primary: true)],
    ),
  );
}

/// Los premios recién ganados, con un botón para usarlos ya.
Future<void> showRewardReveal(BuildContext context, List<Reward> rewards) =>
    showSkinDialog<void>(context, builder: (_) => _RewardReveal(rewards));

class _RewardReveal extends StatefulWidget {
  final List<Reward> rewards;
  const _RewardReveal(this.rewards);

  @override
  State<_RewardReveal> createState() => _RewardRevealState();
}

class _RewardRevealState extends State<_RewardReveal> {
  final _equipped = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return SkinDialog(
      title: tr('reward.title'),
      glyph: '宝',
      glyphColor: t.gold,
      body: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final r in widget.rewards)
              SizedBox(
                width: 104,
                child: Column(
                  children: [
                    RewardPreview(r, size: 72),
                    const SizedBox(height: 6),
                    Text(
                      tr(r.kindKey).toUpperCase(),
                      style: TextStyle(color: t.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                    Text(
                      tr(r.nameKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.text, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    _equipped.contains(r.key)
                        ? Text(tr('reward.inUse'), style: TextStyle(color: t.textMuted, fontSize: 12))
                        : Pressable(
                            semanticLabel: tr('reward.use'),
                            onTap: () {
                              skinTap();
                              r.equip();
                              setState(() => _equipped.add(r.key));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                tr('reward.use'),
                                style: TextStyle(color: t.accent, fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [SkinAction(tr('common.close'), () => Navigator.pop(context), primary: true)],
    );
  }
}
