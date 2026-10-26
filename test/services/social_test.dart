import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/services/games.dart';
import 'package:hexiege/services/social.dart';
import 'package:hexiege/solo/campaign.dart';
import 'package:hexiege/ui/theme/settings.dart';

void main() {
  setUp(() => setLanguage('es'));

  group('DailyShare', () {
    test('muestra turnos usados y racha, sin la posición', () {
      final t = DailyShare.text(day: 298, used: 1, turns: 2, streak: 5);
      expect(t, contains('#299'));
      expect(t, contains('⬢⬡'));
      expect(t, contains('1 de 2'));
      expect(t, contains('5 días'));
    });

    test('sin racha no muestra la llama', () {
      final t = DailyShare.text(day: 0, used: 2, turns: 2, streak: 1);
      expect(t, contains('⬢⬢'));
      expect(t, isNot(contains('🔥')));
    });

    test('existe en los tres idiomas', () {
      for (final l in supportedLanguages) {
        setLanguage(l);
        final t = DailyShare.text(day: 3, used: 1, turns: 2, streak: 3);
        expect(t, isNot(contains('share.')), reason: l);
        expect(t, isNot(contains('{')), reason: l);
      }
    });
  });

  group('Games.earned', () {
    final s = AppSettings.instance;
    final story = [for (final c in campaigns) ...c.stages.map((x) => x.id)];
    tearDown(() => s.resetStory(story));

    test('el primer jefe es la batalla 6', () {
      s.markCleared(shaolinCampaign[4].id);
      expect(Games.earned(s), isNot(contains(Feat.firstBoss)));
      s.markCleared(shaolinCampaign[5].id);
      expect(Games.earned(s), containsAll([Feat.firstWin, Feat.firstBoss]));
    });

    test('terminar cada campaña y El Sello', () {
      s.markCleared(ninjaCampaign.last.id);
      expect(Games.earned(s), contains(Feat.ninjaDone));
      expect(Games.earned(s), isNot(contains(Feat.shaolinDone)));
      s.markCleared(finale.last.id);
      expect(Games.earned(s), contains(Feat.seal));
    });
  });

  test('textos del aviso diario en los tres idiomas', () {
    for (final l in supportedLanguages) {
      setLanguage(l);
      for (final k in ['reminder.body', 'reminder.offerTitle', 'settings.reminder', 'games.title']) {
        expect(tr(k), isNot(k), reason: '$l $k');
      }
      expect(tr('reminder.streak', {'n': 4}), contains('4'));
      expect(tr('reminder.offerText', {'hour': '19:00'}), contains('19:00'));
    }
  });
}
