import 'dart:math';

import 'package:flutter/material.dart';

import '../config.dart';
import '../codex/gifts.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/avatar_face.dart';
import 'widgets/rank_badge.dart';
import 'widgets/skin_kit.dart';

/// Lo que el menú ofrece, sea cual sea su armado.
class MenuModel {
  final Animation<double> float;

  /// null = partidas online apagadas (`kOnlineMatches`): se muestra deshabilitada.
  final VoidCallback? findMatch;
  final VoidCallback solo;
  final VoidCallback local;
  final VoidCallback tutorial;
  final VoidCallback rules;
  final VoidCallback gallery;
  final VoidCallback settings;
  final VoidCallback rename;
  final ValueChanged<Faction> setFaction;

  /// Etapas superadas y total de un jugador.
  final int soloDone;
  final int soloTotal;

  const MenuModel({
    required this.float,
    required this.findMatch,
    required this.solo,
    required this.local,
    required this.tutorial,
    required this.rules,
    required this.gallery,
    required this.settings,
    required this.rename,
    required this.setFaction,
    required this.soloDone,
    required this.soloTotal,
  });

  Faction get faction => AppSettings.instance.faction;
  String get soloProgress => '$soloDone/$soloTotal';

  /// "Galería", con un punto si hay regalos sin abrir.
  String get galleryLabel => Gift.pending.isEmpty ? tr('gallery.title') : '${tr('gallery.title')} •';
}

PieceType leaderOf(Faction f) => f == Faction.shaolin ? PieceType.monk : PieceType.shogun;

/// Las dos fichas del logo flotando a destiempo.
class FloatingPieces extends StatelessWidget {
  final Animation<double> float;
  final double size;
  final Axis axis;
  const FloatingPieces({super.key, required this.float, this.size = 32, this.axis = Axis.horizontal});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: float,
    builder: (_, _) {
      final a = float.value * 2 * pi;
      final pieces = [
        PieceChip(type: PieceType.monk, owner: 0, size: size, lift: 0.25 + 0.2 * sin(a)),
        SizedBox(width: size * 0.18, height: size * 0.1),
        PieceChip(type: PieceType.shogun, owner: 1, size: size, lift: 0.25 + 0.2 * sin(a + pi)),
      ];
      return axis == Axis.horizontal
          ? Row(mainAxisSize: MainAxisSize.min, children: pieces)
          : Column(mainAxisSize: MainAxisSize.min, children: pieces);
    },
  );
}

String _record() {
  if (!kOnlineMatches) return tr('menu.winsVsAi', {'n': AppSettings.instance.wins});
  final l = AppSettings.instance.ladder;
  if (l.games == 0) return tr('menu.firstGame');
  return tr('menu.record', {'w': l.wins, 'l': l.losses}) + (l.draws > 0 ? tr('menu.recordDraws', {'d': l.draws}) : '');
}

/// Opción del menú que todavía no está disponible: atenuada y sin toque.
Widget _off(VoidCallback? onTap, Widget child) =>
    onTap != null ? child : IgnorePointer(child: Opacity(opacity: 0.45, child: child));

/// Avatar y nombre del jugador con su lápiz: tocarlo abre el perfil.
/// [sub] va debajo del nombre (rango, récord), al lado del avatar.
class _Name extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final double size;
  final double avatar;
  final Widget? sub;
  const _Name({required this.onTap, required this.color, this.size = 20, this.avatar = 58, this.sub});

  @override
  Widget build(BuildContext context) => Pressable(
    semanticLabel: tr('menu.rename'),
    onTap: () {
      skinTap();
      onTap();
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarFace(
          avatar: AppSettings.instance.avatarFor(AppSettings.instance.faction),
          frame: AppSettings.instance.frame,
          size: avatar,
          color: HexTheme.faction(AppSettings.instance.faction),
          borderColor: HexTheme.of(context).gold,
        ),
        // El marco sobresale del avatar: se le deja lugar para no pisar el nombre.
        SizedBox(width: AppSettings.instance.frame == null ? 12 : 12 + avatar * 0.2),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      AppSettings.instance.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: size, color: color, height: 1.15),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_rounded, size: size * 0.75, color: color.withValues(alpha: 0.5)),
                ],
              ),
              if (sub != null) ...[const SizedBox(height: 3), sub!],
            ],
          ),
        ),
      ],
    ),
  );
}

