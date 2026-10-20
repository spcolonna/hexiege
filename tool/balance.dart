// ignore_for_file: avoid_print
// Simulación de balance IA vs IA (en paralelo, un isolate por núcleo).
// Uso: dart run tool/balance.dart [partidas por orden=20] [nivel=easy] [maxTurnos=200] [opciones]
// Opciones de reglas (por defecto, las oficiales; --clasicas parte de las del prototipo):
//   --sin-habilidades   --cd=N   --cargas=N   --shinobi=N   --grulla=2|12   --tengu=N   --asedio=N --rondas=N (0 = sin)
//   --mano=shinobi:2,kitsune:3   (cambia cantidades; la facción sale del tipo de ficha)
//   --tengu-lider=allowed|notClosing|never   (Tengu junto al Líder rival; notClosing = sin cerrar el cerco)
//   --shinobi-lider=0|1 (0: el Shinobi no cruza compuertas para llegar junto al Líder rival)
//   --sin-intercambio   --sin-paralisis   --sin-sello   (apagan efectos de unidad Ninja)
//   --detalle           uso de habilidades y efectos (y si preceden a una victoria) y
//                       llegada de cada ficha al Líder rival
import 'dart:io';
import 'dart:isolate';

import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/game_state.dart';
import 'package:hexiege/engine/hex.dart';
import 'package:hexiege/engine/pieces.dart';

Rules parseRules(List<String> flags) {
  var r = flags.contains('--clasicas') ? Rules.classic : Rules.standard;
  String? opt(String name) {
    for (final f in flags) {
      if (f.startsWith('--$name=')) return f.substring(name.length + 3);
    }
    return null;
  }

  if (opt('cd') case final v?) r = r.copyWith(abilityCooldown: int.parse(v));
  if (opt('cargas') case final v?) r = r.copyWith(abilityCharges: () => int.parse(v));
  if (opt('shinobi') case final v?) r = r.copyWith(shinobiRange: () => int.parse(v));
  if (opt('grulla') case final v?) r = r.copyWith(craneShortJump: v == '12');
  if (opt('tengu') case final v?) r = r.copyWith(tenguMinTouch: int.parse(v));
  if (opt('asedio') case final v?) r = r.copyWith(siegeRound: () => v == '0' ? null : int.parse(v));
  if (opt('rondas') case final v?) r = r.copyWith(roundLimit: () => v == '0' ? null : int.parse(v));
  if (opt('tengu-lider') case final v?) r = r.copyWith(tenguNearLeader: TenguNearLeader.values.byName(v));
  if (opt('shinobi-lider') case final v?) r = r.copyWith(shinobiGateNextToLeader: v == '1');
  if (flags.contains('--sin-intercambio')) r = r.copyWith(shogunSwap: false);
  if (flags.contains('--sin-paralisis')) r = r.copyWith(kunoichiParalysis: false);
  if (flags.contains('--sin-sello')) r = r.copyWith(shadowSeal: false);
  if (opt('mano') case final v?) {
    final hands = {for (final e in r.hands.entries) e.key: Map.of(e.value)};
    for (final kv in v.split(',')) {
      final [name, n] = kv.split(':');
      final t = PieceType.values.byName(name);
      hands[t.faction]![t] = int.parse(n);
    }
    r = r.copyWith(hands: hands);
  }
  return r;
}

class Stats {
  final wins = {for (final f in playableFactions) f.name: 0};
  var draws = 0,
      timeouts = 0,
      firstPlayerWins = 0,
      totalPlies = 0,
      decided = 0,
      bySiege = 0,
      firstSiegeWins = 0,
      siegeDecided = 0;
  final arrivals = <String, int>{};
  final uses = <String, int>{};

  /// Por "facción efecto": usos totales, partidas con ≥1 uso, de esas cuántas
  /// ganó quien lo usó, y usos en los últimos 2 turnos propios antes de ganar.
  /// Ficha cuya llegada completa el cerco ganador ("facción tipo").
  final closers = <String, int>{};
  final fxUses = <String, int>{}, fxGames = <String, int>{}, fxWins = <String, int>{}, fxFinal = <String, int>{};
  final lengths = <int>[];

  /// Profundidad completada por la búsqueda (Difícil/Maestro): suma y turnos.
  final depthSum = <String, int>{}, depthTurns = <String, int>{};

  void add(String k, Map<String, int> m, [int n = 1]) => m[k] = (m[k] ?? 0) + n;

  void merge(Stats o) {
    o.wins.forEach((k, v) => add(k, wins, v));
    draws += o.draws;
    timeouts += o.timeouts;
    firstPlayerWins += o.firstPlayerWins;
    totalPlies += o.totalPlies;
    decided += o.decided;
    bySiege += o.bySiege;
    firstSiegeWins += o.firstSiegeWins;
    siegeDecided += o.siegeDecided;
    o.arrivals.forEach((k, v) => add(k, arrivals, v));
    o.uses.forEach((k, v) => add(k, uses, v));
    o.closers.forEach((k, v) => add(k, closers, v));
    o.fxUses.forEach((k, v) => add(k, fxUses, v));
    o.fxGames.forEach((k, v) => add(k, fxGames, v));
    o.fxWins.forEach((k, v) => add(k, fxWins, v));
    o.fxFinal.forEach((k, v) => add(k, fxFinal, v));
    lengths.addAll(o.lengths);
    o.depthSum.forEach((k, v) => add(k, depthSum, v));
    o.depthTurns.forEach((k, v) => add(k, depthTurns, v));
  }
}

