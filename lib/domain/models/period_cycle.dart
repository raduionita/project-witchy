import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'period_cycle.freezed.dart';
part 'period_cycle.g.dart';

@HiveType(typeId: 0)
@freezed
class PeriodCycle with _$PeriodCycle {
  const factory PeriodCycle({
    @HiveField(0) required String id,
    @HiveField(1) required DateTime startDate,
    @HiveField(2) required DateTime endDate,
    @HiveField(3) @Default(false) bool isCompleted,
  }) = _PeriodCycle;

  factory PeriodCycle.fromJson(Map<String, dynamic> json) => _$PeriodCycleFromJson(json);
}
