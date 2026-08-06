import 'package:freezed_annotation/freezed_annotation.dart';

import 'flow_intensity.dart';

part 'period_log.freezed.dart';
part 'period_log.g.dart';

/// A single day's period record.
@freezed
abstract class PeriodLog with _$PeriodLog {
  const factory PeriodLog({
    required String id,
    required DateTime date,
    FlowIntensity? intensity,
    @Default(<String>[]) List<String> symptoms,
    String? mood,
    String? notes,
  }) = _PeriodLog;

  factory PeriodLog.fromJson(Map<String, dynamic> json) =>
      _$PeriodLogFromJson(json);
}