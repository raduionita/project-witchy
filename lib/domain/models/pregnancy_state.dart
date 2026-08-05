import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'pregnancy_state.freezed.dart';
part 'pregnancy_state.g.dart';

@HiveType(typeId: 2)
@freezed
class PregnancyState with _$PregnancyState {
  const factory PregnancyState({
    @HiveField(0) required String id,
    @HiveField(1) required DateTime conceptionDate,
    @HiveField(2) @Default(false) bool isCurrent,
  }) = _PregnancyState;

  factory PregnancyState.fromJson(Map<String, dynamic> json) => _$PregnancyStateFromJson(json);
}
