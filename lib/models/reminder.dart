import 'package:freezed_annotation/freezed_annotation.dart';

import 'reminder_type.dart';
import 'time_of_day_model.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// A scheduled notification reminder.
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required ReminderType type,
    required String title,
    required TimeOfDayModel time,
    @Default(<int>[]) List<int> weekday,
    @Default(true) bool enabled,
    String? body,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}