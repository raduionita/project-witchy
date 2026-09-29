import 'package:flutter/material.dart';

import '../models/cycle_phase.dart';
import '../models/period_span.dart';
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
    final stated = _onboarding.lastPeriodStart;
    final logged = bleeds.isEmpty ? null : bleeds.last.start;
    effectiveLastStart = (logged == null || logged.isBefore(stated)) ? stated : logged;
  }

  int get bleedLength => _onboarding.bleedLength;

  int cycleDay({DateTime? today}) => CycleCalculator.cycleDay(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  CyclePhase phaseAt(DateTime date) => CycleCalculator.phaseAt(effectiveLastStart, date, effectiveCycleLength, bleedLength);

  CyclePhase phase({DateTime? today}) => phaseAt(today ?? DateTime.now());

  DateTime nextPeriodStart({DateTime? today}) => CycleCalculator.nextPeriodStart(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  int daysUntilPeriod({DateTime? today}) => CycleCalculator.daysUntilPeriod(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  DateTime ovulationDay({DateTime? today}) => CycleCalculator.ovulationDay(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  int daysUntilOvulation({DateTime? today}) => CycleCalculator.daysUntilOvulation(effectiveLastStart, today ?? DateTime.now(), effectiveCycleLength);

  bool isPeriodDay(DateTime date) => CycleCalculator.isPeriodDay(effectiveLastStart, date, effectiveCycleLength, bleedLength);

  bool isFertileDay(DateTime date) => CycleCalculator.isFertileDay(effectiveLastStart, date, effectiveCycleLength);

  bool isOvulationDay(DateTime date) => CycleCalculator.isOvulationDay(effectiveLastStart, date, effectiveCycleLength);

  bool get fertileToday => isFertileDay(DateTime.now());

  bool get ovulationToday => isOvulationDay(DateTime.now());

  int get ovulationCycleDay => CycleCalculator.ovulationCycleDay(effectiveCycleLength);

  int get fertileStartCycleDay => CycleCalculator.fertileStartCycleDay(effectiveCycleLength);

  int get fertileEndCycleDay => CycleCalculator.fertileEndCycleDay(effectiveCycleLength);

  double? get meanCycleLength => PeriodHistory.mean(observedCycleLengths);

  double? get meanBleedLength => PeriodHistory.mean([for (final s in bleeds) s.length]);
}
