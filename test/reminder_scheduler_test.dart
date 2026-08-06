import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:witchy/features/reminders/reminder_scheduler.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';
import 'package:witchy/models/time_of_day_model.dart';

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  });

  Reminder reminder({
    String id = 'r1',
    ReminderType type = ReminderType.water,
    List<int> weekday = const <int>[1, 3],
  }) {
    return Reminder(
      id: id,
      type: type,
      title: 'Water',
      body: 'Drink up',
      time: const TimeOfDayModel(hour: 9, minute: 30),
      weekday: weekday,
    );
  }

  group('notification id helpers', () {
    test('ids are stable for the same reminder and weekday', () {
      expect(notificationIdFor(reminder(), 1), notificationIdFor(reminder(), 1));
    });

    test('ids differ across weekdays and from the one-shot id', () {
      expect(notificationIdFor(reminder(), 1),
          isNot(notificationIdFor(reminder(), 2)));
      expect(notificationIdFor(reminder(), 1), isNot(oneShotIdFor(reminder())));
    });

    test('ids are always positive', () {
      for (int weekday = 1; weekday <= 7; weekday++) {
        expect(notificationIdFor(reminder(), weekday), greaterThanOrEqualTo(0));
      }
      expect(oneShotIdFor(reminder()), greaterThanOrEqualTo(0));
    });
  });

  group('nextWeekdayAt', () {
    test('returns the requested weekday at the requested time', () {
      final tz.TZDateTime result = nextWeekdayAt(tz.UTC, 3, 9, 30);
      expect(result.weekday, 3);
      expect(result.hour, 9);
      expect(result.minute, 30);
    });

    test('is always in the future and within the next 7 days', () {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.UTC);
      final tz.TZDateTime result = nextWeekdayAt(tz.UTC, 1, 7, 0);
      expect(result.isAfter(now), isTrue);
      expect(result.difference(now).inDays, lessThanOrEqualTo(7));
    });

    test('keeps the hour and minute for any weekday', () {
      for (int weekday = 1; weekday <= 7; weekday++) {
        final tz.TZDateTime result = nextWeekdayAt(tz.UTC, weekday, 21, 5);
        expect(result.hour, 21);
        expect(result.minute, 5);
        expect(result.weekday, weekday);
      }
    });
  });

  group('periodTriggerAt', () {
    test('anchors on the predicted date at the reminder time', () {
      final tz.TZDateTime result =
          periodTriggerAt(tz.UTC, DateTime(2026, 5, 20), 8, 15);
      expect(result.year, 2026);
      expect(result.month, 5);
      expect(result.day, 20);
      expect(result.hour, 8);
      expect(result.minute, 15);
    });
  });
}
