import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_phase.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;
  late OnboardingProvider onboarding;
  late LoggingProvider logging;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  void buildSources({DateTime? lastStart, int cycleLength = 40}) {
    onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: cycleLength, bleedLength: 5, lastPeriodStart: lastStart ?? DateTime(2026, 9, 1));
    logging = LoggingProvider(prefs);
  }

  group('CycleProvider adaptation', () {
    test('no logs falls back to onboarding settings', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 1));
      expect(cycle.effectiveCycleLength, 40);
      expect(cycle.bleeds, isEmpty);
      expect(cycle.meanCycleLength, isNull);
      expect(cycle.meanBleedLength, isNull);
    });

    test('single observed cycle keeps settings length but adopts logged start', () {
      buildSources();
      logging.setFlow(DateTime(2026, 8, 16), 'Heavy');
      logging.setFlow(DateTime(2026, 8, 17), 'Light');
      logging.setFlow(DateTime(2026, 9, 14), 'Heavy');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.bleeds, hasLength(2));
      expect(cycle.effectiveCycleLength, 40);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 14));
      expect(cycle.meanCycleLength, 29.0);
      expect(cycle.meanBleedLength, 1.5);
    });

    test('two observed cycles override length with median and adopt latest start', () {
      buildSources();
      for (final start in [DateTime(2026, 7, 30), DateTime(2026, 8, 27), DateTime(2026, 9, 24)]) {
        logging.setFlow(start, 'Medium');
        logging.setFlow(DateTime(start.year, start.month, start.day + 1), 'Light');
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.bleeds, hasLength(3));
      expect(cycle.observedCycleLengths, [28, 28]);
      expect(cycle.effectiveCycleLength, 28);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 24));
    });

    test('logged start older than stated start keeps the stated one', () {
      buildSources();
      logging.setFlow(DateTime(2026, 8, 16), 'Heavy');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 1));
    });
  });

  group('CycleProvider reactivity', () {
    test('notifies and recomputes when logging changes', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      var notified = 0;
      cycle.addListener(() => notified++);
      logging.setFlow(DateTime(2026, 9, 14), 'Heavy');
      expect(notified, 1);
      expect(cycle.bleeds, hasLength(1));
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 14));
    });

    test('notifies when onboarding cycle length changes', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      var notified = 0;
      cycle.addListener(() => notified++);
      onboarding.setCycle(33);
      expect(notified, 1);
      expect(cycle.effectiveCycleLength, 33);
    });

    test('predictions use effective inputs', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      final cycle = CycleProvider(onboarding, logging);
      final today = DateTime(2026, 9, 10);
      expect(cycle.cycleDay(today: today), 10);
      expect(cycle.nextPeriodStart(today: today), DateTime(2026, 9, 29));
      expect(cycle.daysUntilPeriod(today: today), 19);
      expect(cycle.phase(today: today).label, 'Waxing Glow');
    });
  });

  group('CycleProvider daysLate', () {
    test('counts days past the due date and resets on a new bleed', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.daysLate(today: DateTime(2026, 9, 28)), 0);
      expect(cycle.daysLate(today: DateTime(2026, 9, 29)), 0);
      expect(cycle.daysLate(today: DateTime(2026, 10, 1)), 2);
      expect(cycle.daysLate(today: DateTime(2026, 10, 2)), 3);
      logging.setFlow(DateTime(2026, 10, 1), 'Medium');
      expect(cycle.effectiveLastStart, DateTime(2026, 10, 1));
      expect(cycle.daysLate(today: DateTime(2026, 10, 3)), 0);
    });
  });

  group('CycleProvider fertility gate', () {
    test('cycle mode keeps fertile and ovulation predictions', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.showFertilityPredictions, isTrue);
      // Ovulation is cycle day 14 = Sep 14 with a 28-day cycle.
      expect(cycle.isOvulationDay(DateTime(2026, 9, 14)), isTrue);
      expect(cycle.isFertileDay(DateTime(2026, 9, 12)), isTrue);
    });

    test('pregnancy mode suppresses fertile and ovulation predictions', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: DateTime(2026, 9, 1), trackingModes: {TrackingMode.pregnancy});
      logging = LoggingProvider(prefs);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.showFertilityPredictions, isFalse);
      expect(cycle.isOvulationDay(DateTime(2026, 9, 14)), isFalse);
      expect(cycle.isFertileDay(DateTime(2026, 9, 12)), isFalse);
      // Bleed predictions stay visible.
      expect(cycle.isPeriodDay(DateTime(2026, 9, 1)), isTrue);
      expect(cycle.daysUntilPeriod(today: DateTime(2026, 9, 10)), 19);
    });
  });

  group('CycleProvider perimenopause range', () {
    test('no history falls back to a single-day window from the effective length', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 40);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.isPerimenopause, isFalse);
      expect(cycle.shortestCycleLength, 40);
      expect(cycle.longestCycleLength, 40);
      expect(cycle.cycleSpread, isNull);
      final range = cycle.predictedRange(today: DateTime(2026, 9, 10));
      expect(range.earliest, DateTime(2026, 10, 11));
      expect(range.latest, DateTime(2026, 10, 11));
    });

    test('observed spread widens the window with shortest-to-longest lengths', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 40, bleedLength: 5, lastPeriodStart: DateTime(2026, 9, 1), trackingModes: {TrackingMode.perimenopause});
      logging = LoggingProvider(prefs);
      // 28-day then 35-day observed cycles ending at Sep 2.
      for (final start in [DateTime(2026, 7, 1), DateTime(2026, 7, 29), DateTime(2026, 9, 2)]) {
        logging.setFlow(start, 'Medium');
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.isPerimenopause, isTrue);
      expect(cycle.showFertilityPredictions, isFalse);
      expect(cycle.observedCycleLengths, [28, 35]);
      expect(cycle.shortestCycleLength, 28);
      expect(cycle.longestCycleLength, 35);
      expect(cycle.cycleSpread, 7);
      final range = cycle.predictedRange(today: DateTime(2026, 9, 10));
      expect(range.earliest, DateTime(2026, 9, 30));
      expect(range.latest, DateTime(2026, 10, 7));
    });
  });
}
