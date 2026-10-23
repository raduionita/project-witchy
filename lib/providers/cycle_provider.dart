import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cycle_condition.dart';
import '../models/cycle_phase.dart';
import '../models/day_log.dart';
import '../models/fertile_window.dart';
import '../models/fertility_status.dart';
import '../models/period_span.dart';
import '../models/prediction_snapshot.dart';
import '../models/tracking_mode.dart';
import '../models/trend_summary.dart';
import '../services/bbt_analyzer.dart';
import '../services/cycle_calculator.dart';
import '../services/cycle_stats.dart';
import '../services/period_history.dart';
import '../services/prediction_snapshot_store.dart';
import '../services/trend_analyzer.dart';
import 'logging_provider.dart';
import 'gestation_provider.dart';
import 'onboarding_provider.dart';

/// Reactive read-model over onboarding settings + logged days.
/// Effective inputs adapt to logged period history (median cycle length,
/// latest logged start) and fall back to onboarding settings otherwise.
class CycleProvider extends ChangeNotifier {
  CycleProvider(
    this._onboarding,
    this._logging, {
    GestationProvider? gestation,
    PredictionSnapshotStore? snapshots,
  }) : _gestation = gestation,
       _snapshots = snapshots {
    _onboarding.addListener(_changed);
    _logging.addListener(_changed);
    _gestation?.addListener(_changed);
    _recompute();
    _recordSnapshot();
  }

  final OnboardingProvider _onboarding;
  final LoggingProvider _logging;
  final GestationProvider? _gestation;
  final PredictionSnapshotStore? _snapshots;

  late DateTime effectiveLastStart;
  late int effectiveCycleLength;
  late int rawCycleLength;
  late List<PeriodSpan> bleeds;
  late List<int> observedCycleLengths;

  /// BBT-measured personal luteal length; null when logged temperatures
  /// cannot support it (then [lutealLength] falls back to the average).
  late int? detectedLutealLength;

  /// Most recent BBT-confirmed ovulation date; null without enough data.
  late DateTime? confirmedOvulationDate;

  /// Provisional ovulation from the latest positive OPK (that date + 1 day);
  /// null when no positive test is logged. BBT confirmation always wins.
  late DateTime? opkIndicatedOvulationDate;

  /// Ovulation suggested by a current-cycle body log (ovulation pain or
  /// fertile cervical fluid). Null when no usable signal is logged.
  late DateTime? loggedSignalOvulationDate;

  /// Most recent pregnancy test result and its date; null when never logged.
  late DateTime? latestPregnancyTestDate;
  late String? latestPregnancyTestResult;

  /// Directional summaries for cycle length, bleed length and symptoms.
  late List<TrendSummary> trends;

  /// Luteal length driving every ovulation/fertility computation: personal
  /// when measured, otherwise the population-average fallback.
  int get lutealLength => detectedLutealLength ?? BbtAnalyzer.fallbackLutealLength;

  void _changed() {
    _recompute();
    _recordSnapshot();
    notifyListeners();
  }

  /// Freeze the first prediction seen for this cycle. The store dedupes by
  /// cycle start, so later signals can update live values without rewriting
  /// the historical record.
  void _recordSnapshot() {
    final store = _snapshots;
    if (store == null) return;
    final range = predictedRange();
    if (range == null) return;
    final window = showFertilityPredictions ? fertileWindow() : null;
    unawaited(
      store.record(
        PredictionSnapshot(
          cycleStart: effectiveLastStart,
          earliest: range.earliest,
          latest: range.latest,
          peak: window?.peak,
          fertileStart: window?.start,
          fertileEnd: window?.end,
          recordedAt: DateTime.now(),
        ),
      ),
    );
  }

  /// Newest-first saved predictions. Empty when no store is attached.
  List<PredictionSnapshot> get predictionHistory {
    final saved = _snapshots?.snapshots ?? const <PredictionSnapshot>[];
    return saved.reversed.toList(growable: false);
  }

