import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_item.dart';

class NotificationService {
  NotificationService._();

  static const int periodPredictionId = 424242;
  static const int periodPredictionHour = 9;

  static const String _channelId = 'witchy_reminders';
  static const String _channelName = 'Amulet Reminders';

  /// Daytime window used for 'Hourly' bells (repeat through match: time).
  static const List<int> _daytimeHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Amulet bells and cycle predictions',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Plugin + timezone setup and permission prompts; call once at startup.
  static Future<void> init() async {
    if (kIsWeb) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep the UTC default when the platform timezone lookup fails.
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true),
        ),
      );
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions();
    } catch (_) {
      // Platform channel unavailable (desktop/test hosts) — notifications stay off.
    }
  }

  /// Pure mapping of bells to schedule specs; never calls the plugin.
  /// One spec per bell; [ids] aligns with [hours] (hourly bells fan out).
  static List<({List<int> ids, String title, String body, List<int> hours, int minute, DateTimeComponents match})> buildNotificationRequests(List<ReminderItem> items) {
    final specs = <({List<int> ids, String title, String body, List<int> hours, int minute, DateTimeComponents match})>[];
    for (final item in items) {
      if (!item.enabled) continue;
      final hours = hoursFor(item);
      final minute = item.time.trim().toLowerCase() == 'hourly' ? 0 : _parseTime(item.time).$2;
      specs.add((
        ids: [for (final h in hours) idAtHour(item.title, h)],
        title: item.title,
        body: item.subtitle,
        hours: hours,
        minute: minute,
        match: DateTimeComponents.time,
      ));
    }
    return specs;
  }

  /// Fire hours for a bell: daytime window when 'Hourly', else its stated time.
  static List<int> hoursFor(ReminderItem item) => item.time.trim().toLowerCase() == 'hourly' ? _daytimeHours : [_parseTime(item.time).$1];

  /// Deterministic per title+hour so schedule and cancel always target the same id.
  static int idAtHour(String title, int hour) => (idForTitle(title) + hour * 97) & 0x7fffffff;

  static int idForTitle(String title) => title.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  static Future<void> syncAll(List<ReminderItem> items) async {
    if (kIsWeb) return;
    for (final item in items) {
      await syncReminder(item);
    }
  }

  static Future<void> syncReminder(ReminderItem item) async {
    if (kIsWeb) return;
    try {
      if (!item.enabled) {
        for (final h in hoursFor(item)) {
          await _plugin.cancel(id: idAtHour(item.title, h));
        }
        return;
      }
      final specs = buildNotificationRequests([item]);
      if (specs.isNotEmpty) await _schedule(specs.first);
    } catch (_) {
      // Best-effort: no platform channel (desktop/test hosts).
    }
  }

  /// Toggles the monthly period-prediction alert for the given cycle data.
  static Future<void> syncPeriodPrediction({required bool enabled, DateTime? predictedStart}) async {
    if (kIsWeb) return;
    try {
      if (!enabled || predictedStart == null) {
        await _plugin.cancel(id: periodPredictionId);
        return;
      }
      final now = tz.TZDateTime.now(tz.local);
      final at = tz.TZDateTime(tz.local, predictedStart.year, predictedStart.month, predictedStart.day, periodPredictionHour);
      if (!at.isAfter(now)) {
        // Prediction is today or already past — the app surfaces it live.
        await _plugin.cancel(id: periodPredictionId);
        return;
      }
      await _plugin.zonedSchedule(
        id: periodPredictionId,
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        title: 'Tide Commencing',
        body: 'Your bleeding phase is predicted to begin today.',
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } catch (_) {
      // Best-effort: no platform channel (desktop/test hosts).
    }
  }

  static Future<void> _schedule(({List<int> ids, String title, String body, List<int> hours, int minute, DateTimeComponents match}) spec) async {
    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < spec.hours.length; i++) {
      final hour = spec.hours[i];
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, spec.minute);
      if (!at.isAfter(now)) {
        at = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, hour, spec.minute);
      }
      await _plugin.zonedSchedule(
        id: spec.ids[i],
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        title: spec.title,
        body: spec.body,
        matchDateTimeComponents: spec.match,
      );
    }
  }

  static (int, int) _parseTime(String raw) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$', caseSensitive: false).firstMatch(raw.trim());
    if (match == null) return (9, 0);
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final suffix = match.group(3)?.toUpperCase();
    if (suffix == 'PM' && hour < 12) hour += 12;
    if (suffix == 'AM' && hour == 12) hour = 0;
    return (hour.clamp(0, 23), minute.clamp(0, 59));
  }
}
