import 'package:flutter/material.dart';

import '../models/cycle_phase.dart';
import '../models/day_log.dart';
import '../models/fertility_status.dart';
import '../models/period_span.dart';
import '../models/tracking_mode.dart';
import '../services/bbt_analyzer.dart';
import '../services/cycle_calculator.dart';
import '../services/cycle_stats.dart';
import '../services/period_history.dart';
import 'logging_provider.dart';
import 'gestation_provider.dart';
import 'onboarding_provider.dart';

/// Reactive read-model over onboarding settings + logged days.
/// Effective inputs adapt to logged period history (median cycle length,
/// latest logged start) and fall back to onboarding settings otherwise.
class CycleProvider extends ChangeNotifier {
  CycleProvider(this._onboarding, this._logging, {GestationProvider? gestation}) : _gestation = gestation {
    _onboarding.addListener(_changed);
    _logging.addListener(_changed);
    _gestation?.addListener(_changed);
    _recompute();
  }

  final OnboardingProvider _onboarding;
  final LoggingProvider _logging;
  final GestationProvider? _gestation;

  late DateTime effectiveLastStart;
  late int effectiveCycleLength;
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

  /// Luteal length driving every ovulation/fertility computation: personal
  /// when measured, otherwise the population-average fallback.
  int get lutealLength => detectedLutealLength ?? BbtAnalyzer.fallbackLutealLength;

  void _changed() {
    _recompute();
    notifyListeners();
  }

