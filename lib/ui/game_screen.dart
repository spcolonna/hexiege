import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import '../match/ladder.dart';
import '../match/matchmaker.dart';
import '../solo/catalog.dart';
import '../solo/solver.dart';
import '../tutorial/lessons.dart';
import 'board_painter.dart';
import 'fx/board_fx.dart';
import 'fx/sfx.dart';
import 'hex_layout.dart';
import 'matchmaking_screen.dart';
import 'piece_chip.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/coach_card.dart';
import 'widgets/emotes.dart';
import 'widgets/player_banner.dart';
import 'widgets/ranked_result.dart';
import 'widgets/stage_card.dart';
import 'widgets/tabletop.dart';

/// Función top-level: el closure no captura el State (que no es enviable entre isolates).
Future<List<AiAction>> _thinkInIsolate(GameState snapshot, AiLevel level, Map<String, int> seen) =>
    Isolate.run(() => AiPlayer(level, seen: seen).chooseTurn(snapshot));

/// Defensa del rival en un problema: busca la respuesta que evita el cerco.
Future<List<AiAction>> _defendInIsolate(GameState snapshot, int attackerTurns) =>
    Isolate.run(() => defend(snapshot, attackerTurns));

enum _Mode { idle, placing, moving, effect, jadeRelocate, jadeRelocateTarget, jadeSwap, jadeSwapTarget, kawarimi }

class GameScreen extends StatefulWidget {
  final Faction p0;
  final Faction p1;

  /// Jugador controlado por la IA (null = Pass & Play).
  final int? aiPlayer;
  final AiLevel aiLevel;

  /// Índice de la lección inicial en modo tutorial (null = partida normal).
  final int? lesson;

  /// Partida por puntos (null = casual).
  final MatchFound? match;

  /// Problema, desafío o batalla de campaña (null = partida libre).
  final Stage? stage;

  /// Etapa que sigue a [stage] en su lista, para el botón "Siguiente".
  final Stage? nextStage;

  const GameScreen({super.key, required this.p0, required this.p1, this.aiPlayer, this.aiLevel = AiLevel.normal})
    : lesson = null,
      match = null,
      stage = null,
      nextStage = null;

  /// Contenido de un jugador: vos sos el jugador 0 y la IA el 1.
  GameScreen.stage({super.key, required Stage this.stage, this.nextStage})
    : p0 = stage.you,
      p1 = stage.opp,
      aiPlayer = 1,
      aiLevel = stage.level,
      lesson = null,
      match = null;

  /// Tutorial: vos (Shaolin) contra el Sensei, con escenarios armados.
  const GameScreen.tutorial({super.key, this.lesson = 0})
    : p0 = Faction.shaolin,
      p1 = Faction.ninja,
      aiPlayer = 1,
      aiLevel = AiLevel.easy,
      match = null,
      stage = null,
      nextStage = null;

  /// Partida por puntos contra el rival del emparejamiento. Quien empieza
  /// juega con las fichas claras (jugador 0).
  GameScreen.ranked({super.key, required MatchFound this.match})
    : p0 = match.youFirst ? match.yourFaction : match.opponent.faction,
      p1 = match.youFirst ? match.opponent.faction : match.yourFaction,
      aiPlayer = match.youFirst ? 1 : 0,
      aiLevel = match.opponent.bot ?? AiLevel.normal,
      lesson = null,
      stage = null,
      nextStage = null;

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

  /// Jugador cuyas casillas muestra [_lastMove] (se acumulan durante su turno).

  /// Registro de la partida y largo que tenía en cada estado de [_history].
  final List<({int round, GameEvent e})> _log = [];
  final List<int> _logLens = [];

  /// Aviso de efecto visible (eventos + clave para re-animar).
  List<GameEvent> _notice = const [];
  int _noticeKey = 0;
  Timer? _noticeTimer;

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

  // Partida por puntos
  bool get _ranked => widget.match != null;
  bool _reported = false;
  bool _resigned = false;
  LadderRecord? _ladderBefore;

  // Problemas, desafíos y campaña
  Stage? get _stage => widget.stage;
  bool get _staged => widget.stage != null;
  late GameState _stageStart;
  bool _stageOver = false;

