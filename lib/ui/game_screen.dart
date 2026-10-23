import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

import '../codex/avatars.dart';
import '../engine/ai.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/pieces.dart';
import '../i18n/i18n.dart';
import '../match/ladder.dart';
import '../match/matchmaker.dart';
import '../match/rivals.dart';
import '../match/saved_game.dart';
import '../solo/catalog.dart';
import '../solo/daily.dart';
import '../solo/solver.dart';
import '../solo/stars.dart';
import '../store/paywall.dart';
import '../story/script.dart';
import '../story/story_screen.dart';
import '../tutorial/guide.dart';
import '../tutorial/lessons.dart';
import 'board_painter.dart';
import 'fx/board_fx.dart';
import 'fx/sfx.dart';
import 'gallery_screen.dart';
import 'campaign_screen.dart';
import 'hex_layout.dart';
import 'matchmaking_screen.dart';
import 'piece_chip.dart';
import 'stage_list_screen.dart';
import 'theme/hex_theme.dart';
import 'theme/settings.dart';
import 'theme/ui_style.dart';
import 'widgets/arena_backdrop.dart';
import 'widgets/avatar_face.dart';
import 'widgets/coach_card.dart';
import 'widgets/emotes.dart';
import 'widgets/duel_scoreboard.dart';
import 'widgets/skin_kit.dart';
import 'widgets/ranked_result.dart';
import 'widgets/stage_intro.dart';
import 'widgets/star_row.dart';

