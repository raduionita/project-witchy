import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_condition.dart';
import 'package:witchy/models/fertility_status.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 9, 14);

  CycleProvider buildCycle(
    Set<TrackingMode> modes, {
    DateTime? lmpDate,
    Set<CycleCondition> conditions = const {},
  }) {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime(2026, 9, 1),
      trackingModes: modes,
      cycleConditions: conditions,
    );
    return CycleProvider(
      onboarding,
      LoggingProvider(prefs),
      gestation: GestationProvider(prefs, lmpDate: lmpDate),
    );
  }

  Iterable<Set<TrackingMode>> nonEmptySubsets() sync* {
    final values = TrackingMode.values;
    for (var mask = 1; mask < 1 << values.length; mask++) {
      yield {
        for (var i = 0; i < values.length; i++)
          if (mask & (1 << i) != 0) values[i],
      };
    }
  }

  test('every tracking-mode subset gates fertility correctly', () {
    for (final modes in nonEmptySubsets()) {
      for (final lmpDate in [null, DateTime(2026, 8, 1)]) {
        final cycle = buildCycle(modes, lmpDate: lmpDate);
        final hasCycle = modes.contains(TrackingMode.cycle);
        final pregnancyActive = modes.contains(TrackingMode.pregnancy) && lmpDate != null;
        final expected = hasCycle &&
            !pregnancyActive &&
            !modes.contains(TrackingMode.contraception);

        final reason = 'modes=$modes lmp=$lmpDate';
        expect(cycle.pregnancyModeOn, modes.contains(TrackingMode.pregnancy), reason: reason);
        expect(cycle.pregnancyActive, pregnancyActive, reason: reason);
        expect(cycle.contraceptionModeOn, modes.contains(TrackingMode.contraception), reason: reason);
        expect(cycle.isPerimenopause, modes.contains(TrackingMode.perimenopause), reason: reason);
        expect(cycle.showPeriodRange, modes.contains(TrackingMode.perimenopause), reason: reason);
        expect(cycle.showFertilityPredictions, expected, reason: reason);
        expect(cycle.showFertilityNow(today: today), expected, reason: reason);
        expect(cycle.fertileWindow(today: today) != null, expected, reason: reason);
        expect(cycle.isFertileDay(today), expected, reason: reason);
        expect(
          cycle.fertilityStatus(today: today),
          expected ? FertilityStatus.peakToday : FertilityStatus.passed,
          reason: reason,
        );
      }
    }
  });

  test('fertility-pausing conditions suppress every cycle-mode subset', () {
    for (final modes in nonEmptySubsets().where((set) => set.contains(TrackingMode.cycle))) {
      for (final condition in [
        CycleCondition.postpartum,
        CycleCondition.breastfeeding,
        CycleCondition.pregnancyLoss,
      ]) {
        final cycle = buildCycle(modes, conditions: {condition});
        final reason = 'modes=$modes condition=${condition.name}';

        expect(cycle.conditionPausesFertility, isTrue, reason: reason);
        expect(cycle.showFertilityPredictions, isFalse, reason: reason);
        expect(cycle.fertileWindow(today: today), isNull, reason: reason);
        expect(cycle.fertilityStatus(today: today), FertilityStatus.passed, reason: reason);
      }
    }
  });

  test('PCOS widens the window without suppressing it', () {
    final cycle = buildCycle({TrackingMode.cycle}, conditions: {CycleCondition.pcos});

    expect(cycle.showFertilityPredictions, isTrue);
    expect(cycle.fertileWindowPad, 1);
    expect(cycle.fertileWindow(today: today) != null, isTrue);
    expect(cycle.fertilityStatus(today: today), FertilityStatus.peakToday);
  });
}
