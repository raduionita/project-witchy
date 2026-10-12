import 'package:flutter/material.dart';

import '../models/cycle_phase.dart';
import '../models/period_span.dart';
import '../models/tracking_mode.dart';
import '../services/cycle_calculator.dart';
import '../services/period_history.dart';
import 'logging_provider.dart';
import 'onboarding_provider.dart';

/// Reactive read-model over onboarding settings + logged days.
/// Effective inputs adapt to logged period history (median cycle length,
/// latest logged start) and fall back to onboarding settings otherwise.
class CycleProvider extends ChangeNotifier {
  CycleProvider(this._onboarding, this._logging) {
    _onboarding.addListener(_changed);
    _logging.addListener(_changed);
    _recompute();
  }

  final OnboardingProvider _onboarding;
  final LoggingProvider _logging;

  late DateTime effectiveLastStart;
  late int effectiveCycleLength;
  late List<PeriodSpan> bleeds;
  late List<int> observedCycleLengths;

  void _changed() {
    _recompute();
    notifyListeners();
  }

  void _recompute() {
    bleeds = PeriodHistory.spans(_logging.snapshot());
    observedCycleLengths = PeriodHistory.cycleLengths(PeriodHistory.startsOf(bleeds));
    effectiveCycleLength = observedCycleLengths.length >= 2 ? PeriodHistory.median(observedCycleLengths)! : _onboarding.cycleLength;
    effectiveLastStart = _resolveAnchor();
  }

