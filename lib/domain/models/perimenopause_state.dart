import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'perimenopause_state.freezed.dart';
part 'perimenopause_state.g.dart';

@HiveType(typeId: 3)
@freezed
class PerimenopauseState with _$PerimenopauseState {
  const factory PerimenopauseState({
    @HiveField(0) required String id,
    @HiveField(1) @Default(false) bool isTracking,
  }) = _PerimenopauseState;

  factory PerimenopauseState.fromJson(Map<String, dynamic> json) => _$PerimenopauseStateFromJson(json);
}
