import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../engine/pieces.dart';
import '../match/ladder.dart';
import '../match/matchmaker.dart';
import 'fx/sfx.dart';
import 'game_screen.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';
import 'theme/ui_style.dart';
import 'widgets/rank_badge.dart';
import 'widgets/skin_kit.dart';

/// Búsqueda de partida: radar mientras se busca, presentación del rival y
/// cuenta regresiva. No sabe si el rival es humano o IA: eso lo decide el
/// [Matchmaker].
class MatchmakingScreen extends StatefulWidget {
  final Faction faction;
  final Matchmaker? matchmaker;

  const MatchmakingScreen({super.key, required this.faction, this.matchmaker});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> with TickerProviderStateMixin {
  late final _radar = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  late final _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  StreamSubscription<MatchmakingEvent>? _sub;
  Timer? _clock;
  Timer? _countdownTimer;
  final _started = DateTime.now();
  int _elapsed = 0;
  int _range = 50;
  MatchFound? _match;
  int _countdown = 3;

  LadderRecord get _record => AppSettings.instance.ladder;

  @override
  void initState() {
    super.initState();
    final mm = widget.matchmaker ?? BotMatchmaker();
    _sub = mm
        .search(MatchRequest(nickname: AppSettings.instance.nickname, faction: widget.faction, record: _record))
        .listen(_onEvent);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = DateTime.now().difference(_started).inSeconds);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _clock?.cancel();
    _countdownTimer?.cancel();
    _radar.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _onEvent(MatchmakingEvent e) {
    if (!mounted) return;
    switch (e) {
      case Searching(:final range):
        setState(() => _range = range);
      case Found(:final match):
        _clock?.cancel();
        SoundBoard.instance.play(Sfx.turn);
        Haptics.heavy();
        setState(() => _match = match);
        _reveal.forward();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          if (_countdown <= 1) {
            timer.cancel();
            _start();
            return;
          }
          SoundBoard.instance.play(Sfx.tick);
          Haptics.select();
          setState(() => _countdown--);
        });
    }
  }

  void _start() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => GameScreen.ranked(match: _match!),
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 1.06, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
  }

  void _cancel() {
    Haptics.select();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    return Scaffold(
      body: ArenaBackdrop(
        accent: HexTheme.faction(widget.faction),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _match == null ? _searching(t) : _found(t, _match!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searching(HexTheme t) {
    final skin = Skin.of(context);
    final r = _record.rating;
    final mm = (_elapsed ~/ 60).toString();
    final ss = (_elapsed % 60).toString().padLeft(2, '0');
    return Column(
      key: const ValueKey('searching'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: _radar,
            builder: (_, child) => CustomPaint(
              painter: _RadarPainter(_radar.value, t.gold, HexTheme.faction(widget.faction)),
              child: child,
            ),
            child: Center(
              child: PieceChip(
                type: widget.faction == Faction.shaolin ? PieceType.monk : PieceType.shogun,
                owner: 0,
                size: 34,
                lift: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(tr('mm.searching'), style: skin.display(30, color: t.text)),
        const SizedBox(height: 6),
        Text(
          '$mm:$ss',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: t.textMuted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _range > 50
                ? tr('mm.widening', {'lo': r - _range, 'hi': r + _range})
                : tr('mm.range', {'lo': r - _range, 'hi': r + _range}),
            key: ValueKey(_range),
            style: TextStyle(fontSize: 13, color: t.textMuted),
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(width: 200, child: SkinButton(label: tr('mm.cancel'), onPressed: _cancel)),
      ],
    );
  }

  Widget _found(HexTheme t, MatchFound m) {
    final skin = Skin.of(context);
    final me = _record;
    final o = m.opponent;
    final slide = CurvedAnimation(parent: _reveal, curve: Curves.easeOutBack);
    return Column(
      key: const ValueKey('found'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(tr('mm.found'), style: skin.display(30, color: t.text)),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: slide,
          builder: (_, _) => Row(
            children: [
              Expanded(
                child: Transform.translate(
                  offset: Offset(-120 * (1 - slide.value), 0),
                  child: Opacity(
                    opacity: _reveal.value.clamp(0, 1),
                    child: _PlayerCard(
                      nickname: AppSettings.instance.nickname,
                      avatar: m.yourFaction == Faction.shaolin ? '僧' : '将',
                      faction: m.yourFaction,
                      rating: me.rating,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: Curves.elasticOut.transform(((_reveal.value - 0.3) / 0.7).clamp(0, 1)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: KanjiBadge('対', size: 40, color: t.danger),
                ),
              ),
              Expanded(
                child: Transform.translate(
                  offset: Offset(120 * (1 - slide.value), 0),
                  child: Opacity(
                    opacity: _reveal.value.clamp(0, 1),
                    child: _PlayerCard(nickname: o.nickname, avatar: o.avatar, faction: o.faction, rating: o.rating),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text(
          m.youFirst ? tr('mm.youFirst') : tr('mm.theyFirst', {'name': o.nickname}),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: t.text),
        ),
        const SizedBox(height: 22),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Text(
            '$_countdown',
            key: ValueKey(_countdown),
            style: skin.display(64, color: t.gold),
          ),
        ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String nickname;
  final String avatar;
  final Faction faction;
  final int rating;
  const _PlayerCard({required this.nickname, required this.avatar, required this.faction, required this.rating});

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final color = HexTheme.faction(faction);
    final rank = Rank.of(rating);
    return SkinPanel(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
      highlight: color,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [Color.lerp(color, Colors.white, 0.25)!, Color.lerp(color, Colors.black, 0.35)!],
              ),
              border: Border.all(color: t.surfaceHigh, width: 2),
            ),
            child: Text(
              avatar,
              style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800, height: 1),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: t.text),
          ),
          Text(
            faction.displayName,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RankBadge(rank: rank, size: 22),
              const SizedBox(width: 6),
              Text(
                '$rating',
                style: TextStyle(fontWeight: FontWeight.w800, color: t.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ondas hexagonales que salen del centro, como un radar.
class _RadarPainter extends CustomPainter {
  final double t;
  final Color gold;
  final Color accent;
  _RadarPainter(this.t, this.gold, this.accent);

  Path _hex(Offset c, double r, double rot) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = pi / 3 * i + rot;
      final v = c + Offset(cos(a), sin(a)) * r;
      i == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      maxR * 0.45,
      Paint()
        ..color = accent.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxR * 0.2),
    );
    for (var k = 0; k < 3; k++) {
      final p = (t + k / 3) % 1;
      canvas.drawPath(
        _hex(c, maxR * (0.3 + 0.7 * p), p * 0.6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + 2.5 * (1 - p)
          ..color = gold.withValues(alpha: 0.75 * (1 - p)),
      );
    }
    // Barrido giratorio.
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        transform: GradientRotation(t * 2 * pi),
        colors: [Colors.transparent, gold.withValues(alpha: 0.0), gold.withValues(alpha: 0.28)],
        stops: const [0, 0.75, 1],
      ).createShader(Rect.fromCircle(center: c, radius: maxR));
    canvas.drawCircle(c, maxR * 0.98, sweep);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.t != t;
}
