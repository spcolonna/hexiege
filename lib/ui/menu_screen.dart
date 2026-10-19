import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../codex/avatars.dart';
import '../engine/pieces.dart';
import '../engine/rules.dart';
import '../solo/catalog.dart';
import 'codex_screen.dart';
import 'gallery_screen.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'matchmaking_screen.dart';
import 'menu_layouts.dart';
import 'piece_chip.dart';
import 'solo_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/avatar_face.dart';
import 'widgets/skin_kit.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  Faction get _faction => AppSettings.instance.faction;
  late final _float = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void initState() {
    super.initState();
    // Regalos ganados antes de que existiera la galería (o en otra pantalla).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) GiftToast.check(context, delay: const Duration(milliseconds: 1200));
    });
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context); // reconstruye al cambiar de idioma
    final t = HexTheme.of(context);
    final style = Skin.of(context).style;
    return Scaffold(
      body: ArenaBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: ListenableBuilder(
                      listenable: AppSettings.instance,
                      builder: (context, _) {
                        final m = _model();
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: KeyedSubtree(
                            key: ValueKey(style),
                            child: switch (style) {
                              UiStyle.box => BoxMenu(m),
                              UiStyle.ema => EmaMenu(m),
                              UiStyle.comb => CombMenu(m),
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: tr('menu.toggleTheme'),
                      color: t.text,
                      icon: Icon(t.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                      onPressed: () {
                        Haptics.select();
                        AppSettings.instance.toggleBrightness(context);
                      },
                    ),
                    // En el panal, Ajustes ya es una casilla.
                    if (style != UiStyle.comb)
                      IconButton(
                        tooltip: tr('menu.settings'),
                        color: t.text,
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: _settings,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MenuModel _model() {
    final all = stageLists.expand((l) => l).toList();
    return MenuModel(
      float: _float,
      findMatch: _findMatch,
      solo: _solo,
      local: _passAndPlay,
      tutorial: _tutorial,
      rules: _rules,
      gallery: () => Navigator.push(context, _fade(const GalleryScreen())),
      settings: _settings,
      rename: _rename,
      setFaction: (f) {
        if (f == _faction) return;
        SoundBoard.instance.play(Sfx.tick);
        Haptics.select();
        AppSettings.instance.faction = f;
      },
      soloDone: all.where((s) => AppSettings.instance.isCleared(s.id)).length,
      soloTotal: all.length,
    );
  }

  void _findMatch() {
    SoundBoard.instance.play(Sfx.place);
    Haptics.heavy();
    Navigator.push(context, _fade(MatchmakingScreen(faction: _faction)));
  }

  void _rename() {
    showSkinDialog<void>(context, builder: (_) => const _RenameDialog());
  }

  /// Partida local en un mismo dispositivo: el Jugador 2 elige su facción.
  void _passAndPlay() {
    showSkinSheet<void>(
      context,
      title: tr('menu.localTitle'),
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('menu.localBody', {'faction': _faction.displayName}),
            style: TextStyle(color: HexTheme.of(ctx).textMuted, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkinToggle(
                  label: tr('local.faceToFace'),
                  value: AppSettings.instance.faceToFace,
                  onChanged: (v) => AppSettings.instance.faceToFace = v,
                ),
                Text(
                  tr(AppSettings.instance.faceToFace ? 'local.faceToFaceOn' : 'local.faceToFaceOff'),
                  style: TextStyle(color: HexTheme.of(ctx).textMuted, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final f in Faction.values) ...[
                Expanded(
                  child: SkinButton(
                    height: 64,
                    label: f.displayName,
                    color: HexTheme.faction(f),
                    leading: PieceChip(type: leaderOf(f), owner: f == _faction ? 0 : 1, size: 15),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        _fade(GameScreen(p0: _faction, p1: f, faceToFace: AppSettings.instance.faceToFace)),
                      );
                    },
                  ),
                ),
                if (f != Faction.values.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Route<void> _fade(Widget page) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: 1.04, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );

  void _tutorial() {
    Haptics.select();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen.tutorial()));
  }

  void _solo() {
    Haptics.select();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SoloScreen()));
  }

  void _settings() {
    showSkinSheet<void>(
      context,
      title: tr('menu.settings'),
      builder: (ctx) => ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (ctx, _) {
          final s = AppSettings.instance;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkinLabel(tr('settings.uiStyle')),
              for (final style in UiStyle.values)
                Padding(padding: const EdgeInsets.only(bottom: 8), child: _StyleOption(style)),
              SkinLabel(tr('settings.theme')),
              SkinChoice<ThemeMode>(
                options: [
                  SkinOption(ThemeMode.system, tr('settings.system')),
                  SkinOption(ThemeMode.light, tr('settings.light')),
                  SkinOption(ThemeMode.dark, tr('settings.dark')),
                ],
                selected: s.themeMode,
                onChanged: (v) => s.themeMode = v,
              ),
              SkinLabel(tr('settings.language')),
              SkinChoice<String?>(
                options: [
                  SkinOption(null, tr('settings.system')),
                  const SkinOption('es', 'Español'),
                  const SkinOption('en', 'English'),
                  const SkinOption('zh', '中文'),
                ],
                selected: s.language,
                onChanged: (v) => s.language = v,
              ),
              // Los caracteres chinos solo se ofrecen en chino.
              if (currentLanguage == 'zh') ...[
                SkinLabel(tr('settings.pieces')),
                SkinChoice<PieceStyle>(
                  options: [
                    SkinOption(PieceStyle.images, tr('settings.pieceImages')),
                    SkinOption(PieceStyle.glyphs, tr('settings.pieceGlyphs')),
                  ],
                  selected: s.pieceStyle,
                  onChanged: (v) => s.pieceStyle = v,
                ),
              ],
              const SizedBox(height: 12),
              SkinToggle(label: tr('common.sound'), value: s.sound, onChanged: (v) => s.sound = v),
              SkinToggle(label: tr('settings.haptics'), value: s.haptics, onChanged: (v) => s.haptics = v),
              const SizedBox(height: 22),
              const _StudioCredit(),
            ],
          );
        },
      ),
    );
  }

  void _rules() {
    final skin = Skin.of(context);
    showSkinSheet<void>(
      context,
      title: tr('rules.title'),
      builder: (ctx) {
        final t = HexTheme.of(ctx);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('rules.body', {
                'charges': _r.abilityCharges!,
                'cooldown': _r.abilityCooldown,
                'siege': _r.siegeRound!,
                'limit': _r.roundLimit!,
              }),
              style: TextStyle(fontSize: 15, height: 1.45, color: t.text),
            ),
            const SizedBox(height: 16),
            SkinButton(
              glyph: '鑑',
              label: tr('codex.open'),
              onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CodexScreen())),
            ),
            for (final f in Faction.values) ...[
              const SizedBox(height: 22),
              Text(f.displayName, style: skin.display(24, color: HexTheme.faction(f))),
              const SizedBox(height: 2),
              Text('${f.abilityName}: ${f.abilityDescription}', style: TextStyle(color: t.textMuted, height: 1.4)),
              const SizedBox(height: 8),
              for (final e in startingHands[f]!.entries)
                Pressable(
                  semanticLabel: e.key.displayName,
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => CodexPieceScreen(initial: e.key))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PieceChip(type: e.key, owner: f == Faction.shaolin ? 0 : 1, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${e.key.displayName} ×${e.value}  ',
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                TextSpan(text: e.key.rulesText),
                              ],
                            ),
                            style: TextStyle(color: t.text, height: 1.4),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: t.textMuted),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

/// Un estilo de interfaz en Ajustes, mostrado con su propia tipografía e insignia.
class _StyleOption extends StatelessWidget {
  final UiStyle style;
  const _StyleOption(this.style);

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.instance;
    final t = HexTheme.of(context);
    final skin = Skin.forStyle(style);
    final selected = s.uiStyle == style;
    final unlocked = s.isStyleUnlocked(style);
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(extensions: [t, skin]),
      child: Builder(
        builder: (context) => SkinTile(
          leading: KanjiBadge(switch (style) {
            UiStyle.box => '盤',
            UiStyle.ema => '道',
            UiStyle.comb => '巣',
          }, size: 34),
          title: style.displayName,
          text: style.blurb,
          highlight: selected,
          color: t.gold,
          trailing: Icon(
            !unlocked
                ? Icons.lock_rounded
                : selected
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            color: selected ? t.gold : t.textMuted,
            semanticLabel: unlocked ? null : tr('uiStyle.locked'),
          ),
          onTap: unlocked ? () => s.uiStyle = style : null,
        ),
      ),
    );
  }
}

