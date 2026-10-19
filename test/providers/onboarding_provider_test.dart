import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group('previous period history', () {
    test('stores newest first and ignores duplicates', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.addPreviousPeriod(DateTime(2026, 9, 10));
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.previousPeriodStarts, [DateTime(2026, 9, 10), DateTime(2026, 8, 5)]);

      onboarding.removePreviousPeriod(DateTime(2026, 9, 10));
      expect(onboarding.previousPeriodStarts, [DateTime(2026, 8, 5)]);
    });

    test('resetToDefaults clears entered history', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.resetToDefaults();
      expect(onboarding.previousPeriodStarts, isEmpty);
    });
  });

  group('deriveCycleLengthFromHistory', () {
    test('is null until two starts exist', () {
      expect(onboarding.deriveCycleLengthFromHistory(), isNull);
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.deriveCycleLengthFromHistory(), isNull);
    });

    test('returns the single known gap from two starts', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 10));
      onboarding.setDate(DateTime(2026, 9, 5));
      expect(onboarding.deriveCycleLengthFromHistory(), 26);
    });

    test('returns the median across three completed cycles', () {
      onboarding.addPreviousPeriod(DateTime(2026, 7, 10));
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.setDate(DateTime(2026, 8, 31));
      // Gaps: 26, 26 -> median 26.
      expect(onboarding.deriveCycleLengthFromHistory(), 26);

      onboarding.addPreviousPeriod(DateTime(2026, 6, 15));
      // Gaps: 25, 26, 26 -> median 26.
      expect(onboarding.deriveCycleLengthFromHistory(), 26);
    });

    test('clamps an extreme median into the slider range', () {
      // 15-day gaps are the smallest the validator allows, so this is the
      // shortest derivable cycle length: it lands exactly on the floor.
      onboarding.addPreviousPeriod(DateTime(2026, 6, 1));
      onboarding.addPreviousPeriod(DateTime(2026, 6, 16));
      onboarding.addPreviousPeriod(DateTime(2026, 7, 1));
      onboarding.setDate(DateTime(2026, 7, 16));
      // Gaps 15,15,15 -> median 15, clamped to minCycleLength 15.
      expect(onboarding.deriveCycleLengthFromHistory(), OnboardingProvider.minCycleLength);
    });

    test('clamps a long median down into the slider range', () {
      onboarding.addPreviousPeriod(DateTime(2026, 6, 1));
      onboarding.addPreviousPeriod(DateTime(2026, 8, 10));
      onboarding.setDate(DateTime(2026, 10, 19));
      // Gaps 70,70 -> median 70, clamped to maxCycleLength 60.
      expect(onboarding.deriveCycleLengthFromHistory(), OnboardingProvider.maxCycleLength);
    });
  });

  group('15-day validation', () {
    test('rejects a start closer than 15 days to the last period', () {
      onboarding.setDate(DateTime(2026, 9, 10));
      expect(onboarding.addPreviousPeriod(DateTime(2026, 9, 5)), isFalse);
      expect(onboarding.lastValidationError, contains('15 days'));
      expect(onboarding.previousPeriodStarts, isEmpty);
    });

    test('rejects a start closer than 15 days to an existing entry', () {
      expect(onboarding.addPreviousPeriod(DateTime(2026, 8, 1)), isTrue);
      expect(onboarding.addPreviousPeriod(DateTime(2026, 8, 10)), isFalse);
      expect(onboarding.lastValidationError, contains('15 days'));
      expect(onboarding.previousPeriodStarts, hasLength(1));
    });

    test('accepts exactly 15 days apart', () {
      onboarding.setDate(DateTime(2026, 9, 10));
      expect(onboarding.addPreviousPeriod(DateTime(2026, 8, 26)), isTrue);
      expect(onboarding.previousPeriodStarts, hasLength(1));
    });

    test('caps the list at maxPreviousPeriods', () {
      var day = DateTime(2026, 9, 1);
      for (var i = 0; i < OnboardingProvider.maxPreviousPeriods; i++) {
        expect(onboarding.addPreviousPeriod(day), isTrue, reason: 'entry $i should fit');
        day = DateTime(day.year, day.month, day.day - 20);
      }
      expect(onboarding.addPreviousPeriod(DateTime(day.year, day.month, day.day - 20)), isFalse);
      expect(onboarding.lastValidationError, contains('Remove an older date'));
      expect(onboarding.previousPeriodStarts, hasLength(OnboardingProvider.maxPreviousPeriods));
    });

    test('replace revalidates the new date against remaining entries', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 1));
      onboarding.addPreviousPeriod(DateTime(2026, 7, 10));
      // Replacing Jul 10 with a date 4 days from Aug 1 fails.
      expect(onboarding.replacePreviousPeriod(DateTime(2026, 7, 10), DateTime(2026, 7, 28)), isFalse);
      expect(onboarding.previousPeriodStarts, hasLength(2));
      // A valid replace swaps in place.
      expect(onboarding.replacePreviousPeriod(DateTime(2026, 7, 10), DateTime(2026, 7, 5)), isTrue);
      expect(onboarding.previousPeriodStarts, contains(DateTime(2026, 7, 5)));
      expect(onboarding.previousPeriodStarts, isNot(contains(DateTime(2026, 7, 10))));
    });

    test('replace enforces the 15-day gap against the last period', () {
      onboarding.setDate(DateTime(2026, 9, 10));
      expect(onboarding.addPreviousPeriod(DateTime(2026, 8, 1)), isTrue);
      // Editing Aug 1 to within 15 days of the Sep 10 last period fails.
      expect(onboarding.replacePreviousPeriod(DateTime(2026, 8, 1), DateTime(2026, 9, 5)), isFalse);
      expect(onboarding.lastValidationError, contains('15 days'));
      expect(onboarding.previousPeriodStarts, [DateTime(2026, 8, 1)]);
    });
  });

  group('period lengths', () {
    test('durationFor falls back to the bleeding length', () {
      expect(onboarding.durationFor(DateTime(2026, 8, 5)), onboarding.bleedLength);
    });

    test('stores a per-period length and clamps it to 2-10', () {
      final start = DateTime(2026, 8, 5);
      onboarding.setPreviousPeriodDuration(start, 7);
      expect(onboarding.durationFor(start), 7);
      onboarding.setPreviousPeriodDuration(start, 99);
      expect(onboarding.durationFor(start), 10);
      onboarding.setPreviousPeriodDuration(start, 1);
      expect(onboarding.durationFor(start), 2);
    });

    test('a new entry starts at the bleeding length', () {
      onboarding.setBleed(6);
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.durationFor(DateTime(2026, 8, 5)), 6);
    });
  });

  group('restorePreviousPeriod', () {
    test('undo puts the date and its length back', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.setPreviousPeriodDuration(DateTime(2026, 8, 5), 7);
      onboarding.removePreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.previousPeriodStarts, isEmpty);

      onboarding.restorePreviousPeriod(DateTime(2026, 8, 5), duration: 7);
      expect(onboarding.previousPeriodStarts, [DateTime(2026, 8, 5)]);
      expect(onboarding.durationFor(DateTime(2026, 8, 5)), 7);
    });

    test('undo skips a date that is already listed', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.restorePreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.previousPeriodStarts, hasLength(1));
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
}
