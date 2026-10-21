import '../services/cycle_calculator.dart';

class PeriodSpan {
  const PeriodSpan({
    required this.start,
    required this.end,
    this.estimated = false,
    this.startOnly = false,
  });

  final DateTime start;
  final DateTime end;
  final bool estimated;
  final bool startOnly;

  int get length => startOnly ? 0 : CycleCalculator.daysBetween(start, end) + 1;
}