/// Perfil: el avatar y el nombre que ven los rivales.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog();

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _c = TextEditingController(text: AppSettings.instance.nickname);
  late String _avatar = AppSettings.instance.avatarFor(AppSettings.instance.faction);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    AppSettings.instance.nickname = _c.text;
    // Si quedó el inicial de la facción, no se fija: así sigue a la facción elegida.
    final s = AppSettings.instance;
    s.avatar = s.avatar == null && _avatar == Avatars.defaultFor(s.faction) ? null : _avatar;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return SkinDialog(
      title: tr('menu.profile'),
      glyph: '名',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in Avatars.all)
                Pressable(
                  semanticLabel: tr(a.nameKey),
                  onTap: () {
                    skinTap();
                    setState(() => _avatar = a.id);
                  },
                  child: AvatarFace(
                    avatar: a.id,
                    size: 54,
                    color: HexTheme.faction(a.faction),
                    borderColor: a.id == _avatar ? t.gold : t.outline,
                    borderWidth: a.id == _avatar ? 3 : 1.2,
                    shadow: [if (a.id == _avatar) BoxShadow(color: t.gold.withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _c,
            maxLength: 16,
            textCapitalization: TextCapitalization.words,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.text),
            cursorColor: t.accent,
            decoration: InputDecoration(
              counterText: '',
              hintText: tr('menu.yourName'),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: t.outline, width: 1.5)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: t.accent, width: 2)),
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        SkinAction(tr('common.cancel'), () => Navigator.pop(context)),
        SkinAction(tr('common.save'), _save, primary: true),
      ],
    );
  }
}

const _r = Rules.standard;

/// Firma del estudio al pie de los ajustes.
class _StudioCredit extends StatelessWidget {
  const _StudioCredit();

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/brand/oraki_symbol_${dark ? 'light' : 'dark'}.webp',
            width: 26,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 10),
          Text(
            tr('settings.madeBy'),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: t.textMuted),
          ),
        ],
      ),
    );
  }
}
