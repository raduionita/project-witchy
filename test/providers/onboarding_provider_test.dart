import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_condition.dart';
import 'package:witchy/models/period_range.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PrefsService prefs;
  late OnboardingProvider onboarding;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(prefs);
  });

  /// A period that starts on [start] and lasts [days] days.
  PeriodRange period(DateTime start, int days) => PeriodRange(
        start: start,
        end: DateTime(start.year, start.month, start.day + days - 1),
      );

  group('past period ranges', () {
    test('stores newest first and rejects a duplicate range', () {
      expect(onboarding.addPeriodRange(period(DateTime(2026, 9, 10), 5)), isTrue);
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5)), isTrue);
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5)), isFalse);
      expect(onboarding.pastPeriods, hasLength(2));
      expect(onboarding.pastPeriods.first.start, DateTime(2026, 9, 10));
      expect(onboarding.pastPeriods.last.start, DateTime(2026, 8, 5));
    });

    test('the newest start anchors the cycle', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 9, 10), 5));
      expect(onboarding.lastPeriodStart, DateTime(2026, 9, 10));
      expect(onboarding.pickedDate, DateTime(2026, 9, 10));
    });

    test('removing the newest range promotes the next one', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 9, 10), 5));
      onboarding.removePeriodRange(DateTime(2026, 9, 10));
      expect(onboarding.pastPeriods, hasLength(1));
      expect(onboarding.lastPeriodStart, DateTime(2026, 8, 5));
    });

    test('resetToDefaults clears entered history', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5));
      onboarding.resetToDefaults();
      expect(onboarding.pastPeriods, isEmpty);
      expect(onboarding.pickedDate, isNull);
    });
  });

  group('deriveCycleLengthFromHistory', () {
    test('is null until two starts exist', () {
      expect(onboarding.deriveCycleLengthFromHistory(), isNull);
      onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5));
      expect(onboarding.deriveCycleLengthFromHistory(), isNull);
    });

    test('returns the single known gap from two starts', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 10), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 9, 5), 5));
      expect(onboarding.deriveCycleLengthFromHistory(), 26);
    });

    test('returns the median across three completed cycles', () {
      onboarding.addPeriodRange(period(DateTime(2026, 7, 10), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 8, 5), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 8, 31), 5));
      // Gaps: 26, 26 -> median 26.
      expect(onboarding.deriveCycleLengthFromHistory(), 26);

      onboarding.addPeriodRange(period(DateTime(2026, 6, 15), 5));
      // Gaps: 25, 26, 26 -> median 26.
      expect(onboarding.deriveCycleLengthFromHistory(), 26);
    });

    test('clamps an extreme median into the slider range', () {
      // 15-day gaps are the smallest the rules allow, so this is the shortest
      // derivable cycle length: it lands exactly on the floor.
      onboarding.addPeriodRange(period(DateTime(2026, 6, 1), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 6, 16), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 7, 1), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 7, 16), 5));
      // Gaps 15,15,15 -> median 15, clamped to minCycleLength 15.
      expect(onboarding.deriveCycleLengthFromHistory(), OnboardingProvider.minCycleLength);
    });

    test('clamps a long median down into the slider range', () {
      onboarding.addPeriodRange(period(DateTime(2026, 6, 1), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 8, 10), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 10, 19), 5));
      // Gaps 70,70 -> median 70, clamped to maxCycleLength 60.
      expect(onboarding.deriveCycleLengthFromHistory(), OnboardingProvider.maxCycleLength);
    });
  });

  group('range validation', () {
    test('rejects a start closer than 15 days to an existing start', () {
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 5)), isTrue);
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 10), 5)), isFalse);
      expect(onboarding.lastValidationError, contains('15 days'));
      expect(onboarding.pastPeriods, hasLength(1));
    });

    test('accepts exactly 15 days apart', () {
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 5)), isTrue);
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 16), 5)), isTrue);
      expect(onboarding.pastPeriods, hasLength(2));
    });

    test('rejects a period shorter than two days', () {
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 1)), isFalse);
      expect(onboarding.lastValidationError, contains('at least 2 days'));
      expect(onboarding.pastPeriods, isEmpty);
    });

    test('rejects a period longer than ten days', () {
      expect(onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 11)), isFalse);
      expect(onboarding.lastValidationError, contains('at most 10 days'));
      expect(onboarding.pastPeriods, isEmpty);
    });

    test('caps the list at maxPeriods', () {
      var day = DateTime(2026, 1, 1);
      for (var i = 0; i < OnboardingProvider.maxPeriods; i++) {
        expect(onboarding.addPeriodRange(period(day, 5)), isTrue, reason: 'entry $i should fit');
        day = DateTime(day.year, day.month, day.day + 15);
      }
      expect(onboarding.addPeriodRange(period(day, 5)), isFalse);
      expect(onboarding.lastValidationError, contains('up to 7 periods'));
      expect(onboarding.pastPeriods, hasLength(OnboardingProvider.maxPeriods));
    });

    test('replace revalidates the new range against the remaining entries', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 7, 10), 5));
      // Replacing Jul 10 with a range 4 days from Aug 1 fails.
      expect(onboarding.replacePeriodRange(DateTime(2026, 7, 10), period(DateTime(2026, 7, 28), 5)), isFalse);
      expect(onboarding.pastPeriods, hasLength(2));
      // A valid replace swaps in place.
      expect(onboarding.replacePeriodRange(DateTime(2026, 7, 10), period(DateTime(2026, 7, 5), 5)), isTrue);
      expect(onboarding.pastPeriods.map((r) => r.start), contains(DateTime(2026, 7, 5)));
      expect(onboarding.pastPeriods.map((r) => r.start), isNot(contains(DateTime(2026, 7, 10))));
    });

    test('replace ignores the range it is replacing', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 5));
      // Moving the same range a few days is fine, even though its own start
      // would be inside the 15-day window of its old position.
      expect(onboarding.replacePeriodRange(DateTime(2026, 8, 1), period(DateTime(2026, 8, 4), 5)), isTrue);
      expect(onboarding.pastPeriods.single.start, DateTime(2026, 8, 4));
    });

    test('replace enforces the 15-day gap against the other periods', () {
      onboarding.addPeriodRange(period(DateTime(2026, 8, 1), 5));
      onboarding.addPeriodRange(period(DateTime(2026, 9, 10), 5));
      // Editing Aug 1 to within 15 days of the Sep 10 period fails.
      expect(onboarding.replacePeriodRange(DateTime(2026, 8, 1), period(DateTime(2026, 9, 5), 5)), isFalse);
      expect(onboarding.lastValidationError, contains('15 days'));
      expect(onboarding.pastPeriods.map((r) => r.start), [DateTime(2026, 9, 10), DateTime(2026, 8, 1)]);
    });
  });

  group('restorePeriodRange', () {
    test('undo puts the range back', () {
      final range = period(DateTime(2026, 8, 5), 5);
      onboarding.addPeriodRange(range);
      onboarding.removePeriodRange(range.start);
      expect(onboarding.pastPeriods, isEmpty);

      onboarding.restorePeriodRange(range);
      expect(onboarding.pastPeriods, [range]);
    });

    test('undo skips a range that is already listed', () {
      final range = period(DateTime(2026, 8, 5), 5);
      onboarding.addPeriodRange(range);
      onboarding.restorePeriodRange(range);
      expect(onboarding.pastPeriods, hasLength(1));
    });
  });

  group('setCycle clamp', () {
    test('clamps out-of-range values into the slider bounds', () {
      onboarding.setCycle(5);
      expect(onboarding.cycleLength, OnboardingProvider.minCycleLength);
      onboarding.setCycle(99);
      expect(onboarding.cycleLength, OnboardingProvider.maxCycleLength);
      onboarding.setCycle(30, fromHistory: true);
      expect(onboarding.cycleLengthFromHistory, isTrue);
      onboarding.setCycle(28);
      expect(onboarding.cycleLengthFromHistory, isFalse);
    });
  });

  group('cycle conditions', () {
    test('toggle persists and survives a fresh load', () async {
      onboarding.toggleCycleCondition(CycleCondition.pcos);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      onboarding.toggleCycleCondition(CycleCondition.breastfeeding);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final reloaded = await OnboardingProvider.load(prefs);
      expect(reloaded.cycleConditions, {CycleCondition.pcos, CycleCondition.breastfeeding});

      reloaded.toggleCycleCondition(CycleCondition.pcos);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final cleared = await OnboardingProvider.load(prefs);
      expect(cleared.cycleConditions, {CycleCondition.breastfeeding});
    });
  });
}
