import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/reminders/reminder_provider.dart';
import 'package:witchy/features/reminders/reminder_scheduler.dart';
import 'package:witchy/features/reminders/reminders_screen.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';
import 'package:witchy/models/time_of_day_model.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/storage_service.dart';

class FakeReminderScheduler extends ReminderScheduler {
  FakeReminderScheduler({this.granted = true});

  final bool granted;
  final List<String> scheduled = <String>[];
  int permissionRequests = 0;

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
  }

  @override
  Future<void> cancel(Reminder reminder) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  late AppStateProvider state;
  late FakeReminderScheduler scheduler;
  late ReminderProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    state = AppStateProvider(storage)..load();
    final CycleProvider cycle = CycleProvider(state)..recompute();
    scheduler = FakeReminderScheduler();
    provider = ReminderProvider(state, scheduler, cycle: cycle)..load();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<ReminderProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: RemindersScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state when there are no reminders',
      (WidgetTester tester) async {
    await pumpScreen(tester);
    expect(find.text('No reminders yet'), findsOneWidget);
    expect(find.text('Your reminders'), findsNothing);
  });

  testWidgets('shows the permission fallback when denied',
      (WidgetTester tester) async {
    scheduler = FakeReminderScheduler(granted: false);
    provider = ReminderProvider(state, scheduler)..load();
    await pumpScreen(tester);

    expect(find.text('Notifications are off'), findsOneWidget);
    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();
    // One request on screen open (initState) plus the explicit tap.
    expect(scheduler.permissionRequests, 2);
  });

  testWidgets('creating a reminder schedules it and shows it in the list',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('New reminder'));
    await tester.pumpAndSettle();

    expect(find.text('New reminder'), findsWidgets);
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();

    expect(provider.reminders, hasLength(1));
    expect(scheduler.scheduled, hasLength(1));
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('toggling a reminder keeps it and reschedules',
      (WidgetTester tester) async {
    await provider.save(Reminder(
      id: 'w1',
      type: ReminderType.water,
      title: 'Water',
      body: 'Drink up',
      time: const TimeOfDayModel(hour: 10, minute: 0),
      weekday: const <int>[1, 2, 3, 4, 5],
    ));
    await pumpScreen(tester);

    expect(find.text('Water'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(provider.reminders.single.enabled, isFalse);
  });
}