  void _recompute() {
    final logs = _logging.snapshot();
    bleeds = PeriodHistory.spansFrom(logs, _logging.periodRecords);
    observedCycleLengths = PeriodHistory.cycleLengths(PeriodHistory.startsOf(bleeds));
    // One value drives predictions and every displayed average: the last-6
    // median once two completed cycles exist, otherwise the setup value.
    final recentMedian = observedCycleLengths.length >= 2 ? stats.rawMedianRecent : null;
    rawCycleLength = recentMedian ?? _onboarding.cycleLength;
    effectiveCycleLength = rawCycleLength.clamp(OnboardingProvider.minCycleLength, OnboardingProvider.maxCycleLength);
    effectiveLastStart = _resolveAnchor();
    final temps = <DateTime, double?>{for (final e in logs.entries) e.key: e.value.temperature};
    final bbt = BbtAnalyzer.analyze(
      temps: temps,
      bleedStarts: PeriodHistory.startsOf(bleeds),
      excludedNights: _disturbedNights(logs),
    );
    detectedLutealLength = bbt.personalLutealLength;
    confirmedOvulationDate = bbt.confirmedOvulation;
    opkIndicatedOvulationDate = _latestPositiveOpk(logs);
    detectedLutealLength ??= _opkLutealLength(logs, PeriodHistory.startsOf(bleeds));
    loggedSignalOvulationDate = _loggedSignalOvulation(logs);
    _readLatestPregnancyTest(logs);
    trends = TrendAnalyzer.summaries(
      observedCycleLengths: observedCycleLengths,
      spans: bleeds,
      logs: logs,
    );
  }

