import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/engine/ai.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/match/ladder.dart';
import 'package:hexiege/match/matchmaker.dart';

LadderRecord play(LadderRecord r, List<MatchResult> results) => results.fold(r, (acc, x) => acc.apply(x));

const w = MatchResult.win, l = MatchResult.loss;

void main() {
  group('puntos y rachas', () {
    test('jugador nuevo arranca como Discípulo contra IA Fácil', () {
      const r = LadderRecord();
      expect(r.rating, 1000);
      expect(r.rank, Rank.disciple);
      expect(r.targetLevel, AiLevel.easy);
    });

    test('ganar en racha suma un extra; perder resta fijo', () {
      final r = play(const LadderRecord(), [w, w, w, w]);
      // 25, 25, 25+5, 25+10
      expect(r.rating, 1000 + 25 + 25 + 30 + 35);
      expect(r.streak, 4);
      expect(r.apply(l).rating, r.rating - 20);
      expect(r.apply(l).streak, -1);
    });

    test('racha de victorias sube la IA un escalón; de derrotas, la baja', () {
      final hot = play(const LadderRecord(), [w, w, w]);
      expect(hot.rank, Rank.warrior); // 1080 → franja Normal
      expect(hot.targetLevel, AiLevel.hard); // +1 por racha

      final cold = play(const LadderRecord(), [l, l, l]);
      expect(cold.rank, Rank.disciple); // 940
      expect(cold.targetLevel, AiLevel.novice); // -1 por racha

      final freezing = play(const LadderRecord(), [l, l, l, l, l]);
      expect(freezing.targetLevel, AiLevel.novice); // no baja de Aprendiz
    });

    test('una victoria corta la mala racha', () {
      final r = play(const LadderRecord(), [l, l, l, w]);
      expect(r.streak, 1);
      expect(r.targetLevel, r.rank.level);
    });

    test('los puntos no bajan del mínimo y el pico se conserva', () {
      final r = play(const LadderRecord(), List.filled(40, l));
      expect(r.rating, LadderRecord.minRating);
      expect(r.peak, 1000);
    });

    test('ida y vuelta a JSON', () {
      final r = play(const LadderRecord(), [w, l, w, w, MatchResult.draw]);
      final back = LadderRecord.fromJson(r.toJson());
      expect(back.toJson(), r.toJson());
    });
  });

  group('emparejamiento simulado', () {
    test('busca, amplía el rango y encuentra rival', () async {
      final events = await BotMatchmaker(
        seed: 1,
        waitScale: 0,
      ).search(const MatchRequest(nickname: 'Seba', faction: Faction.shaolin, record: LadderRecord())).toList();
      expect(events.first, isA<Searching>());
      expect(events.last, isA<Found>());
      final m = (events.last as Found).match;
      expect(m.yourFaction, Faction.shaolin);
      expect(m.opponent.bot, isNotNull);
    });

    test('el nivel del rival sigue a la racha, con variación de un escalón como mucho', () {
      for (final record in [
        const LadderRecord(),
        play(const LadderRecord(), [w, w, w, w, w, w]),
        play(const LadderRecord(), [l, l, l, l]),
      ]) {
        final mm = BotMatchmaker(seed: 7);
        final counts = <AiLevel, int>{};
        for (var i = 0; i < 300; i++) {
          final m = mm.pickMatch(MatchRequest(nickname: 'x', faction: Faction.ninja, record: record));
          final lvl = m.opponent.bot!;
          counts[lvl] = (counts[lvl] ?? 0) + 1;
          expect((lvl.index - record.targetLevel.index).abs(), lessThanOrEqualTo(1));
        }
        expect(counts[record.targetLevel]!, greaterThan(200), reason: '$counts');
      }
    });

    test('los puntos del rival caen en la franja de su nivel', () {
      final mm = BotMatchmaker(seed: 3);
      for (var i = 0; i < 200; i++) {
        final m = mm.pickMatch(const MatchRequest(nickname: 'x', faction: Faction.ninja, record: LadderRecord()));
        expect(Rank.of(m.opponent.rating).level, m.opponent.bot);
      }
    });

    test('los nicks de los bots entran en el límite de 16 caracteres', () {
      final rng = Random(0);
      for (var i = 0; i < 2000; i++) {
        expect(botName(rng).length, lessThanOrEqualTo(16));
      }
    });
  });
}
