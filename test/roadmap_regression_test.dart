import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_condition.dart';
import 'package:witchy/models/fertility_status.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/prefs_service.dart';

/// Cross-phase regression checks. Each test pins one invariant that P0-P3
/// introduced so a later refactor cannot quietly change the story again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PrefsService prefs;
  late OnboardingProvider onboarding;
  late LoggingProvider logging;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime(2026, 1, 1),
    );
    logging = LoggingProvider(prefs);
  });

  void logBleed(DateTime start, int days) {
    for (var i = 0; i < days; i++) {
      logging.setFlow(DateTime(start.year, start.month, start.day + i), i == 0 ? 'Medium' : 'Light');
    }
  }

  test('P0/P1: an overdue cycle pauses projections but keeps the real elapsed day', () {
    final cycle = CycleProvider(onboarding, logging);
    final today = DateTime(2026, 2, 15);

    expect(cycle.daysLate(today: today), 17);
    expect(cycle.predictionsConfident(today: today), isFalse);
    expect(cycle.isOverdue(today: today), isTrue);
    expect(cycle.fertileWindow(today: today), isNull);
    expect(cycle.fertilityStatus(today: today), FertilityStatus.overdue);
    expect(cycle.cycleDay(today: today), 18);
    expect(cycle.elapsedCycleDay(today: today), 46);
  });

  test('P1: the due window never rolls forward while the cycle is late', () {
    final cycle = CycleProvider(onboarding, logging);

    final early = cycle.predictedRange(today: DateTime(2026, 1, 30));
    final later = cycle.predictedRange(today: DateTime(2026, 2, 2));

    expect(early, isNotNull);
    expect(later, isNotNull);
    expect(early!.earliest, DateTime(2026, 1, 29));
    expect(later!.earliest, early.earliest);
    expect(later.latest, early.latest);
  });

  test('P0/P2: spotting never anchors the cycle or enters bleed statistics', () {
    logging.setFlow(DateTime(2026, 2, 10), 'Spotting');
    final cycle = CycleProvider(onboarding, logging);

    expect(cycle.effectiveLastStart, DateTime(2026, 1, 1));
    expect(cycle.bleeds, hasLength(1));
    expect(cycle.bleeds.single.spottingOnly, isTrue);
    expect(cycle.medianBleedLength, isNull);
  });

  test('P2: typical bleed uses the median of measured periods', () {
    logBleed(DateTime(2025, 9, 1), 3);
    logBleed(DateTime(2025, 10, 1), 5);
    logBleed(DateTime(2025, 11, 1), 7);
    final cycle = CycleProvider(onboarding, logging);

    expect(cycle.bleeds, hasLength(3));
    expect(cycle.medianBleedLength, 5);
    expect(cycle.bleedLength, 5);
  });

  test('P3: a fertility-pausing condition suppresses predictions', () {
    onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime(2026, 1, 1),
      trackingModes: {TrackingMode.cycle},
      cycleConditions: {CycleCondition.postpartum},
    );
    final cycle = CycleProvider(onboarding, logging);

    expect(cycle.conditionPausesFertility, isTrue);
    expect(cycle.showFertilityPredictions, isFalse);
    expect(cycle.fertileWindow(today: DateTime(2026, 1, 14)), isNull);
    expect(cycle.fertilityStatus(today: DateTime(2026, 1, 14)), FertilityStatus.passed);
  });
}
