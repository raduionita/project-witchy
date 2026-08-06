import 'package:flutter/foundation.dart';

import '../utils/date_utils.dart';
import 'cycle_phase.dart';

/// A computed set of predicted dates for the current/next cycle.
///
/// All dates are date-only. This is a derived value (never persisted).
@immutable
class CyclePrediction {
  const CyclePrediction({
    required this.nextPeriodStart,
    required this.ovulationDay,
    required this.fertileWindow,
    required this.currentCycleStart,
    required this.currentCyclePhase,
  });

  /// Predicted start of the next period (after the current cycle).
  final DateTime nextPeriodStart;

  /// Predicted ovulation date.
  final DateTime ovulationDay;

  /// Inclusive fertile window (typically 5 days before ovulation).
  final DaySpan fertileWindow;

  /// Start of the current (ongoing) cycle.
  final DateTime currentCycleStart;

  /// Which phase today falls into.
  final CyclePhase currentCyclePhase;

  /// Whether [date] is within the fertile window.
  bool isFertile(DateTime date) => fertileWindow.contains(date);

  /// Whether [date] is the predicted ovulation day.
  bool isOvulation(DateTime date) => dateOnly(date) == dateOnly(ovulationDay);

  /// Whether [date] is within the predicted next period.
  bool isPredictedPeriod(DateTime date, int periodLength) =>
      DaySpan(nextPeriodStart, addDays(nextPeriodStart, periodLength - 1))
          .contains(date);

  @override
  String toString() =>
      'CyclePrediction(period $currentCycleStart->$nextPeriodStart, '
      'ovulation ${dateOnly(ovulationDay)}, fertile $fertileWindow)';
}