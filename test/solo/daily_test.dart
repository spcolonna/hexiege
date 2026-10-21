import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/solo/daily.dart';
import 'package:hexiege/solo/daily_pool.dart';
import 'package:hexiege/solo/solver.dart';
import 'package:hexiege/ui/theme/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('el desafío del día tiene solución en 2 y no en 1, también girado', () {
    final n = dailyPool.length;
    // Seis días que caen en posiciones distintas del banco y con cada giro.
    for (var turn = 0; turn < 6; turn++) {
      final g = Daily.forDay(turn * n + turn * 13).build();
      expect(forcedWin(g, 1), isNull, reason: 'giro $turn');
      expect(forcedWin(g, 2), isNotNull, reason: 'giro $turn');
    }
  });

  test('el día cambia a medianoche local', () {
    expect(Daily.dayOf(DateTime(2026, 1, 1, 23, 59)), 0);
    expect(Daily.dayOf(DateTime(2026, 1, 2, 0, 1)), 1);
  });

  test('la racha sube con días seguidos y se corta si se saltea uno', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppSettings.instance;
    await s.load();
    s.solveDaily(100);
    s.solveDaily(100);
    s.solveDaily(101);
    expect(s.dailyStreakOn(101), 2);
    expect(s.dailyStreakOn(102), 2, reason: 'hoy todavía se puede seguir');
    expect(s.dailyStreakOn(103), 0);
    s.solveDaily(103);
    expect(s.dailyStreakOn(103), 1);
    expect(s.dailyBest, 2);
  });
}
