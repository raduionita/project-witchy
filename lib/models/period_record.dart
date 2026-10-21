import '../services/cycle_calculator.dart';
import 'period_span.dart';

enum PeriodSource { manual, onboarding, migrated }

/// An explicitly known period start. [end] is null when only the start date is
/// known, so the app never invents a bleed range from onboarding input.
class PeriodRecord {
  const PeriodRecord({
    required this.start,
    this.end,
    this.source = PeriodSource.manual,
    this.estimated = false,
  });

  final DateTime start;
  final DateTime? end;
  final PeriodSource source;
  final bool estimated;

  bool get startOnly => end == null;

  int? get length {
    final finish = end;
    if (finish == null) return null;
    return CycleCalculator.daysBetween(start, finish) + 1;
  }

  PeriodSpan toSpan() => PeriodSpan(
    start: start,
    end: end ?? start,
    estimated: estimated,
    startOnly: startOnly,
  );

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    if (end != null) 'end': end!.toIso8601String(),
    'source': source.name,
    'estimated': estimated,
  };

  factory PeriodRecord.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['start'] as String? ?? '');
    if (start == null) {
      throw const FormatException('Period record is missing a start date');
    }
    final end = DateTime.tryParse(json['end'] as String? ?? '');
    final sourceName = json['source'] as String?;
    final source = PeriodSource.values.firstWhere(
      (s) => s.name == sourceName,
      orElse: () => PeriodSource.manual,
    );
    return PeriodRecord(
      start: DateTime(start.year, start.month, start.day),
      end: end == null ? null : DateTime(end.year, end.month, end.day),
      source: source,
      estimated: json['estimated'] as bool? ?? false,
    );
  }
}
