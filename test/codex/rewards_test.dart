import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/codex/avatars.dart';
import 'package:hexiege/codex/cosmetics.dart';
import 'package:hexiege/codex/rewards.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/solo/catalog.dart';
import 'package:hexiege/ui/theme/settings.dart';

void main() {
  final allStages = [for (final c in campaigns) ...c.stages.map((s) => s.id)];
  setUp(() => setLanguage('es'));
  tearDown(() => AppSettings.instance.resetStory(allStages));

  test('cada cosmético que no es inicial se gana en la campaña, una sola vez', () {
    final keys = Reward.all.map((r) => r.key).toList();
    expect(keys.toSet().length, keys.length);
    for (final a in Avatars.all) {
      final initial = playableFactions.any((f) => Avatars.defaultFor(f) == a.id);
      expect(Reward.of(RewardKind.avatar, a.id) == null, initial, reason: a.id);
    }
    for (final f in Cosmetics.frames) {
      expect(Reward.of(RewardKind.frame, f.id), isNotNull, reason: f.id);
    }
    for (final t in Cosmetics.tables) {
      expect(Reward.of(RewardKind.table, t.id), isNotNull, reason: t.id);
    }
    for (final st in Cosmetics.stones.where((s) => !s.isClassic)) {
      expect(Reward.of(RewardKind.stone, st.id, st.faction), isNotNull, reason: st.id);
    }
    for (final r in Reward.all) {
      expect(tr(r.nameKey), isNot(r.nameKey));
      expect(tr(r.hintKey, r.hintArgs), isNot(contains('{')));
    }
  });

  test('sin campaña, todo cerrado salvo lo inicial', () {
    expect(Reward.all.where((r) => r.isEarned), isEmpty);
    expect(Reward.isOpen(RewardKind.frame, null), isTrue);
    expect(Reward.isOpen(RewardKind.table, null), isTrue);
    expect(Reward.isOpen(RewardKind.stone, Cosmetics.classic, Faction.ninja), isTrue);
    expect(Reward.isOpen(RewardKind.avatar, 'novice'), isTrue);
  });

  test('lo guardado sin ganar no se muestra; al ganarlo, sí', () {
    final s = AppSettings.instance;
    s
      ..avatar = 'staff'
      ..frame = 'bronze'
      ..table = 'temple_wood'
      ..setStone(Faction.shaolin, 'sandstone');
    expect(s.avatarFor(Faction.shaolin), 'novice');
    expect(s.frame, isNull);
    expect(s.table, isNull);
    expect(s.stoneFor(Faction.shaolin), Cosmetics.classic);

    for (final st in shaolinCampaign.take(8)) {
      s.markCleared(st.id);
    }
    expect(s.avatarFor(Faction.shaolin), 'staff');
    expect(s.frame, 'bronze');
    expect(s.table, 'temple_wood');
    expect(s.stoneFor(Faction.shaolin), 'sandstone');
    s
      ..avatar = null
      ..frame = null
      ..table = null
      ..setStone(Faction.shaolin, Cosmetics.classic);
  });

  test('los marcos neutrales se ganan desde cualquiera de las dos campañas', () {
    final bronze = Reward.of(RewardKind.frame, 'bronze')!;
    expect(bronze.isEarned, isFalse);
    AppSettings.instance.markCleared(ninjaCampaign[7].id);
    expect(bronze.isEarned, isTrue);
  });

  test('cada premio se anuncia una sola vez', () {
    for (final st in shaolinCampaign.take(3)) {
      AppSettings.instance.markCleared(st.id);
    }
    final fresh = Reward.takeNew();
    expect(fresh.map((r) => r.key), containsAll(['table:temple_wood', 'avatar:staff']));
    expect(Reward.takeNew(), isEmpty);
  });
}
