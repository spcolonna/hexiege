import 'dart:math';

import 'package:flutter/material.dart';

import '../codex/codex_scenes.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import 'board_painter.dart';
import 'fx/board_fx.dart';
import 'fx/piece_renderer.dart';
import 'hex_layout.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/skin_kit.dart';

/// Códice: todas las fichas por facción. Cada una abre su ficha de estudio.
class CodexScreen extends StatelessWidget {
  const CodexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        accent: t.gold,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (context, _) {
              final s = AppSettings.instance;
              final seen = PieceType.values.where((p) => s.isPieceSeen(p.name)).length;
              return Column(
                children: [
                  SkinHeader(
                    title: tr('codex.title'),
                    subtitle: tr('codex.subtitle'),
                    trailing: '$seen/${PieceType.values.length}',
                    backTooltip: tr('common.back'),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        for (final f in Faction.values) ...[
                          _FactionHeader(f),
                          for (final p in PieceType.values.where((p) => p.faction == f))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SkinTile(
                                leading: PieceChip(type: p, owner: 0, size: 22),
                                title: p.displayName,
                                text: p.rulesText,
                                trailing: s.isPieceSeen(p.name)
                                    ? Icon(Icons.chevron_right_rounded, color: t.textMuted)
                                    : _NewTag(color: HexTheme.faction(f)),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CodexPieceScreen(initial: p)),
                                ),
                              ),
                            ),
                          const SizedBox(height: 14),
                        ],
                        Text(
                          tr('codex.example'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: t.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewTag extends StatelessWidget {
  final Color color;
  const _NewTag({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(
      tr('codex.new').toUpperCase(),
      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
    ),
  );
}

/// Emblema, nombre y habilidad de la facción, encima de sus fichas.
class _FactionHeader extends StatelessWidget {
  final Faction f;
  const _FactionHeader(this.f);

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Row(
        children: [
          Image.asset(
            'assets/emblems/${f.name}_emblem.webp',
            width: 60,
            height: 60,
            errorBuilder: (_, _, _) => KanjiBadge(f == Faction.shaolin ? '寺' : '忍', size: 44),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.displayName, style: skin.display(24, color: HexTheme.faction(f))),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${tr('codex.factionAbility')} · ${f.abilityName}: ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: f.abilityDescription),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, height: 1.35, color: t.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ficha de estudio: se recorren las 12 deslizando o con anterior/siguiente.
class CodexPieceScreen extends StatefulWidget {
  final PieceType initial;
  const CodexPieceScreen({super.key, required this.initial});

  @override
  State<CodexPieceScreen> createState() => _CodexPieceScreenState();
}

class _CodexPieceScreenState extends State<CodexPieceScreen> {
  late final PageController _pages = PageController(initialPage: widget.initial.index);
  late int _index = widget.initial.index;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.markPieceSeen(widget.initial.name);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final i = _index + delta;
    if (i < 0 || i >= PieceType.values.length) return;
    _pages.animateToPage(i, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final type = PieceType.values[_index];
    return Scaffold(
      body: ArenaBackdrop(
        accent: HexTheme.faction(type.faction),
        child: SafeArea(
          child: Column(
            children: [
              SkinHeader(
                title: tr('codex.title'),
                trailing: '${_index + 1}/${PieceType.values.length}',
                backTooltip: tr('common.back'),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: PieceType.values.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    AppSettings.instance.markPieceSeen(PieceType.values[i].name);
                  },
                  itemBuilder: (_, i) => _PiecePage(PieceType.values[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: tr('codex.prev'),
                      onPressed: _index > 0 ? () => _go(-1) : null,
                      icon: Icon(Icons.chevron_left_rounded, size: 34, color: t.text),
                    ),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        children: [
                          for (var i = 0; i < PieceType.values.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: i == _index ? 18 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _index
                                    ? HexTheme.faction(PieceType.values[i].faction)
                                    : t.textMuted.withValues(alpha: 0.35),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: tr('codex.next'),
                      onPressed: _index < PieceType.values.length - 1 ? () => _go(1) : null,
                      icon: Icon(Icons.chevron_right_rounded, size: 34, color: t.text),
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
}

class _PiecePage extends StatelessWidget {
  final PieceType type;
  const _PiecePage(this.type);

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final skin = Skin.of(context);
    final color = HexTheme.faction(type.faction);
    final count = startingHands[type.faction]![type]!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Row(
          children: [
            PieceChip(type: type, owner: 0, size: 44, lift: 0.15),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.displayName, style: skin.display(28, color: t.text)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        type.faction.displayName,
                        style: TextStyle(color: color, fontWeight: FontWeight.w800),
                      ),
                      Text('· ${tr('codex.count', {'n': count})}', style: TextStyle(color: t.textMuted)),
                      if (type.isLeader)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: t.gold, width: 1.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tr('codex.leader'),
                            style: TextStyle(color: t.gold, fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            KanjiBadge(type.glyph, size: 34, color: color),
          ],
        ),
        const SizedBox(height: 14),
        SkinPanel(
          padding: const EdgeInsets.all(6),
          child: AspectRatio(aspectRatio: 1.15, child: CodexBoard(scene: CodexScene.of(type))),
        ),
        const SizedBox(height: 6),
        Text(
          tr('codex.example'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: t.textMuted),
        ),
        const SizedBox(height: 14),
        Text(
          type.rulesText,
          style: TextStyle(fontSize: 17, height: 1.4, color: t.text, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(tr('codex.tip.${type.name}'), style: TextStyle(fontSize: 15, height: 1.45, color: t.textMuted)),
      ],
    );
  }
}

/// Mini tablero animado: la ficha recorre, una por una, las casillas a las que puede ir.
class CodexBoard extends StatefulWidget {
  final CodexScene scene;
  const CodexBoard({super.key, required this.scene});

  @override
  State<CodexBoard> createState() => _CodexBoardState();
}

class _CodexBoardState extends State<CodexBoard> with SingleTickerProviderStateMixin {
  static const _perTarget = Duration(milliseconds: 1900);
  late final List<Hex> _tour = widget.scene.tour;
  late final AnimationController _clock = AnimationController(vsync: this, duration: _perTarget * max(1, _tour.length))
    ..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final scene = widget.scene;
    return LayoutBuilder(
      builder: (context, box) {
        final layout = _fit(box.biggest);
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: BoardPainter(
                    game: scene.lifted,
                    layout: layout,
                    theme: t,
                    selected: scene.subject,
                    targets: scene.targets,
                    targetColor: t.highlight,
                    lastMove: const {},
                    swapTargets: scene.swapTargets,
                  ),
                ),
              ),
              CustomPaint(painter: _MoverPainter(_clock, scene, _tour, layout, t)),
            ],
          ),
        );
      },
    );
  }

  /// Encuadra fichas, destinos y sellos en el espacio disponible.
  HexLayout _fit(Size size) {
    final s = widget.scene;
    final cells = {...s.game.board.occupied, ...s.targets, s.subject, ...s.game.seals.keys};
    const unit = HexLayout(1, Offset.zero);
    var minX = double.infinity, maxX = -double.infinity, minY = double.infinity, maxY = -double.infinity;
    for (final h in cells) {
      final p = unit.toPixel(h);
      minX = min(minX, p.dx);
      maxX = max(maxX, p.dx);
      minY = min(minY, p.dy);
      maxY = max(maxY, p.dy);
    }
    // Margen: medio hexágono a cada lado más aire para la ficha levantada.
    final w = maxX - minX + sqrt(3) + 0.6, h = maxY - minY + 2 + 0.8;
    final hex = min(size.width / w, size.height / h);
    final mid = Offset((minX + maxX) / 2, (minY + maxY) / 2) * hex;
    return HexLayout(hex, size.center(Offset.zero) - mid + Offset(0, hex * 0.2));
  }
}

class _MoverPainter extends CustomPainter {
  final Animation<double> clock;
  final CodexScene scene;
  final List<Hex> tour;
  final HexLayout layout;
  final HexTheme theme;
  _MoverPainter(this.clock, this.scene, this.tour, this.layout, this.theme) : super(repaint: clock);

  bool get _flies => const {PieceType.dragon, PieceType.crane, PieceType.wukong, PieceType.tiger}.contains(scene.type);

  @override
  void paint(Canvas canvas, Size size) {
    final piece = scene.game.board.top(scene.subject)!;
    final src = layout.toPixel(scene.subject);
    void draw(Offset c, {double z = 0, double opacity = 1}) => PieceRenderer.draw(
      canvas,
      theme: theme,
      type: piece.type,
      owner: piece.owner,
      c: c,
      radius: layout.size,
      z: z,
      opacity: opacity,
      seed: piece.id,
    );

    if (tour.isEmpty) {
      draw(src);
      return;
    }
    final v = clock.value * tour.length;
    final dst = tour[min(v.floor(), tour.length - 1)];
    final f = v - v.floor();
    final to = layout.toPixel(dst);
    // Si cae encima de una pila (Rey Mono), queda a la altura de esa pila.
    final landZ = scene.lifted.board.height(dst) * layout.size * BoardFx.stackStep;
    final hop = layout.size * (_flies ? 0.9 : 0.3);

    if (f < 0.18) {
      draw(src);
    } else if (f < 0.58) {
      final p = Curves.easeInOutCubic.transform((f - 0.18) / 0.4);
      if (scene.type == PieceType.tengu) {
        // Se esfuma y reaparece.
        p < 0.5 ? draw(src, opacity: 1 - p * 2) : draw(to, z: landZ, opacity: p * 2 - 1);
      } else {
        draw(Offset.lerp(src, to, p)!, z: sin(pi * p) * hop + landZ * p);
      }
    } else if (f < 0.86) {
      draw(to, z: landZ);
    } else {
      final p = (f - 0.86) / 0.14;
      draw(to, z: landZ, opacity: 1 - p);
      draw(src, opacity: p);
    }
  }

  @override
  bool shouldRepaint(covariant _MoverPainter o) => o.scene != scene || o.layout != layout || o.theme != theme;
}
