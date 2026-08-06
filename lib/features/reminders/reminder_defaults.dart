import '../../models/reminder.dart';
import '../../models/reminder_type.dart';
import '../../models/time_of_day_model.dart';

/// Sensible per-type defaults and labels for reminders.
abstract class ReminderDefaults {
  /// Human label for a [ReminderType].
  static String typeLabel(ReminderType type) => switch (type) {
        ReminderType.periodStart => 'Period start',
        ReminderType.periodEnd => 'Period end',
        ReminderType.medication => 'Medication',
        ReminderType.water => 'Water',
        ReminderType.sleep => 'Sleep',
        ReminderType.custom => 'Custom',
      };

  /// A fully-formed [Reminder] pre-filled with a sensible configuration.
  static Reminder forType(ReminderType type, {required String id}) {
    final (String title, String body, TimeOfDayModel time, List<int> weekdays) =
        _preset(type);
    return Reminder(
      id: id,
      type: type,
      title: title,
      body: body,
      time: time,
      weekday: weekdays,
    );
  }

  static (String, String, TimeOfDayModel, List<int>) _preset(ReminderType type) {
    const TimeOfDayModel morning = TimeOfDayModel(hour: 8, minute: 0);
    const TimeOfDayModel midday = TimeOfDayModel(hour: 10, minute: 0);
    const TimeOfDayModel evening = TimeOfDayModel(hour: 21, minute: 30);
    const List<int> everyDay = <int>[1, 2, 3, 4, 5, 6, 7];

    return switch (type) {
      ReminderType.periodStart => (
          'Period coming up',
          'Your period is expected to start soon.',
          morning,
          const <int>[],
        ),
      ReminderType.periodEnd => (
          'Period reminder',
          'Your period may be wrapping up.',
          morning,
          const <int>[],
        ),
      ReminderType.medication => (
          'Medication',
          'Take your medication now.',
          TimeOfDayModel(hour: 9, minute: 0),
          everyDay,
        ),
      ReminderType.water => (
          'Water break',
          'Time for some water.',
          midday,
          everyDay,
        ),
      ReminderType.sleep => (
          'Wind down',
          'Start winding down for the night.',
          evening,
          everyDay,
        ),
      ReminderType.custom => (
          'Reminder',
          'You set this reminder.',
          midday,
          everyDay,
        ),
    };
  }

  /// Whether a type is tied to the predicted cycle rather than a fixed week.
  static bool isPeriodBased(ReminderType type) =>
      type == ReminderType.periodStart || type == ReminderType.periodEnd;
}
