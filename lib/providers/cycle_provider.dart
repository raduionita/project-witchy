import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/cycle_prediction.dart';
import '../models/flow_intensity.dart';
import '../models/period_log.dart';
import '../models/user_profile.dart';
import '../services/cycle_calculator.dart';
import '../utils/date_utils.dart';
import 'app_state_provider.dart';

/// Reactive facade over the cycle domain.
///
/// Reads raw data from [AppStateProvider]'s repositories, computes the current
/// [CyclePrediction], and exposes mutations (log/remove a period day) that
/// persist through the repositories and trigger a recompute on every change.
class CycleProvider extends ChangeNotifier {
  CycleProvider(this._state, {DateTime Function()? now})
      : _calculator = CycleCalculator(now: now);

  final AppStateProvider _state;
  final CycleCalculator _calculator;
  final Uuid _uuid = const Uuid();

  /// All dates with a logged period, as date-only values.
  Set<DateTime> _periodDays = <DateTime>{};

  /// The latest computed prediction, or null when data is insufficient.
  CyclePrediction? _prediction;

  Set<DateTime> get periodDays => _periodDays;
  CyclePrediction? get prediction => _prediction;

  /// The logged-in days of the current on-going period (if any).
  UserProfile? get profile => _state.profile.profile;

  /// Recomputes derived state from the repositories. Called after loads and
  /// every mutation.
  void recompute() {
    _periodDays = _state.logs.periodLogs.items
        .map((PeriodLog log) => dateOnly(log.date))
        .toSet();

    final UserProfile? profile = _state.profile.profile;
    _prediction = profile == null
        ? null
        : _calculator.predict(
            profile: profile,
            loggedPeriodDays: _periodDays,
            cycles: _state.cycles.cyclesSorted,
          );
    notifyListeners();
  }

  /// Logs a period day, creating or updating the log for [date].
  Future<void> logPeriodDay(
    DateTime date, {
    FlowIntensity? intensity,
    List<String> symptoms = const <String>[],
    String? mood,
    String? notes,
  }) async {
    final DateTime day = dateOnly(date);
    final PeriodLog? existing = _logFor(day);

    if (existing == null) {
      await _state.logs.periodLogs.add(
        PeriodLog(
          id: _uuid.v4(),
          date: day,
          intensity: intensity,
          symptoms: symptoms,
          mood: mood,
          notes: notes,
        ),
      );
    } else {
      await _state.logs.periodLogs.update(
        existing.copyWith(
          intensity: intensity ?? existing.intensity,
          symptoms: symptoms.isEmpty ? existing.symptoms : symptoms,
          mood: mood ?? existing.mood,
          notes: notes ?? existing.notes,
        ),
      );
    }
    recompute();
  }

  /// Removes the period log for [date], if present.
  Future<void> removePeriodDay(DateTime date) async {
    final DateTime day = dateOnly(date);
    final PeriodLog? existing = _logFor(day);
    if (existing == null) return;
    await _state.logs.periodLogs.remove(existing);
    recompute();
  }

  /// Whether any period is logged for [date].
  bool isPeriodDay(DateTime date) => _periodDays.contains(dateOnly(date));

  /// Recent period logs, newest first.
  List<PeriodLog> get recentPeriodLogs {
    final List<PeriodLog> logs = List<PeriodLog>.from(_state.logs.periodLogs.items)
      ..sort((PeriodLog a, PeriodLog b) => b.date.compareTo(a.date));
    return logs.take(10).toList();
  }

  PeriodLog? _logFor(DateTime day) {
    for (final PeriodLog log in _state.logs.periodLogs.items) {
      if (dateOnly(log.date) == day) return log;
    }
    return null;
  }
}