  void _readLatestPregnancyTest(Map<DateTime, DayLog> days) {
    latestPregnancyTestDate = null;
    latestPregnancyTestResult = null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final entry in days.entries) {
      final day = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (day.isAfter(today) || entry.value.pregnancyTest == null) continue;
      if (latestPregnancyTestDate == null || day.isAfter(latestPregnancyTestDate!)) {
        latestPregnancyTestDate = day;
        latestPregnancyTestResult = entry.value.pregnancyTest;
      }
    }
  }

  /// Latest log date with a positive OPK, shifted to the implied ovulation
  /// day (tomorrow). BBT-confirmed dates take precedence in consumers.
  static DateTime? _latestPositiveOpk(Map<DateTime, DayLog> days) {
    DateTime? latest;
    for (final e in days.entries) {
      if (e.value.ovulationTest != 'positive') continue;
      if (latest == null || e.key.isAfter(latest)) latest = e.key;
    }
    if (latest == null) return null;
    return DateTime(latest.year, latest.month, latest.day + 1);
  }

  /// Median luteal length implied by positive OPKs (implied ovulation to the
  /// next bleed start), clamped like the BBT measurement. Only used when BBT
  /// cannot support a personal length - BBT wins every conflict.
  static int? _opkLutealLength(Map<DateTime, DayLog> days, List<DateTime> bleedStarts) {
    final gaps = <int>[];
    for (final e in days.entries) {
      if (e.value.ovulationTest != 'positive') continue;
      final ovu = DateTime(e.key.year, e.key.month, e.key.day + 1);
      DateTime? next;
      for (final s in bleedStarts) {
        if (s.isAfter(ovu) && (next == null || s.isBefore(next))) next = s;
      }
      if (next != null) gaps.add(CycleCalculator.daysBetween(ovu, next));
    }
    if (gaps.isEmpty) return null;
    gaps.sort();
    final median = gaps.length.isOdd ? gaps[gaps.length ~/ 2] : ((gaps[gaps.length ~/ 2 - 1] + gaps[gaps.length ~/ 2]) / 2).round();
    return median.clamp(BbtAnalyzer.minLutealLength, BbtAnalyzer.maxLutealLength);
  }

  /// Sleep entries that make a temperature reading unreliable for shift
  /// detection. The dates are excluded before baseline and post-rise windows
  /// are built.
  static const Set<String> _poorSleepSignals = {
    'Restless sleep',
    'Insomnia',
    'Woke up at night',
    'Woke up early',
  };

  Set<DateTime> _disturbedNights(Map<DateTime, DayLog> days) {
    final result = <DateTime>{};
    for (final entry in days.entries) {
      if (entry.value.sleep.any(_poorSleepSignals.contains)) {
        final day = entry.key;
        result.add(DateTime(day.year, day.month, day.day));
      }
    }
    return result;
  }

  /// Latest current-cycle body signal that can stand in for ovulation when BBT
  /// and OPK are absent. Ovulation pain wins over egg-white fluid, which wins
  /// over watery fluid. The signal must be plausible for this cycle and close
  /// to the arithmetic estimate, otherwise it is ignored.
  DateTime? _loggedSignalOvulation(Map<DateTime, DayLog> days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidates = [
      _latestDayMatching(
        days,
        (log) => log.symptoms.contains('Ovulation pain'),
        today,
      ),
      _latestDayMatching(
        days,
        (log) => log.discharge.contains('Egg white'),
        today,
      ),
      _latestDayMatching(
        days,
        (log) => log.discharge.contains('Watery'),
        today,
      ),
    ];
    for (final signal in candidates) {
      if (signal == null) continue;
      if (signal.isBefore(effectiveLastStart)) continue;
      final cycleDay = CycleCalculator.daysBetween(effectiveLastStart, signal) + 1;
      if (cycleDay < 5) continue;
      final arithmetic = _arithmeticOvulation();
      if (CycleCalculator.daysBetween(signal, arithmetic).abs() > 7) continue;
      return signal;
    }
    return null;
  }

  DateTime? _latestDayMatching(
    Map<DateTime, DayLog> days,
    bool Function(DayLog log) matches,
    DateTime today,
  ) {
    DateTime? latest;
    for (final entry in days.entries) {
      if (!matches(entry.value)) continue;
      final day = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (day.isAfter(today)) continue;
      if (latest == null || day.isAfter(latest)) latest = day;
    }
    return latest;
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
    // Only true period spans anchor the cycle; a lone flow day is spotting and
    // must not move the anchor or the modular arithmetic with it.
    final periodStarts = PeriodHistory.startsOf(bleeds);
    final candidates = <DateTime>[
      if (periodStarts.isNotEmpty) periodStarts.last,
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

  /// Typical logged bleed length, clamped, falling back to the setup slider
  /// until at least one measured period exists. Estimated and start-only
  /// records never contribute.
  int get bleedLength {
    final median = medianBleedLength;
    return median == null ? _onboarding.bleedLength : median.clamp(2, 10).toInt();
  }

  /// Median length of the most recent measured periods, or null before one is
  /// available. This is the single bleed statistic used by predictions and
  /// display.
  int? get medianBleedLength => PeriodHistory.medianRecentBleedLength(bleeds);

  /// True when any period span came from an estimated start rather than flow.
  bool get hasEstimatedPeriods => bleeds.any((span) => span.estimated);

  /// Start dates that came from onboarding or migration rather than flow logs.
  Set<DateTime> get estimatedPeriodStarts => {
    for (final span in bleeds)
      if (span.estimated) span.start,
  };

  /// True when the effective cycle length comes from logged history rather than the slider.
  bool get isCycleLengthAuto => observedCycleLengths.length >= 2;

  /// True when history fell outside the supported 15-60 day prediction range
  /// and was clamped for safety.
  bool get isCycleLengthClamped => rawCycleLength != effectiveCycleLength;

  bool get isPcos => _onboarding.cycleConditions.contains(CycleCondition.pcos);

  bool get isPostpartum => _onboarding.cycleConditions.contains(CycleCondition.postpartum);

  bool get isBreastfeeding => _onboarding.cycleConditions.contains(CycleCondition.breastfeeding);

  bool get hasPregnancyLoss => _onboarding.cycleConditions.contains(CycleCondition.pregnancyLoss);

  /// Conditions that make cycle/fertility predictions unsafe until the user
  /// turns them off or re-anchors with a new period.
  bool get conditionPausesFertility => isPostpartum || isBreastfeeding || hasPregnancyLoss;

  /// True when the latest logged test is negative and belongs to this cycle.
  bool get hasNegativeTestThisCycle =>
      latestPregnancyTestResult == 'negative' &&
      latestPregnancyTestDate != null &&
      !latestPregnancyTestDate!.isBefore(effectiveLastStart);

  /// True when a negative test was logged in the last three days, the window
  /// where retesting too early is unhelpful.
  bool get hasRecentNegativeTest {
    final test = latestPregnancyTestDate;
    if (test == null || latestPregnancyTestResult != 'negative') return false;
    return CycleCalculator.daysBetween(test, DateTime.now()) <= 3;
  }

  /// Plain-language source for every prediction: observed history once two
  /// completed cycles exist, otherwise the onboarding default.
  String get predictionBasis {
    final count = observedCycleLengths.length;
    return count >= 2 ? 'Based on $count cycles' : 'Based on default ${_onboarding.cycleLength} days';
  }

  /// True when [date] falls inside a logged bleed span, including spotting.
  bool hasLoggedBleedOn(DateTime date) => _spanIndexOf(date) >= 0;

  /// True when [date] falls inside a logged period span. Spotting and
  /// single-day flow records stay visible as bleeding, but do not count as a
  /// period for phase, tags or cycle-day numbering.
  bool hasLoggedPeriodBleedOn(DateTime date) {
    final index = _spanIndexOf(date);
    if (index < 0) return false;
    final span = bleeds[index];
    return !span.spottingOnly && span.length >= PeriodHistory.minSpanDays;
  }

  int _spanIndexOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (var i = 0; i < bleeds.length; i++) {
      final s = bleeds[i];
      if (s.startOnly) continue;
      if (!d.isBefore(s.start) && !d.isAfter(s.end)) return i;
    }
    return -1;
  }

  /// Bleeding day number for [date]: position within its logged period span,
  /// otherwise the arithmetic prediction day (0 = not a bleed day). Spotting
  /// does not get a period day number.
  int bleedDayOf(DateTime date) {
    final index = _spanIndexOf(date);
    if (index >= 0) {
      final s = bleeds[index];
      if (!s.spottingOnly && s.length >= PeriodHistory.minSpanDays) {
        return CycleCalculator.daysBetween(s.start, DateTime(date.year, date.month, date.day)) + 1;
      }
    }
    if (isOverdue(today: date)) return 0;
    return CycleCalculator.bleedDay(effectiveLastStart, date, effectiveCycleLength, bleedLength);
  }

  /// Fertility predictions surface while the Cycle mode is active, unless a
  /// dated pregnancy, birth-control mode or a condition that suppresses
  /// ovulation predictions is present.
  bool get showFertilityPredictions =>
      _onboarding.trackingModes.contains(TrackingMode.cycle) &&
      !pregnancyActive &&
      !contraceptionModeOn &&
      !conditionPausesFertility;

  bool get contraceptionModeOn => _onboarding.trackingModes.contains(TrackingMode.contraception);

  /// Fertility predictions for [today] only while the cycle is still credible.
  /// Mode and pregnancy checks stay in [showFertilityPredictions].
  bool showFertilityNow({DateTime? today}) =>
      showFertilityPredictions && predictionsConfident(today: today);

  /// Pregnancy mode is selected, with or without dates entered yet.
  bool get pregnancyModeOn => _onboarding.trackingModes.contains(TrackingMode.pregnancy);

  /// Pregnancy mode is selected AND dated (LMP present): period countdown,
  /// late alerts and fertility predictions stay hidden.
  bool get pregnancyActive => pregnancyModeOn && (_gestation?.hasLmp ?? false);

  bool get isPerimenopause => _onboarding.trackingModes.contains(TrackingMode.perimenopause);

  /// Rolling statistics over the observed lengths; ancient cycles age out
  /// of predictions, averages and spread instead of dragging them forever.
  CycleStats get stats => CycleStats(observedCycleLengths);

  /// Shortest observed cycle length; falls back to the effective length.
  int get shortestCycleLength => observedCycleLengths.isEmpty ? effectiveCycleLength : observedCycleLengths.reduce((a, b) => a < b ? a : b);

  /// Longest observed cycle length; falls back to the effective length.
  int get longestCycleLength => observedCycleLengths.isEmpty ? effectiveCycleLength : observedCycleLengths.reduce((a, b) => a > b ? a : b);

  /// Spread of the last 6 observed cycles (null until 2+); drives the
  /// Records irregularity status and the fertile-window uncertainty pad.
  int? get cycleSpread => stats.spreadRecent;

  /// Uncertainty in days shown as copy (for example "may shift by 2 days").
  /// It no longer widens the fertile window itself - the window is the
  /// biological ovu-5 .. ovu+1 range.
  int get uncertaintyPad {
    if (observedCycleLengths.length < 3) return 2;
    final spread = cycleSpread ?? 0;
    if (spread <= 7) return 0;
    final half = spread ~/ 2;
    return half > 4 ? 4 : half;
  }

  /// Extra days added to each side of the fertile window for bodies whose
  /// ovulation timing is less predictable. PCOS adds one day; a wide observed
  /// spread adds another. Capped at two so the window never becomes a blanket.
  int get fertileWindowPad {
    var pad = isPcos ? 1 : 0;
    if (observedCycleLengths.length >= 3 && (cycleSpread ?? 0) > 7) pad += 1;
    return pad > 2 ? 2 : pad;
  }

  /// Longest of the last 6 observed cycles; falls back to the effective
  /// length until enough history exists.
  int get longestRecentCycleLength => stats.longestRecent ?? effectiveCycleLength;

  /// Outlier-resistant shortest/latest due lengths. The trimmed range drives
  /// the due-date window, so one extreme cycle cannot make the app call a
  /// normal cycle late.
  int get earliestPlausibleCycleLength => stats.shortestTrimmed ?? effectiveCycleLength;
  int get latestPlausibleCycleLength => stats.longestTrimmed ?? effectiveCycleLength;

  /// Days of grace after the latest plausible due date before predictions are
  /// treated as unreliable.
  static const int confidenceGraceDays = 5;

  /// Days past the latest plausible due date after which modular projection
  /// stops entirely until a new bleed is logged.
  static const int projectionGraceDays = 10;

  /// False once the cycle runs more than [confidenceGraceDays] past its latest
  /// plausible due date: fertility/peak surfaces pause, calendar prediction
  /// dots hide and Today shows an overdue state.
  bool predictionsConfident({DateTime? today}) => daysLate(today: today) <= confidenceGraceDays;

  /// True once the projection has run past [projectionGraceDays]: no next
  /// start or range is produced until a new bleed re-anchors the cycle.
  bool projectionStopped({DateTime? today}) => !CycleCalculator.projectionValid(
    lastStart: effectiveLastStart,
    today: today ?? DateTime.now(),
    latestPlausibleLength: latestPlausibleCycleLength,
    graceDays: projectionGraceDays,
  );

  /// True while the current cycle is past its latest plausible due date plus
  /// the confidence grace. This is the explicit overdue state: fertility
  /// predictions are suppressed, not silently re-projected into a new cycle.
  bool isOverdue({DateTime? today}) => !predictionsConfident(today: today);

  /// Earliest/latest due dates for the current cycle. Unlike a rolling
  /// projection, the bounds never move into the following cycle on their own:
  /// the window stays anchored to the last logged start until a new bleed
  /// arrives. Null once projection has stopped.
  ({DateTime earliest, DateTime latest})? predictedRange({DateTime? today}) {
    final t = today ?? DateTime.now();
    if (projectionStopped(today: t)) return null;
    final a = _addDays(effectiveLastStart, earliestPlausibleCycleLength);
    final b = _addDays(effectiveLastStart, latestPlausibleCycleLength);
    return (
      earliest: a.isBefore(b) ? a : b,
      latest: a.isAfter(b) ? a : b,
    );
  }

  DateTime _addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

  /// True when the Today countdown renders as an earliest/latest range:
  /// always in perimenopause, otherwise once the outlier-resistant recent
  /// range varies by 2+ days.
  bool get showPeriodRange => isPerimenopause || (stats.spreadTrimmed ?? 0) >= 2;

  int cycleDay({DateTime? today}) => CycleCalculator.cycleDay(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  /// Actual elapsed day since the last period start, with no modular wrap.
  /// Display surfaces use this; [cycleDay] remains the phase-math projection.
  int elapsedCycleDay({DateTime? today}) =>
      CycleCalculator.elapsedCycleDay(effectiveLastStart, today ?? DateTime.now());

  /// Phase for [date]. A day with logged period flow is always menstrual, even
  /// when the pure-arithmetic cycle position would place it in another phase.
  /// Once the cycle is overdue, the phase freezes at luteal instead of wrapping
  /// into a phantom next cycle. Within the current cycle the BBT/OPK peak moves
  /// the ovulatory and fertile phases with it.
  CyclePhase phaseAt(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (hasLoggedPeriodBleedOn(day)) return CyclePhase.menstrual;
    if (isOverdue(today: day)) return CyclePhase.luteal;
    if (day.isBefore(effectiveLastStart)) {
      return CycleCalculator.phaseAt(effectiveLastStart, day, effectiveCycleLength, bleedLength, lutealLength: lutealLength);
    }
    final peak = _effectiveOvulation();
    if (CycleCalculator.daysBetween(day, peak) == 0) return CyclePhase.ovulatory;
    final pad = fertileWindowPad;
    final start = _addDays(peak, -(5 + pad));
    final end = _addDays(peak, 1 + pad);
    if (!day.isBefore(start) && !day.isAfter(end)) return CyclePhase.fertile;
    return day.isBefore(peak) ? CyclePhase.follicular : CyclePhase.luteal;
  }

  CyclePhase phase({DateTime? today}) => phaseAt(today ?? DateTime.now());

  /// Earliest credible next start for the current cycle. Unlike the old
  /// rolling projection this never advances to the following cycle: once the
  /// earliest due date passes, or the projection stops, it returns null until
  /// a new bleed is logged.
  DateTime? nextPeriodStart({DateTime? today}) {
    final date = today ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    if (projectionStopped(today: day)) return null;
    final due = _addDays(effectiveLastStart, earliestPlausibleCycleLength);
    return day.isAfter(due) ? null : due;
  }

  /// Days until the earliest credible next start; null once that date has
  /// passed or the projection has stopped. Due today returns 0.
  int? daysUntilPeriod({DateTime? today}) {
    final date = today ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final next = nextPeriodStart(today: day);
    if (next == null) return null;
    final days = CycleCalculator.daysBetween(day, next);
    return days < 0 ? 0 : days;
  }

  DateTime? _confirmedThisCycle() {
    final confirmed = confirmedOvulationDate;
    if (confirmed == null) return null;
    final day = DateTime(confirmed.year, confirmed.month, confirmed.day);
    return day.isBefore(effectiveLastStart) ? null : day;
  }

  DateTime? _opkThisCycle() {
    final opk = opkIndicatedOvulationDate;
    if (opk == null) return null;
    final day = DateTime(opk.year, opk.month, opk.day);
    return day.isBefore(effectiveLastStart) ? null : day;
  }

  DateTime _arithmeticOvulation() => _addDays(
    effectiveLastStart,
    CycleCalculator.ovulationCycleDay(effectiveCycleLength, lutealLength: lutealLength) - 1,
  );

  /// Current-cycle peak: BBT confirmation first, then a positive OPK, then a
  /// logged body signal, then the arithmetic projection. Signals dated before
  /// the current anchor belong to an earlier cycle and are ignored so the
  /// window cannot inherit a stale peak.
  DateTime _effectiveOvulation() =>
      _confirmedThisCycle() ??
      _opkThisCycle() ??
      loggedSignalOvulationDate ??
      _arithmeticOvulation();

  /// Current-cycle ovulation date, moved by BBT, OPK or a logged body signal
  /// when one confirms it.
  DateTime ovulationDay({DateTime? today}) => _effectiveOvulation();

  /// Resolved fertile window for the current cycle. Null when fertility
  /// predictions are off, the cycle is overdue, or projection has stopped.
  FertileWindow? fertileWindow({DateTime? today}) {
    if (!showFertilityNow(today: today)) return null;
    final peak = _effectiveOvulation();
    final pad = fertileWindowPad;
    return FertileWindow(
      start: _addDays(peak, -(5 + pad)),
      peak: peak,
      end: _addDays(peak, 1 + pad),
    );
  }

  /// First day of the fertile window; null when fertility predictions are off
  /// or the cycle is overdue.
  DateTime? fertileWindowStart({DateTime? today}) => fertileWindow(today: today)?.start;

  /// Last day of the fertile window; null when fertility predictions are off
  /// or the cycle is overdue.
  DateTime? fertileWindowEnd({DateTime? today}) => fertileWindow(today: today)?.end;

  /// This cycle's ovulation date. Unlike [nextOvulationDate] it never rolls
  /// forward, so a peak that already passed can still be named.
  DateTime ovulationDateThisCycle({DateTime? today}) => ovulationDay(today: today);

  /// Where today sits relative to this cycle's ovulation. Deriving copy from the
  /// effective ovulation date keeps the window from claiming "ovulation nears"
  /// after the peak has passed or after a BBT/OPK shift.
  FertilityStatus fertilityStatus({DateTime? today}) {
    final date = today ?? DateTime.now();
    if (!showFertilityPredictions) return FertilityStatus.passed;
    if (!predictionsConfident(today: date)) return FertilityStatus.overdue;
    final day = DateTime(date.year, date.month, date.day);
    final peak = _effectiveOvulation();
    final pad = fertileWindowPad;
    final daysToPeak = CycleCalculator.daysBetween(day, peak);
    if (daysToPeak > 0) {
      return !day.isBefore(_addDays(peak, -(5 + pad))) ? FertilityStatus.windowOpen : FertilityStatus.beforeWindow;
    }
    if (daysToPeak == 0) return FertilityStatus.peakToday;
    return !day.isAfter(_addDays(peak, 1 + pad)) ? FertilityStatus.windowClosing : FertilityStatus.passed;
  }

  int daysUntilOvulation({DateTime? today}) {
    final date = today ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    return CycleCalculator.daysBetween(day, nextOvulationDate(today: day));
  }

  /// The ovulation date [daysUntilOvulation] counts down to - rolls into the next
  /// cycle once this cycle's peak has passed, so value and label never disagree.
  DateTime nextOvulationDate({DateTime? today}) {
    final date = today ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final peak = _effectiveOvulation();
    return day.isAfter(peak) ? _addDays(peak, effectiveCycleLength) : peak;
  }

  /// Days past the latest plausible due date with no new period logged
  /// (0 = not late). Using the latest plausible length means a 35-day cycle is
  /// not called late on day 33 just because the median is 32.
  int daysLate({DateTime? today}) {
    final t = today ?? DateTime.now();
    final due = _addDays(effectiveLastStart, latestPlausibleCycleLength);
    final diff = CycleCalculator.daysBetween(due, t);
    return diff > 0 ? diff : 0;
  }

  /// A period day is either a logged period-flow day or an arithmetic
  /// prediction day while the current projection is still credible. Spotting
  /// never becomes a period day on its own, and overdue modular days are
  /// suppressed because they would describe a phantom next cycle.
  bool isPeriodDay(DateTime date) =>
      hasLoggedPeriodBleedOn(date) ||
      (predictionsConfident(today: date) &&
          CycleCalculator.isPeriodDay(effectiveLastStart, date, effectiveCycleLength, bleedLength));

  bool isFertileDay(DateTime date) {
    final window = fertileWindow(today: date);
    if (window == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(window.start) && !day.isAfter(window.end);
  }

  bool isOvulationDay(DateTime date) {
    if (!showFertilityNow(today: date)) return false;
    final day = DateTime(date.year, date.month, date.day);
    return CycleCalculator.daysBetween(day, _effectiveOvulation()) == 0;
  }

  bool get fertileToday => isFertileDay(DateTime.now());

  bool get ovulationToday => isOvulationDay(DateTime.now());

  int get ovulationCycleDay => CycleCalculator.daysBetween(effectiveLastStart, _effectiveOvulation()) + 1;

  int get fertileStartCycleDay {
    final day = ovulationCycleDay - 5 - fertileWindowPad;
    return day < 1 ? 1 : day;
  }

  int get fertileEndCycleDay => ovulationCycleDay + 1 + fertileWindowPad;
}
