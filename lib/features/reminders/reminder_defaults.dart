import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';
import '../../models/reminder_type.dart';
import '../../models/time_of_day_model.dart';

/// Sensible per-type defaults and labels for reminders.
abstract class ReminderDefaults {
  /// Human label for a [ReminderType].
  static String typeLabel(AppLocalizations l10n, ReminderType type) =>
      switch (type) {
        ReminderType.periodStart => l10n.reminderTypePeriodStart,
        ReminderType.periodEnd => l10n.reminderTypePeriodEnd,
        ReminderType.medication => l10n.reminderTypeMedication,
        ReminderType.water => l10n.reminderTypeWater,
        ReminderType.sleep => l10n.reminderTypeSleep,
        ReminderType.custom => l10n.reminderTypeCustom,
      };

  /// A fully-formed [Reminder] pre-filled with a sensible configuration.
  static Reminder forType(
    AppLocalizations l10n,
    ReminderType type, {
    required String id,
  }) {
    final (String title, String body, TimeOfDayModel time, List<int> weekdays) =
        _preset(l10n, type);
    return Reminder(
      id: id,
      type: type,
      title: title,
      body: body,
      time: time,
      weekday: weekdays,
    );
  }

  static (String, String, TimeOfDayModel, List<int>) _preset(
      AppLocalizations l10n, ReminderType type) {
    const TimeOfDayModel morning = TimeOfDayModel(hour: 8, minute: 0);
    const TimeOfDayModel midday = TimeOfDayModel(hour: 10, minute: 0);
    const TimeOfDayModel evening = TimeOfDayModel(hour: 21, minute: 30);
    const List<int> everyDay = <int>[1, 2, 3, 4, 5, 6, 7];

    return switch (type) {
      ReminderType.periodStart => (
          l10n.presetPeriodComingUp,
          l10n.presetBodyPeriodComingUp,
          morning,
          const <int>[],
        ),
      ReminderType.periodEnd => (
          l10n.presetPeriodReminder,
          l10n.presetBodyPeriodReminder,
          morning,
          const <int>[],
        ),
      ReminderType.medication => (
          l10n.presetMedication,
          l10n.presetBodyMedication,
          TimeOfDayModel(hour: 9, minute: 0),
          everyDay,
        ),
      ReminderType.water => (
          l10n.presetWaterBreak,
          l10n.presetBodyWater,
          midday,
          everyDay,
        ),
      ReminderType.sleep => (
          l10n.presetWindDown,
          l10n.presetBodySleep,
          evening,
          everyDay,
        ),
      ReminderType.custom => (
          l10n.presetReminder,
          l10n.presetBodyCustom,
          midday,
          everyDay,
        ),
    };
  }

  /// Whether a type is tied to the predicted cycle rather than a fixed week.
  static bool isPeriodBased(ReminderType type) =>
      type == ReminderType.periodStart || type == ReminderType.periodEnd;
}