// =================================================================== caja

/// Caja de juego: una bandeja tallada con tu ficha, huecos para elegir
/// facción y compartimentos para cada modo.
class BoxMenu extends StatelessWidget {
  final MenuModel m;
  const BoxMenu(this.m, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final l = AppSettings.instance.ladder;
    final wood = boxWood(t);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: FloatingPieces(float: m.float, size: 30)),
        const SizedBox(height: 8),
        Text(
          'Hexiege',
          textAlign: TextAlign.center,
          style: s.display(54, color: t.text, height: 1.25),
        ),
        Text(
          tr('menu.tagline'),
          textAlign: TextAlign.center,
          style: TextStyle(color: t.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: wood,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.gold.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: t.shadow.withValues(alpha: t.shadow.a * 0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
                decoration: BoxDecoration(color: t.surfaceHigh, borderRadius: BorderRadius.circular(9)),
                child: Row(
                  children: [
                    if (kOnlineMatches) ...[RankBadge(rank: l.rank, size: 38), const SizedBox(width: 10)],
                    Expanded(
                      child: _Name(
                        onTap: m.rename,
                        color: t.text,
                        sub: Row(
                          children: [
                            if (kOnlineMatches)
                              Text(
                                l.rank.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: l.rank.textOn(t.isDark),
                                ),
                              ),
                            Flexible(
                              child: Text(
                                kOnlineMatches ? '  ${_record()}' : _record(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: t.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (kOnlineMatches && l.streak >= 2)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '🔥 ${l.streak}',
                          style: TextStyle(fontWeight: FontWeight.w900, color: t.text),
                        ),
                      ),
                    if (kOnlineMatches)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${l.rating}', style: s.display(26, color: t.text, height: 1)),
                          Text(tr('menu.points'), style: TextStyle(fontSize: 11, color: t.textMuted)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final f in playableFactions) ...[
                    Expanded(child: _Well(f, m)),
                    if (f != playableFactions.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (!AppSettings.instance.tutorialDone) ...[
          const SizedBox(height: 14),
          SkinTile(
            glyph: '師',
            color: t.gold,
            highlight: true,
            title: tr('menu.firstTime'),
            text: tr('menu.learn'),
            onTap: m.tutorial,
          ),
        ],
        const SizedBox(height: 16),
        SkinPrimaryButton(
          label: m.findMatch == null ? tr('menu.onlineSoon') : tr('menu.findMatch'),
          glyph: '戦',
          onPressed: m.findMatch,
        ),
        const SizedBox(height: 12),
        SkinTile(
          glyph: '独',
          color: wood,
          title: tr('solo.title'),
          text: tr('menu.soloSub'),
          progress: m.soloTotal == 0 ? 0 : m.soloDone / m.soloTotal,
          trailing: Text(m.soloProgress, style: s.display(18, color: t.textMuted)),
          onTap: m.solo,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SkinButton(glyph: '友', color: null, label: tr('menu.local'), onPressed: m.local),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SkinButton(glyph: '師', label: tr('menu.tutorial'), onPressed: m.tutorial),
            ),
          ],
        ),
        // De a dos por fila: con cuatro en una, los nombres no entran en inglés.
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SkinButton(glyph: '法', label: tr('menu.rules'), onPressed: m.rules),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SkinButton(
                glyph: '宝',
                color: Gift.pending.isEmpty ? null : t.gold,
                label: tr('gallery.title'),
                onPressed: m.gallery,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Hueco hexagonal tallado: la facción elegida tiene a su Líder apoyado adentro.
class _Well extends StatelessWidget {
  final Faction f;
  final MenuModel m;
  const _Well(this.f, this.m);

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final selected = m.faction == f;
    final wood = boxWood(t);
    final hollow = Color.lerp(wood, Colors.black, 0.35)!;
    const light = Color(0xFFF3E6CF);
    return Pressable(
      semanticLabel: f.displayName,
      onTap: () => m.setFaction(f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 9),
        decoration: BoxDecoration(
          color: Color.lerp(wood, Colors.black, 0.2),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: selected ? t.gold : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            ClipPath(
              clipper: const HexClipper(),
              child: Container(
                width: 60,
                height: 69,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.85), hollow],
                  ),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: selected ? 0.35 : 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (_, lift, _) => Opacity(
                    opacity: selected ? 1 : 0.5,
                    child: PieceChip(type: leaderOf(f), owner: 0, size: 21, lift: lift),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              f.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
                color: selected ? Color.lerp(HexTheme.faction(f), Colors.white, 0.45) : light,
              ),
            ),
            Text(
              f.abilityName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: light.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================== ema

/// Ema y washi: logo a pincel con sello, y los modos colgando de un riel como
/// tablillas de templo.
class EmaMenu extends StatelessWidget {
  final MenuModel m;
  const EmaMenu(this.m, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final l = AppSettings.instance.ladder;
    final rule = BorderSide(color: inkOf(t).withValues(alpha: 0.28));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FloatingPieces(float: m.float, size: 17, axis: Axis.vertical),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Hexiege', style: s.display(64, color: inkOf(t), height: 1)),
              ),
            ),
            const SizedBox(width: 10),
            const KanjiBadge('六', size: 34),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 18),
          child: Text(tr('menu.tagline'), style: TextStyle(fontSize: 15, color: t.textMuted)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: rule, bottom: rule),
          ),
          child: Row(
            children: [
              if (kOnlineMatches) ...[RankBadge(rank: l.rank, size: 34), const SizedBox(width: 12)],
              Expanded(
                child: _Name(
                  onTap: m.rename,
                  color: t.text,
                  size: 21,
                  avatar: 62,
                  sub: Row(
                    children: [
                      if (kOnlineMatches)
                        Text(l.rank.displayName, style: TextStyle(fontSize: 14, color: l.rank.textOn(t.isDark))),
                      Flexible(
                        child: Text(
                          kOnlineMatches ? '  ${_record()}' : _record(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: t.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (kOnlineMatches) Text('${l.rating}', style: s.display(38, color: inkOf(t), height: 1)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: [
            for (final f in playableFactions)
              Pressable(
                semanticLabel: f.displayName,
                onTap: () => m.setFaction(f),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: m.faction == f ? FontWeight.w900 : FontWeight.w400,
                          color: m.faction == f ? HexTheme.faction(f) : t.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: m.faction == f ? 7 : 0,
                        height: 7,
                        decoration: BoxDecoration(color: HexTheme.faction(f), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (!AppSettings.instance.tutorialDone) ...[
          const SizedBox(height: 6),
          SkinTile(glyph: '師', title: tr('menu.firstTime'), text: tr('menu.learn'), highlight: true, onTap: m.tutorial),
        ],
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final w = min(104.0, (c.maxWidth - 48) / 3);
            return Column(
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: t.isDark
                        ? Color.lerp(t.gold, Colors.black, 0.35)
                        : Color.lerp(boxWood(t), const Color(0xFF6B4527), 0.5),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmaPlaque(
                      width: w,
                      tilt: -0.04,
                      glyph: '独',
                      label: tr('solo.title'),
                      sub: m.soloProgress,
                      onTap: m.solo,
                    ),
                    _off(
                      m.findMatch,
                      EmaPlaque(
                        width: w * 1.12,
                        glyph: '戦',
                        label: m.findMatch == null ? 'Online' : tr('menu.findMatch'),
                        sub: m.findMatch == null ? tr('menu.soon') : null,
                        main: true,
                        onTap: m.findMatch ?? () {},
                      ),
                    ),
                    EmaPlaque(width: w, tilt: 0.035, glyph: '友', label: tr('menu.local'), onTap: m.local),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            SkinLink(label: tr('menu.tutorial'), onPressed: m.tutorial),
            SkinLink(label: tr('menu.rules'), onPressed: m.rules),
            SkinLink(label: m.galleryLabel, onPressed: m.gallery),
          ],
        ),
      ],
    );
  }
}

/// Tablilla votiva colgada de su cordón. Al tocarla se balancea.
class EmaPlaque extends StatefulWidget {
  final double width;
  final double tilt;
  final String glyph;
  final String label;
  final String? sub;
  final bool main;
  final VoidCallback onTap;
  const EmaPlaque({
    super.key,
    required this.width,
    required this.glyph,
    required this.label,
    required this.onTap,
    this.sub,
    this.tilt = 0,
    this.main = false,
  });

  @override
  State<EmaPlaque> createState() => _EmaPlaqueState();
}

class _EmaPlaqueState extends State<EmaPlaque> with SingleTickerProviderStateMixin {
  late final _swing = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void dispose() {
    _swing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final w = widget.width;
    final h = w * (widget.main ? 1.42 : 1.25);
    final wood = t.isDark
        ? [const Color(0xFF7A5634), const Color(0xFF5A3D22)]
        : [const Color(0xFFE8C792), const Color(0xFFCDA569)];
    final fill = widget.main
        ? [Color.lerp(t.accent, Colors.white, 0.08)!, Color.lerp(t.accent, Colors.black, 0.25)!]
        : wood;
    final ink = widget.main || t.isDark ? const Color(0xFFFFF6E2) : const Color(0xFF3A2410);
    return Pressable(
      semanticLabel: widget.label,
      onTap: () {
        skinTap();
        _swing.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _swing,
        builder: (_, child) {
          final p = _swing.value;
          final a = widget.tilt + 0.16 * sin(p * 3 * pi) * (1 - p);
          return Transform.rotate(angle: a, alignment: Alignment.topCenter, child: child);
        },
        child: Column(
          children: [
            Container(width: 2, height: 18, color: hankoRed),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(color: hankoRed, shape: BoxShape.circle),
            ),
            const SizedBox(height: 2),
            PhysicalShape(
              clipper: const _EmaClipper(),
              clipBehavior: Clip.antiAlias,
              color: fill.last,
              shadowColor: Colors.black,
              elevation: 5,
              child: Container(
                width: w,
                height: h,
                padding: EdgeInsets.fromLTRB(6, h * 0.24, 6, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: fill),
                ),
                child: Column(
                  children: [
                    Text(widget.glyph, style: s.glyph(widget.main ? 34 : 28, color: ink)),
                    const Spacer(),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: widget.main ? 14 : 12.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                    if (widget.sub != null)
                      Text(widget.sub!, style: TextStyle(fontSize: 11.5, color: ink.withValues(alpha: 0.75))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Silueta de ema: rectángulo con techo a dos aguas.
class _EmaClipper extends CustomClipper<Path> {
  const _EmaClipper();
  @override
  Path getClip(Size s) {
    final roof = s.width * 0.22;
    return Path()
      ..moveTo(s.width / 2, 0)
      ..lineTo(s.width, roof)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..lineTo(0, roof)
      ..close();
  }

  @override
  bool shouldReclip(_EmaClipper oldClipper) => false;
}

// =================================================================== panal

/// Panal: el menú es un pequeño tablero. “Jugar” ocupa la casilla del centro
/// y los demás modos la rodean; una casilla tiene a tu Líder para cambiar de facción.
class CombMenu extends StatelessWidget {
  final MenuModel m;
  const CombMenu(this.m, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final l = AppSettings.instance.ladder;
    final tutorialPending = !AppSettings.instance.tutorialDone;
    return Column(
      children: [
        FloatingPieces(float: m.float, size: 26),
        const SizedBox(height: 8),
        Text('Hexiege', style: s.display(48, color: t.text)),
        const SizedBox(height: 2),
        Text(tr('menu.tagline'), style: TextStyle(color: t.textMuted, fontSize: 14)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 20, 10),
          decoration: ShapeDecoration(
            shape: combShape(14, side: BorderSide(color: t.gold.withValues(alpha: 0.6))),
            color: t.surfaceHigh.withValues(alpha: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kOnlineMatches) ...[RankBadge(rank: l.rank, size: 32), const SizedBox(width: 8)],
              Flexible(
                child: _Name(
                  onTap: m.rename,
                  color: t.text,
                  size: 18,
                  avatar: 52,
                  sub: Text(_record(), style: TextStyle(fontSize: 13, color: t.textMuted)),
                ),
              ),
              if (kOnlineMatches) const SizedBox(width: 14),
              if (kOnlineMatches)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${l.rating}', style: s.display(20, color: t.text, height: 1)),
                    Text(
                      l.rank.displayName,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: l.rank.textOn(t.isDark)),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            const gap = 5.0;
            final w = min(118.0, (c.maxWidth - 2 * gap) / 3);
            final h = w * 1.1547;
            final dx = w + gap, dy = h * 0.75 + gap * 0.87;
            final cx = (c.maxWidth - w) / 2, cy = dy;
            Widget at(double x, double y, Widget cell) => Positioned(left: cx + x, top: cy + y, child: cell);
            return SizedBox(
              height: h + 2 * dy,
              child: Stack(
                children: [
                  at(
                    -dx / 2,
                    -dy,
                    HexCell(width: w, glyph: '独', label: tr('solo.title'), sub: m.soloProgress, onTap: m.solo),
                  ),
                  at(
                    dx / 2,
                    -dy,
                    HexCell(
                      width: w,
                      glyph: '師',
                      label: tr('menu.tutorial'),
                      gilded: tutorialPending,
                      onTap: m.tutorial,
                    ),
                  ),
                  at(-dx, 0, HexCell(width: w, glyph: '友', label: tr('menu.local'), onTap: m.local)),
                  at(
                    0,
                    0,
                    _off(
                      m.findMatch,
                      HexCell(
                        width: w,
                        glyph: '戦',
                        label: m.findMatch == null ? 'Online' : tr('menu.play'),
                        sub: m.findMatch == null ? tr('menu.soon') : tr('menu.ranked'),
                        main: true,
                        semantic: m.findMatch == null ? tr('menu.onlineSoon') : tr('menu.findMatch'),
                        onTap: m.findMatch ?? () {},
                      ),
                    ),
                  ),
                  at(dx, 0, HexCell(width: w, glyph: '法', label: tr('menu.rules'), onTap: m.rules)),
                  at(-dx / 2, dy, HexCell(width: w, glyph: '設', label: tr('menu.settings'), onTap: m.settings)),
                  at(
                    dx / 2,
                    dy,
                    HexCell(
                      width: w,
                      label: m.faction.displayName,
                      sub: tr('menu.switchFaction'),
                      labelColor: HexTheme.faction(m.faction),
                      leading: PieceChip(type: leaderOf(m.faction), owner: 0, size: w * 0.15, lift: 0.2),
                      onTap: () => m.setFaction(playableFactions[(m.faction.index + 1) % playableFactions.length]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        SkinLink(label: m.galleryLabel, onPressed: m.gallery),
      ],
    );
  }
}

/// Casilla hexagonal del panal.
class HexCell extends StatelessWidget {
  final double width;
  final String label;
  final String? glyph;
  final Widget? leading;
  final String? sub;
  final String? semantic;
  final Color? labelColor;
  final bool main;

  /// Resaltada en oro (algo pendiente, como el tutorial).
  final bool gilded;
  final VoidCallback onTap;
  const HexCell({
    super.key,
    required this.width,
    required this.label,
    required this.onTap,
    this.glyph,
    this.leading,
    this.sub,
    this.semantic,
    this.labelColor,
    this.main = false,
    this.gilded = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final s = Skin.of(context);
    final h = width * 1.1547;
    final fill = main
        ? [Color.lerp(t.accent, Colors.white, 0.1)!, Color.lerp(t.accent, Colors.black, 0.25)!]
        : gilded
        ? [Color.lerp(t.gold, Colors.white, 0.55)!, Color.lerp(t.gold, Colors.white, 0.25)!]
        : [t.surfaceHigh, Color.lerp(t.surfaceHigh, t.surface, 0.9)!];
    final ink = main ? Colors.white : (gilded ? const Color(0xFF2A1E08) : t.text);
    return Pressable(
      semanticLabel: semantic ?? label,
      depth: 0.94,
      onTap: () {
        skinTap();
        onTap();
      },
      child: SizedBox(
        width: width,
        height: h,
        child: CustomPaint(
          painter: _CellPainter(fill, main ? Color.lerp(t.accent, Colors.black, 0.5)! : t.gold, t.shadow),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(height: 2)],
                if (glyph != null) Text(glyph!, style: s.glyph(width * (main ? 0.26 : 0.21), color: ink)),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: main ? 17 : 12.5,
                    fontWeight: main ? FontWeight.w900 : FontWeight.w700,
                    height: 1.1,
                    color: labelColor ?? ink,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    style: TextStyle(fontSize: 11, color: (main ? Colors.white : t.textMuted).withValues(alpha: 0.85)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CellPainter extends CustomPainter {
  final List<Color> fill;
  final Color rim;
  final Color shadow;
  _CellPainter(this.fill, this.rim, this.shadow);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final p = hexPath(r.deflate(1.5));
    canvas.drawShadow(p, shadow, 5, false);
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fill,
        ).createShader(r),
    );
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = rim,
    );
    // Filete interior: la casilla parece tallada.
    canvas.drawPath(
      hexPath(r.deflate(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = rim.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_CellPainter old) => old.fill != fill || old.rim != rim;
}
