import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../models/reminder.dart';
import '../../models/reminder_type.dart';
import 'reminder_defaults.dart';

/// FNV-1a over [value], masked to a positive 31-bit id.
///
/// Unlike [Object.hash] this is deterministic across app launches, so
/// previously scheduled platform notifications can always be cancelled and
/// replaced instead of silently stacking duplicates on every relaunch.
int _stableHashCode(String value) {
  int hash = 0x811c9dc5;
  for (final int unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// Stable notification id for [reminder] recurring on [weekday] (ISO 1-7).
int notificationIdFor(Reminder reminder, int weekday) =>
    _stableHashCode('${reminder.id}|$weekday');

/// Stable notification id for [reminder]'s period-based one-shot alert.
int oneShotIdFor(Reminder reminder) => _stableHashCode('${reminder.id}|period');

/// Next occurrence of [weekday] at [hour]:[minute] in [location], using today
/// if that time is still ahead, otherwise the following matching weekday.
tz.TZDateTime nextWeekdayAt(
  tz.Location location,
  int weekday,
  int hour,
  int minute,
) {
  final tz.TZDateTime now = tz.TZDateTime.now(location);
  final tz.TZDateTime todayAt =
      tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
  int days = weekday - now.weekday;
  if (days < 0 || (days == 0 && !todayAt.isAfter(now))) days += 7;
  return tz.TZDateTime(location, now.year, now.month, now.day + days, hour, minute);
}

/// One-shot trigger for a period reminder anchored on a predicted date.
tz.TZDateTime periodTriggerAt(
  tz.Location location,
  DateTime date,
  int hour,
  int minute,
) =>
    tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);

/// Wraps the platform notification plugin.
///
/// Handles init, permission requests, and (un)scheduling. Pure date/id
/// helpers are top-level functions so scheduling logic stays unit-testable.
class ReminderScheduler {
  ReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Set<int> _scheduledIds = <int>{};

  bool _initialized = false;
  bool _timezoneReady = false;

  bool _initializeTimezones() {
    if (_timezoneReady) return true;
    try {
      tzdata.initializeTimeZones();
      _timezoneReady = true;
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initializeTimezones();
    await _trySetLocalTimezone();

    try {
      const InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } on Exception {
      // Plugin unavailable (e.g. unit/widget tests); stay uninitialized so the
      // app still boots and every later call degrades gracefully.
    }
  }

  Future<void> _trySetLocalTimezone() async {
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Requests the platform permission needed to show notifications.
  Future<bool> requestPermissions() async {
    await initialize();
    bool granted = true;

    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        granted = await android.requestNotificationsPermission() ?? granted;
      }
      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        granted = await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            granted;
      }
    } on Exception {
      granted = true;
    }
    return granted;
  }

  /// Whether notifications are currently enabled on the platform.
  Future<bool> areNotificationsEnabled() async {
    await initialize();
    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? true;
      }
    } on Exception {
      return true;
    }
    return true;
  }

  /// (Re)schedules [reminder]. Cancels any previously scheduled ids first.
  ///
  /// Period-based types schedule a one-shot at the predicted cycle date when
  /// [nextPeriodStart] is available; otherwise they fall back to a fixed
  /// weekly schedule like the other types.
  Future<void> schedule(
    Reminder reminder, {
    DateTime? nextPeriodStart,
    int periodLength = 5,
  }) async {
    await initialize();
    await cancel(reminder);
    if (!reminder.enabled) return;

    final NotificationDetails details = _detailsFor(reminder.type);

    if (ReminderDefaults.isPeriodBased(reminder.type) &&
        nextPeriodStart != null) {
      await _scheduleOneShot(
        reminder,
        _oneShotDate(reminder, nextPeriodStart, periodLength),
        details,
      );
      return;
    }

    for (final int weekday in reminder.weekday) {
      final int id = notificationIdFor(reminder, weekday);
      final tz.TZDateTime trigger = nextWeekdayAt(
        tz.local,
        weekday,
        reminder.time.hour,
        reminder.time.minute,
      );
      await _scheduleRecurring(id, reminder, trigger, details);
    }
  }

  DateTime _oneShotDate(Reminder reminder, DateTime nextPeriodStart, int periodLength) {
    return switch (reminder.type) {
      ReminderType.periodStart => nextPeriodStart,
      ReminderType.periodEnd =>
        DateTime(nextPeriodStart.year, nextPeriodStart.month,
            nextPeriodStart.day + periodLength),
      _ => nextPeriodStart,
    };
  }

  Future<void> _scheduleOneShot(
    Reminder reminder,
    DateTime date,
    NotificationDetails details,
  ) async {
    final int id = oneShotIdFor(reminder);
    final tz.TZDateTime trigger =
        periodTriggerAt(tz.local, date, reminder.time.hour, reminder.time.minute);
    await _schedule(id, reminder, trigger, details);
  }

  Future<void> _scheduleRecurring(
    int id,
    Reminder reminder,
    tz.TZDateTime trigger,
    NotificationDetails details,
  ) async {
    await _schedule(
      id,
      reminder,
      trigger,
      details,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _schedule(
    int id,
    Reminder reminder,
    tz.TZDateTime trigger,
    NotificationDetails details, {
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        reminder.title,
        reminder.body,
        trigger,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      _scheduledIds.add(id);
    } on Exception {
      // Exact alarms can be unavailable (e.g. permission withheld). Fall back
      // to an inexact schedule rather than failing the whole save.
      try {
        await _plugin.zonedSchedule(
          id,
          reminder.title,
          reminder.body,
          trigger,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: matchDateTimeComponents,
        );
        _scheduledIds.add(id);
      } on Exception {
        // Last resort: leave unscheduled.
      }
    }
  }

  /// Cancels every notification associated with [reminder].
  Future<void> cancel(Reminder reminder) async {
    for (final int weekday in reminder.weekday) {
      final int id = notificationIdFor(reminder, weekday);
      await _safeCancel(id);
    }
    await _safeCancel(oneShotIdFor(reminder));
  }

  /// Cancels every notification scheduled through this instance.
  Future<void> cancelAll() async {
    for (final int id in _scheduledIds.toList()) {
      await _safeCancel(id);
    }
    _scheduledIds.clear();
  }

  Future<void> _safeCancel(int id) async {
    try {
      await _plugin.cancel(id);
    } on Exception {
      // Plugin unavailable; nothing to cancel.
    }
    _scheduledIds.remove(id);
  }

  NotificationDetails _detailsFor(ReminderType type) {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'witchy_reminders',
      'Witchy reminders',
      channelDescription: 'Reminders for period, medication, water and sleep.',
      importance: Importance.high,
      priority: Priority.high,
    );
    return const NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(),
    );
  }

  @visibleForTesting
  FlutterLocalNotificationsPlugin get plugin => _plugin;
}