/// Función top-level: el closure no captura el State (que no es enviable entre isolates).
Future<List<AiAction>> _thinkInIsolate(
  GameState snapshot,
  AiLevel level,
  Map<String, int> seen, {
  bool abilities = true,
}) => Isolate.run(() => AiPlayer(level, seen: seen, useAbilities: abilities).chooseTurn(snapshot));

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

  /// Pass & Play cara a cara: el dispositivo en la mesa entre los dos y la
  /// parte de arriba girada hacia el Jugador 2.
  final bool faceToFace;

  /// Iniciación: partida completa contra el Sensei, con sus consejos.
  final bool initiation;

  /// Rival casual elegido en la partida local (null = el Sensei o un amigo).
  final Rival? rival;

  /// Partida casual guardada desde la que se retoma.
  final GameState? resume;

  const GameScreen({
    super.key,
    required this.p0,
    required this.p1,
    this.aiPlayer,
    this.aiLevel = AiLevel.normal,
    this.faceToFace = false,
    this.rival,
    this.resume,
  }) : lesson = null,
       match = null,
       stage = null,
       nextStage = null,
       initiation = false;

  /// Contenido de un jugador: vos sos el jugador 0 y la IA el 1.
  GameScreen.stage({super.key, required Stage this.stage, this.nextStage})
    : p0 = stage.you,
      p1 = stage.opp,
      aiPlayer = 1,
      aiLevel = stage.level,
      lesson = null,
      match = null,
      faceToFace = false,
      initiation = false,
      rival = null,
      resume = null;

  /// Tutorial: vos (Shaolin) contra el Sensei, con escenarios armados.
  const GameScreen.tutorial({super.key, this.lesson = 0})
    : p0 = Faction.shaolin,
      p1 = Faction.ninja,
      aiPlayer = 1,
      aiLevel = AiLevel.easy,
      match = null,
      stage = null,
      nextStage = null,
      faceToFace = false,
      initiation = false,
      rival = null,
      resume = null;

  /// Iniciación: elegiste [faction] y el Sensei juega con la otra, sin
  /// habilidad y a nivel novato, mientras te aconseja.
  GameScreen.initiation({super.key, required Faction faction})
    : p0 = faction,
      p1 = playableFactions.firstWhere((f) => f != faction),
      aiPlayer = 1,
      aiLevel = AiLevel.novice,
      lesson = null,
      match = null,
      stage = null,
      nextStage = null,
      faceToFace = false,
      initiation = true,
      rival = null,
      resume = null;

  /// Partida por puntos contra el rival del emparejamiento. Quien empieza
  /// juega con las fichas claras (jugador 0).
  GameScreen.ranked({super.key, required MatchFound this.match})
    : p0 = match.youFirst ? match.yourFaction : match.opponent.faction,
      p1 = match.youFirst ? match.opponent.faction : match.yourFaction,
      aiPlayer = match.youFirst ? 1 : 0,
      aiLevel = match.opponent.bot ?? AiLevel.normal,
      lesson = null,
      stage = null,
      nextStage = null,
      faceToFace = false,
      initiation = false,
      rival = null,
      resume = null;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const _canvas = 4000.0;
  static const _hexSize = 40.0;
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

  // Iniciación
  bool get _init => widget.initiation;
  GuideTip? _tip;
  AiAction? _suggestion;
  final _seenTips = <String>{};

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

  /// Presentación de la etapa a la vista, y si ya se cerró alguna vez.
  bool _intro = false;
  bool _introSeen = false;

  /// Cambia al cerrar una viñeta: la presentación vuelve a entrar con su animación.
  int _introTake = 0;

  /// La viñeta tapa la presentación: espera a que se cierre para entrar.
  bool _storyOnTop = false;

  /// Asiento del jugador local (abajo) y del rival (arriba).
  int get _mySeat => widget.aiPlayer == null ? 0 : 1 - widget.aiPlayer!;
  int get _oppSeat => 1 - _mySeat;

  /// Cara a cara: la mitad de arriba (Jugador 2) está girada 180°.
  bool get _f2f => widget.faceToFace && widget.aiPlayer == null;

  /// Hacia quién se abre un diálogo: en cara a cara, girado si es para el Jugador 2.
  bool _flipFor(int player) => _f2f && player == 1;

  @override
  void initState() {
    super.initState();
    _fx = BoardFx(this, _layout);
    _live++;
    MusicBoard.instance.play(_musicTrack);
    _lessonIdx = widget.lesson;
    _game = _lesson?.build() ?? _stage?.build() ?? widget.resume?.copy() ?? GameState(widget.p0, widget.p1);
    _lifecycle = AppLifecycleListener(onHide: _autosave);
    _stageStart = _game.copy();
    // Las etapas arrancan con su presentación; la escena se arma al cerrarla.
    _intro = _staged;
    if (_tutorial) WidgetsBinding.instance.addPostFrameCallback((_) => _introScene());
    // Campaña: la viñeta de antes, la primera vez, sobre la presentación.
    final pre = _stage == null ? null : Scene.of(_stage!.id, post: false);
    if (pre != null && !AppSettings.instance.isSceneSeen(pre.id)) {
      _storyOnTop = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playIntroScene(pre);
      });
    }
    final nick = AppSettings.instance.nickname;
    final m = widget.match;
    if (m != null) {
      final me = PlayerProfile(
        nickname: nick,
        faction: m.yourFaction,
        avatar: AppSettings.instance.avatarFor(m.yourFaction),
        frame: AppSettings.instance.frame,
        rating: AppSettings.instance.ladder.rating,
      );
      final o = m.opponent;
      final opp = PlayerProfile(nickname: o.nickname, faction: o.faction, avatar: o.avatar, rating: o.rating);
      _profiles = _mySeat == 0 ? [me, opp] : [opp, me];
    } else {
      _profiles = _staged
          ? [
              PlayerProfile(
                nickname: nick,
                faction: widget.p0,
                avatar: AppSettings.instance.avatarFor(widget.p0),
                frame: AppSettings.instance.frame,
              ),
              if (Scene.opponentOf(_stage!.id) case final who?)
                PlayerProfile(nickname: who.displayName, faction: widget.p1, isAi: true, avatar: who.avatar)
              else
                PlayerProfile(
                  nickname: _stage!.isPuzzle
                      ? tr('common.sensei')
                      : '${tr('common.sensei')} · ${widget.aiLevel.displayName}',
                  faction: widget.p1,
                  isAi: true,
                ),
            ]
          : _tutorial || _init
          ? [
              PlayerProfile(
                nickname: nick,
                faction: widget.p0,
                avatar: AppSettings.instance.avatarFor(widget.p0),
                frame: AppSettings.instance.frame,
              ),
              PlayerProfile(nickname: tr('common.sensei'), faction: widget.p1, isAi: true),
            ]
          : widget.aiPlayer == null
          ? [
              PlayerProfile(
                nickname: nick,
                faction: widget.p0,
                avatar: AppSettings.instance.avatarFor(widget.p0),
                frame: AppSettings.instance.frame,
              ),
              PlayerProfile(nickname: tr('common.player2'), faction: widget.p1, avatar: Avatars.defaultFor(widget.p1)),
            ]
          : [
              PlayerProfile(
                nickname: nick,
                faction: widget.p0,
                avatar: AppSettings.instance.avatarFor(widget.p0),
                frame: AppSettings.instance.frame,
              ),
              if (widget.rival case final r?)
                PlayerProfile(nickname: r.name, faction: widget.p1, isAi: true, avatar: r.avatar)
              else
                PlayerProfile(
                  nickname: '${tr('common.sensei')} · ${widget.aiLevel.displayName}',
                  faction: widget.p1,
                  isAi: true,
                ),
            ];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRunAi();
      _refreshGuide();
    });
  }

  /// La campaña suena con su facción y El Sello con el Oni; el resto, con la tuya.
  MusicTrack get _musicTrack {
    final s = widget.stage;
    if (s != null && finale.any((x) => x.id == s.id)) return MusicTrack.oni;
    final mine = s != null && s.kind == StageKind.campaign
        ? campaigns.firstWhere((c) => c.stages.any((x) => x.id == s.id)).faction
        : widget.aiPlayer == 1
        ? widget.p0
        : widget.aiPlayer == 0
        ? widget.p1
        : widget.p0;
    return mine == Faction.ninja ? MusicTrack.ninja : MusicTrack.shaolin;
  }

  /// Partidas abiertas: al pasar a la siguiente batalla la nueva se abre
  /// antes de cerrar la vieja, y la música del menú no debe colarse.
  static int _live = 0;

  /// Partida casual (local o contra un rival): se guarda para retomarla.
  bool get _casual => !_staged && !_tutorial && !_init && !_ranked;
  late final AppLifecycleListener _lifecycle;

  void _autosave() {
    if (!_casual) return;
    if (_game.isOver) {
      SavedGame.clear();
    } else {
      SavedGame(
        _game,
        aiPlayer: widget.aiPlayer,
        aiLevel: widget.aiLevel,
        faceToFace: widget.faceToFace,
        rival: widget.rival,
      ).save();
    }
  }

  @override
  void dispose() {
    _autosave();
    _lifecycle.dispose();
    if (--_live == 0) MusicBoard.instance.play(MusicTrack.menu);
    for (final t in _emoteTimers) {
      t?.cancel();
    }
    _retryTimer?.cancel();
    _noticeTimer?.cancel();
    _camera?.dispose();
    _fx.dispose();
    _transform.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- derivados

  Set<Hex> get _targets {
    final raw = _rawTargets;
    return _tutorial ? raw.where((h) => _lessonAllows(_mode, h)).toSet() : raw;
  }

  Set<Hex> get _rawTargets => switch (_mode) {
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

  // En el tutorial solo vale la jugada que pide la lección: se calculan todas
  // las legales y quedan las que cumplen el objetivo.
  List<AiAction> _lessonCache = const [];
  GameState? _lessonCacheFor;
  int _lessonCachePly = -1;

  List<AiAction> get _lessonActions {
    final g = _game;
    if (identical(_lessonCacheFor, g) && _lessonCachePly == g.ply) return _lessonCache;
    final l = _lesson!;
    final start = _history.isEmpty ? g : _history.first;
    final main = mainActions(g);
    final candidates = [
      for (final a in main)
        if (a is! PlaceAction || (l.hand?.contains(a.type) ?? true)) a,
      // Mover sin aplicar el efecto (botón "sin efecto").
      for (final a in main)
        if (a is MoveAction && (a.paralyze != null || a.seal != null)) MoveAction(a.from, a.to),
      if (l.ability) ...abilityActions(g),
    ];
    _lessonCache = [
      for (final a in candidates)
        if (_reaches(a, g, start, l)) a,
    ];
    _lessonCacheFor = g;
    _lessonCachePly = g.ply;
    return _lessonCache;
  }

  static bool _reaches(AiAction a, GameState g, GameState start, Lesson l) {
    final s = g.copy();
    return a.apply(s) && l.done(start, s);
  }

  /// ¿La lección permite tocar [h] en el modo [mode]?
  bool _lessonAllows(_Mode mode, Hex h) => _lessonActions.any(
    (a) => switch ((mode, a)) {
      (_Mode.placing, PlaceAction(:final type, :final at)) => type == _placing && at == h,
      (_Mode.moving, MoveAction(:final from, :final to)) => from == _selected && to == h,
      (_Mode.moving, SwapAction(:final from, :final to)) => from == _selected && to == h,
      (_Mode.effect, MoveAction(:final from, :final to, :final paralyze, :final seal)) =>
        from == _selected && to == _effectTo && (paralyze == h || seal == h),
      (_Mode.jadeRelocate, JadeRelocateAction(:final from)) => from == h,
      (_Mode.jadeRelocateTarget, JadeRelocateAction(:final from, :final to)) => from == _selected && to == h,
      (_Mode.jadeSwap, JadeSwapAction(:final a, :final b)) => a == h || b == h,
      (_Mode.jadeSwapTarget, JadeSwapAction(:final a, :final b)) =>
        (a == _selected && b == h) || (b == _selected && a == h),
      (_Mode.kawarimi, KawarimiAction(:final at)) => at == h,
      _ => false,
    },
  );

  bool get _lessonWantsAbility =>
      _lessonActions.any((a) => a is KawarimiAction || a is JadeRelocateAction || a is JadeSwapAction);

  bool get _lessonSkipsEffect => _lessonActions.any(
    (a) => a is MoveAction && a.from == _selected && a.to == _effectTo && a.paralyze == null && a.seal == null,
  );

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
    if (!mounted || !_isAiTurn || _game.isOver || _aiThinking || _intro) return;
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
          : await _thinkInIsolate(snapshot, level, Map.of(_aiSeen), abilities: !_init);
    } catch (e) {
      debugPrint('IA en isolate falló ($e); calculando en el hilo principal');
      actions = puzzleTurns != null
          ? defend(snapshot, puzzleTurns)
          : AiPlayer(level, seen: Map.of(_aiSeen), useAbilities: !_init).chooseTurn(snapshot);
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
      _Mode.idle when _tutorial || _init => '', // el Sensei ya dice qué hacer
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
    _autosave();
    final events = _game.lastEvents;
    for (final e in events) {
      _log.add((round: before.round, e: e));
    }
    final dur = _fx.animate(before, _game, viewer: widget.aiPlayer == null ? null : _mySeat);
    if (_fx.finisher != null && !before.isOver) _zoomTo(_fx.finisher!.leaders.first);
    if (_init) {
      if (before.current == _mySeat && _game.current != _mySeat && onceTips.contains(_tip?.id)) {
        _seenTips.add(_tip!.id);
      }
      _tip = null;
      _suggestion = null;
      if (!_game.isOver && _game.current == _mySeat) {
        Future.delayed(Duration(milliseconds: (dur * 1000).round() + 250), _refreshGuide);
      }
    }
    if (!_tutorial && !_game.isOver) _warnLeader(before, after: dur);
    if (before.current != _game.current) {
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

  /// Latido cuando al Líder propio le quedan 2 lados libres o menos (más
  /// fuerte con 1). Suena solo cuando el cerco se aprieta, no en cada turno.
  void _warnLeader(GameState before, {required double after}) {
    final me = widget.aiPlayer == null ? _game.current : _mySeat;
    final now = _game.leaderMargin(me), was = before.leaderMargin(me);
    if (now == null || now > 2 || now < 1 || (was != null && was <= now)) return;
    Future.delayed(Duration(milliseconds: (after * 1000).round() + 120), () {
      if (!mounted || _game.isOver) return;
      SoundBoard.instance.play(Sfx.heartbeat, volume: now == 1 ? 1 : 0.75);
      now == 1 ? Haptics.double() : Haptics.medium();
    });
  }

  // Cámara del remate: se acerca al Líder que cae.
  Size _viewport = Size.zero;
  AnimationController? _camera;

  void _zoomTo(Hex h, {double scale = 1.55}) {
    if (_viewport.isEmpty) return;
    final p = _layout.toPixel(h);
    // Un poco por encima del centro: abajo queda la mano.
    final focus = Offset(_viewport.width / 2, _viewport.height * 0.44);
    final target = Matrix4.identity()
      ..translateByDouble(focus.dx - p.dx * scale, focus.dy - p.dy * scale, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    final tween = Matrix4Tween(begin: _transform.value.clone(), end: target);
    _camera?.dispose();
    final c = _camera = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    final curve = CurvedAnimation(parent: c, curve: Curves.easeInOutCubic);
    c.addListener(() => _transform.value = tween.evaluate(curve));
    if (MediaQuery.disableAnimationsOf(context)) {
      c.value = 1;
    } else {
      c.forward();
    }
  }

  /// Vuelve a encuadrar el tablero (revancha o reinicio).
  void _recenter() {
    _camera?.stop();
    _centered = false;
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

  // ----------------------------------------------------------- iniciación

  /// Calcula la jugada que haría el Sensei en tu lugar y el consejo del momento.
  Future<void> _refreshGuide() async {
    if (!_init || !mounted || _game.isOver || _game.current != _mySeat) return;
    final epoch = _epoch, ply = _game.ply;
    setState(() => _tip = guideTip(_game, _mySeat, seen: _seenTips));
    List<AiAction> turn;
    try {
      turn = await _thinkInIsolate(_game.copy(), AiLevel.normal, const {});
    } catch (_) {
      turn = AiPlayer(AiLevel.normal).chooseTurn(_game.copy());
    }
    if (!mounted || epoch != _epoch || ply != _game.ply) return;
    setState(() {
      _suggestion = turn.firstOrNull;
      _tip = guideTip(_game, _mySeat, seen: _seenTips, suggestion: _suggestion);
    });
  }

  void _finishInitiation({required bool won}) {
    if (won) {
      AppSettings.instance.tutorialDone = true;
      GiftToast.check(context);
    }
    showSkinDialog<void>(
      context,
      dismissible: false,
      builder: (ctx) => SkinDialog(
        glyph: won ? '入' : '再',
        glyphColor: won ? HexTheme.of(ctx).gold : null,
        title: tr(won ? 'initiation.wonTitle' : 'initiation.lostTitle'),
        message: tr(won ? 'initiation.wonBody' : 'initiation.lostBody', {'faction': widget.p0.displayName}),
        actions: [
          SkinAction(tr('common.menu'), () {
            Navigator.pop(ctx);
            Navigator.pop(context);
          }),
          if (won)
            SkinAction(
              tr('initiation.story'),
              () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CampaignScreen()));
              },
              primary: true,
              glyph: '記',
            )
          else
            SkinAction(
              tr('common.retry'),
              () {
                Navigator.pop(ctx);
                _fx.clear();
                _epoch++;
                _recenter();
                setState(() {
                  _game = GameState(widget.p0, widget.p1);
                  _aiSeen.clear();
                  _aiThinking = false;
                  _clearHistory();
                  _reset();
                });
                WidgetsBinding.instance.addPostFrameCallback((_) => _refreshGuide());
              },
              primary: true,
              glyph: '戦',
            ),
        ],
      ),
    );
  }

  Widget _guideCard() {
    final tip = _tip;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (c, a) => FadeTransition(
        opacity: a,
        child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: c),
      ),
      child: tip == null
          ? const SizedBox(width: double.infinity, key: ValueKey('none'))
          : GuideCard(key: ValueKey(tip.id), title: tip.title, body: tip.body),
    );
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
    final daily = _stage!.id == Daily.id;
    if (ok && daily) {
      AppSettings.instance.solveDaily(Daily.today);
    } else if (ok) {
      AppSettings.instance.markCleared(_stage!.id);
    }
    // Estrellas: se calculan sobre toda la partida y se guarda el récord.
    final goals = ok && Stars.appliesTo(_stage!) ? Stars.goals(_stageStart, [..._history, _game], _game) : null;
    final previous = AppSettings.instance.starsOf(_stage!.id);
    if (goals != null) AppSettings.instance.recordStars(_stage!.id, Stars.count(goals));
    final wait = Duration(milliseconds: (after * 1000).round() + 500);
    GiftToast.check(context, delay: wait + const Duration(milliseconds: 900));
    Future.delayed(wait, () async {
      if (!mounted) return;
      SoundBoard.instance.play(ok ? Sfx.victory : Sfx.defeat);
      Haptics.heavy();
      // Campaña: al ganar por primera vez, la viñeta de después.
      final post = ok ? Scene.of(_stage!.id, post: true) : null;
      if (post != null && !AppSettings.instance.isSceneSeen(post.id)) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        await playScene(context, post, mine: _storySides, title: _stage!.title);
        if (!mounted) return;
        // Fin del Acto I: el cliffhanger recién visto lleva al desbloqueo.
        if (_nextLocked) {
          await showPaywall(context);
          if (!mounted) return;
        }
      }
      _showStageResult(ok, goals: goals, previous: previous);
    });
  }

  /// La batalla siguiente es de la historia paga y todavía no se compró.
  bool get _nextLocked {
    final next = widget.nextStage;
    return next != null && isPaid(next) && !AppSettings.instance.storyUnlocked;
  }

  /// Bandos que van a la izquierda en las viñetas: el tuyo (en El Sello, los dos).
  Set<Faction> get _storySides => _stage!.id == finale.last.id ? const {Faction.shaolin, Faction.ninja} : {_stage!.you};

  /// Fin de una campaña: la otra mitad de la historia, o El Sello si ya están las dos.
  ({String text, String action, VoidCallback go})? _campaignEnd(BuildContext ctx) {
    final s = _stage!;
    final mine = campaigns.where((c) => !c.isFinale && c.stages.last.id == s.id).firstOrNull;
    if (s.id == finale.last.id) return (text: tr('story.theEnd'), action: '', go: () {});
    if (mine == null) return null;
    final other = campaigns.firstWhere((c) => !c.isFinale && c != mine);
    final otherDone = AppSettings.instance.isCleared(other.stages.last.id);
    void open(Widget page) {
      Navigator.pop(ctx);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    }

    if (!otherDone) {
      return (
        text: tr('story.otherHalf', {'title': other.title}),
        action: other.title,
        go: () => open(StageListScreen(title: other.title, subtitle: other.faction.displayName, stages: other.stages)),
      );
    }
    final f1 = finale.first;
    return (
      text: tr('story.bothDone'),
      action: tr('campaign.finale.title'),
      go: () => open(GameScreen.stage(stage: f1, nextStage: stageAfter(f1))),
    );
  }

  /// Vuelve a mostrar la presentación de la etapa (historia y objetivo).
  void _showStageIntro() {
    if (!mounted) return;
    Haptics.select();
    setState(() => _intro = true);
  }

  /// Por qué cayó el Líder: cerco completo o Asedio, y de quién eran las
  /// fichas de alrededor (todas cuentan). Vacío si no hubo captura.
  String _captureReason() {
    final w = _game.winner;
    final b = w == null ? null : _game.captureBreakdown(1 - w);
    if (b == null) return '';
    final how = _game.inSiege
        ? tr('game.reason.siege', {'round': _game.rules.siegeRound!, 'sides': b.sides})
        : tr('game.reason.full');
    return '\n\n$how ${tr('game.reason.split', {'enemy': b.enemy, 'own': b.own})}';
  }

  String _stageWinText() => _stageWinLine() + (_stage!.isPuzzle ? '' : _captureReason());

  String _stageWinLine() {
    final s = _stage!;
    if (s.kind == StageKind.campaign && widget.nextStage == null) {
      return tr(_game.inSiege ? 'stage.campaignDone.siege' : 'stage.campaignDone');
    }
    if (s.id == Daily.id) {
      return trN('daily.won', AppSettings.instance.dailyStreakOn(Daily.today));
    }
    if (!s.isPuzzle) return tr(_game.inSiege ? 'stage.won.siege' : 'stage.won', {'title': s.title});
    final used = s.puzzleTurns! - s.turnsLeft(_stageStart, _game)! + 1;
    return trN('stage.closedIn', used);
  }

  String _stageFailText() {
    if (_game.endedByLimit) return tr('stage.lost.limit');
    if (_game.draw) return tr('stage.lost.draw');
    if (_game.winner == 1) return tr('stage.lost.surrounded') + _captureReason();
    return tr(_stage!.isPuzzle ? 'stage.lost.puzzle' : 'stage.lost');
  }

  void _showStageResult(bool ok, {List<bool>? goals, int previous = 0}) {
    final next = widget.nextStage;
    showSkinDialog<void>(
      context,
      dismissible: false,
      builder: (ctx) {
        final end = ok ? _campaignEnd(ctx) : null;
        // Empate por doble cerco: no es derrota, pero tampoco pasa la etapa.
        final tie = !ok && _game.draw && !_game.endedByLimit;
        return SkinDialog(
          glyph: ok ? (end != null ? '終' : '勝') : (tie ? '和' : '再'),
          glyphColor: ok ? HexTheme.of(ctx).gold : null,
          title: tr(ok ? 'stage.cleared' : (tie ? 'common.draw' : 'stage.notThisTime')),
          message: end?.text ?? (ok ? _stageWinText() : _stageFailText()),
          body: goals == null ? null : StarsReveal(goals: goals, previous: previous),
          actions: [
            SkinAction(tr('common.back'), () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            }),
            if (end != null && end.action.isNotEmpty)
              SkinAction(end.action, end.go, primary: true)
            else if (ok && next != null)
              SkinAction(tr(_nextLocked ? 'store.unlock' : 'common.next'), () async {
                if (_nextLocked && !await showPaywall(ctx)) return;
                if (!ctx.mounted || !mounted) return;
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (_, _, _) => GameScreen.stage(stage: next, nextStage: stageAfter(next)),
                    transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
                  ),
                );
              }, primary: true)
            else
              SkinAction(tr(ok ? 'common.playAgain' : 'common.retry'), () {
                Navigator.pop(ctx);
                _restartStage();
              }, primary: true),
          ],
        );
      },
    );
  }

  void _restartStage() {
    if (!mounted || !_staged) return;
    final fresh = _stage!.build();
    _epoch++;
    _fx.clear();
    _recenter();
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
    GiftToast.check(context);
    showSkinDialog<void>(
      context,
      dismissible: false,
      builder: (ctx) => SkinDialog(
        glyph: '師',
        glyphColor: HexTheme.of(ctx).gold,
        title: tr('tutorial.readyTitle'),
        message: tr('tutorial.readyBody'),
        actions: [
          SkinAction(tr('common.menu'), () {
            Navigator.pop(ctx);
            Navigator.pop(context);
          }),
          SkinAction(
            tr('tutorial.playSensei'),
            () {
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
            primary: true,
            glyph: '戦',
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
    if (_game.isOver) _recenter();
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
        if (targets.contains(h) && _game.shogunSwapTargets(from).contains(h)) {
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
        (_game.moveTargets(h).isNotEmpty || _game.shogunSwapTargets(h).isNotEmpty) &&
        (!_tutorial ||
            _lessonActions.any((a) => (a is MoveAction && a.from == h) || (a is SwapAction && a.from == h)))) {
      if (_selected != h) _feedbackSelect();
      _mode = _Mode.moving;
      _selected = h;
      _placing = null;
    } else {
      _reset();
    }
  }

  /// Qué hace la habilidad de [me] y cuánto le queda: encabeza su hoja.
  Widget _abilityAbout(HexTheme t, int me) {
    final g = _game;
    final factions = g.rules.dualAbility.contains(me) ? [Faction.shaolin, Faction.ninja] : [g.factions[me]];
    final charges = g.abilityChargesLeft(me);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final f in factions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(f.abilityDescription, style: TextStyle(fontSize: 15, height: 1.35, color: t.text)),
          ),
        Text(
          [
            if (charges != null) trN('game.ability.charges', charges),
            trN('game.ability.cooldown', g.rules.abilityCooldown),
          ].join(' · '),
          style: TextStyle(fontSize: 13, color: t.textMuted),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  /// Mantener apretado el sello: solo explica la habilidad, sin usarla.
  void _explainAbility(int me) {
    Haptics.select();
    final f = _game.factions[me];
    showSkinSheet<void>(
      context,
      flipped: _flipFor(me),
      title: _game.rules.dualAbility.contains(me)
          ? '${Faction.shaolin.abilityName} · ${Faction.ninja.abilityName}'
          : f.abilityName,
      builder: (ctx) => _abilityAbout(HexTheme.of(ctx), me),
    );
  }

  void _startAbility() {
    if (!_game.abilityAvailable) return;
    Haptics.select();
    void enter(_Mode mode) => setState(() {
      _reset();
      _mode = mode;
    });
    if (!_game.hasAbility(Faction.shaolin)) {
      // En la lección va directo; en partida, primero se explica qué hace.
      if (_tutorial) return enter(_Mode.kawarimi);
      final targets = _game.kawarimiTargets().length;
      showSkinSheet<void>(
        context,
        flipped: _flipFor(_game.current),
        title: Faction.ninja.abilityName,
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _abilityAbout(HexTheme.of(ctx), _game.current),
            SkinTile(
              glyph: '替',
              title: tr('game.ability.pick'),
              text: trN('common.options', targets),
              onTap: targets == 0
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      enter(_Mode.kawarimi);
                    },
            ),
          ],
        ),
      );
      return;
    }
    int options(Set<Hex> sources, _Mode mode) =>
        _tutorial ? sources.where((h) => _lessonAllows(mode, h)).length : sources.length;
    final relocate = options(_game.jadeRelocateSources(), _Mode.jadeRelocate);
    final swap = options(_game.jadeSwapSources(), _Mode.jadeSwap);
    // Final de la historia: también el Kawarimi, con la misma recarga.
    final dual = _game.hasAbility(Faction.ninja);
    final swapOut = dual ? options(_game.kawarimiTargets(), _Mode.kawarimi) : 0;
    void pick(BuildContext ctx, _Mode mode) {
      Navigator.pop(ctx);
      setState(() {
        _reset();
        _mode = mode;
      });
    }

    showSkinSheet<void>(
      context,
      flipped: _flipFor(_game.current),
      title: dual ? '${Faction.shaolin.abilityName} · ${Faction.ninja.abilityName}' : Faction.shaolin.abilityName,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _abilityAbout(HexTheme.of(ctx), _game.current),
          SkinTile(
            glyph: '移',
            title: tr('game.jadeRelocate'),
            text: trN('common.options', relocate),
            onTap: relocate == 0 ? null : () => pick(ctx, _Mode.jadeRelocate),
          ),
          const SizedBox(height: 10),
          SkinTile(
            glyph: '換',
            title: tr('game.jadeSwap'),
            text: trN('common.options', swap),
            onTap: swap == 0 ? null : () => pick(ctx, _Mode.jadeSwap),
          ),
          if (dual) ...[
            const SizedBox(height: 10),
            SkinTile(
              glyph: '替',
              title: Faction.ninja.abilityName,
              text: trN('common.options', swapOut),
              onTap: swapOut == 0 ? null : () => pick(ctx, _Mode.kawarimi),
            ),
          ],
        ],
      ),
    );
  }

  void _showInfo(Hex h, {int by = 0}) {
    final stack = _game.board.stackAt(h);
    if (stack.isEmpty) return;
    Haptics.select();
    showSkinSheet<void>(
      context,
      flipped: _flipFor(by),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final p in stack.reversed) ...[
            Row(
              children: [
                PieceChip(
                  type: p.type,
                  owner: p.owner,
                  size: 22,
                  mirror: _game.factions[0] == _game.factions[1],
                  ash: _game.factions[p.owner] == Faction.oni,
                ),
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
    );
  }

  Future<void> _showGameOver({double after = 0}) async {
    await Future.delayed(Duration(milliseconds: (after * 1000).round() + 450));
    if (!mounted || !_game.isOver) return;
    final w = _game.winner;
    final humanLost = widget.aiPlayer != null && w == widget.aiPlayer;
    SoundBoard.instance.play(humanLost ? Sfx.defeat : Sfx.victory);
    Haptics.heavy();
    if (_init) {
      _finishInitiation(won: !humanLost && !_game.draw);
      return;
    }
    if (widget.aiPlayer != null) _showEmote(widget.aiPlayer!, humanLost ? Emote.smug : Emote.gg);
    if (_ranked) {
      _report(_game.draw ? MatchResult.draw : (humanLost ? MatchResult.loss : MatchResult.win));
      _showRankedResult();
      return;
    }
    if (widget.aiPlayer != null && !_game.draw && !humanLost) {
      AppSettings.instance.recordWin();
      if (widget.rival case final r?) AppSettings.instance.markRivalBeaten(r.id);
    }
    GiftToast.check(context);
    final text = _game.endedByLimit
        ? tr('game.over.drawLimit', {'n': _game.rules.roundLimit!})
        : _game.draw
        ? tr('game.over.drawBoth')
        : tr(_game.inSiege ? 'game.over.win.siege' : 'game.over.win', {
                'name': _profiles[w!].nickname,
                'faction': _game.factions[w].displayName,
              }) +
              _captureReason();
    if (!mounted) return;
    showSkinDialog<void>(
      context,
      // Cara a cara: el cartel mira a quien ganó.
      flipped: _flipFor(w ?? 0),
      builder: (ctx) => SkinDialog(
        glyph: humanLost ? '敗' : (_game.draw ? '和' : '勝'),
        glyphColor: humanLost ? null : HexTheme.of(ctx).gold,
        title: tr(humanLost ? 'common.defeat' : (_game.draw ? 'common.draw' : 'common.victory')),
        message: text,
        actions: [
          SkinAction(
            tr('common.rematch'),
            () {
              Navigator.pop(ctx);
              _fx.clear();
              _epoch++;
              _recenter();
              setState(() {
                _game = GameState(widget.p0, widget.p1);
                _aiSeen.clear();
                _aiThinking = false;
                _clearHistory();
                _reset();
              });
              WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRunAi());
            },
            primary: true,
            glyph: '戦',
          ),
          SkinAction(tr('common.undo'), () {
            Navigator.pop(ctx);
            _undo();
          }),
          SkinAction(tr('common.menu'), () {
            Navigator.pop(ctx);
            Navigator.pop(context);
          }),
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
    final ok = await showSkinDialog<bool>(
      context,
      builder: (ctx) => SkinDialog(
        glyph: '降',
        glyphColor: HexTheme.of(ctx).danger,
        title: tr('game.resignTitle'),
        message: tr('game.resignBody'),
        actions: [
          SkinAction(tr('common.resign'), () => Navigator.pop(ctx, true), primary: true, danger: true),
          SkinAction(tr('game.keepPlaying'), () => Navigator.pop(ctx, false)),
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
    GiftToast.check(context);
    final before = _ladderBefore!;
    final after = AppSettings.instance.ladder;
    final opp = widget.match!.opponent;
    final won = after.wins > before.wins;
    final draw = after.draws > before.draws;
    showSkinDialog<void>(
      context,
      dismissible: false,
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
    showSkinSheet<void>(
      context,
      builder: (ctx) => Center(
        // Cara a cara: el de arriba lo lee mirando hacia él.
        child: RotatedBox(
          quarterTurns: _flipFor(player) ? 2 : 0,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
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
                    width: 76,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: HexTheme.of(ctx).outline, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmoteGlyph(e, faction: _profiles[player].faction, size: 58),
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
    final skin = Skin.forStyle(AppSettings.instance.uiStyle);
    return Theme(
      data: _themes[(theme, skin)] ??= theme.toThemeData(skin),
      child: Builder(builder: _build),
    );
  }

  static final _themes = <(HexTheme, Skin), ThemeData>{};

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
          cloth: true,
          child: Stack(
            children: [
              Positioned.fill(child: _board(t, targets)),
              if (_f2f)
                SafeArea(
                  child: Column(
                    children: [
                      RotatedBox(quarterTurns: 2, child: _seat(t, 1)),
                      const Spacer(),
                      _seat(t, 0),
                    ],
                  ),
                )
              else
                SafeArea(
                  // De abajo hacia arriba: la barra de arriba se pinta última y
                  // los emotes que cuelgan del marcador quedan sobre el objetivo.
                  child: Column(
                    verticalDirection: VerticalDirection.up,
                    children: [
                      _dock(t),
                      const SizedBox(height: 8),
                      _hintLine(t),
                      const Spacer(),
                      _noticeCard(t),
                      if (_tutorial) _coachCard() else if (_staged) _goalChip(t) else if (_init) _guideCard(),
                      _topBar(t),
                    ],
                  ),
                ),
              // Presentación de la etapa, encima de todo hasta tocar Comenzar.
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_intro,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _intro
                        ? ArenaBackdrop(key: const ValueKey('intro'), accent: t.accent, child: _stageIntro())
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Set<Hex> get _spotlight => _tutorial && _coach == CoachState.doing
      ? _lesson!.spotlight
      : _init && !_locked && (_mode == _Mode.idle || _mode == _Mode.placing)
      ? (_tip?.spotlight ?? const {})
      : const {};

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

  /// La viñeta de antes de la batalla; al cerrarla, la presentación entra de nuevo.
  Future<void> _playIntroScene(Scene pre, {bool replay = false}) async {
    setState(() => _storyOnTop = true);
    await playScene(context, pre, mine: _storySides, title: _stage!.title, replay: replay);
    if (mounted) {
      setState(() {
        _storyOnTop = false;
        _introTake++;
      });
    }
  }

  Widget _stageIntro() {
    final s = _stage!;
    final pre = Scene.of(s.id, post: false);
    // La primera vez, volver es salir de la etapa; después solo cierra la presentación.
    final first = !_introSeen;
    return StageIntro(
      key: ValueKey(_introTake),
      play: !_storyOnTop,
      onReplay: pre == null ? null : () => _playIntroScene(pre, replay: true),
      glyph: s.kind == StageKind.campaign ? '記' : '試',
      label: switch (s.kind) {
        StageKind.puzzle => tr('stageKind.puzzle'),
        StageKind.challenge => tr('stageKind.challenge'),
        StageKind.campaign => tr('stageKind.campaign'),
      },
      title: s.title,
      story: s.intro,
      goal: s.goal,
      me: _profiles[_mySeat],
      rival: _profiles[_oppSeat],
      rivalLine: s.isPuzzle ? null : widget.p1.displayName,
      backTooltip: tr(first ? 'common.menu' : 'common.close'),
      onBack: first ? () => Navigator.maybePop(context) : _startStage,
      onStart: _startStage,
      stars: Stars.appliesTo(s) ? AppSettings.instance.starsOf(s.id) : null,
    );
  }

  /// Cierra la presentación; la primera vez arma la escena y deja jugar a la IA.
  void _startStage() {
    Haptics.select();
    final first = !_introSeen;
    setState(() {
      _intro = false;
      _introSeen = true;
    });
    if (first) {
      _introScene();
      _maybeRunAi();
    }
  }

  /// Objetivo de la etapa; tocarlo vuelve a abrir la presentación.
  Widget _goalChip(HexTheme t) {
    final s = _stage!;
    final turns = s.turnsLeft(_stageStart, _game);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
      child: Tooltip(
        message: tr('stage.showIntro'),
        child: Pressable(
          onTap: _showStageIntro,
          child: SkinBar(
            radius: 14,
            highlight: t.gold.withValues(alpha: 0.7),
            padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_rounded, size: 15, color: t.gold),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    s.goal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: t.text, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
                if (turns != null) ...[
                  const SizedBox(width: 10),
                  Tooltip(
                    message: tr('stage.turnsLeftTip'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$turns', style: Skin.of(context).display(16, color: turns <= 1 ? t.danger : t.gold)),
                        const SizedBox(width: 3),
                        Text(
                          trN('stage.turn', turns),
                          style: TextStyle(color: t.textMuted, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasSiege {
    if (_fx.finisher != null) return true;
    for (var p = 0; p < 2; p++) {
      if (_game.leaderPressure(p) >= 4 || _game.leaderOpenings(p).isNotEmpty) return true;
    }
    return false;
  }

  /// Barra superior: volver y más opciones; debajo, el marcador de duelo a todo
  /// el ancho para que avatares y nombres se lean (en el tutorial no hay).
  Widget _topBar(HexTheme t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _roundButton(t, Icons.arrow_back_rounded, tr('common.menu'), () => Navigator.maybePop(context)),
              const Spacer(),
              _roundButton(t, Icons.more_horiz_rounded, tr('game.more'), _openMore),
            ],
          ),
          if (!_tutorial && !_init) ...[
            const SizedBox(height: 6),
            DuelScoreboard(me: _side(_mySeat), rival: _side(_oppSeat), center: _roundMark(t)),
          ],
        ],
      ),
    );
  }

  /// Cara a cara: lo de un jugador, mirando hacia él (el de arriba va girado).
  /// Desde el centro hacia su borde: avisos y pista si le toca, su mano y su barra.
  Widget _seat(HexTheme t, int p) {
    final mine = _game.current == p && !_game.isOver;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mine) ...[_noticeCard(t), _hintLine(t), const SizedBox(height: 8)],
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: mine || _game.isOver ? 1 : 0.5,
          child: _dock(t, player: p),
        ),
        _playerStrip(t, p),
      ],
    );
  }

  /// Avatar, nombre y "Tu turno" de un jugador, con la ronda. El de abajo
  /// tiene además los botones de más opciones y volver.
  Widget _playerStrip(HexTheme t, int p) {
    final g = _game;
    final active = g.current == p && !g.isOver;
    final color = HexTheme.faction(g.factions[p]);
    final profile = _profiles[p];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 4),
      child: Row(
        children: [
          // Tocando el avatar se manda un emote; sale como globo hacia el tablero.
          Stack(
            clipBehavior: Clip.none,
            children: [
              Pressable(
                semanticLabel: tr('banner.emote'),
                onTap: () => _pickEmote(p),
                child: AvatarFace(
                  avatar: profile.avatar,
                  frame: profile.frame,
                  size: 36,
                  color: color,
                  borderColor: active ? t.gold : t.outline,
                  borderWidth: active ? 2.2 : 1.2,
                  shadow: [if (active) BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)],
                ),
              ),
              if (_emote[p] != null)
                Positioned(
                  left: 0,
                  bottom: 42,
                  child: EmoteBubble(
                    key: ValueKey(_emoteKey[p]),
                    emote: _emote[p]!,
                    faction: profile.faction,
                    pointUp: false,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // El nombre se corta antes que mover la ronda y los botones.
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    profile.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: t.text),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: active
                      ? Container(
                          key: const ValueKey('turn'),
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            tr('game.yourTurn'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          _roundMark(t),
          if (p == 0) ...[
            const SizedBox(width: 10),
            _roundButton(t, Icons.more_horiz_rounded, tr('game.more'), _openMore),
            const SizedBox(width: 6),
            _roundButton(t, Icons.arrow_back_rounded, tr('common.menu'), () => Navigator.maybePop(context)),
          ] else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Sonido, tema, registro y abandonar: lo que no hace falta tener a la vista.
  void _openMore() {
    final dark = HexTheme.of(context).isDark;
    final sound = AppSettings.instance.sound;
    void run(BuildContext ctx, VoidCallback action) {
      Navigator.pop(ctx);
      action();
    }

    showSkinSheet<void>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_tutorial && _log.isNotEmpty) ...[
            SkinTile(title: tr('common.log'), glyph: '録', onTap: () => run(ctx, _showLog)),
            const SizedBox(height: 10),
          ],
          SkinTile(
            title: tr('common.sound'),
            glyph: sound ? '音' : '静',
            trailing: Icon(sound ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onTap: () => run(ctx, () => setState(() => AppSettings.instance.sound = !sound)),
          ),
          const SizedBox(height: 10),
          SkinTile(
            title: tr(dark ? 'common.lightTheme' : 'common.darkTheme'),
            glyph: dark ? '陽' : '陰',
            onTap: () => run(ctx, () {
              Haptics.select();
              AppSettings.instance.toggleBrightness(context);
            }),
          ),
          if (_ranked && !_reported) ...[
            const SizedBox(height: 10),
            SkinTile(title: tr('common.resign'), glyph: '降', onTap: () => run(ctx, _confirmResign)),
          ],
        ],
      ),
    );
  }

  DuelSide _side(int p) {
    final g = _game;
    final canEmote = !_tutorial && _isHuman(p);
    return DuelSide(
      profile: _profiles[p],
      active: g.current == p && !g.isOver,
      handCount: g.hands[p].values.fold(0, (a, b) => a + b),
      cooldown: g.cooldowns[p],
      charges: g.abilityChargesLeft(p),
      emote: _emote[p],
      emoteKey: _emoteKey[p],
      onEmote: canEmote ? () => _pickEmote(p) : null,
    );
  }

  /// Ronda en el centro del marcador; cambia de color cuando se acerca el
  /// Asedio y cuando ya empezó. El detalle va en el tooltip.
  Widget _roundMark(HexTheme t) {
    final g = _game;
    final skin = Skin.of(context);
    final limit = g.rules.roundLimit;
    if (limit == null) return Text('対', style: skin.glyph(23, color: t.gold));
    final siege = g.rules.siegeRound;
    final toSiege = siege == null ? null : siege - g.round;
    final active = g.inSiege;
    final soon = !active && toSiege != null && toSiege <= 3 && toSiege < (g.roundsLeft ?? 99);
    final ending = !active && (g.roundsLeft ?? 99) <= 3;
    final color = active ? t.danger : (soon || ending ? t.gold : t.text);
    final status = active
        ? tr('round.siegeActive', {'round': g.round, 'limit': limit})
        : soon
        ? trN('round.siegeIn', toSiege)
        : tr('round.ofLimit', {'round': g.round, 'limit': limit});
    return Tooltip(
      message: [
        status,
        if (siege != null) tr('round.siegeTip', {'n': siege}),
        tr('round.limitTip', {'n': limit}),
      ].join('\n'),
      triggerMode: TooltipTriggerMode.tap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: skin.display(24, color: color, height: 1),
            child: Text('${g.round}'),
          ),
          const SizedBox(height: 1),
          Text(
            '/$limit',
            style: TextStyle(
              color: active || soon || ending ? color : t.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
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
        padding: const EdgeInsets.all(12),
        onPressed: onTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => RotationTransition(
            turns: Tween(begin: 0.6, end: 1.0).animate(a),
            child: FadeTransition(opacity: a, child: c),
          ),
          child: Icon(icon, key: ValueKey(icon), color: onTap == null ? t.outline : t.text, size: 26),
        ),
      ),
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
                  color: t.surface.withValues(alpha: 0.9),
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
    showSkinSheet<void>(
      context,
      title: tr('common.log'),
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i == 0 || entries[i - 1].round != entries[i].round)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                child: Text(
                  tr('round.n', {'round': entries[i].round}),
                  style: TextStyle(color: t.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            Pressable(
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _lastMove = entries[i].e.cells);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(_eventIcon(entries[i].e), color: _eventColor(t, entries[i].e), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entries[i].e.text, style: TextStyle(color: t.text, fontSize: 13.5)),
                          Text(
                            _profiles[entries[i].e.player].nickname,
                            style: TextStyle(
                              color: HexTheme.faction(_game.factions[entries[i].e.player]),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Ayuda de la jugada: aparece sobre el tablero y se desvanece sola. Mientras
  /// piensa la IA o hay un efecto por resolver, queda fija.
  Widget _hintLine(HexTheme t) {
    if (_mode == _Mode.effect && (!_tutorial || _lessonSkipsEffect)) {
      return SizedBox(
        width: 230,
        child: SkinButton(label: tr('game.skipEffect'), height: 40, onPressed: () => _applyEffect(null)),
      );
    }
    return _FadingHint(text: _hint, thinking: _isAiTurn, hold: _isAiTurn);
  }

  Widget _board(HexTheme t, Set<Hex> targets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        if (!_centered) {
          _centered = true;
          // Centrado en la zona visible entre las barras superior e inferior.
          _transform.value = Matrix4.identity()
            ..translateByDouble(
              constraints.maxWidth / 2 - _canvas / 2,
              constraints.maxHeight / 2 - _canvas / 2 + (_tutorial || _init ? 50 : (_staged ? 15 : 0)),
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
            onLongPressStart: (d) => _showInfo(
              _layout.fromPixel(d.localPosition),
              // Cara a cara: quien toca en la mitad de arriba es el Jugador 2.
              by: _f2f && d.globalPosition.dy < MediaQuery.sizeOf(context).height / 2 ? 1 : 0,
            ),
            child: CustomPaint(
              size: const Size(_canvas, _canvas),
              painter: BoardPainter(
                game: _game,
                layout: _layout,
                theme: t,
                grid: ArenaBackdrop.gridColor(t),
                fx: _fx,
                selected: _mode == _Mode.effect ? _effectTo : _selected,
                targets: targets.difference(_swapTargets),
                swapTargets: _swapTargets,
                targetColor: _targetColor(t),
                lastMove: _lastMove,
                spotlight: _spotlight,
                flipOwner: _f2f ? 1 : null,
                viewer: widget.aiPlayer == null ? _game.current : _mySeat,
                opportunities: !(_stage?.isPuzzle ?? false),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Abajo: deshacer o reiniciar, la mano en un dock y el sello de la habilidad.
  Widget _dock(HexTheme t, {int? player}) {
    final g = _game;
    // Contra la IA la mano es siempre la tuya; en Pass & Play, la del turno;
    // cara a cara, cada uno tiene la suya.
    final me = player ?? (widget.aiPlayer != null ? 1 - widget.aiPlayer! : g.current);
    final allowed = _lesson?.hand;
    final placeable = me == g.current
        ? g
              .placeableTypes()
              .where((p) => allowed == null || allowed.contains(p))
              .where((p) => !_tutorial || _lessonActions.any((a) => a is PlaceAction && a.type == p))
              .toSet()
        : const <PieceType>{};
    final hand = g.hands[me].entries.where((e) => e.value > 0 && (!_tutorial || placeable.contains(e.key))).toList();
    final showHand = _tutorial ? hand.isNotEmpty : !(_stage?.isPuzzle ?? false) || hand.isNotEmpty;
    final showAbility = !_tutorial || _lesson!.ability;
    final secondary = player == null || player == g.current ? _secondaryAction(t) : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: !showHand
                ? const SizedBox(height: 56)
                : SkinBar(
                    tray: true,
                    radius: 22,
                    padding: const EdgeInsets.all(8),
                    child: hand.isEmpty
                        ? SizedBox(
                            height: 56,
                            child: Center(
                              child: Text(tr('game.emptyHand'), style: TextStyle(color: t.textMuted)),
                            ),
                          )
                        : _handGrid(
                            t,
                            [for (final e in hand) (e.key, e.value, placeable.contains(e.key) && !_locked)],
                            me,
                            maxRows: player == null ? 3 : 2,
                          ),
                  ),
          ),
          const SizedBox(width: 8),
          // Deshacer/reiniciar arriba del sello: la mano se queda con todo el ancho.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [?secondary, if (showAbility) _abilitySeal(t, me) else const SizedBox(width: 64, height: 68)],
          ),
        ],
      ),
    );
  }

  /// Deshacer (casual), reiniciar (etapas y lecciones). En partidas por puntos
  /// no hay: abandonar vive en el menú de más opciones.
  Widget? _secondaryAction(HexTheme t) {
    final Widget? b = _tutorial
        ? _roundButton(t, Icons.replay_rounded, tr('tutorial.restartLesson'), _restartLesson)
        : _staged
        ? _roundButton(t, Icons.replay_rounded, tr('common.restart'), _aiThinking ? null : _restartStage)
        : _ranked
        ? null
        : _roundButton(t, Icons.undo_rounded, tr('common.undo'), _history.isEmpty || _aiThinking ? null : _undo);
    if (b == null) return null;
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: b);
  }

  bool get _inAbility => switch (_mode) {
    _Mode.jadeRelocate || _Mode.jadeRelocateTarget || _Mode.jadeSwap || _Mode.jadeSwapTarget || _Mode.kawarimi => true,
    _ => false,
  };

  /// Sello de la habilidad: listo, en recarga (número) o gastado. Durante la
  /// habilidad, tocarlo la cancela.
  Widget _abilitySeal(HexTheme t, int me) {
    final g = _game;
    final faction = g.factions[me];
    final color = HexTheme.faction(faction);
    final cd = g.cooldowns[me];
    final charges = g.abilityChargesLeft(me);
    final ready = me == g.current && g.abilityAvailable && !_locked && (!_tutorial || _lessonWantsAbility);
    // En la lección de la habilidad el sello late para mostrar dónde tocar.
    final beckon = ready && _tutorial && _coach == CoachState.doing && !_inAbility;
    final cancel = _inAbility;
    final name = g.rules.dualAbility.contains(me)
        ? '${Faction.shaolin.abilityName} · ${Faction.ninja.abilityName}'
        : faction.abilityName;
    final label = charges == 0
        ? tr('game.abilitySpent', {'ability': name})
        : [name, if (cd > 0) '($cd)', if (charges != null) '×$charges'].join(' ');
    return Tooltip(
      message: cancel ? tr('common.cancel') : label,
      triggerMode: TooltipTriggerMode.manual,
      child: GestureDetector(
        onLongPress: () => _explainAbility(me),
        child: Pressable(
          onTap: cancel ? () => setState(_reset) : (ready ? _startAbility : null),
          child: SizedBox(
            width: 64,
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: ready || cancel ? 1 : 0.4,
                  child: _Pulse(
                    active: beckon,
                    child: KanjiBadge(faction == Faction.shaolin ? '玉' : '変', size: 58, color: color),
                  ),
                ),
                if (cancel)
                  const Icon(Icons.close_rounded, color: Colors.white, size: 28)
                else if (cd > 0 && charges != 0)
                  Positioned(top: 0, right: 0, child: _sealTag(t, '$cd', t.text)),
                if (!cancel && charges != null)
                  Positioned(bottom: 0, right: -2, child: _sealTag(t, '×$charges', t.gold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sealTag(HexTheme t, String s, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: t.surfaceHigh, width: 1.5),
    ),
    child: Text(
      s,
      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: t.surfaceHigh, height: 1.1),
    ),
  );

  /// La mano entera a la vista, sin scroll: hasta [maxRows] filas, y cuantas
  /// menos fichas quedan, más grandes se ven.
  Widget _handGrid(HexTheme t, List<(PieceType, int, bool)> items, int owner, {required int maxRows}) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 6.0;
        final n = items.length;
        final cap = (MediaQuery.sizeOf(context).height * 0.085).clamp(58.0, 96.0);
        double cellFor(int rows) {
          final cols = (n / rows).ceil();
          return min(cap, (c.maxWidth - gap * (cols - 1)) / cols);
        }

        // Otra fila solo si las fichas crecen de verdad.
        var rows = 1;
        for (var r = 2; r <= maxRows && r <= n; r++) {
          if (cellFor(r) > cellFor(rows) * 1.08) rows = r;
        }
        final cell = cellFor(rows);
        final base = n ~/ rows, extra = n % rows;
        var i = 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < rows; r++)
              Padding(
                padding: EdgeInsets.only(top: r == 0 ? 0 : gap),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var k = 0; k < base + (r < extra ? 1 : 0); k++, i++)
                      Padding(
                        padding: EdgeInsets.only(left: k == 0 ? 0 : gap),
                        child: _handItem(t, items[i].$1, items[i].$2, owner, enabled: items[i].$3, cell: cell),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _handItem(HexTheme t, PieceType type, int count, int owner, {required bool enabled, required double cell}) {
    final selected = _mode == _Mode.placing && _placing == type;
    // Iniciación: la ficha que el Sensei sugiere colocar late en la mano.
    final suggested =
        _init &&
        enabled &&
        _mode == _Mode.idle &&
        _suggestion is PlaceAction &&
        (_suggestion as PlaceAction).type == type;
    // Sin nombre a la vista: el tooltip (manual) lo da a lectores de pantalla
    // y mantener apretado abre la ficha con sus reglas.
    return Tooltip(
      message: type.displayName,
      triggerMode: TooltipTriggerMode.manual,
      child: GestureDetector(
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
        onLongPress: () => showSkinDialog<void>(
          context,
          flipped: _flipFor(owner),
          builder: (ctx) => SkinDialog(
            title: type.displayName,
            message: type.rulesText,
            body: PieceChip(type: type, owner: owner, size: 26),
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.35,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: cell,
            height: cell,
            alignment: Alignment.center,
            // Cada ficha en su hueco de la bandeja, para distinguirlas.
            decoration: BoxDecoration(
              color: selected ? t.highlight.withValues(alpha: 0.18) : t.text.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(cell * 0.22),
              border: Border.all(
                color: selected
                    ? t.highlight
                    : suggested
                    ? t.gold
                    : t.outline.withValues(alpha: 0.5),
                width: suggested ? 2.4 : 1.6,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // La ficha elegida "se levanta" de la mano.
                _Pulse(
                  active: suggested,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: selected ? 0.4 : 0),
                    duration: const Duration(milliseconds: 260),
                    curve: selected ? Curves.easeOutBack : Curves.easeIn,
                    builder: (_, lift, _) => PieceChip(
                      type: type,
                      owner: owner,
                      size: cell * 0.46,
                      lift: lift,
                      mirror: _game.factions[0] == _game.factions[1],
                      ash: _game.factions[owner] == Faction.oni,
                    ),
                  ),
                ),
                if (count > 1)
                  Positioned(
                    right: -cell * 0.2,
                    top: -cell * 0.12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: t.text, borderRadius: BorderRadius.circular(9)),
                      child: Text(
                        '×$count',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: t.surfaceHigh),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto de ayuda que entra con un fundido y se va a los pocos segundos.
/// Late suave mientras está activo.
class _Pulse extends StatefulWidget {
  final bool active;
  final Widget child;
  const _Pulse({required this.active, required this.child});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Pulse old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active && _c.isAnimating) {
      _c.animateTo(0, duration: const Duration(milliseconds: 150));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 1.0, end: 1.16).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: widget.child,
  );
}

class _FadingHint extends StatefulWidget {
  final String text;
  final bool thinking;

  /// No se desvanece (por ejemplo, mientras piensa la IA).
  final bool hold;
  const _FadingHint({required this.text, required this.thinking, required this.hold});

  @override
  State<_FadingHint> createState() => _FadingHintState();
}

class _FadingHintState extends State<_FadingHint> {
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(_FadingHint old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.hold != widget.hold) {
      _visible = true;
      _arm();
    }
  }

  void _arm() {
    _timer?.cancel();
    if (widget.hold) return;
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HexTheme.of(context);
    final text = widget.text;
    return SizedBox(
      height: 30,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: _visible ? 200 : 900),
        opacity: _visible && text.isNotEmpty ? 1 : 0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: text.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  key: ValueKey(text),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.surface.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.thinking) ...[
                        SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(strokeWidth: 1.8, color: t.textMuted),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: t.textMuted, fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
