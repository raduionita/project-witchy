import 'package:flutter/foundation.dart';

/// A single completed cycle as a chart point (start date + length).
@immutable
class CycleLengthPoint {
  const CycleLengthPoint({required this.startDate, required this.length});

  final DateTime startDate;
  final int length;
}

/// Aggregate length statistics over completed cycles.
@immutable
class CycleMetrics {
  const CycleMetrics({
    required this.cycleCount,
    this.averageLength,
    this.shortestLength,
    this.longestLength,
  });

  final int cycleCount;
  final double? averageLength;
  final int? shortestLength;
  final int? longestLength;
}

/// How accurate cycle-length based predictions have been historically.
@immutable
class PredictionAccuracy {
  const PredictionAccuracy({
    required this.comparisonCount,
    this.averageErrorDays,
  });

  /// Number of predicted-vs-actual comparisons made.
  final int comparisonCount;

  /// Average |predicted - actual| in days, or null when nothing to compare.
  final double? averageErrorDays;
}