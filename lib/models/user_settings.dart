import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 5)
class UserSettings extends HiveObject {
  @HiveField(0)
  double averageCycleLength;

  @HiveField(1)
  double averagePeriodDuration;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  String periodReminderTime;

  @HiveField(4)
  String ovulationReminderTime;

  @HiveField(5)
  double cycleLengthVariation;

  @HiveField(6)
  bool isPregnancyMode;

  @HiveField(7)
  DateTime? pregnancyDueDate;

  @HiveField(8)
  String preferredWeekStartDay;

  @HiveField(9)
  bool anonymousMode;

  UserSettings({
    this.averageCycleLength = 28.0,
    this.averagePeriodDuration = 5.0,
    this.notificationsEnabled = true,
    this.periodReminderTime = '09:00',
    this.ovulationReminderTime = '10:00',
    this.cycleLengthVariation = 7.0,
    this.isPregnancyMode = false,
    this.pregnancyDueDate,
    this.preferredWeekStartDay = 'monday',
    this.anonymousMode = true,
  });

  UserSettings copyWith({
    double? averageCycleLength,
    double? averagePeriodDuration,
    bool? notificationsEnabled,
    String? periodReminderTime,
    String? ovulationReminderTime,
    double? cycleLengthVariation,
    bool? isPregnancyMode,
    DateTime? pregnancyDueDate,
    String? preferredWeekStartDay,
    bool? anonymousMode,
  }) {
    return UserSettings(
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration: averagePeriodDuration ?? this.averagePeriodDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      periodReminderTime: periodReminderTime ?? this.periodReminderTime,
      ovulationReminderTime: ovulationReminderTime ?? this.ovulationReminderTime,
      cycleLengthVariation: cycleLengthVariation ?? this.cycleLengthVariation,
      isPregnancyMode: isPregnancyMode ?? this.isPregnancyMode,
      pregnancyDueDate: pregnancyDueDate ?? this.pregnancyDueDate,
      preferredWeekStartDay: preferredWeekStartDay ?? this.preferredWeekStartDay,
      anonymousMode: anonymousMode ?? this.anonymousMode,
    );
  }
}
