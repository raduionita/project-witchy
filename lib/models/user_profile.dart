import 'dart:convert';

enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal,
}

class UserProfile {
  final String id;
  final String? name;
  final DateTime? lastPeriodStart;
  final int averageCycleLength;
  final int averagePeriodDuration;
  final bool isPregnancyMode;
  final String? pregnancyWeek;
  final String? pregnancyTrimester;
  final String? userName;
  final String? userEmail;
  final bool notificationsEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;

  const UserProfile({
    required this.id,
    this.name,
    this.lastPeriodStart,
    this.averageCycleLength = 28,
    this.averagePeriodDuration = 5,
    this.isPregnancyMode = false,
    this.pregnancyWeek,
    this.pregnancyTrimester,
    this.userName,
    this.userEmail,
    this.notificationsEnabled = true,
    this.reminderTimeHour = 9,
    this.reminderTimeMinute = 0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? lastPeriodStart,
    int? averageCycleLength,
    int? averagePeriodDuration,
    bool? isPregnancyMode,
    String? pregnancyWeek,
    String? pregnancyTrimester,
    String? userName,
    String? userEmail,
    bool? notificationsEnabled,
    int? reminderTimeHour,
    int? reminderTimeMinute,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration: averagePeriodDuration ?? this.averagePeriodDuration,
      isPregnancyMode: isPregnancyMode ?? this.isPregnancyMode,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      pregnancyTrimester: pregnancyTrimester ?? this.pregnancyTrimester,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastPeriodStart': lastPeriodStart?.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'averagePeriodDuration': averagePeriodDuration,
      'isPregnancyMode': isPregnancyMode,
      'pregnancyWeek': pregnancyWeek,
      'pregnancyTrimester': pregnancyTrimester,
      'userName': userName,
      'userEmail': userEmail,
      'notificationsEnabled': notificationsEnabled,
      'reminderTimeHour': reminderTimeHour,
      'reminderTimeMinute': reminderTimeMinute,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String?,
      lastPeriodStart: map['lastPeriodStart'] != null
          ? DateTime.parse(map['lastPeriodStart'] as String)
          : null,
      averageCycleLength: map['averageCycleLength'] as int? ?? 28,
      averagePeriodDuration: map['averagePeriodDuration'] as int? ?? 5,
      isPregnancyMode: map['isPregnancyMode'] as bool? ?? false,
      pregnancyWeek: map['pregnancyWeek'] as String?,
      pregnancyTrimester: map['pregnancyTrimester'] as String?,
      userName: map['userName'] as String?,
      userEmail: map['userEmail'] as String?,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      reminderTimeHour: map['reminderTimeHour'] as int? ?? 9,
      reminderTimeMinute: map['reminderTimeMinute'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
