import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_screen.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/couples/couples_provider.dart';
import 'package:witchy/features/couples/couples_screen.dart';
import 'package:witchy/features/couples/couples_service.dart';
import 'package:witchy/features/reminders/reminder_provider.dart';
import 'package:witchy/features/reminders/reminder_scheduler.dart';
import 'package:witchy/features/reminders/reminders_screen.dart';
import 'package:witchy/features/settings/settings_screen.dart';
import 'package:witchy/features/settings/theme_provider.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/symptom_provider.dart';
import 'package:witchy/services/storage_service.dart';

class FakeReminderScheduler extends ReminderScheduler {
  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> schedule(
    Reminder reminder, {
    DateTime? nextPeriodStart,
    int periodLength = 5,
  }) async {}

  @override
  Future<void> cancel(Reminder reminder) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    final AppStateProvider state = AppStateProvider(storage)..load();
    await state.profile.save(
      const UserProfile(
        id: 'p1',
        averageCycleLength: 28,
        averagePeriodLength: 5,
      ),
    );
    final CycleProvider cycle = CycleProvider(state)..recompute();
    final SymptomProvider symptom = SymptomProvider(state, cycle)..recompute();
    final ReminderProvider reminders =
        ReminderProvider(state, FakeReminderScheduler(), cycle: cycle)..load();
    final AuthProvider auth = AuthProvider(
      AuthService(storage: storage, gateway: NativeAuthGateway()),
    )..load();
    final CouplesProvider couples = CouplesProvider(CoupleService(storage))
      ..load();
    final ThemeProvider theme = ThemeProvider(storage)..load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SymptomProvider>.value(value: symptom),
          ChangeNotifierProvider<ReminderProvider>.value(value: reminders),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<CouplesProvider>.value(value: couples),
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('privacy tile shows a coming-soon snackbar',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Privacy'), 300);
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy is coming soon.'), findsOneWidget);
  });

  testWidgets('about tile shows a coming-soon snackbar',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('About'), 300);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('About is coming soon.'), findsOneWidget);
  });

  testWidgets('reminders tile navigates to the reminders screen',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Reminders'), 300);
    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();

    expect(find.byType(RemindersScreen), findsOneWidget);
  });

  testWidgets('couples mode tile navigates to the couples screen',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Couples mode'), 300);
    await tester.tap(find.text('Couples mode'));
    await tester.pumpAndSettle();

    expect(find.byType(CouplesScreen), findsOneWidget);
  });

  testWidgets('account tile navigates to the auth screen when signed out',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Sign in (optional)'), findsOneWidget);
  });
}