import 'dart:math';

import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../engine/pieces.dart';
import '../engine/rules.dart';
import '../solo/catalog.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'matchmaking_screen.dart';
import 'piece_chip.dart';
import 'solo_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/tabletop.dart';
import 'widgets/rank_badge.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  Faction get _faction => AppSettings.instance.faction;
  late final _float = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  late final _nick = TextEditingController(text: AppSettings.instance.nickname);

  @override
  void dispose() {
    _float.dispose();
    _nick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context); // reconstruye al cambiar de idioma
    final t = HexTheme.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        _logo(t),
                        const SizedBox(height: 28),
                        _card(t, [
                          TextField(
                            controller: _nick,
                            maxLength: 16,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: tr('menu.yourName'),
                              prefixIcon: const Icon(Icons.person_outline),
                              counterText: '',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) => AppSettings.instance.nickname = v,
                          ),
                          const SizedBox(height: 12),
                          ListenableBuilder(listenable: AppSettings.instance, builder: (context, _) => _rankRow(t)),
                        ]),
                        const SizedBox(height: 14),
                        _factionPicker(t),
                        const SizedBox(height: 12),
                        const SizedBox(height: 10),
                        ListenableBuilder(
                          listenable: AppSettings.instance,
                          builder: (context, _) => AppSettings.instance.tutorialDone
                              ? const SizedBox.shrink()
                              : Padding(padding: const EdgeInsets.only(bottom: 12), child: _tutorialInvite(t)),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: SealButton(
                            label: tr('menu.findMatch'),
                            icon: Icons.search_rounded,
                            onPressed: _findMatch,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: PlaqueButton(
                            icon: Icons.auto_stories_rounded,
                            label: ListenableBuilder(
                              listenable: AppSettings.instance,
                              builder: (context, _) => Text(
                                tr('menu.solo', {'progress': _soloProgress()}),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                            onPressed: _solo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.people_outline),
                              label: Text(tr('menu.local')),
                              onPressed: _passAndPlay,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.school_outlined),
                              label: Text(tr('menu.tutorial')),
                              onPressed: _tutorial,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.menu_book_outlined),
                              label: Text(tr('menu.rules')),
                              onPressed: () => _rules(context),
                            ),
                          ],
                        ),
                      ],
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
                      icon: Icon(t.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                      onPressed: () {
                        Haptics.select();
                        AppSettings.instance.toggleBrightness(context);
                      },
                    ),
                    IconButton(
                      tooltip: tr('menu.settings'),
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () => _settings(context),
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

  void _tap(VoidCallback f) {
    SoundBoard.instance.play(Sfx.tick);
    Haptics.select();
    setState(f);
  }

  void _findMatch() {
    SoundBoard.instance.play(Sfx.place);
    Haptics.heavy();
    FocusScope.of(context).unfocus();
    Navigator.push(context, _fade(MatchmakingScreen(faction: _faction)));
  }

  /// Partida local en un mismo dispositivo: el Jugador 2 elige su facción.
  void _passAndPlay() {
    Haptics.select();
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('menu.localTitle'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                tr('menu.localBody', {'faction': _faction.displayName}),
                style: TextStyle(color: HexTheme.of(ctx).textMuted),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final f in Faction.values) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HexTheme.faction(f),
                          side: BorderSide(color: HexTheme.faction(f)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, _fade(GameScreen(p0: _faction, p1: f)));
                        },
                        child: Text(f.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (f != Faction.values.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ],
          ),
        ),
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

  /// Rango, puntos, récord y racha del jugador.
  Widget _rankRow(HexTheme t) {
    final l = AppSettings.instance.ladder;
    return Row(
      children: [
        RankBadge(rank: l.rank, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.rank.displayName,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: l.rank.textOn(t.isDark)),
              ),
              Text(
                l.games == 0
                    ? tr('menu.firstGame')
                    : tr('menu.record', {'w': l.wins, 'l': l.losses}) +
                          (l.draws > 0 ? tr('menu.recordDraws', {'d': l.draws}) : ''),
                style: TextStyle(fontSize: 12, color: t.textMuted),
              ),
            ],
          ),
        ),
        if (l.streak >= 2)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              '🔥 ${l.streak}',
              style: TextStyle(fontWeight: FontWeight.w900, color: t.text),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${l.rating}',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: t.text, height: 1.1),
            ),
            Text(tr('menu.points'), style: TextStyle(fontSize: 11, color: t.textMuted)),
          ],
        ),
      ],
    );
  }

  void _tutorial() {
    Haptics.select();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen.tutorial()));
  }

  void _solo() {
    Haptics.select();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SoloScreen()));
  }

  /// Etapas superadas sobre el total de campaña, desafíos y problemas.
  String _soloProgress() {
    final all = stageLists.expand((l) => l);
    return '${all.where((s) => AppSettings.instance.isCleared(s.id)).length}/${all.length}';
  }

  /// Invitación al tutorial mientras no se haya completado.
  Widget _tutorialInvite(HexTheme t) => Material(
    color: t.gold.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _tutorial,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.gold.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(Icons.school_rounded, color: t.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('menu.firstTime'),
                    style: TextStyle(fontWeight: FontWeight.w900, color: t.text),
                  ),
                  Text(tr('menu.learn'), style: TextStyle(fontSize: 12.5, color: t.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.textMuted),
          ],
        ),
      ),
    ),
  );

  Widget _logo(HexTheme t) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _float,
          builder: (_, _) {
            final a = _float.value * 2 * pi;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PieceChip(type: PieceType.monk, owner: 0, size: 32, lift: 0.25 + 0.2 * sin(a)),
                const SizedBox(width: 6),
                PieceChip(type: PieceType.shogun, owner: 1, size: 32, lift: 0.25 + 0.2 * sin(a + pi)),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'HEXIEGE',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
            color: t.gold,
            shadows: [Shadow(color: t.shadow, blurRadius: 12, offset: const Offset(0, 4))],
          ),
        ),
        Text(tr('menu.tagline'), style: TextStyle(color: t.textMuted, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _card(HexTheme t, List<Widget> children) => Tray(child: Column(children: children));

  Widget _factionPicker(HexTheme t) {
    return _card(t, [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          tr('menu.yourFaction'),
          style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          for (final f in Faction.values) ...[
            Expanded(child: _factionTile(t, f)),
            if (f != Faction.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
    ]);
  }

  Widget _factionTile(HexTheme t, Faction f) {
    final selected = _faction == f;
    final color = HexTheme.faction(f);
    final leader = f == Faction.shaolin ? PieceType.monk : PieceType.shogun;
    return GestureDetector(
      onTap: () => _tap(() => AppSettings.instance.faction = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : t.outline, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: selected ? 0.35 : 0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              builder: (_, lift, _) => PieceChip(type: leader, owner: 0, size: 17, lift: lift),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selected ? color : t.text,
                      fontSize: 13,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    f.abilityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: t.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _settings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (ctx, _) {
          final s = AppSettings.instance;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('menu.settings'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Text(tr('settings.theme')),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto),
                          label: Text(tr('settings.system')),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode),
                          label: Text(tr('settings.light')),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode),
                          label: Text(tr('settings.dark')),
                        ),
                      ],
                      selected: {s.themeMode},
                      onSelectionChanged: (v) => s.themeMode = v.first,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(tr('settings.language')),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String?>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: null, label: Text(tr('settings.system'))),
                        const ButtonSegment(value: 'es', label: Text('Español')),
                        const ButtonSegment(value: 'en', label: Text('English')),
                        const ButtonSegment(value: 'zh', label: Text('中文')),
                      ],
                      selected: {s.language},
                      onSelectionChanged: (v) => s.language = v.first,
                    ),
                  ),
                  // Los caracteres chinos solo se ofrecen en chino.
                  if (currentLanguage == 'zh') ...[
                    const SizedBox(height: 16),
                    Text(tr('settings.pieces')),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<PieceStyle>(
                        segments: [
                          ButtonSegment(value: PieceStyle.images, label: Text(tr('settings.pieceImages'))),
                          ButtonSegment(value: PieceStyle.glyphs, label: Text(tr('settings.pieceGlyphs'))),
                        ],
                        selected: {s.pieceStyle},
                        onSelectionChanged: (v) => s.pieceStyle = v.first,
                      ),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr('common.sound')),
                    value: s.sound,
                    onChanged: (v) => s.sound = v,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr('settings.haptics')),
                    value: s.haptics,
                    onChanged: (v) => s.haptics = v,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _rules(BuildContext context) {
    final t = HexTheme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(tr('rules.title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              tr('rules.body', {
                'charges': _r.abilityCharges!,
                'cooldown': _r.abilityCooldown,
                'siege': _r.siegeRound!,
                'limit': _r.roundLimit!,
              }),
            ),
            for (final f in Faction.values) ...[
              const SizedBox(height: 20),
              Text(
                f.displayName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HexTheme.faction(f)),
              ),
              Text('${f.abilityName}: ${f.abilityDescription}', style: TextStyle(color: t.textMuted)),
              const SizedBox(height: 8),
              for (final e in startingHands[f]!.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PieceChip(type: e.key, owner: f == Faction.shaolin ? 0 : 1, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${e.key.displayName} ×${e.value}: ${e.key.rulesText}')),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

const _r = Rules.standard;
