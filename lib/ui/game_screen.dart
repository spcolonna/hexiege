import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../tutorial/lessons.dart';
import 'board_painter.dart';
import 'fx/board_fx.dart';
import 'fx/sfx.dart';
import 'hex_layout.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/coach_card.dart';
import 'widgets/emotes.dart';
import 'widgets/player_banner.dart';

/// Función top-level: el closure no captura el State (que no es enviable entre isolates).
Future<List<AiAction>> _thinkInIsolate(GameState snapshot, AiLevel level) =>
    Isolate.run(() => AiPlayer(level).chooseTurn(snapshot));

enum _Mode { idle, placing, moving, effect, jadeRelocate, jadeRelocateTarget, jadeSwap, jadeSwapTarget, kawarimi }

class GameScreen extends StatefulWidget {
  final Faction p0;
  final Faction p1;

  /// Jugador controlado por la IA (null = Pass & Play).
  final int? aiPlayer;
  final AiLevel aiLevel;

  /// Índice de la lección inicial en modo tutorial (null = partida normal).
  final int? lesson;

  const GameScreen({super.key, required this.p0, required this.p1, this.aiPlayer, this.aiLevel = AiLevel.normal})
    : lesson = null;

  /// Tutorial: vos (Shaolin) contra el Sensei, con escenarios armados.
  const GameScreen.tutorial({super.key, this.lesson = 0})
    : p0 = Faction.shaolin,
      p1 = Faction.ninja,
      aiPlayer = 1,
      aiLevel = AiLevel.easy;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const _canvas = 4000.0;
  static const _hexSize = 34.0;
  final _layout = const HexLayout(_hexSize, Offset(_canvas / 2, _canvas / 2));
  final _transform = TransformationController();
  bool _centered = false;
  late final BoardFx _fx;
  final _rng = Random();

  late GameState _game;
  final List<GameState> _history = [];
  late final List<PlayerProfile> _profiles;

  _Mode _mode = _Mode.idle;
  PieceType? _placing;
  Hex? _selected;
  Hex? _effectTo;
  ({Set<Hex> paralyze, Set<Hex> seal})? _effects;
  Set<Hex> _lastMove = {};

  // Emotes visibles por jugador (texto + clave para re-animar).
  final _emote = <Emote?>[null, null];
  final _emoteKey = [0, 0];
  final _emoteTimers = <Timer?>[null, null];
  DateTime _lastEmote = DateTime(2000);

  // Tutorial
  int? _lessonIdx;
  CoachState _coach = CoachState.doing;
  Timer? _retryTimer;
  Lesson? get _lesson => _lessonIdx == null ? null : lessons[_lessonIdx!];
  bool get _tutorial => _lessonIdx != null;

  @override
  void initState() {
    super.initState();
    _fx = BoardFx(this, _layout);
    _lessonIdx = widget.lesson;
    _game = _lesson?.build() ?? GameState(widget.p0, widget.p1);
    if (_tutorial) WidgetsBinding.instance.addPostFrameCallback((_) => _introLesson());
    final nick = AppSettings.instance.nickname;
    _profiles = _tutorial
        ? [
            PlayerProfile(nickname: nick, faction: widget.p0),
            PlayerProfile(nickname: 'Sensei', faction: widget.p1, isAi: true),
          ]
        : widget.aiPlayer == null
        ? [PlayerProfile(nickname: nick, faction: widget.p0), PlayerProfile(nickname: 'Jugador 2', faction: widget.p1)]
        : [
            PlayerProfile(nickname: nick, faction: widget.p0),
            PlayerProfile(nickname: 'Sensei · ${widget.aiLevel.displayName}', faction: widget.p1, isAi: true),
          ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRunAi());
  }