  /// Latest known bleed start.
  ///
  /// Real logs win over the stated onboarding date, and a candidate dated in the
  /// future is never usable: anchoring on it makes the modular cycle arithmetic
  /// wrap backwards (Dart's `%` is non-negative), which produced phantom
  /// cycle days and bogus "bleeding in N days" predictions.
  DateTime _resolveAnchor() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidates = <DateTime>[
      if (bleeds.isNotEmpty) bleeds.last.start,
      _onboarding.lastPeriodStart,
    ];
    DateTime? anchor;
    for (final candidate in candidates) {
      final day = DateTime(candidate.year, candidate.month, candidate.day);
      if (day.isAfter(today)) continue;
      if (anchor == null || day.isAfter(anchor)) anchor = day;
    }
    return anchor ?? today;
  }

  /// Bleed length always follows the onboarding slider - logged spans are often
  /// only partially filled in, so inferring a length from them would under-report.
  int get bleedLength => _onboarding.bleedLength;

  /// True when the effective cycle length comes from logged history rather than the slider.
  bool get isCycleLengthAuto => observedCycleLengths.length >= 2;

  /// True when [date] falls inside a logged bleed span.
  bool hasLoggedBleedOn(DateTime date) => _spanIndexOf(date) >= 0;

  int _spanIndexOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (var i = 0; i < bleeds.length; i++) {
      final s = bleeds[i];
      if (!d.isBefore(s.start) && !d.isAfter(s.end)) return i;
    }
    return -1;
  }

  /// Bleeding day number for [date]: position within its logged span when the day
  /// has logged bleeding, otherwise the arithmetic prediction day (0 = not a bleed day).
  int bleedDayOf(DateTime date) {
    final index = _spanIndexOf(date);
    if (index >= 0) {
      final s = bleeds[index];
      return CycleCalculator.daysBetween(s.start, DateTime(date.year, date.month, date.day)) + 1;
    }
    return CycleCalculator.bleedDay(effectiveLastStart, date, effectiveCycleLength, bleedLength);
  }

  /// Fertility predictions only surface while the Cycle mode is active.
  bool get showFertilityPredictions => _onboarding.trackingModes.contains(TrackingMode.cycle);

  bool get isPerimenopause => _onboarding.trackingModes.contains(TrackingMode.perimenopause);

  /// Shortest observed cycle length; falls back to the effective length.
  int get shortestCycleLength => observedCycleLengths.isEmpty ? effectiveCycleLength : observedCycleLengths.reduce((a, b) => a < b ? a : b);

  /// Longest observed cycle length; falls back to the effective length.
  int get longestCycleLength => observedCycleLengths.isEmpty ? effectiveCycleLength : observedCycleLengths.reduce((a, b) => a > b ? a : b);

  /// Variation between longest and shortest observed cycles (needs 2+ cycles).
  int? get cycleSpread => observedCycleLengths.length >= 2 ? longestCycleLength - shortestCycleLength : null;

  /// Earliest/latest predicted next start from shortest/longest cycle lengths.
  ({DateTime earliest, DateTime latest}) predictedRange({DateTime? today}) {
    final t = today ?? DateTime.now();
    final a = CycleCalculator.nextPeriodStart(effectiveLastStart, t, shortestCycleLength);
    final b = CycleCalculator.nextPeriodStart(effectiveLastStart, t, longestCycleLength);
    return a.isBefore(b) ? (earliest: a, latest: b) : (earliest: b, latest: a);
  }

  int cycleDay({DateTime? today}) => CycleCalculator.cycleDay(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  /// Phase for [date]. A day with logged bleeding is always menstrual, even when
  /// the pure-arithmetic cycle position would place it in another phase.
  CyclePhase phaseAt(DateTime date) {
    if (hasLoggedBleedOn(date)) return CyclePhase.menstrual;
    return CycleCalculator.phaseAt(effectiveLastStart, date, effectiveCycleLength, bleedLength);
  }

  CyclePhase phase({DateTime? today}) => phaseAt(today ?? DateTime.now());

  DateTime nextPeriodStart({DateTime? today}) => CycleCalculator.nextPeriodStart(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  int daysUntilPeriod({DateTime? today}) => CycleCalculator.daysUntilPeriod(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  DateTime ovulationDay({DateTime? today}) => CycleCalculator.ovulationDay(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  /// First day of the fertile window (ovulation minus 2); null when fertility predictions are off.
  DateTime? fertileWindowStart({DateTime? today}) => showFertilityPredictions ? ovulationDay(today: today).subtract(const Duration(days: 2)) : null;

  int daysUntilOvulation({DateTime? today}) => CycleCalculator.daysUntilOvulation(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  /// The ovulation date [daysUntilOvulation] counts down to - rolls into the next
  /// cycle once this cycle's peak has passed, so value and label never disagree.
  DateTime nextOvulationDate({DateTime? today}) => CycleCalculator.nextOvulationDay(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  /// Days past the projected due date with no new period logged (0 = not late).
  int daysLate({DateTime? today}) {
    final t = today ?? DateTime.now();
    final due = DateTime(effectiveLastStart.year, effectiveLastStart.month, effectiveLastStart.day + effectiveCycleLength);
    final diff = CycleCalculator.daysBetween(due, t);
    return diff > 0 ? diff : 0;
  }

  /// A period day is either an arithmetic prediction day or a day the user actually logged bleeding on.
  bool isPeriodDay(DateTime date) =>
      hasLoggedBleedOn(date) || CycleCalculator.isPeriodDay(effectiveLastStart, date, effectiveCycleLength, bleedLength);


  bool isFertileDay(DateTime date) => showFertilityPredictions && CycleCalculator.isFertileDay(effectiveLastStart, date, effectiveCycleLength);

  bool isOvulationDay(DateTime date) => showFertilityPredictions && CycleCalculator.isOvulationDay(effectiveLastStart, date, effectiveCycleLength);

  bool get fertileToday => isFertileDay(DateTime.now());

  bool get ovulationToday => isOvulationDay(DateTime.now());

  int get ovulationCycleDay => CycleCalculator.ovulationCycleDay(effectiveCycleLength);

  int get fertileStartCycleDay => CycleCalculator.fertileStartCycleDay(effectiveCycleLength);

  int get fertileEndCycleDay => CycleCalculator.fertileEndCycleDay(effectiveCycleLength);

  double? get meanCycleLength => PeriodHistory.mean(observedCycleLengths);

  double? get meanBleedLength => PeriodHistory.mean([for (final s in bleeds) s.length]);
}
