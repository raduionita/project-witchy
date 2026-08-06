import 'package:freezed_annotation/freezed_annotation.dart';

part 'symptom_log.freezed.dart';
part 'symptom_log.g.dart';

/// A day's symptom + mood record, used for pattern recognition.
@freezed
abstract class SymptomLog with _$SymptomLog {
  const factory SymptomLog({
    required String id,
    required DateTime date,
    @Default(<String>[]) List<String> symptoms,
    String? mood,
    String? notes,
  }) = _SymptomLog;

  factory SymptomLog.fromJson(Map<String, dynamic> json) =>
      _$SymptomLogFromJson(json);
}