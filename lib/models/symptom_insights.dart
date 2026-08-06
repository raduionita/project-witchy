import 'package:flutter/foundation.dart';

import 'cycle_phase.dart';

/// A single symptom with its occurrence count across the logged history.
@immutable
class SymptomFrequency {
  const SymptomFrequency({required this.symptom, required this.count});

  final String symptom;
  final int count;
}

/// Aggregated symptom analysis used by the Insights feature.
@immutable
class SymptomInsights {
  const SymptomInsights({
    required this.totalLogs,
    required this.totalSymptomCount,
    required this.topSymptoms,
  });

  /// Number of logged symptom days.
  final int totalLogs;

  /// Total symptom selections across all logs (a day may have many).
  final int totalSymptomCount;

  /// Most common symptoms, descending by count.
  final List<SymptomFrequency> topSymptoms;

  static const SymptomInsights empty = SymptomInsights(
    totalLogs: 0,
    totalSymptomCount: 0,
    topSymptoms: <SymptomFrequency>[],
  );
}

/// Per-phase frequency for a single symptom.
@immutable
class SymptomPhaseBreakdown {
  const SymptomPhaseBreakdown({
    required this.symptom,
    required this.total,
    required this.byPhase,
  });

  final String symptom;
  final int total;
  final Map<CyclePhase, int> byPhase;
}