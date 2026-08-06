import 'dart:convert';

enum NotificationType {
  periodReminder,
  ovulationReminder,
  medicationReminder,
  waterReminder,
  sleepReminder,
  general,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledDate;
  final bool isEnabled;
  final int? hour;
  final int? minute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledDate,
    this.isEnabled = true,
    this.hour,
    this.minute,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? scheduledDate,
    bool? isEnabled,
    int? hour,
    int? minute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.index,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isEnabled': isEnabled,
      'hour': hour,
      'minute': minute,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.values[map['type'] as int],
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
      isEnabled: map['isEnabled'] as bool? ?? true,
      hour: map['hour'] as int?,
      minute: map['minute'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppNotification.fromJson(String source) =>
      AppNotification.fromMap(json.decode(source) as Map<String, dynamic>);
}
