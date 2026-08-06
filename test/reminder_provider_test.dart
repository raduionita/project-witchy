import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/reminders/reminder_provider.dart';
import 'package:witchy/features/reminders/reminder_scheduler.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';
import 'package:witchy/models/time_of_day_model.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/services/storage_service.dart';

/// Records scheduling calls instead of touching a real notification plugin.
class FakeReminderScheduler extends ReminderScheduler {
  FakeReminderScheduler({this.granted = true});

  final bool granted;
  final List<String> scheduled = <String>[];
  final List<String> cancelled = <String>[];
  int cancelAllCalls = 0;
  int permissionRequests = 0;
  DateTime? lastNextPeriodStart;

  @override
  Future<bool> requestPermissions() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<void> schedule(
    Reminder reminder, {
    DateTime? nextPeriodStart,
    int periodLength = 5,
  }) async {
    scheduled.add(reminder.id);
    lastNextPeriodStart = nextPeriodStart;
  }

  @override
  Future<void> cancel(Reminder reminder) async {
    cancelled.add(reminder.id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }
}

void main() {
  late StorageService storage;
  late AppStateProvider state;
  late FakeReminderScheduler scheduler;
  late ReminderProvider provider;

  Future<void> build() async {
    storage = StorageService(await SharedPreferences.getInstance());
    state = AppStateProvider(storage)..load();
    scheduler = FakeReminderScheduler();
    provider = ReminderProvider(state, scheduler)..load();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await build();
  });

  Reminder water({String id = 'w1', bool enabled = true}) => Reminder(
        id: id,
        type: ReminderType.water,
        title: 'Water',
        body: 'Drink up',
        time: const TimeOfDayModel(hour: 10, minute: 0),
        weekday: const <int>[1, 2, 3, 4, 5],
        enabled: enabled,
      );

  test('save persists the reminder and schedules it', () async {
    await provider.save(water());
    expect(provider.reminders, hasLength(1));
    expect(scheduler.scheduled, contains('w1'));

    final List<dynamic> raw = storage.readList('reminders');
    final Map<String, dynamic> json = raw.first as Map<String, dynamic>;
    expect(json['title'], 'Water');
    expect(json['type'], ReminderType.water.name);
  });

  test('remove deletes the reminder and cancels its notifications',
      () async {
    await provider.save(water());
    await provider.remove('w1');
    expect(provider.reminders, isEmpty);
    expect(scheduler.cancelled, contains('w1'));
  });

  test('disabling a reminder keeps it but stops scheduling', () async {
    await provider.save(water());
    await provider.setEnabled('w1', false);
    expect(provider.reminders.single.enabled, isFalse);
    expect(scheduler.scheduled.last, 'w1');
  });

  test('period reminders receive the predicted start on reschedule',
      () async {
    await state.profile.save(const UserProfile(id: 'p1'));
    await provider.save(Reminder(
      id: 'p1',
      type: ReminderType.periodStart,
      title: 'Period',
      body: 'Soon',
      time: const TimeOfDayModel(hour: 8, minute: 0),
      weekday: const <int>[],
    ));
    expect(scheduler.lastNextPeriodStart, isNull);
  });

  test('requestPermissions records the outcome', () async {
    scheduler = FakeReminderScheduler(granted: false);
    provider = ReminderProvider(state, scheduler);
    final bool granted = await provider.requestPermissions();
    expect(granted, isFalse);
    expect(provider.permissionGranted, isFalse);
    expect(scheduler.permissionRequests, 1);
  });

  test('ensurePermissions only asks once', () async {
    await provider.ensurePermissions();
    await provider.ensurePermissions();
    expect(scheduler.permissionRequests, 1);
  });

  test('load schedules all persisted reminders', () async {
    await provider.save(water(id: 'a'));
    await provider.save(water(id: 'b'));
    final ReminderProvider reloaded = ReminderProvider(state, scheduler);
    await reloaded.load();
    expect(scheduler.cancelAllCalls, 2);
    expect(scheduler.scheduled, contains('a'));
    expect(scheduler.scheduled, contains('b'));
  });
}