  /// Asiento del jugador local (abajo) y del rival (arriba).
  int get _mySeat => widget.aiPlayer == null ? 0 : 1 - widget.aiPlayer!;
  int get _oppSeat => 1 - _mySeat;

  @override
  void initState() {
    super.initState();
    _fx = BoardFx(this, _layout);
    _lessonIdx = widget.lesson;
    _game = _lesson?.build() ?? _stage?.build() ?? GameState(widget.p0, widget.p1);
    _stageStart = _game.copy();
    if (_tutorial || _staged) WidgetsBinding.instance.addPostFrameCallback((_) => _introScene());
    if (_staged && !_stage!.isPuzzle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showStageIntro());
    }
    final nick = AppSettings.instance.nickname;
    final m = widget.match;
    if (m != null) {
      final me = PlayerProfile(nickname: nick, faction: m.yourFaction, rating: AppSettings.instance.ladder.rating);
      final o = m.opponent;
      final opp = PlayerProfile(nickname: o.nickname, faction: o.faction, avatar: o.avatar, rating: o.rating);
      _profiles = _mySeat == 0 ? [me, opp] : [opp, me];
    } else {
      _profiles = _staged
          ? [
              PlayerProfile(nickname: nick, faction: widget.p0),
              PlayerProfile(
                nickname: _stage!.isPuzzle
                    ? tr('common.sensei')
                    : '${tr('common.sensei')} · ${widget.aiLevel.displayName}',
                faction: widget.p1,
                isAi: true,
              ),
            ]
          : _tutorial
          ? [
              PlayerProfile(nickname: nick, faction: widget.p0),
              PlayerProfile(nickname: tr('common.sensei'), faction: widget.p1, isAi: true),
            ]
          : widget.aiPlayer == null
          ? [
              PlayerProfile(nickname: nick, faction: widget.p0),
              PlayerProfile(nickname: tr('common.player2'), faction: widget.p1),
            ]
          : [
              PlayerProfile(nickname: nick, faction: widget.p0),
              PlayerProfile(
                nickname: '${tr('common.sensei')} · ${widget.aiLevel.displayName}',
                faction: widget.p1,
                isAi: true,
              ),
            ];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRunAi());
  }

  @override
  void dispose() {
    for (final t in _emoteTimers) {
      t?.cancel();
    }
    _retryTimer?.cancel();
    _noticeTimer?.cancel();
    _fx.dispose();
    _transform.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- derivados

  Set<Hex> get _targets => switch (_mode) {
    _Mode.idle => {},
    _Mode.placing => _game.placementTargets(),
    _Mode.moving => {..._game.moveTargets(_selected!), ..._swapTargets},
    _Mode.effect => {..._effects!.paralyze, ..._effects!.seal},
    _Mode.jadeRelocate => _game.jadeRelocateSources(),
    _Mode.jadeRelocateTarget => _game.jadeRelocateTargets(_selected!),
    _Mode.jadeSwap => _game.jadeSwapSources(),
    _Mode.jadeSwapTarget => _game.jadeSwapTargets(_selected!),
    _Mode.kawarimi => _game.kawarimiTargets(),
  };

  /// Shinobis con los que el Shogun seleccionado puede intercambiarse.
  Set<Hex> get _swapTargets => _mode == _Mode.moving ? _game.shogunSwapTargets(_selected!) : const {};

  Color _targetColor(HexTheme t) => switch (_mode) {
    _Mode.effect || _Mode.kawarimi || _Mode.jadeRelocate => t.danger,
    _Mode.jadeRelocateTarget || _Mode.jadeSwap || _Mode.jadeSwapTarget => t.gold,
    _ => t.highlight,
  };

  bool _aiThinking = false;

  /// Cambia al reiniciar la partida: descarta lo que la IA estaba pensando.
  int _epoch = 0;

  /// Posiciones que dejó la IA (evita que repita idas y vueltas).
  final Map<String, int> _aiSeen = {};

  bool get _isAiTurn => widget.aiPlayer != null && _game.current == widget.aiPlayer;

  /// Bloquea la interacción mientras juega la IA.
  bool get _locked => _isAiTurn || _aiThinking || _resigned || _stageOver || (_tutorial && _coach != CoachState.doing);

  bool _isHuman(int p) => widget.aiPlayer != p;

  Future<void> _maybeRunAi() async {
    if (!mounted || !_isAiTurn || _game.isOver || _aiThinking) return;
    setState(() => _aiThinking = true);
    final snapshot = _game.copy();
    final level = widget.aiLevel;
    final started = DateTime.now();
    final epoch = _epoch;
    final puzzleTurns = _stage?.turnsLeft(_stageStart, snapshot);
    List<AiAction> actions;
    try {
      actions = puzzleTurns != null
          ? await _defendInIsolate(snapshot, puzzleTurns)
          : await _thinkInIsolate(snapshot, level, Map.of(_aiSeen));
    } catch (e) {
      debugPrint('IA en isolate falló ($e); calculando en el hilo principal');
      actions = puzzleTurns != null
          ? defend(snapshot, puzzleTurns)
          : AiPlayer(level, seen: Map.of(_aiSeen)).chooseTurn(snapshot);
    }
    if (epoch != _epoch) return; // se reinició la partida mientras pensaba
    // Pausa mínima para que se perciba el "pensamiento". En partidas por
    // puntos el rival se toma tiempos de persona.
    final minThink = Duration(milliseconds: _ranked ? 900 + _rng.nextInt(1800) : 650);
    final elapsed = DateTime.now().difference(started);
    if (elapsed < minThink) {
      await Future.delayed(minThink - elapsed);
    }
    if (mounted && !_game.isOver && !_resigned && epoch == _epoch) {
      final a = actions.firstOrNull;
      final dur = _commit((g) => a == null ? g.pass() : a.apply(g));
      final key = _game.board.key;
      _aiSeen[key] = (_aiSeen[key] ?? 0) + 1;
      if (!_game.isOver) _maybeAiTaunt();
      await Future.delayed(Duration(milliseconds: max(550, (dur * 1000).round() + 300)));
    }
    if (!mounted || epoch != _epoch) return;
    setState(() => _aiThinking = false);
    _autoPassIfStuck();
  }

  /// Si al humano le toca y no tiene ninguna acción legal, pasa solo.
  void _autoPassIfStuck() {
    if (_game.isOver || _tutorial || !_isHuman(_game.current) || !_game.canPass) return;
    final epoch = _epoch;
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted || epoch != _epoch || _aiThinking || _resigned || _stageOver) return;
      if (!_isHuman(_game.current) || !_game.canPass) return;
      _commit((g) => g.pass());
    });
  }

  String get _hint {
    if (_game.isOver || _resigned || _stageOver || (_tutorial && _coach != CoachState.doing)) return '';
    if (_isAiTurn) return tr('game.thinking', {'name': _profiles[_game.current].nickname});
    return switch (_mode) {
      _Mode.placing => tr('game.hint.place', {'piece': _placing!.displayName}),
      _Mode.moving when _swapTargets.isNotEmpty => tr('game.hint.shogunSwap'),
      _Mode.moving => tr('game.hint.moveTo', {'piece': _game.board.top(_selected!)!.type.displayName}),
      _Mode.effect => _effects!.paralyze.isNotEmpty ? tr('game.hint.paralyze') : tr('game.hint.seal'),
      _Mode.jadeRelocate => tr('game.hint.jadeRelocate'),
      _Mode.jadeRelocateTarget => tr('game.hint.jadeRelocateTarget'),
      _Mode.jadeSwap => tr('game.hint.jadeSwap'),
      _Mode.jadeSwapTarget => tr('game.hint.jadeSwapTarget'),
      _Mode.kawarimi => tr('game.hint.kawarimi'),
      _Mode.idle when _tutorial => '', // el Sensei ya dice qué hacer
      _Mode.idle =>
        _game.mustPlaceLeader
            ? tr('game.hint.mustLeader')
            : !_game.hasAnyAction()
            ? tr('game.hint.noMoves')
            : _game.abilityAvailable
            ? tr('game.hint.withAbility')
            : tr('game.hint.idle'),
    };
  }

  // ----------------------------------------------------------- acciones

  /// Aplica la acción, la anima y devuelve la duración de la animación (s).
  double _commit(bool Function(GameState g) action) {
    final before = _game.copy();
    _game.recordEvents = true;
    if (!action(_game)) return 0;
    _history.add(before);
    _logLens.add(_log.length);
    final events = _game.lastEvents;
    for (final e in events) {
      _log.add((round: before.round, e: e));
    }
    final dur = _fx.animate(before, _game);
    if (before.current != _game.current) {
      Haptics.light();
      if (_isHuman(_game.current) && !_game.isOver) {
        Future.delayed(const Duration(milliseconds: 200), () => SoundBoard.instance.play(Sfx.turn, volume: 0.6));
      }
    }
    setState(() {
      if (events.isNotEmpty && events.first is! Passed) {
        // La jugada completa del turno: acción y efectos.
        _lastMove = {for (final e in events) ...e.cells};
      }
      _reset();
    });
    final notable = events.where((e) => e.notable).toList();
    if (notable.isNotEmpty) _showNotice(notable, after: dur);
    if (_tutorial) {
      _checkLesson(before, after: dur);
    } else if (_staged) {
      _checkStage(after: dur);
    } else if (_game.isOver) {
      _showGameOver(after: dur);
    }
    if (!_tutorial && !_game.isOver && !before.inSiege && _game.inSiege) _announceSiege();
    if (before.current != _game.current && !_game.isOver) {
      if (_isAiTurn) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRunAi());
      } else if (!_aiThinking) {
        _autoPassIfStuck();
      }
    }
    return dur;
  }

  /// Muestra qué efectos se dispararon, cuando la animación ya los mostró.
  void _showNotice(List<GameEvent> events, {double after = 0}) {
    _noticeTimer?.cancel();
    _noticeTimer = Timer(Duration(milliseconds: (after * 600).round()), () {
      if (!mounted) return;
      setState(() {
        _notice = events;
        _noticeKey++;
      });
      _noticeTimer = Timer(Duration(milliseconds: 2600 + 900 * events.length), () {
        if (mounted) setState(() => _notice = const []);
      });
    });
  }

  void _clearHistory() {
    _history.clear();
    _log.clear();
    _logLens.clear();
    _lastMove = {};
    _noticeTimer?.cancel();
    _notice = const [];
  }

  GameState _popHistory() {
    _log.length = _logLens.removeLast();
    return _history.removeLast();
  }

  void _announceSiege() {
    Haptics.heavy();
    SoundBoard.instance.play(Sfx.ability);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Text(tr('game.siegeStarts')),
      ),
    );
  }

  // ----------------------------------------------------------- tutorial

  /// Las fichas del escenario caen una tras otra sobre el tablero vacío.
  void _introScene() {
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
    } else if (_game.ply != before.ply || _game.isOver) {
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
      _clearHistory();
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
      _clearHistory();
      _reset();
    });
    _introScene();
  }

  // ----------------------------------------------------------- un jugador

  void _checkStage({required double after}) {
    if (_stageOver) return;
    final ok = _stage!.verdict(_stageStart, _game);
    if (ok == null) return;
    setState(() {
      _stageOver = true;
      _reset();
    });
    if (ok) AppSettings.instance.markCleared(_stage!.id);
    Future.delayed(Duration(milliseconds: (after * 1000).round() + 500), () {
      if (!mounted) return;
      SoundBoard.instance.play(ok ? Sfx.victory : Sfx.defeat);
      Haptics.heavy();
      _showStageResult(ok);
    });
  }

  /// Presentación de un desafío o batalla: historia y objetivo.
  void _showStageIntro() {
    if (!mounted) return;
    final s = _stage!;
    final t = HexTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          s.kind == StageKind.campaign ? Icons.auto_stories_rounded : Icons.emoji_events_outlined,
          color: t.gold,
          size: 36,
        ),
        title: Text(s.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.intro),
            const SizedBox(height: 12),
            Text(
              s.goal,
              style: TextStyle(fontWeight: FontWeight.w800, color: t.text),
            ),
            const SizedBox(height: 4),
            Text(
              tr('game.rivalLine', {'faction': widget.p1.displayName, 'level': widget.aiLevel.displayName}),
              style: TextStyle(fontSize: 12, color: t.textMuted),
            ),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common.start')))],
      ),
    );
  }

  String _stageWinText() {
    final s = _stage!;
    if (s.kind == StageKind.campaign && widget.nextStage == null) {
      return tr(_game.inSiege ? 'stage.campaignDone.siege' : 'stage.campaignDone');
    }
    if (!s.isPuzzle) return tr(_game.inSiege ? 'stage.won.siege' : 'stage.won', {'title': s.title});
    final used = s.puzzleTurns! - s.turnsLeft(_stageStart, _game)! + 1;
    return trN('stage.closedIn', used);
  }

  String _stageFailText() {
    if (_game.endedByLimit) return tr('stage.lost.limit');
    if (_game.draw) return tr('stage.lost.draw');
    if (_game.winner == 1) return tr('stage.lost.surrounded');
    return tr(_stage!.isPuzzle ? 'stage.lost.puzzle' : 'stage.lost');
  }

  void _showStageResult(bool ok) {
    final next = widget.nextStage;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          ok ? Icons.workspace_premium_rounded : Icons.replay_rounded,
          color: ok ? HexTheme.of(ctx).gold : HexTheme.of(ctx).textMuted,
          size: 40,
        ),
        title: Text(tr(ok ? 'stage.cleared' : 'stage.notThisTime')),
        content: Text(ok ? _stageWinText() : _stageFailText()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(tr('common.back')),
          ),
          if (ok && next != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (_, _, _) => GameScreen.stage(stage: next, nextStage: stageAfter(next)),
                    transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
                  ),
                );
              },
              child: Text(tr('common.next')),
            )
          else
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _restartStage();
              },
              child: Text(tr(ok ? 'common.playAgain' : 'common.retry')),
            ),
        ],
      ),
    );
  }

  void _restartStage() {
    if (!mounted || !_staged) return;
    final fresh = _stage!.build();
    _epoch++;
    _fx.animate(_game, fresh);
    setState(() {
      _game = fresh;
      _stageStart = fresh.copy();
      _stageOver = false;
      _aiThinking = false;
      _aiSeen.clear();
      _clearHistory();
      _reset();
    });
  }

  void _finishTutorial() {
    AppSettings.instance.tutorialDone = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.workspace_premium_rounded, color: HexTheme.of(ctx).gold, size: 40),
        title: Text(tr('tutorial.readyTitle')),
        content: Text(tr('tutorial.readyBody')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(tr('common.menu')),
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
            child: Text(tr('tutorial.playSensei')),
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
      _game = _popHistory();
      // Contra la IA, volver hasta un estado en que juega el humano.
      while (widget.aiPlayer != null && _game.current == widget.aiPlayer && _history.isNotEmpty) {
        _game = _popHistory();
      }
      _lastMove = {};
      _notice = const [];
      _reset();
    });
  }

  void _onTapHex(Hex h) {
    if (_game.isOver || _locked) return;
    final targets = _targets;
    switch (_mode) {
      case _Mode.placing:
        if (targets.contains(h)) {
          final t = _placing!;
          _commit((g) => g.place(t, h));
          return;
        }
        _trySelect(h);
      case _Mode.moving:
        final from = _selected!;
        if (_game.shogunSwapTargets(from).contains(h)) {
          _commit((g) => g.shogunSwap(from, h));
          return;
        }
        if (targets.contains(h)) {
          final fx = _game.effectOptions(from, h);
          if (fx.paralyze.isEmpty && fx.seal.isEmpty) {
            _commit((g) => g.move(from, h));
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
          _commit((g) => g.jadeRelocate(from, h));
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
          _commit((g) => g.jadeSwap(a, h));
          return;
        }
      case _Mode.kawarimi:
        if (targets.contains(h)) {
          _commit((g) => g.kawarimi(h));
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
    _commit((g) => g.move(from, to, paralyze: isParalyze ? target : null, seal: isParalyze ? null : target));
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
              title: Text(tr('game.jadeRelocate')),
              subtitle: Text(trN('common.options', _game.jadeRelocateSources().length)),
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
              title: Text(tr('game.jadeSwap')),
              subtitle: Text(trN('common.options', _game.jadeSwapSources().length)),
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
                        '${_game.isParalyzed(p) ? tr('game.paralyzedTag') : ''}'
                        '${p == stack.last && _game.isNullified(h) ? tr('game.nullifiedTag') : ''}',
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
    if (_ranked) {
      _report(_game.draw ? MatchResult.draw : (humanLost ? MatchResult.loss : MatchResult.win));
      _showRankedResult();
      return;
    }
    final text = _game.endedByLimit
        ? tr('game.over.drawLimit', {'n': _game.rules.roundLimit!})
        : _game.draw
        ? tr('game.over.drawBoth')
        : tr(_game.inSiege ? 'game.over.win.siege' : 'game.over.win', {
            'name': _profiles[w!].nickname,
            'faction': _game.factions[w].displayName,
          });
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(humanLost ? 'common.defeat' : (_game.draw ? 'common.draw' : 'common.victory'))),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _undo();
            },
            child: Text(tr('common.undo')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(tr('common.menu')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _fx.clear();
              _epoch++;
              setState(() {
                _game = GameState(widget.p0, widget.p1);
                _aiSeen.clear();
                _aiThinking = false;
                _clearHistory();
                _reset();
              });
              WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRunAi());
            },
            child: Text(tr('common.rematch')),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- por puntos

  /// Registra el resultado una sola vez (fin de partida o abandono).
  void _report(MatchResult r) {
    if (!_ranked || _reported) return;
    _reported = true;
    final s = AppSettings.instance;
    _ladderBefore = s.ladder;
    s.ladder = s.ladder.apply(r);
  }

  /// Abandonar cuenta como derrota; se confirma antes.
  Future<void> _confirmResign() async {
    if (_reported) {
      Navigator.pop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.flag_rounded, color: HexTheme.of(ctx).danger, size: 36),
        title: Text(tr('game.resignTitle')),
        content: Text(tr('game.resignBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('game.keepPlaying'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: HexTheme.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('common.resign')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _resigned = true;
      _reset();
    });
    _report(MatchResult.loss);
    SoundBoard.instance.play(Sfx.defeat);
    Haptics.heavy();
    _showEmote(_oppSeat, Emote.gg);
    _showRankedResult();
  }

  void _showRankedResult() {
    final before = _ladderBefore!;
    final after = AppSettings.instance.ladder;
    final opp = widget.match!.opponent;
    final won = after.wins > before.wins;
    final draw = after.draws > before.draws;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RankedResultDialog(
        title: tr(won ? 'common.victory' : (draw ? 'common.draw' : 'common.defeat')),
        subtitle: _resigned
            ? tr('ranked.resigned', {'name': opp.nickname})
            : _game.endedByLimit
            ? tr('ranked.drawLimit', {'n': _game.rules.roundLimit!})
            : draw
            ? tr('ranked.drawBoth')
            : won
            ? tr(_game.inSiege ? 'ranked.won.siege' : 'ranked.won', {'name': opp.nickname})
            : tr(_game.inSiege ? 'ranked.lost.siege' : 'ranked.lost', {'name': opp.nickname}),
        before: before,
        after: after,
        onMenu: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
        onAgain: () {
          Navigator.pop(ctx);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, _, _) => MatchmakingScreen(faction: widget.match!.yourFaction),
              transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        },
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
    // La mesa es la de la facción con la que jugás, aunque en el menú esté elegida otra.
    final theme = HexTheme.forFaction(_game.factions[_mySeat], Theme.of(context).brightness);
    return Theme(
      data: _themes[theme] ??= theme.toThemeData(),
      child: Builder(builder: _build),
    );
  }

  static final _themes = <HexTheme, ThemeData>{};

  Widget _build(BuildContext context) {
    final t = HexTheme.of(context);
    final g = _game;
    final targets = _targets;
    _fx.ambient = _selected != null || targets.isNotEmpty || _hasSiege || _spotlight.isNotEmpty;
    if (_fx.ambient) _fx.wake();
    return PopScope(
      canPop: !_ranked || _reported,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmResign();
      },
      child: Scaffold(
        body: ArenaBackdrop(
          accent: HexTheme.faction(g.currentFaction),
          child: Stack(
            children: [
              Positioned.fill(child: _board(t, targets)),
              SafeArea(
                child: Column(
                  children: [
                    _toolbar(t),
                    if (_tutorial)
                      _coachCard()
                    else if (_staged) ...[
                      _stageCard(),
                      if (!_stage!.isPuzzle) _banner(_oppSeat, top: true),
                    ] else
                      _banner(_oppSeat, top: true),
                    _noticeCard(t),
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

  Widget _stageCard() {
    final s = _stage!;
    return StageCard(
      label: switch (s.kind) {
        StageKind.puzzle => tr('stageKind.puzzle'),
        StageKind.challenge => tr('stageKind.challenge'),
        StageKind.campaign => tr('stageKind.campaign'),
      },
      title: s.title,
      goal: s.goal,
      hint: s.isPuzzle ? s.intro : null,
      turnsLeft: s.turnsLeft(_stageStart, _game),
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
          _roundButton(t, Icons.arrow_back_rounded, tr('common.menu'), () => Navigator.maybePop(context)),
          if (!_tutorial && _game.roundsLeft != null) ...[const SizedBox(width: 8), _roundChip(t)],
          const Spacer(),
          if (!_tutorial) ...[
            _roundButton(t, Icons.receipt_long_rounded, tr('common.log'), _log.isEmpty ? null : _showLog),
            const SizedBox(width: 6),
          ],
          _roundButton(
            t,
            AppSettings.instance.sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            tr('common.sound'),
            () => setState(() => AppSettings.instance.sound = !AppSettings.instance.sound),
          ),
          const SizedBox(width: 6),
          _roundButton(
            t,
            dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tr(dark ? 'common.lightTheme' : 'common.darkTheme'),
            () {
              Haptics.select();
              AppSettings.instance.toggleBrightness(context);
            },
          ),
          const SizedBox(width: 6),
          if (_tutorial)
            _roundButton(t, Icons.replay_rounded, tr('tutorial.restartLesson'), _restartLesson)
          else if (_staged)
            _roundButton(t, Icons.replay_rounded, tr('common.restart'), _aiThinking ? null : _restartStage)
          else if (_ranked)
            _roundButton(t, Icons.flag_outlined, tr('common.resign'), _reported ? null : _confirmResign)
          else
            _roundButton(t, Icons.undo_rounded, tr('common.undo'), _history.isEmpty || _aiThinking ? null : _undo),
        ],
      ),
    );
  }

  /// Ronda actual; avisa cuando se acerca el Asedio y cuando ya empezó.
  Widget _roundChip(HexTheme t) {
    final g = _game;
    final siege = g.rules.siegeRound;
    final toSiege = siege == null ? null : siege - g.round;
    final active = g.inSiege;
    final soon = !active && toSiege != null && toSiege <= 3 && toSiege < (g.roundsLeft ?? 99);
    final ending = !active && (g.roundsLeft ?? 99) <= 3;
    final color = active ? t.danger : (soon || ending ? t.gold : t.textMuted);
    final limit = g.rules.roundLimit;
    final text = active
        ? tr('round.siegeActive', {'round': g.round, 'limit': limit!})
        : soon
        ? trN('round.siegeIn', toSiege)
        // Sin Asedio por delante (o con objetivo de rondas), el límite es lo que importa.
        : siege == null || siege > limit! || _staged
        ? tr('round.ofLimit', {'round': g.round, 'limit': limit!})
        : tr('round.n', {'round': g.round});
    return Tooltip(
      message: [
        if (siege != null) tr('round.siegeTip', {'n': siege}),
        tr('round.limitTip', {'n': g.rules.roundLimit!}),
      ].join('\n'),
      triggerMode: TooltipTriggerMode.tap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? t.danger.withValues(alpha: 0.12) : t.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active || soon || ending ? color : t.outline),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
        ),
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
    final canEmote = !_tutorial && !_staged && _isHuman(p) && (widget.aiPlayer != null || p == g.current);
    return PlayerBanner(
      profile: _profiles[p],
      owner: p,
      active: g.current == p && !g.isOver,
      top: top,
      handCount: handCount,
      cooldown: g.cooldowns[p],
      charges: g.abilityChargesLeft(p),
      emote: _emote[p],
      emoteKey: _emoteKey[p],
      onEmote: canEmote ? () => _pickEmote(p) : null,
    );
  }

  /// Aviso de los efectos que se dispararon en la última acción.
  Widget _noticeCard(HexTheme t) {
    final events = _notice;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (c, a) => FadeTransition(
        opacity: a,
        child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: c),
      ),
      child: events.isEmpty
          ? const SizedBox(width: double.infinity)
          : GestureDetector(
              key: ValueKey(_noticeKey),
              onTap: () => setState(() => _notice = const []),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HexTheme.faction(_game.factions[events.first.player]), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _profiles[events.first.player].nickname,
                      style: TextStyle(color: t.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    for (final e in events)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            Icon(_eventIcon(e), size: 16, color: _eventColor(t, e)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.text,
                                style: TextStyle(color: t.text, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
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

  IconData _eventIcon(GameEvent e) => switch (e) {
    PiecePlaced() => Icons.add_circle_outline_rounded,
    Moved(:final climbed) => climbed ? Icons.layers_rounded : Icons.open_with_rounded,
    Pushed() => Icons.keyboard_double_arrow_right_rounded,
    Paralyzed() => Icons.ac_unit_rounded,
    SealPlaced() => Icons.radio_button_checked_rounded,
    Cancelled() => Icons.block_rounded,
    ShogunSwapped() || JadeSwapped() => Icons.swap_horiz_rounded,
    JadeRelocated() => Icons.auto_awesome_rounded,
    Returned() => Icons.undo_rounded,
    Passed() => Icons.hourglass_empty_rounded,
  };

  Color _eventColor(HexTheme t, GameEvent e) => switch (e) {
    Paralyzed() => t.frost,
    Cancelled() => BoardPainter.jade,
    Pushed() || SealPlaced() => t.danger,
    ShogunSwapped() || JadeSwapped() || JadeRelocated() || Returned() => t.gold,
    _ => t.textMuted,
  };

  /// Registro de la partida, de lo más nuevo a lo más viejo. Tocar una jugada la resalta.
  void _showLog() {
    final t = HexTheme.of(context);
    final entries = _log.reversed.toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  tr('common.log'),
                  style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) {
                    final (:round, :e) = entries[i];
                    final newRound = i == 0 || entries[i - 1].round != round;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (newRound)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                            child: Text(
                              tr('round.n', {'round': round}),
                              style: TextStyle(color: t.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: Icon(_eventIcon(e), color: _eventColor(t, e), size: 20),
                          title: Text(e.text, style: TextStyle(color: t.text, fontSize: 13)),
                          subtitle: Text(
                            _profiles[e.player].nickname,
                            style: TextStyle(color: HexTheme.faction(_game.factions[e.player]), fontSize: 11),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _lastMove = e.cells;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
              constraints.maxHeight / 2 - _canvas / 2 + (_tutorial ? 50 : (_staged ? 30 : -20)),
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
                targets: targets.difference(_swapTargets),
                swapTargets: _swapTargets,
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
    final charges = g.abilityChargesLeft(me);
    final abilityReady = me == g.current && g.abilityAvailable && !_locked && (!_tutorial || _lesson!.ability);
    final showHand = _tutorial
        ? hand.any((e) => placeable.contains(e.key))
        : !(_stage?.isPuzzle ?? false) || hand.isNotEmpty;
    final showActions = !_tutorial || _lesson!.ability;
    if (!showHand && !showActions) return _banner(_mySeat, top: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _banner(_mySeat, top: false),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
          child: Tray(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHand) ...[
                  SizedBox(
                    height: 84,
                    child: hand.isEmpty
                        ? Center(
                            child: Text(tr('game.emptyHand'), style: TextStyle(color: t.textMuted)),
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
                          child: OutlinedButton(
                            onPressed: () => _applyEffect(null),
                            child: Text(tr('game.skipEffect')),
                          ),
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
                              charges == 0
                                  ? tr('game.abilitySpent', {'ability': faction.abilityName})
                                  : [
                                      faction.abilityName,
                                      if (cd > 0) '($cd)',
                                      if (charges != null) '×$charges',
                                    ].join(' '),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (_mode != _Mode.idle && _mode != _Mode.effect)
                        IconButton(onPressed: () => setState(_reset), icon: const Icon(Icons.close)),
                    ],
                  ),
              ],
            ),
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
          width: 74,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  type.shortName,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.1,
                    color: selected ? t.text : t.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