  @override
  void dispose() {
    for (final t in _emoteTimers) {
      t?.cancel();
    }
    _retryTimer?.cancel();
    _fx.dispose();
    _transform.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- derivados

  Set<Hex> get _targets => switch (_mode) {
    _Mode.idle => {},
    _Mode.placing => _game.placementTargets(),
    _Mode.moving => {..._game.moveTargets(_selected!), ..._game.shogunSwapTargets(_selected!)},
    _Mode.effect => {..._effects!.paralyze, ..._effects!.seal},
    _Mode.jadeRelocate => _game.jadeRelocateSources(),
    _Mode.jadeRelocateTarget => _game.jadeRelocateTargets(_selected!),
    _Mode.jadeSwap => _game.jadeSwapSources(),
    _Mode.jadeSwapTarget => _game.jadeSwapTargets(_selected!),
    _Mode.kawarimi => _game.kawarimiTargets(),
  };

  Color _targetColor(HexTheme t) => switch (_mode) {
    _Mode.effect || _Mode.kawarimi || _Mode.jadeRelocate => t.danger,
    _Mode.jadeRelocateTarget || _Mode.jadeSwap || _Mode.jadeSwapTarget => t.gold,
    _ => t.highlight,
  };

  bool _aiThinking = false;

  bool get _isAiTurn => widget.aiPlayer != null && _game.current == widget.aiPlayer;

  /// Bloquea la interacción mientras juega la IA.
  bool get _locked => _isAiTurn || _aiThinking || (_tutorial && _coach != CoachState.doing);

  bool _isHuman(int p) => widget.aiPlayer != p;

  Future<void> _maybeRunAi() async {
    if (!mounted || !_isAiTurn || _game.isOver || _aiThinking) return;
    setState(() => _aiThinking = true);
    final snapshot = _game.copy();
    final level = widget.aiLevel;
    final started = DateTime.now();
    List<AiAction> actions;
    try {
      actions = await _thinkInIsolate(snapshot, level);
    } catch (e) {
      debugPrint('IA en isolate falló ($e); calculando en el hilo principal');
      actions = AiPlayer(level).chooseTurn(snapshot);
    }
    // Pausa mínima para que se perciba el "pensamiento".
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(milliseconds: 650)) {
      await Future.delayed(const Duration(milliseconds: 650) - elapsed);
    }
    for (final a in actions) {
      if (!mounted || _game.isOver) break;
      final dur = _commit((g) => a.apply(g), lastMove: _actionCells(a));
      await Future.delayed(Duration(milliseconds: max(550, (dur * 1000).round() + 300)));
    }
    if (!mounted) return;
    if (!_game.isOver) {
      _maybeAiTaunt();
      _commit((g) => g.endTurn(), lastMove: _lastMove);
    }
    setState(() => _aiThinking = false);
  }

  Set<Hex> _actionCells(AiAction a) => switch (a) {
    PlaceAction(:final at) => {at},
    MoveAction(:final from, :final to) => {from, to},
    SwapAction(:final from, :final to) => {from, to},
    KawarimiAction(:final at) => {at},
    JadeRelocateAction(:final from, :final to) => {from, to},
    JadeSwapAction(:final a, :final b) => {a, b},
  };

  String get _hint {
    if (_game.isOver || (_tutorial && _coach != CoachState.doing)) return '';
    if (_isAiTurn) return '${_profiles[_game.current].nickname} está pensando…';
    return switch (_mode) {
      _Mode.placing => 'Tocá una casilla para colocar ${_placing!.displayName}',
      _Mode.moving => 'Elegí destino para ${_game.board.top(_selected!)!.type.displayName}',
      _Mode.effect =>
        _effects!.paralyze.isNotEmpty
            ? 'Elegí una ficha enemiga para paralizar'
            : 'Elegí dónde dejar el Sello de Sombra',
      _Mode.jadeRelocate => 'Elegí una ficha enemiga perimetral',
      _Mode.jadeRelocateTarget => 'Elegí el nuevo lugar de la ficha enemiga',
      _Mode.jadeSwap => 'Elegí una ficha aliada para intercambiar',
      _Mode.jadeSwapTarget => 'Elegí la ficha aliada adyacente',
      _Mode.kawarimi => 'Elegí una ficha perimetral para devolver a la mano',
      _Mode.idle when _tutorial => '', // el Sensei ya dice qué hacer
      _Mode.idle =>
        _game.mainActionDone
            ? (_game.abilityAvailable ? 'Podés usar la habilidad o terminar el turno' : 'Terminá el turno')
            : _game.mustPlaceLeader
            ? '¡Debés colocar a tu Líder este turno!'
            : !_game.hasAnyMainAction()
            ? 'Sin jugadas posibles: pasá el turno'
            : 'Colocá una ficha o mové una del tablero',
    };
  }

