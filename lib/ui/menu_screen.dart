import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../codex/avatars.dart';
import '../codex/cosmetics.dart';
import '../config.dart';
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
import 'widgets/cosmetic_swatch.dart';
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
      findMatch: kOnlineMatches ? _findMatch : null,
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

  /// Partida local en un mismo dispositivo: cada jugador elige su facción.
  void _passAndPlay() {
    showSkinSheet<void>(
      context,
      title: tr('menu.localTitle'),
      builder: (ctx) => _LocalSetup(
        first: _faction,
        onStart: (p0, p1) {
          Navigator.pop(ctx);
          Navigator.push(context, _fade(GameScreen(p0: p0, p1: p1, faceToFace: AppSettings.instance.faceToFace)));
        },
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
              SkinLabel(tr('settings.table')),
              const _TablePreview(),
              const SizedBox(height: 10),
              const _TablePicker(),
              SkinLabel(tr('settings.stones')),
              for (final f in playableFactions) _StonePicker(f),
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
            for (final f in playableFactions) ...[
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
  late String? _frame = AppSettings.instance.frame;

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
    s.frame = _frame;
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
          const SizedBox(height: 14),
          SkinLabel(tr('profile.frame')),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 8,
            children: [
              for (final f in <FrameDef?>[null, ...Cosmetics.frames])
                CosmeticSwatch(
                  round: true,
                  size: 40,
                  label: tr(f?.nameKey ?? 'frame.none'),
                  selected: f?.id == _frame,
                  onTap: () => setState(() => _frame = f?.id),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AvatarFace(
                      avatar: _avatar,
                      frame: f?.id,
                      size: 32,
                      color: HexTheme.faction(Avatars.byId(_avatar)?.faction ?? AppSettings.instance.faction),
                      borderColor: f?.id == _frame ? t.gold : t.outline,
                    ),
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

/// Cómo se ve la partida con la mesa y las piedras elegidas: un trozo de
/// tablero con su grilla y una ficha de cada facción.
class _TablePreview extends StatelessWidget {
  const _TablePreview();

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        child: ArenaBackdrop(
          cloth: true,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: _PreviewGrid(ArenaBackdrop.gridColor(t)))),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PieceChip(type: PieceType.monk, owner: 0, size: 26),
                  PieceChip(type: PieceType.shogun, owner: 1, size: 26),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una fila de hexágonos como la grilla del tablero, del mismo tamaño que las fichas.
class _PreviewGrid extends CustomPainter {
  final Color color;
  _PreviewGrid(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 30.0, w = r * 1.7320508;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    final c = size.center(Offset.zero);
    for (var row = -1; row <= 1; row++) {
      for (var i = -4; i <= 4; i++) {
        final center = c + Offset(i * w + (row.isEven ? w / 2 : 0), row * r * 1.5);
        canvas.drawPath(hexPath(Rect.fromCenter(center: center, width: w * 0.95, height: r * 2 * 0.95)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PreviewGrid old) => old.color != color;
}

/// Tapete debajo del tablero: el de la facción (pintado) o uno de los cosméticos.
class _TablePicker extends StatelessWidget {
  const _TablePicker();

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = AppSettings.instance;
    return Wrap(
      spacing: 4,
      runSpacing: 10,
      children: [
        CosmeticSwatch(
          label: tr('settings.tableTheme'),
          selected: s.table == null,
          onTap: () => s.table = null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t.backdropTop, t.backdropBottom],
              ),
            ),
            child: Center(
              child: Text(
                '卓',
                style: TextStyle(fontSize: 22, color: t.gold, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        for (final c in Cosmetics.tables)
          CosmeticSwatch(
            label: tr(c.nameKey),
            selected: s.table == c.id,
            onTap: () => s.table = c.id,
            child: Image.asset(c.asset, fit: BoxFit.cover, cacheWidth: 160),
          ),
      ],
    );
  }
}

/// Piedra de las fichas de una facción.
class _StonePicker extends StatelessWidget {
  final Faction faction;
  const _StonePicker(this.faction);

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              faction.displayName,
              style: TextStyle(fontWeight: FontWeight.w800, color: HexTheme.faction(faction)),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 4,
              children: [
                for (final st in Cosmetics.stonesOf(faction))
                  CosmeticSwatch(
                    label: tr(st.nameKey),
                    selected: s.stoneFor(faction) == st.id,
                    onTap: () => s.setStone(faction, st.id),
                    child: Image.asset(st.asset, fit: BoxFit.cover, cacheWidth: 160),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

/// Hoja de la partida local: facción de cada jugador y modo cara a cara.
class _LocalSetup extends StatefulWidget {
  final Faction first;
  final void Function(Faction p0, Faction p1) onStart;
  const _LocalSetup({required this.first, required this.onStart});

  @override
  State<_LocalSetup> createState() => _LocalSetupState();
}

class _LocalSetupState extends State<_LocalSetup> {
  late final _picks = [widget.first, playableFactions.firstWhere((f) => f != widget.first)];

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final mirror = _picks[0] == _picks[1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr('menu.localBody'), style: TextStyle(color: t.textMuted, fontSize: 15, height: 1.4)),
        for (final seat in [0, 1]) ...[
          SkinLabel(tr(seat == 0 ? 'local.player1' : 'local.player2')),
          Row(
            children: [
              for (final f in playableFactions) ...[
                Expanded(
                  child: _FactionPick(
                    faction: f,
                    seat: seat,
                    mirror: mirror,
                    selected: _picks[seat] == f,
                    onTap: () => setState(() => _picks[seat] = f),
                  ),
                ),
                if (f != playableFactions.last) const SizedBox(width: 10),
              ],
            ],
          ),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: mirror
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(tr('local.mirror'), style: TextStyle(color: t.textMuted, fontSize: 13, height: 1.35)),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 12),
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
                style: TextStyle(color: t.textMuted, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SkinButton(
          height: 56,
          label: tr('common.start'),
          color: HexTheme.faction(_picks[0]),
          onPressed: () => widget.onStart(_picks[0], _picks[1]),
        ),
      ],
    );
  }
}

/// Una facción para un asiento: su líder en la piedra de ese jugador.
class _FactionPick extends StatelessWidget {
  final Faction faction;
  final int seat;
  final bool mirror, selected;
  final VoidCallback onTap;
  const _FactionPick({
    required this.faction,
    required this.seat,
    required this.mirror,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = HexTheme.faction(faction);
    return Pressable(
      semanticLabel: faction.displayName,
      onTap: () {
        skinTap();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : t.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? t.gold : t.outline, width: selected ? 2.5 : 1.2),
          boxShadow: [if (selected) BoxShadow(color: t.gold.withValues(alpha: 0.35), blurRadius: 10)],
        ),
        child: Column(
          children: [
            PieceChip(type: leaderOf(faction), owner: seat, size: 20, mirror: mirror && selected),
            const SizedBox(height: 4),
            Text(
              faction.displayName,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.15,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? t.text : t.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
