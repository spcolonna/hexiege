// ignore_for_file: avoid_print
// Simulación de balance IA vs IA (en paralelo, un isolate por núcleo).
// Uso: dart run tool/balance.dart [partidas por orden=20] [nivel=easy] [maxTurnos=200] [opciones]
// Opciones de reglas (por defecto, las oficiales; --clasicas parte de las del prototipo):
//   --sin-habilidades   --cd=N   --cargas=N   --shinobi=N   --grulla=2|12   --tengu=N   --asedio=N --rondas=N (0 = sin)
//   --mano=shinobi:2,kitsune:3   (cambia cantidades; la facción sale del tipo de ficha)
//   --detalle           uso de habilidades y llegada de cada ficha al Líder rival
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
  final wins = {for (final f in Faction.values) f.name: 0};
  var draws = 0,
      timeouts = 0,
      firstPlayerWins = 0,
      totalPlies = 0,
      decided = 0,
      bySiege = 0,
      firstSiegeWins = 0,
      siegeDecided = 0;
  final abilities = <String, int>{};
  final arrivals = <String, int>{};
  final uses = <String, int>{};
  final lengths = <int>[];

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
    o.abilities.forEach((k, v) => add(k, abilities, v));
    o.arrivals.forEach((k, v) => add(k, arrivals, v));
    o.uses.forEach((k, v) => add(k, uses, v));
    lengths.addAll(o.lengths);
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
      var ply = 0;
      for (; ply < maxPlies && !g.isOver; ply++) {
        final me = g.current;
        for (final a in ais[me].chooseTurn(g)) {
          _record(st, g, a);
          a.apply(g);
        }
        if (!g.isOver) g.endTurn();
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

/// Clasifica cada acción: si una habilidad salva al propio Líder y qué fichas
/// alcanzan al Líder rival.
void _record(Stats st, GameState g, AiAction a) {
  final me = g.current;
  final mine = g.board.locateLeader(me), theirs = g.board.locateLeader(1 - me);
  bool near(Hex? l, Hex h) => l != null && l.distanceTo(h) == 1;
  final f = g.factions[me].name;
  switch (a) {
    case KawarimiAction(:final at):
      st.add('$f kawarimi ${near(mine, at) ? 'defensiva' : 'otra'}', st.abilities);
    case JadeRelocateAction(:final from, :final to):
      st.add('$f jade ${near(mine, from) ? 'defensiva' : (near(theirs, to) ? 'ofensiva' : 'otra')}', st.abilities);
    case JadeSwapAction():
      st.add('$f jade intercambio', st.abilities);
    case PlaceAction(:final type, :final at):
      st.add(type.name, st.uses);
      if (near(theirs, at)) st.add(type.name, st.arrivals);
    case MoveAction(:final from, :final to):
      final t = g.board.top(from)!.type.name;
      st.add(t, st.uses);
      if (near(theirs, to) && !near(theirs, from)) st.add(t, st.arrivals);
    case SwapAction():
  }
}

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
  for (final f in Faction.values) {
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
    print('  Habilidades:');
    for (final e in st.abilities.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      print('    ${e.key}: ${e.value}');
    }
    print('  Llega junto al Líder rival (veces / % de sus jugadas):');
    final rows = st.uses.keys.toList()
      ..sort((a, b) => (st.arrivals[b] ?? 0) / st.uses[b]! > (st.arrivals[a] ?? 0) / st.uses[a]! ? 1 : -1);
    for (final k in rows) {
      print('    ${k.padRight(9)} ${st.arrivals[k] ?? 0} / ${pct(st.arrivals[k] ?? 0, st.uses[k])}');
    }
  }
}
