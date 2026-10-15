import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/hex.dart';
import '../engine/pieces.dart';
import 'fx/piece_renderer.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'hex_layout.dart';
import 'menu_screen.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';

/// Bienvenida del primer arranque: la idea del juego en 3 pantallas y, al
/// final, el nombre y la invitación al tutorial.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  late final _nick = TextEditingController(
    text: AppSettings.instance.nickname == 'Vos' ? '' : AppSettings.instance.nickname,
  );
  int _page = 0;
  static const _count = 3;

  @override
  void dispose() {
    _pages.dispose();
    _nick.dispose();
    super.dispose();
  }

  void _go(int page) {
    Haptics.select();
    _pages.animateToPage(page, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
  }

  void _finish({required bool tutorial}) {
    final s = AppSettings.instance;
    s.nickname = _nick.text;
    s.onboarded = true;
    Haptics.medium();
    final nav = Navigator.of(context);
    nav.pushReplacement(_fade(const MenuScreen()));
    if (tutorial) nav.push(_fade(const GameScreen.tutorial()));
  }

  static Route<void> _fade(Widget page) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
  );

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ArenaBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _page < _count - 1 ? 1 : 0,
                    child: TextButton(
                      onPressed: _page < _count - 1 ? () => _go(_count - 1) : null,
                      child: Text('Saltar', style: TextStyle(color: t.textMuted)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [_intro(t), _factions(t), _profile(t)],
                ),
              ),
              _dots(t),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: _page < _count - 1
                    ? _primary(t, 'Siguiente', Icons.arrow_forward_rounded, () => _go(_page + 1))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _primary(t, 'Aprender a jugar · 2 min', Icons.school_rounded, () => _finish(tutorial: true)),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () => _finish(tutorial: false),
                            child: Text('Ya sé jugar', style: TextStyle(color: t.textMuted)),
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

  Widget _primary(HexTheme t, String label, IconData icon, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: t.gold,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      iconAlignment: IconAlignment.end,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      onPressed: onTap,
    ),
  );

  Widget _dots(HexTheme t) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < _count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == _page ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: i == _page ? t.gold : t.outline, borderRadius: BorderRadius.circular(4)),
        ),
    ],
  );

  Widget _text(HexTheme t, String title, String body) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: t.text, height: 1.1),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.5, color: t.textMuted, height: 1.35),
        ),
      ],
    ),
  );

  Widget _intro(HexTheme t) => Column(
    children: [
      const Expanded(child: Center(child: _SurroundDemo())),
      _text(
        t,
        'Rodeá al Líder',
        'Estrategia pura, sin azar ni tablero. Ganás cuando el Líder enemigo queda rodeado por los 6 lados.',
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _factions(HexTheme t) => Column(
    children: [
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _factionCard(t, Faction.shaolin, 0, 'Controlan la colmena: reubican fichas enemigas.'),
                const SizedBox(height: 14),
                _factionCard(t, Faction.ninja, 1, 'Se escabullen y devuelven fichas a la mano.'),
              ],
            ),
          ),
        ),
      ),
      _text(t, 'Dos escuelas', 'Cada facción tiene sus propias fichas y una habilidad especial. Elegí tu estilo.'),
      const SizedBox(height: 12),
    ],
  );

  Widget _factionCard(HexTheme t, Faction f, int owner, String pitch) {
    final color = HexTheme.faction(f);
    final types = startingHands[f]!.keys.toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 18, spreadRadius: -4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PieceChip(type: types.first, owner: owner, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.displayName,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color),
                    ),
                    Text(pitch, style: TextStyle(fontSize: 13, color: t.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final ty in types.skip(1)) PieceChip(type: ty, owner: owner, size: 16)],
          ),
        ],
      ),
    );
  }

  Widget _profile(HexTheme t) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PieceChip(type: PieceType.monk, owner: 0, size: 40, lift: 0.3),
          const SizedBox(height: 24),
          _text(t, '¿Cómo te llamamos?', 'Es el nombre que verá tu rival.'),
          const SizedBox(height: 18),
          TextField(
            controller: _nick,
            maxLength: 16,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: t.text),
            decoration: InputDecoration(
              hintText: 'Tu nombre',
              hintStyle: TextStyle(color: t.textMuted.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
              counterText: '',
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: t.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: t.outline),
              ),
            ),
            onSubmitted: (_) => _finish(tutorial: true),
          ),
        ],
      ),
    ),
  );
}