  void _recompute() {
    bleeds = PeriodHistory.spansFrom(_logging.snapshot(), _logging.periodRecords);
    observedCycleLengths = PeriodHistory.cycleLengths(PeriodHistory.startsOf(bleeds));
    // One value drives predictions and every displayed average: the last-6
    // median once two completed cycles exist, otherwise the setup value.
    final recentMedian = observedCycleLengths.length >= 2 ? stats.medianRecent : null;
    effectiveCycleLength = recentMedian ?? _onboarding.cycleLength;
    effectiveLastStart = _resolveAnchor();
    final temps = <DateTime, double?>{for (final e in _logging.snapshot().entries) e.key: e.value.temperature};
    final bbt = BbtAnalyzer.analyze(temps: temps, bleedStarts: PeriodHistory.startsOf(bleeds));
    detectedLutealLength = bbt.personalLutealLength;
    confirmedOvulationDate = bbt.confirmedOvulation;
    opkIndicatedOvulationDate = _latestPositiveOpk(_logging.snapshot());
    detectedLutealLength ??= _opkLutealLength(_logging.snapshot(), PeriodHistory.startsOf(bleeds));
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

  /// Real logged bleed length, rounded and clamped, falling back to the setup
  /// slider until at least one complete logged span exists.
  int get bleedLength {
    final mean = meanBleedLength;
    return mean == null ? _onboarding.bleedLength : mean.round().clamp(2, 10).toInt();
  }

  /// Start dates that came from onboarding or migration rather than flow logs.
  Set<DateTime> get estimatedPeriodStarts => {
    for (final span in bleeds)
      if (span.estimated) span.start,
  };

  /// True when the effective cycle length comes from logged history rather than the slider.
  bool get isCycleLengthAuto => observedCycleLengths.length >= 2;

  /// Plain-language source for every prediction: observed history once two
  /// completed cycles exist, otherwise the onboarding default.
  String get predictionBasis {
    final count = observedCycleLengths.length;
    return count >= 2 ? 'Based on $count cycles' : 'Based on default ${_onboarding.cycleLength} days';
  }

  /// True when [date] falls inside a logged bleed span.
  bool hasLoggedBleedOn(DateTime date) => _spanIndexOf(date) >= 0;

  int _spanIndexOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (var i = 0; i < bleeds.length; i++) {
      final s = bleeds[i];
      if (s.startOnly) continue;
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
    if (isOverdue(today: date)) return 0;
    return CycleCalculator.bleedDay(effectiveLastStart, date, effectiveCycleLength, bleedLength);
  }

  /// Fertility predictions surface while the Cycle mode is active, unless a
  /// dated pregnancy suppresses them (Flo parity: no period or fertility
  /// predictions once pregnancy tracking has an LMP).
  bool get showFertilityPredictions => _onboarding.trackingModes.contains(TrackingMode.cycle) && !pregnancyActive;

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
  bool projectionStopped({DateTime? today}) => daysLate(today: today) > projectionGraceDays;

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

  /// Phase for [date]. A day with logged bleeding is always menstrual, even when
  /// the pure-arithmetic cycle position would place it in another phase. Once
  /// the cycle is overdue, the phase freezes at luteal instead of wrapping into
  /// a phantom next cycle.
  CyclePhase phaseAt(DateTime date) {
    if (hasLoggedBleedOn(date)) return CyclePhase.menstrual;
    if (isOverdue(today: date)) return CyclePhase.luteal;
    return CycleCalculator.phaseAt(effectiveLastStart, date, effectiveCycleLength, bleedLength, lutealLength: lutealLength);
  }

  CyclePhase phase({DateTime? today}) => phaseAt(today ?? DateTime.now());

  /// Next projected start; null once the projection has stopped
  /// (see [projectionStopped]) until a new bleed is logged.
  DateTime? nextPeriodStart({DateTime? today}) {
    final t = today ?? DateTime.now();
    if (projectionStopped(today: t)) return null;
    return CycleCalculator.nextPeriodStart(effectiveLastStart, t, effectiveCycleLength);
  }

  int daysUntilPeriod({DateTime? today}) => CycleCalculator.daysUntilPeriod(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  DateTime ovulationDay({DateTime? today}) => CycleCalculator.ovulationDay(
    effectiveLastStart,
    today ?? DateTime.now(),
    effectiveCycleLength,
    lutealLength: lutealLength,
  );

  /// First day of the fertile window (ovulation minus 5); null when fertility
  /// predictions are off or the cycle is overdue.
  DateTime? fertileWindowStart({DateTime? today}) =>
      showFertilityNow(today: today) ? _addDays(ovulationDay(today: today), -5) : null;

  /// Last day of the fertile window (ovulation plus 1); null when fertility
  /// predictions are off or the cycle is overdue.
  DateTime? fertileWindowEnd({DateTime? today}) =>
      showFertilityNow(today: today) ? _addDays(ovulationDay(today: today), 1) : null;

  /// This cycle's ovulation date. Unlike [nextOvulationDate] it never rolls
  /// forward, so a peak that already passed can still be named.
  DateTime ovulationDateThisCycle({DateTime? today}) => ovulationDay(today: today);

  /// Where today sits relative to this cycle's ovulation. Deriving copy from the
  /// ovulation date keeps the window from claiming "ovulation nears" after the
  /// peak has passed.
  FertilityStatus fertilityStatus({DateTime? today}) {
    final date = today ?? DateTime.now();
    if (!showFertilityPredictions) return FertilityStatus.passed;
    if (!predictionsConfident(today: date)) return FertilityStatus.overdue;
    final day = DateTime(date.year, date.month, date.day);
    final peak = CycleCalculator.ovulationDay(effectiveLastStart, day, effectiveCycleLength, lutealLength: lutealLength);
    final daysToPeak = CycleCalculator.daysBetween(day, peak);
    final cycleDay = CycleCalculator.cycleDay(effectiveLastStart, day, effectiveCycleLength);
    if (daysToPeak > 0) {
      return cycleDay >= fertileStartCycleDay ? FertilityStatus.windowOpen : FertilityStatus.beforeWindow;
    }
    if (daysToPeak == 0) return FertilityStatus.peakToday;
    return cycleDay <= fertileEndCycleDay ? FertilityStatus.windowClosing : FertilityStatus.passed;
  }

  int daysUntilOvulation({DateTime? today}) => CycleCalculator.daysUntilOvulation(
    effectiveLastStart,
    today ?? DateTime.now(),
    effectiveCycleLength,
    lutealLength: lutealLength,
  );

  /// The ovulation date [daysUntilOvulation] counts down to - rolls into the next
  /// cycle once this cycle's peak has passed, so value and label never disagree.
  DateTime nextOvulationDate({DateTime? today}) => CycleCalculator.nextOvulationDay(
    effectiveLastStart,
    today ?? DateTime.now(),
    effectiveCycleLength,
    lutealLength: lutealLength,
  );

  /// Days past the latest plausible due date with no new period logged
  /// (0 = not late). Using the latest plausible length means a 35-day cycle is
  /// not called late on day 33 just because the median is 32.
  int daysLate({DateTime? today}) {
    final t = today ?? DateTime.now();
    final due = _addDays(effectiveLastStart, latestPlausibleCycleLength);
    final diff = CycleCalculator.daysBetween(due, t);
    return diff > 0 ? diff : 0;
  }

  /// A period day is either a logged bleed day or an arithmetic prediction day
  /// while the current projection is still credible. Once overdue, modular
  /// period days would be a phantom next cycle and are suppressed.
  bool isPeriodDay(DateTime date) =>
      hasLoggedBleedOn(date) ||
      (predictionsConfident(today: date) &&
          CycleCalculator.isPeriodDay(effectiveLastStart, date, effectiveCycleLength, bleedLength));

  bool isFertileDay(DateTime date) =>
      showFertilityNow(today: date) &&
      CycleCalculator.isFertileDay(effectiveLastStart, date, effectiveCycleLength, lutealLength: lutealLength);

  bool isOvulationDay(DateTime date) =>
      showFertilityNow(today: date) &&
      CycleCalculator.isOvulationDay(effectiveLastStart, date, effectiveCycleLength, lutealLength: lutealLength);

  bool get fertileToday => isFertileDay(DateTime.now());

  bool get ovulationToday => isOvulationDay(DateTime.now());

  int get ovulationCycleDay => CycleCalculator.ovulationCycleDay(effectiveCycleLength, lutealLength: lutealLength);

  int get fertileStartCycleDay => CycleCalculator.fertileStartCycleDay(effectiveCycleLength, lutealLength: lutealLength);

  int get fertileEndCycleDay => CycleCalculator.fertileEndCycleDay(effectiveCycleLength, lutealLength: lutealLength);

  double? get meanBleedLength => PeriodHistory.mean([
    for (final s in PeriodHistory.periods(bleeds))
      if (!s.estimated && !s.startOnly) s.length,
  ]);
}
