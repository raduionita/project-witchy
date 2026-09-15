import 'package:freezed_annotation/freezed_annotation.dart';

part 'intercourse_log.freezed.dart';
part 'intercourse_log.g.dart';

/// A recorded intimacy / intercourse day.
@freezed
abstract class IntercourseLog with _$IntercourseLog {
  const factory IntercourseLog({
    required String id,
    required DateTime date,
    String? notes,
  }) = _IntercourseLog;

  factory IntercourseLog.fromJson(Map<String, dynamic> json) =>
      _$IntercourseLogFromJson(json);
}
