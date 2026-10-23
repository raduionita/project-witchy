import '../services/cycle_calculator.dart';

/// A fertile window resolved to real dates for the current cycle.
class FertileWindow {
  const FertileWindow({
    required this.start,
    required this.peak,
    required this.end,
  });

  final DateTime start;
  final DateTime peak;
  final DateTime end;

  int get length => CycleCalculator.daysBetween(start, end) + 1;
}
