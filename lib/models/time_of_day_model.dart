import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_of_day_model.freezed.dart';
part 'time_of_day_model.g.dart';

/// Serializable time-of-day value (hours + minutes).
@freezed
abstract class TimeOfDayModel with _$TimeOfDayModel {
  const factory TimeOfDayModel({
    required int hour,
    required int minute,
  }) = _TimeOfDayModel;

  factory TimeOfDayModel.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayModelFromJson(json);
}