/// Juega las partidas [from]..[to) de cada orden de facciones.
Stats simulate(Rules rules, AiLevel level, int from, int to, int maxPlies, bool abilities) {
  final st = Stats();
  for (final order in [
    [Faction.shaolin, Faction.ninja],
    [Faction.ninja, Faction.shaolin],
  ]) {
    for (var i = from; i < to; i++) {
      final g = GameState(order[0], order[1], rules: rules);
      final ais = [
        AiPlayer(level, seed: i * 2, useAbilities: abilities),
        AiPlayer(level, seed: i * 2 + 1, useAbilities: abilities),
      ];
      final events = <(int, int, String)>[]; // (jugador, ply, "facción efecto")
      var ply = 0;
      for (; ply < maxPlies && !g.isOver; ply++) {
        final me = g.current;
        final turn = ais[me].chooseTurn(g);
        if (ais[me].lastDepth > 0) {
          st.add(g.factions[me].name, st.depthSum, ais[me].lastDepth);
          st.add(g.factions[me].name, st.depthTurns);
        }
        for (final a in turn) {
          for (final (p, fx) in _record(st, g, a)) {
            events.add((p, g.ply, '${g.factions[p].name} $fx'));
          }
          if (g.winner == me) st.add('${g.factions[me].name} ${_closer(g, a)}', st.closers);
        }
        if (turn.isEmpty) g.pass();
      }
      for (final (p, at, k) in events) {
        st.add(k, st.fxUses);
        if (g.winner == p && g.ply - at < 4) st.add(k, st.fxFinal);
      }
      for (final (p, k) in {for (final (p, _, k) in events) (p, k)}) {
        st.add(k, st.fxGames);
        if (g.winner == p) st.add(k, st.fxWins);
      }
      if (g.endedByLimit) st.timeouts++;
      if (g.isOver && g.inSiege && !g.endedByLimit) {
        st.bySiege++;
        if (g.winner != null) st.siegeDecided++;
        if (g.winner == 0) st.firstSiegeWins++;
      }
      if (g.winner != null) {
        st.add(g.factions[g.winner!].name, st.wins);
        if (g.winner == 0) st.firstPlayerWins++;
        st.totalPlies += ply;
        st.lengths.add(ply);
        st.decided++;
      } else if (g.draw && !g.endedByLimit) {
        st.draws++;
      } else if (!g.isOver) {
        st.timeouts++;
      }
    }
  }
  return st;
}

/// Aplica [a] y devuelve los efectos que produjo (jugador, efecto). También
/// cuenta qué fichas alcanzan al Líder rival.
List<(int, String)> _record(Stats st, GameState g, AiAction a) {
  final me = g.current, opp = 1 - me;
  final mine = g.board.locateLeader(me), theirs = g.board.locateLeader(opp);
  bool near(Hex? l, Hex h) => l != null && l.distanceTo(h) == 1;
  final fx = <(int, String)>[];
  String leader(Hex h) => g.board.top(h)!.type.isLeader ? ' al Líder' : '';
  final sealsBefore = Map.of(g.seals);
  final enemyBefore = {
    for (final e in g.board.tops)
      if (e.value.owner == opp) e.key,
  };
  final pressureBefore = g.leaderPressure(me);
  switch (a) {
    case KawarimiAction(:final at):
      fx.add((me, 'kawarimi ${near(mine, at) ? 'defensiva' : (near(theirs, at) ? 'ofensiva' : 'otra')}'));
    case JadeRelocateAction(:final from, :final to):
      fx.add((me, 'jade ${near(mine, from) ? 'defensiva' : (near(theirs, to) ? 'ofensiva' : 'otra')}'));
    case JadeSwapAction():
      fx.add((me, 'jade intercambio'));
    case PlaceAction(:final type, :final at):
      st.add(type.name, st.uses);
      if (near(theirs, at)) st.add(type.name, st.arrivals);
    case MoveAction(:final from, :final to, :final paralyze, :final seal):
      final t = g.board.top(from)!.type;
      st.add(t.name, st.uses);
      if (near(theirs, to) && !near(theirs, from)) st.add(t.name, st.arrivals);
      if (paralyze != null) fx.add((me, 'parálisis Kunoichi${leader(paralyze)}'));
      if (seal != null) fx.add((me, 'sello colocado'));
    case SwapAction():
  }
  a.apply(g);
  if (a is SwapAction) {
    final after = g.leaderPressure(me);
    fx.add((me, 'intercambio Shogun ${after < pressureBefore ? 'escape' : 'otro'} ($pressureBefore→$after)'));
  }
  for (final e in sealsBefore.entries) {
    if (!g.seals.containsKey(e.key) && e.value != me) fx.add((e.value, 'sello activado${leader(e.key)}'));
  }
  if (a is MoveAction && g.board.top(a.to)?.type == PieceType.tiger) {
    final enemyAfter = {
      for (final e in g.board.tops)
        if (e.value.owner == opp) e.key,
    };
    if (enemyAfter.difference(enemyBefore).isNotEmpty) fx.add((me, 'empuje Tigre'));
  }
  return fx;
}

