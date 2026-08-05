import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'daily_log.freezed.dart';
part 'daily_log.g.dart';

@HiveType(typeId: 1)
@freezed
class DailyLog with _$DailyLog {
  const factory DailyLog({
    @HiveField(0) required String id,
    @HiveField(1) required DateTime date,
    @HiveField(2) @Default([]) List<String> symptoms,
    @HiveField(3) @Default(0) int moodScore, // 1-5 scale
    @HiveField(4) String? notes,
  }) = _DailyLog;

  factory DailyLog.fromJson(Map<String, dynamic> json) => _$DailyLogFromJson(json);
}
