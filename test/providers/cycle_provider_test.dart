import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_condition.dart';
import 'package:witchy/models/cycle_phase.dart';
import 'package:witchy/models/fertility_status.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/cycle_calculator.dart';
import 'package:witchy/services/prediction_snapshot_store.dart';
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

  /// Logs a two-day bleed. A single flow day counts as spotting, so every
  /// period-start fixture needs at least PeriodHistory.minSpanDays days.
  void logPeriod(DateTime start, [String flow = 'Medium']) {
    logging.setFlow(start, flow);
    logging.setFlow(DateTime(start.year, start.month, start.day + 1), 'Light');
  }

  /// Logs a measured period of [days] consecutive flow days.
  void logPeriodDays(DateTime start, int days) {
    for (var i = 0; i < days; i++) {
      logging.setFlow(
        DateTime(start.year, start.month, start.day + i),
        i == 0 ? 'Medium' : 'Light',
      );
    }
  }

  group('CycleProvider adaptation', () {
    test('no logs falls back to onboarding settings', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 1));
      expect(cycle.effectiveCycleLength, 40);
      expect(cycle.bleeds, isEmpty);
      expect(cycle.medianBleedLength, isNull);
    });

    test('single observed cycle keeps settings length but adopts logged start', () {
      buildSources();
      logPeriod(DateTime(2026, 8, 16), 'Heavy');
      logPeriod(DateTime(2026, 9, 14), 'Heavy');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.bleeds, hasLength(2));
      expect(cycle.effectiveCycleLength, 40);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 14));
      expect(cycle.medianBleedLength, 2);
    });

    test('two observed cycles override length with median and adopt latest start', () {
      buildSources();
      for (final start in [DateTime(2026, 7, 30), DateTime(2026, 8, 27), DateTime(2026, 9, 24)]) {
        logPeriod(start);
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
      logPeriod(DateTime(2026, 8, 16), 'Heavy');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, DateTime(2026, 9, 1));
    });
  });

  group('CycleProvider fertile window (A1)', () {
    test('window is ovulation minus 5 through ovulation plus 1', () {
      // Uncertainty is copy, not window width: sparse history still shows 7 days.
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.uncertaintyPad, 2);
      expect(cycle.fertileStartCycleDay, 9);
      expect(cycle.fertileEndCycleDay, 15);
      expect(cycle.fertileWindowStart(today: DateTime(2026, 9, 20)), DateTime(2026, 9, 9));
      expect(cycle.fertileWindowEnd(today: DateTime(2026, 9, 20)), DateTime(2026, 9, 15));
      expect(cycle.phaseAt(DateTime(2026, 9, 9)), CyclePhase.fertile);
      expect(cycle.phaseAt(DateTime(2026, 9, 8)), CyclePhase.follicular);
    });

    test('steady history keeps the same 7-day window with no uncertainty copy', () {
      buildSources(lastStart: DateTime(2026, 9, 24), cycleLength: 40);
      for (final start in [DateTime(2026, 7, 2), DateTime(2026, 7, 30), DateTime(2026, 8, 27), DateTime(2026, 9, 24)]) {
        logPeriod(start);
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.observedCycleLengths, [28, 28, 28]);
      expect(cycle.uncertaintyPad, 0);
      expect(cycle.fertileStartCycleDay, 9);
      expect(cycle.fertileEndCycleDay, 15);
    });

    test('irregular history widens the window by one day', () {
      buildSources(lastStart: DateTime(2026, 11, 21), cycleLength: 40);
      for (final start in [DateTime(2026, 9, 1), DateTime(2026, 9, 25), DateTime(2026, 10, 19), DateTime(2026, 11, 21)]) {
        logPeriod(start);
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.observedCycleLengths, [24, 24, 33]);
      expect(cycle.uncertaintyPad, 4);
      expect(cycle.fertileWindowPad, 1);
      expect(cycle.fertileEndCycleDay - cycle.fertileStartCycleDay + 1, 9);
    });

    test('PCOS and irregular history cap the window pad at two days', () {
      onboarding = OnboardingProvider(
        prefs,
        onboarded: true,
        cycleLength: 40,
        bleedLength: 5,
        lastPeriodStart: DateTime(2025, 11, 15),
        cycleConditions: {CycleCondition.pcos},
      );
      logging = LoggingProvider(prefs);
      for (final start in [DateTime(2025, 8, 1), DateTime(2025, 9, 1), DateTime(2025, 10, 1), DateTime(2025, 11, 15)]) {
        logPeriod(start);
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.observedCycleLengths, [31, 30, 45]);
      expect(cycle.uncertaintyPad, 4);
      expect(cycle.fertileWindowPad, 2);
      expect(cycle.fertileEndCycleDay - cycle.fertileStartCycleDay + 1, 11);
    });

    test('status moves before window -> open -> peak -> closing -> passed', () {
      // Anchor Oct 2 2026 with a 27-day cycle: ovulation day 13 = Oct 14,
      // window days 8-14 = Oct 9-15, next peak Nov 10.
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 27, bleedLength: 5, lastPeriodStart: DateTime(2026, 10, 2));
      logging = LoggingProvider(prefs);
      final cycle = CycleProvider(onboarding, logging);
      FertilityStatus at(DateTime day) => cycle.fertilityStatus(today: day);
      expect(at(DateTime(2026, 10, 8)), FertilityStatus.beforeWindow);
      expect(at(DateTime(2026, 10, 9)), FertilityStatus.windowOpen);
      expect(at(DateTime(2026, 10, 14)), FertilityStatus.peakToday);
      expect(at(DateTime(2026, 10, 15)), FertilityStatus.windowClosing);
      expect(at(DateTime(2026, 10, 17)), FertilityStatus.passed);
      expect(cycle.ovulationDateThisCycle(today: DateTime(2026, 10, 17)), DateTime(2026, 10, 14));
      expect(cycle.fertileWindowStart(today: DateTime(2026, 10, 17)), DateTime(2026, 10, 9));
      expect(cycle.fertileWindowEnd(today: DateTime(2026, 10, 17)), DateTime(2026, 10, 15));
      expect(cycle.nextOvulationDate(today: DateTime(2026, 10, 17)), DateTime(2026, 11, 10));
    });
  });

  group('CycleProvider rolling statistics (A2)', () {
    test('ancient outliers age out of predictions and status', () {
      // Two ancient 45-day cycles followed by twelve steady 28-day cycles.
      buildSources(lastStart: DateTime(2026, 9, 24), cycleLength: 40);
      var start = DateTime(2025, 6, 1);
      final starts = <DateTime>[];
      for (final gap in [45, 45, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28]) {
        starts.add(start);
        start = DateTime(start.year, start.month, start.day + gap);
      }
      for (final s in starts) {
        logPeriod(s);
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.observedCycleLengths, hasLength(14));
      // Prediction basis is the last-6 median: steady 28s only.
      expect(cycle.effectiveCycleLength, 28);
      // Status uses the same last-6 window: regular despite the ancient 45s.
      expect(cycle.cycleSpread, 0);
      // All-time display still shows the full range.
      expect(cycle.shortestCycleLength, 28);
      expect(cycle.longestCycleLength, 45);
    });
  });

  group('CycleProvider reactivity', () {
    test('notifies and recomputes when logging changes', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      var notified = 0;
      cycle.addListener(() => notified++);
      logPeriod(DateTime(2026, 9, 14), 'Heavy');
      // Two flow entries (the start and its second day) mean two notifications.
      expect(notified, 2);
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
      // The window is fixed at days 9-15, so day 10 is fertile.
      expect(cycle.phase(today: today).label, 'Fertile Window');
      expect(cycle.phase(today: DateTime(2026, 9, 6)).label, 'Follicular');
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
      logPeriod(DateTime(2026, 10, 1));
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
      expect(range, isNotNull);
      expect(range!.earliest, DateTime(2026, 10, 11));
      expect(range.latest, DateTime(2026, 10, 11));
    });

    test('observed spread widens the window with shortest-to-longest lengths', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 40, bleedLength: 5, lastPeriodStart: DateTime(2026, 9, 1), trackingModes: {TrackingMode.perimenopause});
      logging = LoggingProvider(prefs);
      // 28-day then 35-day observed cycles ending at Sep 2.
      for (final start in [DateTime(2026, 7, 1), DateTime(2026, 7, 29), DateTime(2026, 9, 2)]) {
        logPeriod(start);
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.isPerimenopause, isTrue);
      expect(cycle.showFertilityPredictions, isFalse);
      expect(cycle.observedCycleLengths, [28, 35]);
      expect(cycle.shortestCycleLength, 28);
      expect(cycle.longestCycleLength, 35);
      expect(cycle.cycleSpread, 7);
      final range = cycle.predictedRange(today: DateTime(2026, 9, 10));
      expect(range, isNotNull);
      expect(range!.earliest, DateTime(2026, 9, 30));
      expect(range.latest, DateTime(2026, 10, 7));
    });
  });

  group('CycleProvider late handling (A3)', () {
    void seedTwo28s(DateTime last) {
      buildSources(lastStart: last, cycleLength: 28);
      for (final start in [last.subtract(const Duration(days: 56)), last.subtract(const Duration(days: 28)), last]) {
        logPeriod(start);
      }
    }

    test('five days past the latest due date stays confident and projecting', () {
      final today = DateTime(2026, 10, 9);
      seedTwo28s(today.subtract(const Duration(days: 33)));
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.daysLate(today: today), 5);
      expect(cycle.latestPlausibleCycleLength, 28);
      expect(cycle.predictionsConfident(today: today), isTrue);
      expect(cycle.isOverdue(today: today), isFalse);
      expect(cycle.projectionStopped(today: today), isFalse);
      expect(cycle.nextPeriodStart(today: today), isNull);
      expect(cycle.daysUntilPeriod(today: today), isNull);
      final range = cycle.predictedRange(today: today);
      expect(range, isNotNull);
      expect(range!.earliest, today.subtract(const Duration(days: 5)));
    });

    test('six days past the latest due date loses confidence but keeps projecting', () {
      final today = DateTime(2026, 10, 9);
      seedTwo28s(today.subtract(const Duration(days: 34)));
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.daysLate(today: today), 6);
      expect(cycle.predictionsConfident(today: today), isFalse);
      expect(cycle.isOverdue(today: today), isTrue);
      expect(cycle.projectionStopped(today: today), isFalse);
      expect(cycle.nextPeriodStart(today: today), isNull);
      expect(cycle.daysUntilPeriod(today: today), isNull);
      final range = cycle.predictedRange(today: today);
      expect(range, isNotNull);
      // The window stays on the current cycle; it does not roll to the next one.
      expect(range!.earliest, today.subtract(const Duration(days: 6)));
    });

    test('ten days past the latest due date still projects (strict boundary)', () {
      final today = DateTime(2026, 10, 9);
      seedTwo28s(today.subtract(const Duration(days: 38)));
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.daysLate(today: today), 10);
      expect(cycle.predictionsConfident(today: today), isFalse);
      expect(cycle.projectionStopped(today: today), isFalse);
      expect(cycle.nextPeriodStart(today: today), isNull);
      expect(cycle.daysUntilPeriod(today: today), isNull);
    });

    test('eleven days past the latest due date stops the projection', () {
      final today = DateTime(2026, 10, 9);
      seedTwo28s(today.subtract(const Duration(days: 39)));
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.daysLate(today: today), 11);
      expect(cycle.predictionsConfident(today: today), isFalse);
      expect(cycle.projectionStopped(today: today), isTrue);
      expect(cycle.nextPeriodStart(today: today), isNull);
      expect(cycle.predictedRange(today: today), isNull);
    });

    test('longest recent falls back to the effective length without history', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.longestRecentCycleLength, 40);
      expect(cycle.latestPlausibleCycleLength, 40);
    });

    test('overdue pauses every fertility surface and phantom period days', () {
      final today = DateTime(2026, 10, 9);
      final last = today.subtract(const Duration(days: 34));
      seedTwo28s(last);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.isOverdue(today: today), isTrue);
      expect(cycle.fertilityStatus(today: today), FertilityStatus.overdue);
      expect(cycle.showFertilityNow(today: today), isFalse);
      expect(cycle.isFertileDay(today), isFalse);
      expect(cycle.isOvulationDay(today), isFalse);
      expect(cycle.fertileWindowStart(today: today), isNull);
      expect(cycle.fertileWindowEnd(today: today), isNull);
      // Two cycles after the anchor would be a modular period day, but the
      // projection is paused, so no phantom period is claimed.
      expect(cycle.isPeriodDay(last.add(const Duration(days: 56))), isFalse);
      expect(cycle.phaseAt(today), CyclePhase.luteal);
    });

    test('elapsed cycle day keeps counting while the modular day wraps', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.elapsedCycleDay(today: DateTime(2026, 10, 9)), 39);
      expect(cycle.cycleDay(today: DateTime(2026, 10, 9)), 11);
    });
  });

  group('CycleProvider range promotion (A6)', () {
    void seedGaps(DateTime last, List<int> gapsOldestFirst) {
      buildSources(lastStart: last, cycleLength: 28);
      // Forward calendar-day seeding (DST-safe): anchor so the final start is `last`.
      final total = gapsOldestFirst.fold(0, (a, b) => a + b);
      var start = DateTime(last.year, last.month, last.day - total);
      for (final gap in [...gapsOldestFirst, 0]) {
        logPeriod(start);
        start = DateTime(start.year, start.month, start.day + gap);
      }
    }

    test('ancient outliers age out of predictedRange but stay on Insights', () {
      final last = DateTime(2026, 9, 24);
      seedGaps(last, [45, 45, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28]);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.observedCycleLengths, hasLength(14));
      expect(cycle.longestCycleLength, 45);
      expect(cycle.shortestCycleLength, 28);
      final today = DateTime(2026, 10, 10);
      final range = cycle.predictedRange(today: today);
      expect(range, isNotNull);
      expect(range!.earliest, range.latest);
      expect(range.earliest, cycle.nextPeriodStart(today: today));
      expect(cycle.showPeriodRange, isFalse);
    });

    test('a single outlier inside the last 6 is trimmed from the range', () {
      final last = DateTime(2026, 9, 24);
      seedGaps(last, [28, 28, 28, 28, 28, 49]);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.observedCycleLengths, hasLength(6));
      // Full spread still drives Irregularity; the range trims the 49.
      expect(cycle.cycleSpread, 21);
      expect(cycle.stats.spreadTrimmed, 0);
      expect(cycle.showPeriodRange, isFalse);
      final range = cycle.predictedRange(today: DateTime(2026, 10, 10));
      expect(range, isNotNull);
      expect(range!.earliest, range.latest);
      expect(range.earliest, DateTime(2026, 10, 22));
    });

    test('recent variation widens the range and flips the Today flag', () {
      final last = DateTime(2026, 9, 2);
      seedGaps(last, [28, 35]);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.cycleSpread, 7);
      expect(cycle.showPeriodRange, isTrue);
      final range = cycle.predictedRange(today: DateTime(2026, 9, 10));
      expect(range, isNotNull);
      expect(range!.earliest, DateTime(2026, 9, 30));
      expect(range.latest, DateTime(2026, 10, 7));
    });

    test('the window stays on the current cycle after the earliest due date passes', () {
      final last = DateTime(2026, 9, 2);
      seedGaps(last, [28, 35]);
      final cycle = CycleProvider(onboarding, logging);
      final range = cycle.predictedRange(today: DateTime(2026, 10, 1));
      expect(range, isNotNull);
      // The shortest bound has passed, but it must not roll into the next cycle.
      expect(range!.earliest, DateTime(2026, 9, 30));
      expect(range.latest, DateTime(2026, 10, 7));
      expect(cycle.daysLate(today: DateTime(2026, 10, 1)), 0);
    });

    test('a long cycle is not called late against the median', () {
      final last = DateTime(2026, 9, 2);
      seedGaps(last, [28, 35]);
      final cycle = CycleProvider(onboarding, logging);
      // Median is 32, but the latest plausible due date is Oct 7.
      expect(cycle.effectiveCycleLength, 32);
      expect(cycle.daysLate(today: DateTime(2026, 10, 5)), 0);
      expect(cycle.daysLate(today: DateTime(2026, 10, 8)), 1);
    });

    test('steady cycles keep the single-day countdown', () {
      final last = DateTime(2026, 9, 24);
      seedGaps(last, [28, 28]);
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.cycleSpread, 0);
      expect(cycle.showPeriodRange, isFalse);
      final range = cycle.predictedRange(today: DateTime(2026, 10, 10));
      expect(range, isNotNull);
      expect(range!.earliest, range.latest);
    });

    test('no history collapses the range except in perimenopause', () {
      buildSources();
      var cycle = CycleProvider(onboarding, logging);
      expect(cycle.showPeriodRange, isFalse);
      final range = cycle.predictedRange(today: DateTime(2026, 10, 10));
      expect(range, isNotNull);
      expect(range!.earliest, range.latest);

      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: DateTime(2026, 9, 24), trackingModes: {TrackingMode.perimenopause});
      logging = LoggingProvider(prefs);
      cycle = CycleProvider(onboarding, logging);
      expect(cycle.showPeriodRange, isTrue);
    });
  });

  // Regression: a derived onboarding date landing in the future used to win over
  // real logged history, which made the modular cycle math wrap backwards.
  group('CycleProvider rejects future anchors', () {
    DateTime day(int offset, [DateTime? base]) {
      final b = base ?? DateTime.now();
      return DateTime(b.year, b.month, b.day + offset);
    }

    test('a future stated date never beats real logged history', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 26, bleedLength: 5, lastPeriodStart: day(30));
      logging = LoggingProvider(prefs);
      // Two completed 26-day cycles plus the current one, all in the past.
      for (final startOffset in [-59, -33, -7]) {
        for (var i = 0; i < 5; i++) {
          logging.setFlow(day(startOffset + i), 'Medium');
        }
      }
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, day(-7));
      expect(cycle.effectiveCycleLength, 26);
      expect(cycle.cycleDay(today: DateTime.now()), 8);
      expect(cycle.nextPeriodStart(today: DateTime.now()), day(19));
      expect(cycle.daysUntilPeriod(today: DateTime.now()), 19);
    });

    test('a lone flow day today anchors at cycle day 1 but stays spotting', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 26, bleedLength: 5, lastPeriodStart: day(30));
      logging = LoggingProvider(prefs);
      logging.setFlow(DateTime.now(), 'Medium');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
      expect(cycle.cycleDay(today: DateTime.now()), 1);
      expect(cycle.hasLoggedPeriodBleedOn(DateTime.now()), isFalse);
      expect(cycle.phase(today: DateTime.now()), CyclePhase.follicular);
    });
  });

  group('CycleProvider logged bleed days', () {
    DateTime day(int offset) {
      final b = DateTime.now();
      return DateTime(b.year, b.month, b.day + offset);
    }

    test('a logged bleed day is always menstrual, never luteal', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 26, bleedLength: 5, lastPeriodStart: day(-30));
      logging = LoggingProvider(prefs);
      logPeriod(day(-3), 'Light');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.effectiveLastStart, day(-3));
      expect(cycle.isPeriodDay(day(-3)), isTrue);
      expect(cycle.phaseAt(day(-3)), CyclePhase.menstrual);
      expect(cycle.bleedDayOf(day(-3)), 1);
      expect(cycle.cycleDay(today: DateTime.now()), 4);
    });

    test('bleeding logged outside the predicted window still counts as a period day', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: day(-20));
      logging = LoggingProvider(prefs);
      // Cycle days 19-20 - well past the 5-day predicted bleed window.
      logging.setFlow(day(-2), 'Light');
      logging.setFlow(day(-1), 'Light');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.bleedDayOf(day(-2)), 1);
      expect(cycle.phaseAt(day(-2)), CyclePhase.menstrual);
      expect(cycle.isPeriodDay(day(-2)), isTrue);
    });

    test('a single flow day outside the predicted window stays spotting', () {
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: day(-20));
      logging = LoggingProvider(prefs);
      logging.setFlow(day(-2), 'Light');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.hasLoggedBleedOn(day(-2)), isTrue);
      expect(cycle.hasLoggedPeriodBleedOn(day(-2)), isFalse);
      expect(cycle.bleedDayOf(day(-2)), 0);
      expect(cycle.phaseAt(day(-2)), isNot(CyclePhase.menstrual));
      expect(cycle.isPeriodDay(day(-2)), isFalse);
    });
  });

  group('CycleProvider ovulation date consistency', () {
    test('nextOvulationDate agrees with daysUntilOvulation once the peak has passed', () {
      final today = DateTime.now();
      onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: DateTime(today.year, today.month, today.day - 20));
      logging = LoggingProvider(prefs);
      final cycle = CycleProvider(onboarding, logging);
      // Cycle day 21, so the day-14 peak is already behind us.
      expect(cycle.cycleDay(today: today), 21);
      final days = cycle.daysUntilOvulation(today: today);
      final date = cycle.nextOvulationDate(today: today);
      expect(CycleCalculator.daysBetween(today, date), days);
      expect(date.isAfter(today), isTrue);
    });
  });

  group('CycleProvider pregnancy suppression (A5)', () {
    ({CycleProvider cycle, GestationProvider gestation}) buildSuppressed({required Set<TrackingMode> modes, DateTime? lmp}) {
      final ob = OnboardingProvider(
        prefs,
        onboarded: true,
        cycleLength: 28,
        bleedLength: 5,
        lastPeriodStart: DateTime(2026, 9, 13),
        trackingModes: modes,
      );
      final log = LoggingProvider(prefs);
      final gest = GestationProvider(prefs, lmpDate: lmp);
      return (cycle: CycleProvider(ob, log, gestation: gest), gestation: gest);
    }

    test('mode plus LMP suppresses fertility predictions', () {
      final s = buildSuppressed(modes: {TrackingMode.cycle, TrackingMode.pregnancy}, lmp: DateTime(2026, 8, 1));
      expect(s.cycle.pregnancyModeOn, isTrue);
      expect(s.cycle.pregnancyActive, isTrue);
      expect(s.cycle.showFertilityPredictions, isFalse);
      expect(s.cycle.fertileWindowStart(), isNull);
    });

    test('mode without LMP keeps predictions (gap state, F6 parity)', () {
      final s = buildSuppressed(modes: {TrackingMode.cycle, TrackingMode.pregnancy});
      expect(s.cycle.pregnancyModeOn, isTrue);
      expect(s.cycle.pregnancyActive, isFalse);
      expect(s.cycle.showFertilityPredictions, isTrue);
    });

    test('LMP without pregnancy mode changes nothing', () {
      final s = buildSuppressed(modes: {TrackingMode.cycle}, lmp: DateTime(2026, 8, 1));
      expect(s.cycle.pregnancyModeOn, isFalse);
      expect(s.cycle.pregnancyActive, isFalse);
      expect(s.cycle.showFertilityPredictions, isTrue);
    });

    test('no gestation provider means no suppression', () {
      buildSources();
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.pregnancyActive, isFalse);
    });

    test('setting the LMP flips suppression live', () async {
      final s = buildSuppressed(modes: {TrackingMode.cycle, TrackingMode.pregnancy});
      var notified = 0;
      s.cycle.addListener(() => notified++);
      expect(s.cycle.pregnancyActive, isFalse);
      await s.gestation.setLmp(DateTime(2026, 8, 1));
      expect(s.cycle.pregnancyActive, isTrue);
      expect(s.cycle.showFertilityPredictions, isFalse);
      expect(notified, greaterThan(0));
    });

    test('pregnancy-only mode with LMP suppresses fertility too', () {
      final s = buildSuppressed(modes: {TrackingMode.pregnancy}, lmp: DateTime(2026, 8, 1));
      expect(s.cycle.pregnancyModeOn, isTrue);
      expect(s.cycle.pregnancyActive, isTrue);
      expect(s.cycle.showFertilityPredictions, isFalse);
      expect(s.cycle.fertileWindowStart(), isNull);
    });

    test('cycle plus peri keeps fertility and forces the range', () {
      final s = buildSuppressed(modes: {TrackingMode.cycle, TrackingMode.perimenopause});
      expect(s.cycle.pregnancyActive, isFalse);
      expect(s.cycle.showFertilityPredictions, isTrue);
      expect(s.cycle.showPeriodRange, isTrue);
    });
  });

  group('CycleProvider OPK indication (B4)', () {
    void seedTwentyEight() {
      buildSources(lastStart: DateTime(2026, 1, 1), cycleLength: 28);
      logPeriod(DateTime(2026, 1, 1));
      logPeriod(DateTime(2026, 1, 29));
    }

    test('latest positive implies ovulation tomorrow and feeds luteal stats', () {
      seedTwentyEight();
      logging.setOvulationTest(DateTime(2026, 1, 14), 'positive');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.opkIndicatedOvulationDate, DateTime(2026, 1, 15));
      expect(cycle.confirmedOvulationDate, isNull);
      expect(cycle.detectedLutealLength, 14);
      expect(cycle.lutealLength, 14);
    });

    test('no positive test leaves OPK indication null', () {
      seedTwentyEight();
      logging.setOvulationTest(DateTime(2026, 1, 14), 'negative');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.opkIndicatedOvulationDate, isNull);
      expect(cycle.detectedLutealLength, isNull);
    });

    test('BBT wins over a conflicting OPK-implied length', () {
      seedTwentyEight();
      for (var d = 10; d <= 15; d++) {
        logging.setTemperature(DateTime(2026, 1, d), 36.4);
      }
      for (var d = 16; d <= 19; d++) {
        logging.setTemperature(DateTime(2026, 1, d), 36.8);
      }
      logging.setOvulationTest(DateTime(2026, 1, 10), 'positive');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.confirmedOvulationDate, DateTime(2026, 1, 15));
      expect(cycle.opkIndicatedOvulationDate, DateTime(2026, 1, 11));
      expect(cycle.detectedLutealLength, 14);
    });
  });

  group('CycleProvider effective ovulation', () {
    DateTime ago(int days) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day - days);
    }

    test('a current-cycle positive OPK moves the peak, window and phase', () {
      buildSources(lastStart: ago(10), cycleLength: 28);
      logPeriod(ago(10));
      logging.setOvulationTest(ago(3), 'positive');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.effectiveLastStart, ago(10));
      expect(cycle.opkIndicatedOvulationDate, ago(2));
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(2));
      expect(cycle.ovulationCycleDay, 9);
      expect(cycle.fertileWindowStart(today: ago(0)), ago(7));
      expect(cycle.fertileWindowEnd(today: ago(0)), ago(1));
      expect(cycle.isOvulationDay(ago(2)), isTrue);
      expect(cycle.isFertileDay(ago(7)), isTrue);
      expect(cycle.phaseAt(ago(2)), CyclePhase.ovulatory);
      expect(cycle.phaseAt(ago(8)), CyclePhase.follicular);
      expect(cycle.fertilityStatus(today: ago(1)), FertilityStatus.windowClosing);
    });

    test('a prior-cycle positive OPK never becomes the current peak', () {
      buildSources(lastStart: ago(10), cycleLength: 28);
      logPeriod(ago(38));
      logPeriod(ago(10));
      logging.setOvulationTest(ago(24), 'positive');
      final cycle = CycleProvider(onboarding, logging);

      // The prior OPK still measures luteal length (13 days), but it must not
      // place this cycle's peak. Arithmetic uses that length for day 15.
      expect(cycle.opkIndicatedOvulationDate, ago(23));
      expect(cycle.detectedLutealLength, 13);
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(-4));
      expect(cycle.ovulationCycleDay, 15);
      expect(cycle.isOvulationDay(ago(23)), isFalse);
    });

    test('current-cycle BBT confirmation outranks a conflicting OPK', () {
      buildSources(lastStart: ago(13), cycleLength: 28);
      for (var d = 12; d >= 7; d--) {
        logging.setTemperature(ago(d), 36.4);
      }
      for (var d = 6; d >= 0; d--) {
        logging.setTemperature(ago(d), 36.8);
      }
      logging.setOvulationTest(ago(10), 'positive');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.confirmedOvulationDate, ago(7));
      expect(cycle.opkIndicatedOvulationDate, ago(9));
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(7));
      expect(cycle.phaseAt(ago(7)), CyclePhase.ovulatory);
      expect(cycle.phaseAt(ago(5)), CyclePhase.luteal);
    });

    test('typical bleed uses the median of measured periods', () {
      buildSources(lastStart: ago(90), cycleLength: 28);
      logPeriodDays(ago(90), 2);
      logPeriodDays(ago(60), 4);
      logPeriodDays(ago(30), 8);
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.medianBleedLength, 4);
      expect(cycle.bleedLength, 4);
    });

    test('estimated records are excluded from typical bleed but still anchor', () {
      buildSources(lastStart: ago(40), cycleLength: 28);
      logging.addPeriodRecord(ago(10), end: ago(8), estimated: true);
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.effectiveLastStart, ago(10));
      expect(cycle.hasEstimatedPeriods, isTrue);
      expect(cycle.medianBleedLength, isNull);
      expect(cycle.bleedLength, 5);
    });

    test('ovulation pain moves the current peak, window and phase', () {
      buildSources(lastStart: ago(20), cycleLength: 28);
      logPeriod(ago(20));
      logging.toggleSymptom(ago(5), 'Ovulation pain');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.loggedSignalOvulationDate, ago(5));
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(5));
      expect(cycle.ovulationCycleDay, 16);
      expect(cycle.fertileWindowStart(today: ago(0)), ago(10));
      expect(cycle.fertileWindowEnd(today: ago(0)), ago(4));
      expect(cycle.phaseAt(ago(5)), CyclePhase.ovulatory);
      expect(cycle.phaseAt(ago(4)), CyclePhase.fertile);
      expect(cycle.isOvulationDay(ago(5)), isTrue);
    });

    test('egg-white fluid moves the peak when no pain is logged', () {
      buildSources(lastStart: ago(20), cycleLength: 28);
      logPeriod(ago(20));
      logging.toggleDischarge(ago(6), 'Egg white');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.loggedSignalOvulationDate, ago(6));
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(6));
    });

    test('a prior-cycle pain never masks current egg-white fluid', () {
      buildSources(lastStart: ago(20), cycleLength: 28);
      logPeriod(ago(48));
      logPeriod(ago(20));
      logging.toggleSymptom(ago(30), 'Ovulation pain');
      logging.toggleDischarge(ago(6), 'Egg white');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.loggedSignalOvulationDate, ago(6));
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(6));
    });

    test('a prior-cycle logged signal never becomes the current peak', () {
      buildSources(lastStart: ago(10), cycleLength: 28);
      logPeriod(ago(38));
      logPeriod(ago(10));
      logging.toggleSymptom(ago(24), 'Ovulation pain');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.loggedSignalOvulationDate, isNull);
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(-3));
    });

    test('a signal before cycle day 5 is ignored', () {
      buildSources(lastStart: ago(20), cycleLength: 28);
      logPeriod(ago(20));
      logging.toggleSymptom(ago(19), 'Ovulation pain');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.loggedSignalOvulationDate, isNull);
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(7));
    });

    test('a signal far from the arithmetic peak is ignored', () {
      buildSources(lastStart: ago(20), cycleLength: 28);
      logPeriod(ago(20));
      logging.toggleSymptom(ago(15), 'Ovulation pain');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.loggedSignalOvulationDate, isNull);
      expect(cycle.ovulationDateThisCycle(today: ago(0)), ago(7));
    });
  });

  group('CycleProvider spotting rule', () {
    test('a lone flow day never starts a period or moves the anchor', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      logPeriod(DateTime(2026, 8, 16), 'Heavy');
      final before = CycleProvider(onboarding, logging);
      final anchor = before.effectiveLastStart;
      final lengths = before.observedCycleLengths;
      // Cycle day 16: past the fixed window, but a lone flow day is spotting.
      logging.setFlow(DateTime(2026, 9, 16), 'Light');
      final after = CycleProvider(onboarding, logging);
      expect(after.bleeds, hasLength(2));
      expect(after.effectiveLastStart, anchor);
      expect(after.observedCycleLengths, lengths);
      expect(after.fertilityStatus(today: DateTime(2026, 9, 16)), FertilityStatus.passed);
    });

    test('typical bleed ignores spotting spans', () {
      buildSources(lastStart: DateTime(2026, 9, 1), cycleLength: 28);
      logPeriod(DateTime(2026, 8, 16), 'Heavy');
      logging.setFlow(DateTime(2026, 9, 16), 'Light');
      final cycle = CycleProvider(onboarding, logging);
      expect(cycle.bleeds, hasLength(2));
      expect(cycle.medianBleedLength, 2);
    });
  });

  group('CycleProvider P3 modes, conditions and clamps', () {
    test('postpartum, breastfeeding and loss pause fertility predictions', () {
      for (final condition in [
        CycleCondition.postpartum,
        CycleCondition.breastfeeding,
        CycleCondition.pregnancyLoss,
      ]) {
        SharedPreferences.setMockInitialValues({});
        final localPrefs = PrefsService();
        final ob = OnboardingProvider(
          localPrefs,
          onboarded: true,
          cycleLength: 28,
          bleedLength: 5,
          lastPeriodStart: DateTime(2026, 9, 20),
          cycleConditions: {condition},
        );
        final cycle = CycleProvider(ob, LoggingProvider(localPrefs));

        expect(cycle.conditionPausesFertility, isTrue, reason: condition.label);
        expect(cycle.showFertilityPredictions, isFalse, reason: condition.label);
      }
    });

    test('an observed cycle longer than 60 days is clamped', () {
      buildSources(lastStart: DateTime(2025, 1, 1), cycleLength: 40);
      logPeriod(DateTime(2025, 1, 1));
      logPeriod(DateTime(2025, 3, 12));
      logPeriod(DateTime(2025, 5, 31));
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.observedCycleLengths, [70, 80]);
      expect(cycle.rawCycleLength, 75);
      expect(cycle.effectiveCycleLength, OnboardingProvider.maxCycleLength);
      expect(cycle.isCycleLengthClamped, isTrue);
    });

    test('a current-cycle negative test registers and a prior one does not', () {
      buildSources(lastStart: DateTime(2026, 9, 20), cycleLength: 28);
      final now = DateTime.now();
      final day = DateTime(now.year, now.month, now.day);
      logging.setPregnancyTest(day, 'negative');
      final cycle = CycleProvider(onboarding, logging);

      expect(cycle.latestPregnancyTestResult, 'negative');
      expect(cycle.hasNegativeTestThisCycle, isTrue);
      expect(cycle.hasRecentNegativeTest, isTrue);

      SharedPreferences.setMockInitialValues({});
      final localPrefs = PrefsService();
      final priorOnboarding = OnboardingProvider(
        localPrefs,
        onboarded: true,
        cycleLength: 28,
        bleedLength: 5,
        lastPeriodStart: DateTime(2026, 9, 20),
      );
      final priorLogging = LoggingProvider(localPrefs)
        ..setPregnancyTest(DateTime(2026, 9, 10), 'negative');
      final priorCycle = CycleProvider(priorOnboarding, priorLogging);

      expect(priorCycle.hasNegativeTestThisCycle, isFalse);
      expect(priorCycle.hasRecentNegativeTest, isFalse);
    });

    test('prediction snapshots record the current cycle', () async {
      SharedPreferences.setMockInitialValues({});
      final storePrefs = PrefsService();
      final store = PredictionSnapshotStore(storePrefs);
      // Anchored to today: projections stop a few days after the latest
      // plausible due date, so a hard-coded start would age out and make this
      // test fail once the calendar moves past it.
      final today = DateTime.now();
      final lastStart = DateTime(today.year, today.month, today.day - 10);
      buildSources(lastStart: lastStart, cycleLength: 28);
      final cycle = CycleProvider(onboarding, logging, snapshots: store);
      await Future<void>.delayed(Duration.zero);

      expect(cycle.predictionHistory, hasLength(1));
      expect(cycle.predictionHistory.first.cycleStart, lastStart);
    });
  });
}
