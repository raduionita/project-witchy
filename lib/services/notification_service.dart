import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_item.dart';

/// Resolved schedule for one enabled bell. Recurring bells fill
/// [hours]/[ids] with a non-null [match]; one-shot bells fill [oneShots]
/// with [match] null.
typedef BellSpec = ({
  String title,
  String body,
  List<int> hours,
  List<int> ids,
  int minute,
  DateTimeComponents? match,
  List<({int id, DateTime at})> oneShots,
});

class NotificationService {
  NotificationService._();

  static const int periodPredictionId = 424242;
  static const int periodPredictionHour = 9;

  static const String _channelId = 'witchy_reminders';
  static const String _channelName = 'Amulet Reminders';

  /// Daytime window used for 'Hourly' bells (repeat through match: time).
  static const List<int> _daytimeHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

  /// Freq labels that resolve to absolute one-shot dates instead of a daily repeat.
  static const Set<String> oneShotFreqs = {'Daily during peak', 'Window start', '3 days prior'};

  /// How far one-shot ids are retracted around resync so stale bells disappear.
  static const int _oneShotCancelBack = 7;
  static const int _oneShotCancelForward = 45;

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
    } catch (e) {
      debugPrint('Notification timezone lookup failed: $e');
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
    } catch (e) {
      debugPrint('Notification init unavailable: $e');
    }
  }

  static bool isOneShotFreq(String freq) => oneShotFreqs.contains(freq);

  /// Pure mapping of bells to schedule specs; never calls the plugin.
  /// Cycle anchors drive the one-shot freqs; [now] is injectable for tests.
  static List<BellSpec> buildNotificationRequests(
    List<ReminderItem> items, {
    DateTime? predictedStart,
    DateTime? fertileStart,
    int? bleedLength,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final specs = <BellSpec>[];
    for (final item in items) {
      if (!item.enabled) continue;
      final minute = item.time.trim().toLowerCase() == 'hourly' ? 0 : _parseTime(item.time).$2;
      if (isOneShotFreq(item.freq)) {
        final days = _oneShotDates(item.freq, today: today, predictedStart: predictedStart, fertileStart: fertileStart, bleedLength: bleedLength);
        if (days.isEmpty) continue;
        final (hour, _) = _parseTime(item.time);
        specs.add((
          title: item.title,
          body: item.subtitle,
          hours: const [],
          ids: const [],
          minute: minute,
          match: null,
          oneShots: [for (final d in days) (id: idAtDate(item.title, d), at: DateTime(d.year, d.month, d.day, hour, minute))],
        ));
      } else {
        final hours = hoursFor(item);
        specs.add((
          title: item.title,
          body: item.subtitle,
          hours: hours,
          ids: [for (final h in hours) idAtHour(item.title, h)],
          minute: minute,
          match: DateTimeComponents.time,
          oneShots: const [],
        ));
      }
    }
    return specs;
  }

  /// Absolute dates a one-shot freq must fire on, filtered to [today] onward.
  static List<DateTime> _oneShotDates(
    String freq, {
    required DateTime today,
    DateTime? predictedStart,
    DateTime? fertileStart,
    int? bleedLength,
  }) {
    final List<DateTime> raw;
    if (freq == 'Daily during peak') {
      if (predictedStart == null || bleedLength == null) return const [];
      raw = [for (var i = 0; i < bleedLength; i++) _dateOnly(predictedStart.add(Duration(days: i)))];
    } else if (freq == 'Window start') {
      raw = fertileStart == null ? const [] : [_dateOnly(fertileStart)];
    } else if (freq == '3 days prior') {
      raw = predictedStart == null ? const [] : [_dateOnly(predictedStart.subtract(const Duration(days: 3)))];
    } else {
      return const [];
    }
    return raw.where((d) => !d.isBefore(today)).toList();
  }

  /// Fire hours for a bell: daytime window when 'Hourly', else its stated time.
  static List<int> hoursFor(ReminderItem item) => item.time.trim().toLowerCase() == 'hourly' ? _daytimeHours : [_parseTime(item.time).$1];

  /// Deterministic per title+hour so schedule and cancel always target the same id.
  static int idAtHour(String title, int hour) => (idForTitle(title) + hour * 97) & 0x7fffffff;

  /// Deterministic per title+absolute date for one-shot bells.
  static int idAtDate(String title, DateTime date) {
    final days = _dateOnly(date).difference(DateTime(2000, 1, 1)).inDays;
    return (idForTitle(title) + days * 97) & 0x7fffffff;
  }

  static int idForTitle(String title) => title.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  static Future<void> syncAll(
    List<ReminderItem> items, {
    DateTime? predictedStart,
    DateTime? fertileStart,
    int? bleedLength,
  }) async {
    if (kIsWeb) return;
    for (final item in items) {
      await syncReminder(item, predictedStart: predictedStart, fertileStart: fertileStart, bleedLength: bleedLength);
    }
  }

  static Future<void> syncReminder(
    ReminderItem item, {
    DateTime? predictedStart,
    DateTime? fertileStart,
    int? bleedLength,
  }) async {
    if (kIsWeb) return;
    try {
      final oneShot = isOneShotFreq(item.freq);
      if (oneShot) await _cancelOneShots(item.title);
      if (!item.enabled) {
        if (oneShot) return;
        for (final h in hoursFor(item)) {
          await _plugin.cancel(id: idAtHour(item.title, h));
        }
        return;
      }
      final specs = buildNotificationRequests([item], predictedStart: predictedStart, fertileStart: fertileStart, bleedLength: bleedLength);
      for (final spec in specs) {
        await _schedule(spec);
      }
    } catch (e) {
      debugPrint('Notification sync failed for ${item.title}: $e');
      rethrow;
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
        // Prediction is today or already past - the app surfaces it live.
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
    } catch (e) {
      debugPrint('Period prediction sync failed: $e');
      rethrow;
    }
  }

  /// Retracts one-shot ids around today so stale window bells disappear.
  static Future<void> _cancelOneShots(String title) async {
    final today = _dateOnly(DateTime.now());
    for (var i = -_oneShotCancelBack; i <= _oneShotCancelForward; i++) {
      await _plugin.cancel(id: idAtDate(title, today.add(Duration(days: i))));
    }
  }

  static Future<void> _schedule(BellSpec spec) async {
    final now = tz.TZDateTime.now(tz.local);
    if (spec.match != null) {
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
      return;
    }
    for (final shot in spec.oneShots) {
      final at = tz.TZDateTime(tz.local, shot.at.year, shot.at.month, shot.at.day, shot.at.hour, shot.at.minute);
      if (!at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: shot.id,
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        title: spec.title,
        body: spec.body,
      );
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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
