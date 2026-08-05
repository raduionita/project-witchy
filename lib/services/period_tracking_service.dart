// Period tracking service - core business logic for cycle tracking and predictions

import 'package:witchy/models/cycle_models.dart';
import 'dart:math';

class PeriodTrackingService {
  final List<CycleEntry> _entries;

  PeriodTrackingService() : _entries = [];

  void addEntry(CycleEntry entry) {
    _entries.add(entry);
    // Sort by date (newest first)
    _entries.sort((a, b) => b.date.compareTo(a.date));
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
  }

  List<CycleEntry> get entries => List.unmodifiable(_entries);

  /// Get the most recent period start date
  DateTime? get lastPeriodStart {
    return _entries
        .firstWhere(
          (e) => e.isPeriodStart(),
          orElse: () => throw StateError('No period start found'),
        )
        .date;
  }

  /// Get the most recent period end date
  DateTime? get lastPeriodEnd {
    return _entries
        .firstWhere(
          (e) => e.isPeriodEnd(),
          orElse: () => throw StateError('No period end found'),
        )
        .date;
  }

  /// Get the most recent ovulation date
  DateTime? get lastOvulation {
    return _entries
        .firstWhere(
          (e) => e.isOvulation(),
          orElse: () => throw StateError('No ovulation recorded'),
        )
        .date;
  }

  /// Calculate the average cycle length from recorded periods
  int get averageCycleLength {
    final periods = _entries.where((e) => e.isPeriodStart()).toList();
    if (periods.length < 2) return 28; // Default cycle length

    int totalDays = 0;
    for (int i = 1; i < periods.length; i++) {
      totalDays += periods[i].date.difference(periods[i - 1].date).inDays;
    }

    return totalDays ~/ (periods.length - 1);
  }

  /// Get the shortest cycle length recorded
  int get shortestCycle {
    final periods = _entries.where((e) => e.isPeriodStart()).toList();
    if (periods.length < 2) return 28;

    int min = periods[1].date.difference(periods[0].date).inDays;
    for (int i = 2; i < periods.length; i++) {
      int days = periods[i].date.difference(periods[i - 1].date).inDays;
      if (days < min) min = days;
    }

    return min;
  }

  /// Get the longest cycle length recorded
  int get longestCycle {
    final periods = _entries.where((e) => e.isPeriodStart()).toList();
    if (periods.length < 2) return 28;

    int max = periods[1].date.difference(periods[0].date).inDays;
    for (int i = 2; i < periods.length; i++) {
      int days = periods[i].date.difference(periods[i - 1].date).inDays;
      if (days > max) max = days;
    }

    return max;
  }

  /// Check if the user is regular (cycles within 7 days of average)
  bool get isRegular => _entries.where((e) => e.isPeriodStart()).length >= 3;

  /// Calculate cycle predictions
  CyclePrediction calculatePredictions() {
    final avgCycle = averageCycleLength;
    final lastStart = lastPeriodStart ?? DateTime.now();

    // Next period prediction (based on average cycle length)
    int? nextPeriodStart = null;
    if (lastPeriodStart.isBefore(DateTime.now())) {
      nextPeriodStart = lastStartDate().difference(DateTime.now()).inDays + avgCycle;
    }

    // Next ovulation (typically 14 days before next period)
    int? nextOvulation = null;
    if (nextPeriodStart != null && nextPeriodStart > 0) {
      nextOvulation = (nextPeriodStart - 14).clamp(0, 28);
    }

    // Generate fertile days (typically 5 days before ovulation + day of)
    final fertileDays = nextOvulation != null
        ? List.generate(6, (i) => (nextOvulation - 5 + i).toString())
        : [];

    // Check if currently fertile (within 6 days of next ovulation)
    bool isFertileNow = false;
    if (nextOvulation != null && nextOvulation >= 0 && nextOvulation <= 6) {
      isFertileNow = true;
    }

    return CyclePrediction(
      nextPeriodStart: nextPeriodStart,
      nextOvulation: nextOvulation,
      fertileDays: fertileDays,
      isFertileNow: isFertileNow,
    );
  }

  /// Get the current cycle phase based on days since last period start
  CyclePhase getCurrentPhase() {
    final daysSinceLastStart = DateTime.now().difference(lastPeriodStart ?? DateTime.now()).inDays;

    if (daysSinceLastStart < 7) return CyclePhase.all()[0]; // Premenstrual
    if (daysSinceLastStart < 12) return CyclePhase.all()[1]; // Menstruation
    if (daysSinceLastStart < 22) return CyclePhase.all()[2]; // Follicular
    if (daysSinceLastStart == 22) return CyclePhase.all()[3]; // Ovulation
    if (daysSinceLastStart < 28) return CyclePhase.all()[4]; // Luteal
    return CyclePhase.all()[5]; // Unknown
  }

  /// Get the current cycle day number (1-28+)
  int getCurrentCycleDay() {
    return DateTime.now().difference(lastPeriodStart ?? DateTime.now()).inDays + 1;
  }

  /// Get the number of days until next period
  int? getDaysUntilNextPeriod() {
    final predictions = calculatePredictions();
    return predictions.nextPeriodStart;
  }

  /// Get the number of days until next ovulation
  int? getDaysUntilNextOvulation() {
    final predictions = calculatePredictions();
    return predictions.nextOvulation;
  }

  /// Get the cycle length for the given period
  int getCycleLengthForPeriod(int index) {
    final starts = _entries.where((e) => e.isPeriodStart()).toList();
    if (index + 1 >= starts.length) return null;

    final start = starts[index].date;
    final end = _entries.firstWhere(
      (e) => e.isPeriodEnd() && e.date.isAfter(start),
    );

    return end.date.difference(start).inDays;
  }

  /// Check if a given date falls on the fertile window
  bool isDateFertile(DateTime date) {
    final predictions = calculatePredictions();
    return predictions.fertileDays.contains(date.toIso8601String.split('-')[1]);
  }

  /// Get summary of the current month's tracking data
  MonthlySummary getMonthlySummary() {
    final starts = _entries.where((e) => e.isPeriodStart()).toList();

    if (starts.length < 2) {
      return MonthlySummary(
        averageCycleLength: 28,
        shortestCycle: 28,
        longestCycle: 28,
        averageLength: null,
        isRegular: false,
      );
    }

    final totalDays = starts.fold(0, (sum, entry) {
      // Calculate days between consecutive periods
      final nextPeriod = starts.indexOf(entry) + 1 < starts.length
          ? starts[starts.indexOf(entry) + 1].date
          : null;

      if (nextPeriod == null) return sum;
      return sum + nextPeriod.difference(entry.date).inDays;
    });

    final avg = totalDays / starts.length.toDouble();
    return MonthlySummary(
      averageCycleLength: avg.round(),
      shortestCycle: shortestCycle,
      longestCycle: longestCycle,
      averageLength: avg,
      isRegular: avg.diff(28).abs() < 7, // Regular if within 7 days of 28
    );
  }

  DateTime lastStartDate() {
    return _entries.firstWhere(
      (e) => e.isPeriodStart(),
      orElse: () => DateTime.now(),
    ).date;
  }

}
