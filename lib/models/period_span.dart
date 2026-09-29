import '../services/cycle_calculator.dart';

class PeriodSpan {
  const PeriodSpan({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get length => CycleCalculator.daysBetween(start, end) + 1;
}
