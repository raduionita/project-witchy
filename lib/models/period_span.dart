import '../services/cycle_calculator.dart';

class PeriodSpan {
  const PeriodSpan({
    required this.start,
    required this.end,
    this.estimated = false,
    this.startOnly = false,
    this.spottingOnly = false,
  });

  final DateTime start;
  final DateTime end;
  final bool estimated;
  final bool startOnly;

  /// True when every logged day in the span is spotting. Spotting stays visible
  /// in history but must never seed cycle math or move the cycle anchor.
  final bool spottingOnly;

  int get length => startOnly ? 0 : CycleCalculator.daysBetween(start, end) + 1;
}