String _closer(GameState g, AiAction a) => switch (a) {
  PlaceAction(:final type) => '${type.name} (colocada)',
  MoveAction(:final to) => g.board.top(to)!.type.name,
  SwapAction() => 'intercambio Shogun',
  KawarimiAction() => 'kawarimi',
  JadeRelocateAction() => 'jade',
  JadeSwapAction() => 'jade intercambio',
};

Future<void> main(List<String> allArgs) async {
  final flags = allArgs.where((a) => a.startsWith('--')).toList();
  final args = allArgs.where((a) => !a.startsWith('--')).toList();
  final games = args.isNotEmpty ? int.parse(args[0]) : 20;
  final level = args.length > 1 ? AiLevel.values.byName(args[1]) : AiLevel.easy;
  final maxPlies = args.length > 2 ? int.parse(args[2]) : 200;
  final abilities = !flags.contains('--sin-habilidades');
  final rules = parseRules(flags);

  final sw = Stopwatch()..start();
  final workers = Platform.numberOfProcessors.clamp(1, games);
  final chunks = [for (var w = 0; w < workers; w++) (games * w ~/ workers, games * (w + 1) ~/ workers)];
  final parts = await Future.wait([
    for (final (from, to) in chunks) Isolate.run(() => simulate(rules, level, from, to, maxPlies, abilities)),
  ]);
  final st = Stats();
  for (final p in parts) {
    st.merge(p);
  }

  final total = games * 2;
  String pct(int n, [int? of]) => '${(100 * n / (of ?? total)).toStringAsFixed(0)}%';
  print('Nivel ${level.name}${abilities ? '' : ' (sin habilidades)'}, $total partidas (${sw.elapsed.inSeconds}s)');
  print('  Reglas: $rules');
  for (final f in playableFactions) {
    print('  ${f.displayName.padRight(16)} ${st.wins[f.name]} victorias (${pct(st.wins[f.name]!)})');
  }
  print(
    '  Empates: ${st.draws}  Sin terminar (límite de rondas o $maxPlies turnos): ${st.timeouts} (${pct(st.timeouts)})  '
    'Terminan en Asedio: ${st.bySiege} (${pct(st.bySiege)})',
  );
  if (st.decided > 0) {
    final byRing = st.decided - st.siegeDecided;
    print(
      '  Gana quien empieza: ${st.firstPlayerWins}/${st.decided} (${pct(st.firstPlayerWins, st.decided)}) · '
      'por cerco ${st.firstPlayerWins - st.firstSiegeWins}/$byRing · por Asedio ${st.firstSiegeWins}/${st.siegeDecided}',
    );
    final l = st.lengths..sort();
    int q(double f) => l[(l.length * f).floor().clamp(0, l.length - 1)];
    print(
      '  Duración de partidas decididas: media ${(st.totalPlies / st.decided).toStringAsFixed(0)} turnos, '
      'mediana ${q(.5)}, p90 ${q(.9)}',
    );
  }
  if (flags.contains('--detalle')) {
    if (st.depthTurns.isNotEmpty) {
      print(
        '  Profundidad media de búsqueda: '
        '${st.depthTurns.keys.map((f) => '$f ${(st.depthSum[f]! / st.depthTurns[f]!).toStringAsFixed(2)}').join(' · ')}',
      );
    }
    print('  Cierra el cerco ganador:');
    for (final e in st.closers.entries.toList()..sort((a, b) => b.value - a.value)) {
      print('    ${e.key.padRight(28)} ${e.value}');
    }
    print('  Efectos: usos · partidas con uso · gana quien lo usa · usos en sus 2 últimos turnos antes de ganar');
    for (final k in st.fxUses.keys.toList()..sort()) {
      final games = st.fxGames[k]!, wins = st.fxWins[k] ?? 0;
      print(
        '    ${k.padRight(40)} ${'${st.fxUses[k]}'.padLeft(5)} · ${'$games'.padLeft(3)} · '
        '${pct(wins, games).padLeft(4)} · ${st.fxFinal[k] ?? 0}',
      );
    }
    print('  Llega junto al Líder rival (veces / % de sus jugadas):');
    final rows = st.uses.keys.toList()
      ..sort((a, b) => (st.arrivals[b] ?? 0) / st.uses[b]! > (st.arrivals[a] ?? 0) / st.uses[a]! ? 1 : -1);
    for (final k in rows) {
      print('    ${k.padRight(9)} ${st.arrivals[k] ?? 0} / ${pct(st.arrivals[k] ?? 0, st.uses[k])}');
    }
  }
}
