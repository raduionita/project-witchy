import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/features/reminders/reminder_defaults.dart';
import 'package:witchy/l10n/app_localizations_en.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('ReminderDefaults.typeLabel', () {
    test('labels every type', () {
      expect(ReminderDefaults.typeLabel(l10n, ReminderType.periodStart),
          'Period start');
      expect(ReminderDefaults.typeLabel(l10n, ReminderType.periodEnd),
          'Period end');
      expect(ReminderDefaults.typeLabel(l10n, ReminderType.medication),
          'Medication');
      expect(ReminderDefaults.typeLabel(l10n, ReminderType.water), 'Water');
      expect(ReminderDefaults.typeLabel(l10n, ReminderType.sleep), 'Sleep');
      expect(ReminderDefaults.typeLabel(l10n, ReminderType.custom), 'Custom');
    });
  });

  group('ReminderDefaults.forType', () {
    test('every type produces a complete, enabled reminder', () {
      for (final ReminderType type in ReminderType.values) {
        final Reminder reminder =
            ReminderDefaults.forType(l10n, type, id: 'r-$type');
        expect(reminder.id, 'r-$type');
        expect(reminder.type, type);
        expect(reminder.title, isNotEmpty);
        expect(reminder.body, isNotEmpty);
        expect(reminder.enabled, isTrue);
      }
    });

    test('daily types default to every weekday', () {
      final Reminder water =
          ReminderDefaults.forType(l10n, ReminderType.water, id: 'r1');
      expect(water.weekday, <int>[1, 2, 3, 4, 5, 6, 7]);
    });

    test('period-based types start without a fixed weekday set', () {
      final Reminder start =
          ReminderDefaults.forType(l10n, ReminderType.periodStart, id: 'r2');
      final Reminder end =
          ReminderDefaults.forType(l10n, ReminderType.periodEnd, id: 'r3');
      expect(start.weekday, isEmpty);
      expect(end.weekday, isEmpty);
    });

    test('distinct types get distinct sensible times', () {
      final Reminder medication =
          ReminderDefaults.forType(l10n, ReminderType.medication, id: 'm');
      final Reminder sleep =
          ReminderDefaults.forType(l10n, ReminderType.sleep, id: 's');
      expect(medication.time.hour, isNot(sleep.time.hour));
    });
  });

  group('ReminderDefaults.isPeriodBased', () {
    test('only period start/end are period based', () {
      expect(ReminderDefaults.isPeriodBased(ReminderType.periodStart), isTrue);
      expect(ReminderDefaults.isPeriodBased(ReminderType.periodEnd), isTrue);
      expect(ReminderDefaults.isPeriodBased(ReminderType.medication), isFalse);
      expect(ReminderDefaults.isPeriodBased(ReminderType.water), isFalse);
      expect(ReminderDefaults.isPeriodBased(ReminderType.sleep), isFalse);
      expect(ReminderDefaults.isPeriodBased(ReminderType.custom), isFalse);
    });
  });
}
