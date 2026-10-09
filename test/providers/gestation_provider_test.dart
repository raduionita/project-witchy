import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  group('gestation math', () {
    test('LMP today is week 0 day 0 with a full term ahead', () {
      final g = GestationProvider(prefs, lmpDate: DateTime.now());
      expect(g.days(), 0);
      expect(g.week(), 0);
      expect(g.dayOfWeek(), 0);
      expect(g.progress(), 0);
      expect(g.daysRemaining(), 280);
      expect(g.daysPastDue(), 0);
      expect(g.trimester(), 1);
    });

    test('day 84 is week 12 with 196 days remaining', () {
      final today = DateTime(2026, 10, 9);
      final g = GestationProvider(prefs, lmpDate: today.subtract(const Duration(days: 84)));
      expect(g.days(today: today), 84);
      expect(g.week(today: today), 12);
      expect(g.dayOfWeek(today: today), 0);
      expect(g.daysRemaining(today: today), 196);
      expect(g.trimester(today: today), 1);
    });

    test('280 boundary clamps progress and clears the countdown', () {
      final today = DateTime(2026, 10, 9);
      final g = GestationProvider(prefs, lmpDate: today.subtract(const Duration(days: 280)));
      expect(g.progress(today: today), 1.0);
      expect(g.daysRemaining(today: today), 0);
      expect(g.daysPastDue(today: today), 0);
      expect(g.trimester(), 3);
    });

    test('past due counts over days but never negative progress', () {
      final today = DateTime(2026, 10, 9);
      final g = GestationProvider(prefs, lmpDate: today.subtract(const Duration(days: 285)));
      expect(g.progress(today: today), 1.0);
      expect(g.daysRemaining(today: today), 0);
      expect(g.daysPastDue(today: today), 5);
    });

    test('future LMP clamps to week 0', () {
      final g = GestationProvider(prefs, lmpDate: DateTime.now().add(const Duration(days: 3)));
      expect(g.days(), 0);
      expect(g.week(), 0);
    });

    test('due date is LMP plus 280 days', () {
      final g = GestationProvider(prefs, lmpDate: DateTime(2026, 1, 5));
      expect(g.dueDate, DateTime(2026, 1, 5).add(const Duration(days: 280)));
    });

    test('trimester boundaries at weeks 13 and 28', () {
      final today = DateTime(2026, 10, 9);
      GestationProvider at(int days) => GestationProvider(prefs, lmpDate: today.subtract(Duration(days: days)));
      expect(at(90).week(today: today), 12);
      expect(at(90).trimester(today: today), 1);
      expect(at(91).week(today: today), 13);
      expect(at(91).trimester(today: today), 2);
      expect(at(195).trimester(today: today), 2);
      expect(at(196).week(today: today), 28);
      expect(at(196).trimester(today: today), 3);
    });
  });

  test('setLmp normalizes to date-only and persists across reload', () async {
    final g = GestationProvider(prefs);
    expect(g.hasLmp, isFalse);
    expect(g.dueDate, isNull);
    await g.setLmp(DateTime(2026, 6, 15, 14, 30));
    expect(g.lmpDate, DateTime(2026, 6, 15));
    final reloaded = await GestationProvider.load(prefs);
    expect(reloaded.lmpDate, DateTime(2026, 6, 15));
    expect(reloaded.hasLmp, isTrue);
  });
}
