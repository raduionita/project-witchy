import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/cycle.dart';
import '../models/symptom_insights.dart';
import '../models/symptom_log.dart';
import '../services/symptom_pattern_service.dart';
import '../utils/date_utils.dart';
import 'app_state_provider.dart';
import 'cycle_provider.dart';

/// Reactive facade over symptom logging and analysis.
///
/// Reads from `LogsRepository.symptomLogs`, exposes mutation methods that
/// persist through the repository, and re-derives symptom [insights] on every
/// change.
class SymptomProvider extends ChangeNotifier {
  SymptomProvider(this._state, this._cycleProvider)
      : _patternService = SymptomPatternService();

  final AppStateProvider _state;
  final CycleProvider _cycleProvider;
  final SymptomPatternService _patternService;
  final Uuid _uuid = const Uuid();

  SymptomInsights _insights = SymptomInsights.empty;

  SymptomInsights get insights => _insights;

  /// All logged symptom days, newest first.
  List<SymptomLog> get recentLogs {
    final List<SymptomLog> logs =
        List<SymptomLog>.from(_state.logs.symptomLogs.items)
          ..sort((SymptomLog a, SymptomLog b) => b.date.compareTo(a.date));
    return logs;
  }

  /// Recomputes insights from the repository. Called at startup and after
  /// every mutation.
  void recompute() {
    _insights = _patternService.analyze(
      logs: _state.logs.symptomLogs.items,
    );
    notifyListeners();
  }

  /// Logs (or updates) a symptom day.
  Future<void> logSymptoms(
    DateTime date, {
    List<String> symptoms = const <String>[],
    String? mood,
    String? notes,
  }) async {
    final DateTime day = dateOnly(date);
    final SymptomLog? existing = _logFor(day);

    if (existing == null) {
      await _state.logs.symptomLogs.add(
        SymptomLog(
          id: _uuid.v4(),
          date: day,
          symptoms: symptoms,
          mood: mood,
          notes: notes,
        ),
      );
    } else {
      await _state.logs.symptomLogs.update(
        existing.copyWith(
          symptoms: symptoms.isEmpty ? existing.symptoms : symptoms,
          mood: mood ?? existing.mood,
          notes: notes ?? existing.notes,
        ),
      );
    }
    recompute();
  }

  /// Removes the symptom log for [date], if any.
  Future<void> removeLog(DateTime date) async {
    final DateTime day = dateOnly(date);
    final SymptomLog? existing = _logFor(day);
    if (existing == null) return;
    await _state.logs.symptomLogs.remove(existing);
    recompute();
  }

  /// Phase breakdown for [symptom] across the logged history.
  SymptomPhaseBreakdown breakdownFor(String symptom) {
    final List<Cycle> cycles = _state.cycles.cyclesSorted;
    return _patternService.breakdownByPhase(
      symptom: symptom,
      logs: _state.logs.symptomLogs.items,
      cycles: cycles,
      currentPrediction: _cycleProvider.prediction,
    );
  }

  /// Cycle day indexes on which [symptom] was logged.
  List<int> dayIndexesFor(String symptom) {
    return _patternService.dayIndexesForSymptom(
      symptom: symptom,
      logs: _state.logs.symptomLogs.items,
      cycles: _state.cycles.cyclesSorted,
      currentPrediction: _cycleProvider.prediction,
    );
  }

  /// Trend direction for [symptom] across the logged timeline.
  SymptomTrend trendFor(String symptom) => _patternService.trendFor(
        symptom: symptom,
        logs: _state.logs.symptomLogs.items,
      );

  bool isSymptomDay(DateTime date) => recentLogs.any(
        (SymptomLog log) => dateOnly(log.date) == dateOnly(date),
      );

  SymptomLog? _logFor(DateTime day) {
    for (final SymptomLog log in _state.logs.symptomLogs.items) {
      if (dateOnly(log.date) == day) return log;
    }
    return null;
  }
}