/// Ilustración animada: seis fichas caen una a una alrededor del Shogun hasta
/// encerrarlo; brilla en rojo y vuelve a empezar.
class _SurroundDemo extends StatefulWidget {
  const _SurroundDemo();

  @override
  State<_SurroundDemo> createState() => _SurroundDemoState();
}

class _SurroundDemoState extends State<_SurroundDemo> with SingleTickerProviderStateMixin {
  static const cycle = 4.4;
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4400))..repeat();
  int _landed = 0;
  bool _firstLoop = true;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      final n = _SurroundPainter.landedAt(_c.value * cycle);
      if (n < _landed) _firstLoop = false; // el ciclo volvió a empezar
      // Solo la primera vuelta suena: después sería ruido.
      if (n > _landed && _firstLoop) {
        SoundBoard.instance.play(n == 6 ? Sfx.stamp : Sfx.place, volume: 0.55);
        Haptics.light();
      }
      _landed = n;
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return AspectRatio(aspectRatio: 1, child: CustomPaint(painter: _SurroundPainter(t, _c)));
  }
}

class _SurroundPainter extends CustomPainter {
  final HexTheme theme;
  final Animation<double> anim;
  _SurroundPainter(this.theme, this.anim) : super(repaint: anim);

  static const _start = 0.5, _gap = 0.32, _fall = 0.3;
  static const _ring = [
    (PieceType.tiger, 0),
    (PieceType.shinobi, 1),
    (PieceType.dragon, 0),
    (PieceType.kunoichi, 1),
    (PieceType.serpent, 0),
    (PieceType.crane, 0),
  ];

  static int landedAt(double s) {
    var n = 0;
    for (var i = 0; i < 6; i++) {
      if (s >= _start + i * _gap + _fall) n++;
    }
    return n;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = anim.value * _SurroundDemoState.cycle;
    final hex = size.width / 7.2;
    final layout = HexLayout(hex, size.center(Offset.zero));
    final fade = s > 3.9 ? (1 - (s - 3.9) / 0.5).clamp(0.0, 1.0) : 1.0;

    // Rejilla tenue de las casillas en juego.
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = theme.grid;
    for (final h in [Hex.origin, ...Hex.origin.neighbors]) {
      canvas.drawPath(layout.hexPath(h, scale: 0.96), grid);
    }

    // Cerco completo: el Shogun brilla en rojo.
    final closed = landedAt(s) == 6;
    if (closed) {
      final pulse = 0.5 + 0.5 * sin(s * 9);
      canvas.drawCircle(
        layout.toPixel(Hex.origin),
        hex * (1.6 + 0.2 * pulse),
        Paint()
          ..color = theme.danger.withValues(alpha: 0.35 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }

    PieceRenderer.draw(
      canvas,
      theme: theme,
      type: PieceType.shogun,
      owner: 1,
      c: layout.toPixel(Hex.origin),
      radius: hex,
      scale: closed ? 0.96 : 1,
    );

    // Orden de pintado por y para que las de abajo tapen a las de arriba.
    final order = [0, 1, 2, 3, 4, 5]..sort((a, b) => Hex.directions[a].r.compareTo(Hex.directions[b].r));
    for (final i in order) {
      final t0 = _start + i * _gap;
      if (s < t0) continue;
      final p = ((s - t0) / _fall).clamp(0.0, 1.0);
      final z = pow(1 - p, 2) * hex * 4;
      // Rebote al asentarse.
      final after = s - t0 - _fall;
      final squash = after > 0 && after < 0.25 ? 1 - 0.07 * sin(after / 0.25 * pi) : 1.0;
      final (type, owner) = _ring[i];
      PieceRenderer.draw(
        canvas,
        theme: theme,
        type: type,
        owner: owner,
        c: layout.toPixel(Hex.directions[i]),
        radius: hex,
        z: z.toDouble(),
        scale: squash,
        opacity: fade * (0.3 + 0.7 * p),
        seed: i,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SurroundPainter old) => old.theme != theme;
}