  // ----------------------------------------------------------- acciones

  /// Aplica la acción, la anima y devuelve la duración de la animación (s).
  double _commit(bool Function(GameState g) action, {Set<Hex> lastMove = const {}}) {
    final before = _game.copy();
    if (!action(_game)) return 0;
    _history.add(before);
    final dur = _fx.animate(before, _game);
    if (before.current != _game.current) {
      Haptics.light();
      if (_isHuman(_game.current) && !_game.isOver) {
        Future.delayed(const Duration(milliseconds: 200), () => SoundBoard.instance.play(Sfx.turn, volume: 0.6));
      }
    }
    setState(() {
      _lastMove = lastMove;
      _reset();
    });
    if (_tutorial) {
      _checkLesson(before, after: dur);
    } else if (_game.isOver) {
      _showGameOver(after: dur);
    }
    return dur;
  }

  // ----------------------------------------------------------- tutorial

  /// Las fichas del escenario caen una tras otra sobre el tablero vacío.
  void _introLesson() {
    if (!mounted) return;
    _fx.clear();
    _fx.animate(GameState(widget.p0, widget.p1), _game);
  }

  void _checkLesson(GameState before, {required double after}) {
    final l = _lesson!;
    if (l.done(_history.first, _game)) {
      setState(() => _coach = CoachState.done);
      Future.delayed(Duration(milliseconds: (after * 1000).round() + 120), () {
        if (!mounted) return;
        SoundBoard.instance.play(_game.winner == 0 ? Sfx.victory : Sfx.ability);
        Haptics.medium();
      });
    } else if (_game.mainActionDone || _game.abilityUsedThisTurn || _game.isOver) {
      // Jugada válida pero no la pedida: el Sensei lo marca y rearma la escena.
      setState(() => _coach = CoachState.retry);
      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(milliseconds: (after * 1000).round() + 900), _restartLesson);
    }
  }

  void _restartLesson() {
    if (!mounted || _lesson == null) return;
    _retryTimer?.cancel();
    final fresh = _lesson!.build();
    // Mismos ids que el escenario original: las fichas vuelven volando a su lugar.
    _fx.animate(_game, fresh);
    setState(() {
      _game = fresh;
      _history.clear();
      _lastMove = {};
      _reset();
      _coach = CoachState.doing;
    });
  }

  void _nextLesson() {
    final next = _lessonIdx! + 1;
    if (next >= lessons.length) {
      _finishTutorial();
      return;
    }
    Haptics.select();
    setState(() {
      _lessonIdx = next;
      _coach = CoachState.doing;
      _game = _lesson!.build();
      _history.clear();
      _lastMove = {};
      _reset();
    });
    _introLesson();
  }

  void _finishTutorial() {
    AppSettings.instance.tutorialDone = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.workspace_premium_rounded, color: HexTheme.of(ctx).gold, size: 40),
        title: const Text('¡Listo para jugar!'),
        content: const Text(
          'Ya sabés lo esencial. El resto lo vas a descubrir jugando: '
          'mantené apretada cualquier ficha para leer cómo se mueve.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Menú'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 450),
                  pageBuilder: (_, _, _) =>
                      const GameScreen(p0: Faction.shaolin, p1: Faction.ninja, aiPlayer: 1, aiLevel: AiLevel.easy),
                  transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
                ),
              );
            },
            child: const Text('Jugar vs Sensei'),
          ),
        ],
      ),
    );
  }

  void _reset() {
    _mode = _Mode.idle;
    _placing = null;
    _selected = null;
    _effectTo = null;
    _effects = null;
  }

  void _undo() {
    if (_history.isEmpty || _aiThinking) return;
    _fx.clear();
    Haptics.light();
    setState(() {
      _game = _history.removeLast();
      // Contra la IA, volver hasta un estado en que juega el humano.
      while (widget.aiPlayer != null && _game.current == widget.aiPlayer && _history.isNotEmpty) {
        _game = _history.removeLast();
      }
      _lastMove = {};
      _reset();
    });
  }

  void _endTurn() {
    _commit((g) => g.endTurn(), lastMove: _lastMove);
    _maybeRunAi();
  }

  void _onTapHex(Hex h) {
    if (_game.isOver || _locked) return;
    final targets = _targets;
    switch (_mode) {
      case _Mode.placing:
        if (targets.contains(h)) {
          final t = _placing!;
          _commit((g) => g.place(t, h), lastMove: {h});
          return;
        }
        _trySelect(h);
      case _Mode.moving:
        final from = _selected!;
        if (_game.shogunSwapTargets(from).contains(h)) {
          _commit((g) => g.shogunSwap(from, h), lastMove: {from, h});
          return;
        }
        if (targets.contains(h)) {
          final fx = _game.effectOptions(from, h);
          if (fx.paralyze.isEmpty && fx.seal.isEmpty) {
            _commit((g) => g.move(from, h), lastMove: {from, h});
          } else {
            _mode = _Mode.effect;
            _effectTo = h;
            _effects = fx;
            Haptics.select();
          }
          setState(() {});
          return;
        }
        _trySelect(h);
      case _Mode.effect:
        if (targets.contains(h)) {
          _applyEffect(h);
          return;
        }
      case _Mode.jadeRelocate:
        if (targets.contains(h)) {
          _selected = h;
          _mode = _Mode.jadeRelocateTarget;
          _feedbackSelect();
        }
      case _Mode.jadeRelocateTarget:
        if (targets.contains(h)) {
          final from = _selected!;
          _commit((g) => g.jadeRelocate(from, h), lastMove: {from, h});
          return;
        }
      case _Mode.jadeSwap:
        if (targets.contains(h)) {
          _selected = h;
          _mode = _Mode.jadeSwapTarget;
          _feedbackSelect();
        }
      case _Mode.jadeSwapTarget:
        if (targets.contains(h)) {
          final a = _selected!;
          _commit((g) => g.jadeSwap(a, h), lastMove: {a, h});
          return;
        }
      case _Mode.kawarimi:
        if (targets.contains(h)) {
          _commit((g) => g.kawarimi(h), lastMove: {h});
          return;
        }
      case _Mode.idle:
        _trySelect(h);
    }
    setState(() {});
  }

  void _feedbackSelect() {
    SoundBoard.instance.play(Sfx.select);
    Haptics.select();
  }

  void _applyEffect(Hex? target) {
    final from = _selected!, to = _effectTo!;
    final isParalyze = _effects!.paralyze.isNotEmpty;
    _commit(
      (g) => g.move(from, to, paralyze: isParalyze ? target : null, seal: isParalyze ? null : target),
      lastMove: {from, to},
    );
  }

  void _trySelect(Hex h) {
    final p = _game.board.top(h);
    if (p != null &&
        p.owner == _game.current &&
        (_game.moveTargets(h).isNotEmpty || _game.shogunSwapTargets(h).isNotEmpty)) {
      if (_selected != h) _feedbackSelect();
      _mode = _Mode.moving;
      _selected = h;
      _placing = null;
    } else {
      _reset();
    }
  }

  void _startAbility() {
    if (!_game.abilityAvailable) return;
    Haptics.select();
    if (_game.currentFaction == Faction.ninja) {
      setState(() {
        _reset();
        _mode = _Mode.kawarimi;
      });
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_with),
              title: const Text('Reubicar ficha enemiga'),
              subtitle: Text('${_game.jadeRelocateSources().length} opciones'),
              enabled: _game.jadeRelocateSources().isNotEmpty,
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _reset();
                  _mode = _Mode.jadeRelocate;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Intercambiar fichas aliadas'),
              subtitle: Text('${_game.jadeSwapSources().length} opciones'),
              enabled: _game.jadeSwapSources().isNotEmpty,
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _reset();
                  _mode = _Mode.jadeSwap;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(Hex h) {
    final stack = _game.board.stackAt(h);
    if (stack.isEmpty) return;
    Haptics.select();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final p in stack.reversed) ...[
                Row(
                  children: [
                    PieceChip(type: p.type, owner: p.owner, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${p.type.displayName} — ${_profiles[p.owner].nickname}'
                        '${_game.isParalyzed(p) ? ' (paralizada)' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Padding(padding: const EdgeInsets.only(top: 6, bottom: 12), child: Text(p.type.rulesText)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showGameOver({double after = 0}) async {
    await Future.delayed(Duration(milliseconds: (after * 1000).round() + 450));
    if (!mounted || !_game.isOver) return;
    final w = _game.winner;
    final humanLost = widget.aiPlayer != null && w == widget.aiPlayer;
    SoundBoard.instance.play(humanLost ? Sfx.defeat : Sfx.victory);
    Haptics.heavy();
    if (widget.aiPlayer != null) _showEmote(widget.aiPlayer!, humanLost ? Emote.smug : Emote.gg);
    final text = _game.draw
        ? '¡Empate! Ambos Líderes quedaron rodeados.'
        : '¡Gana ${_profiles[w!].nickname}!\n${_game.factions[w].displayName} rodeó al Líder enemigo.';
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(humanLost ? 'Derrota' : (_game.draw ? 'Empate' : 'Victoria')),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _undo();
            },
            child: const Text('Deshacer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Menú'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _fx.clear();
              setState(() {
                _game = GameState(widget.p0, widget.p1);
                _aiThinking = false;
                _history.clear();
                _lastMove = {};
                _reset();
              });
              WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRunAi());
            },
            child: const Text('Revancha'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- emotes

  void _showEmote(int player, Emote e) {
    SoundBoard.instance.play(Sfx.emote);
    _emoteTimers[player]?.cancel();
    setState(() {
      _emote[player] = e;
      _emoteKey[player]++;
    });
    _emoteTimers[player] = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _emote[player] = null);
    });
  }

  void _pickEmote(int player) {
    if (DateTime.now().difference(_lastEmote) < const Duration(seconds: 2)) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final e in Emote.values)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(ctx);
                    _lastEmote = DateTime.now();
                    _showEmote(player, e);
                    _maybeAiReply(e);
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: HexTheme.of(ctx).outline, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmoteGlyph(e, size: 30),
                        const SizedBox(height: 2),
                        Text(e.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeAiReply(Emote e) {
    final ai = widget.aiPlayer;
    if (ai == null || _rng.nextDouble() > 0.6) return;
    final reply = switch (e) {
      Emote.hello => Emote.hello,
      Emote.gg => Emote.gg,
      Emote.smug || Emote.fire => Emote.oops,
      Emote.oops => Emote.smug,
      Emote.nice => Emote.nice,
      _ => Emote.values[_rng.nextInt(Emote.values.length)],
    };
    Future.delayed(Duration(milliseconds: 900 + _rng.nextInt(800)), () {
      if (mounted) _showEmote(ai, reply);
    });
  }

  /// La IA provoca cuando aprieta el cerco sobre tu Líder.
  void _maybeAiTaunt() {
    final ai = widget.aiPlayer;
    if (ai == null) return;
    final leader = _game.board.locateLeader(1 - ai);
    if (leader != null && _game.board.occupiedNeighbors(leader) >= 5 && _rng.nextDouble() < 0.5) {
      _showEmote(ai, _rng.nextBool() ? Emote.fire : Emote.smug);
    }
  }

  // ----------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final g = _game;
    final targets = _targets;
    _fx.ambient = _selected != null || targets.isNotEmpty || _hasSiege || _spotlight.isNotEmpty;
    if (_fx.ambient) _fx.wake();
    return Scaffold(
      body: ArenaBackdrop(
        accent: HexTheme.faction(g.currentFaction),
        child: Stack(
          children: [
            Positioned.fill(child: _board(t, targets)),
            SafeArea(
              child: Column(
                children: [
                  _toolbar(t),
                  if (_tutorial) _coachCard() else _banner(1, top: true),
                  const Spacer(),
                  _hintPill(t),
                  const SizedBox(height: 8),
                  _bottomSection(t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Hex> get _spotlight => _tutorial && _coach == CoachState.doing ? _lesson!.spotlight : const {};

  Widget _coachCard() {
    final l = _lesson!;
    return CoachCard(
      step: _lessonIdx! + 1,
      total: lessons.length,
      title: l.title,
      body: l.body,
      goal: l.goal,
      retry: l.retry,
      state: _coach,
      onNext: _nextLesson,
    );
  }

  bool get _hasSiege {
    for (var p = 0; p < 2; p++) {
      final h = _game.board.locateLeader(p);
      if (h != null && _game.board.occupiedNeighbors(h) >= 4) return true;
    }
    return false;
  }

  Widget _toolbar(HexTheme t) {
    final dark = t.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
        children: [
          _roundButton(t, Icons.arrow_back_rounded, 'Menú', () => Navigator.pop(context)),
          const Spacer(),
          _roundButton(
            t,
            AppSettings.instance.sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            'Sonido',
            () => setState(() => AppSettings.instance.sound = !AppSettings.instance.sound),
          ),
          const SizedBox(width: 6),
          _roundButton(
            t,
            dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            dark ? 'Tema claro' : 'Tema oscuro',
            () {
              Haptics.select();
              AppSettings.instance.toggleBrightness(context);
            },
          ),
          const SizedBox(width: 6),
          if (_tutorial)
            _roundButton(t, Icons.replay_rounded, 'Reiniciar lección', _restartLesson)
          else
            _roundButton(t, Icons.undo_rounded, 'Deshacer', _history.isEmpty || _aiThinking ? null : _undo),
        ],
      ),
    );
  }

  Widget _roundButton(HexTheme t, IconData icon, String tip, VoidCallback? onTap) {
    return Material(
      color: t.surface,
      shape: CircleBorder(side: BorderSide(color: t.outline)),
      child: IconButton(
        tooltip: tip,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => RotationTransition(
            turns: Tween(begin: 0.6, end: 1.0).animate(a),
            child: FadeTransition(opacity: a, child: c),
          ),
          child: Icon(icon, key: ValueKey(icon), color: onTap == null ? t.outline : t.text, size: 22),
        ),
      ),
    );
  }

  Widget _banner(int p, {required bool top}) {
    final g = _game;
    final handCount = g.hands[p].values.fold(0, (a, b) => a + b);
    final canEmote = !_tutorial && _isHuman(p) && (widget.aiPlayer != null || p == g.current);
    return PlayerBanner(
      profile: _profiles[p],
      owner: p,
      active: g.current == p && !g.isOver,
      top: top,
      handCount: handCount,
      cooldown: g.cooldowns[p],
      emote: _emote[p],
      emoteKey: _emoteKey[p],
      onEmote: canEmote ? () => _pickEmote(p) : null,
    );
  }

  Widget _hintPill(HexTheme t) {
    final text = _hint;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (c, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a),
          child: c,
        ),
      ),
      child: text.isEmpty
          ? const SizedBox(height: 32)
          : Container(
              key: ValueKey(text),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isAiTurn) ...[
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: t.textMuted),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.text, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _board(HexTheme t, Set<Hex> targets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_centered) {
          _centered = true;
          // Centrado en la zona visible entre las barras superior e inferior.
          _transform.value = Matrix4.identity()
            ..translateByDouble(
              constraints.maxWidth / 2 - _canvas / 2,
              constraints.maxHeight / 2 - _canvas / 2 + (_tutorial ? 50 : -20),
              0,
              1,
            );
        }
        return InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.4,
          maxScale: 2.5,
          child: GestureDetector(
            onTapUp: (d) => _onTapHex(_layout.fromPixel(d.localPosition)),
            onLongPressStart: (d) => _showInfo(_layout.fromPixel(d.localPosition)),
            child: CustomPaint(
              size: const Size(_canvas, _canvas),
              painter: BoardPainter(
                game: _game,
                layout: _layout,
                theme: t,
                fx: _fx,
                selected: _mode == _Mode.effect ? _effectTo : _selected,
                targets: targets,
                targetColor: _targetColor(t),
                lastMove: _lastMove,
                spotlight: _spotlight,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomSection(HexTheme t) {
    final g = _game;
    // Contra la IA la mano es siempre la tuya; en Pass & Play, la del turno.
    final me = widget.aiPlayer != null ? 1 - widget.aiPlayer! : g.current;
    final faction = g.factions[me];
    final color = HexTheme.faction(faction);
    final allowed = _lesson?.hand;
    final placeable = me == g.current
        ? g.placeableTypes().where((p) => allowed == null || allowed.contains(p)).toSet()
        : const <PieceType>{};
    final hand = g.hands[me].entries.where((e) => e.value > 0).toList();
    final cd = g.cooldowns[me];
    final abilityReady = me == g.current && g.abilityAvailable && !_locked && (!_tutorial || _lesson!.ability);
    final showHand = !_tutorial || hand.any((e) => placeable.contains(e.key));
    final showActions = !_tutorial || _lesson!.ability;
    if (!showHand && !showActions) return _banner(0, top: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _banner(0, top: false),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 2, 10, 6),
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.outline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHand) ...[
                SizedBox(
                  height: 84,
                  child: hand.isEmpty
                      ? Center(
                          child: Text('Mano vacía', style: TextStyle(color: t.textMuted)),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final e in hand)
                              if (!_tutorial || placeable.contains(e.key))
                                _handItem(t, e.key, e.value, me, enabled: placeable.contains(e.key) && !_locked),
                          ],
                        ),
                ),
                if (showActions) const SizedBox(height: 6),
              ],
              if (showActions)
                Row(
                  children: [
                    if (_mode == _Mode.effect)
                      Expanded(
                        child: OutlinedButton(onPressed: () => _applyEffect(null), child: const Text('Omitir efecto')),
                      )
                    else
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: abilityReady ? color : t.outline),
                          ),
                          onPressed: abilityReady ? _startAbility : null,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(
                            me == g.current && g.abilityUsedThisTurn
                                ? 'Habilidad usada'
                                : cd > 0
                                ? '${faction.abilityName} ($cd)'
                                : faction.abilityName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (_mode != _Mode.idle && _mode != _Mode.effect)
                      IconButton(onPressed: () => setState(_reset), icon: const Icon(Icons.close)),
                    if (!_tutorial)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                        onPressed: g.canEndTurn && _mode != _Mode.effect && !_locked ? _endTurn : null,
                        child: Text(g.mainActionDone ? 'Terminar turno' : 'Pasar'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _handItem(HexTheme t, PieceType type, int count, int owner, {required bool enabled}) {
    final selected = _mode == _Mode.placing && _placing == type;
    return GestureDetector(
      onTap: enabled
          ? () => setState(() {
              _reset();
              if (!selected) {
                _mode = _Mode.placing;
                _placing = type;
                SoundBoard.instance.play(Sfx.tick);
                Haptics.select();
              }
            })
          : null,
      onLongPress: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(title: Text(type.displayName), content: Text(type.rulesText)),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.35,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 70,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: selected ? t.highlight.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? t.highlight : t.outline, width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // La ficha elegida "se levanta" de la mano.
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: selected ? 0.4 : 0),
                    duration: const Duration(milliseconds: 260),
                    curve: selected ? Curves.easeOutBack : Curves.easeIn,
                    builder: (_, lift, _) => PieceChip(type: type, owner: owner, size: 19, lift: lift),
                  ),
                  if (count > 1)
                    Positioned(
                      right: -12,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: t.text, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '×$count',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: t.surfaceHigh),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                type.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: t.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
