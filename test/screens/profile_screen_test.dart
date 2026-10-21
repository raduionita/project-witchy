import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/alert_provider.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/reminders_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/screens/profile_screen.dart';
import 'package:witchy/services/prefs_service.dart';

DateTime previousMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1);
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    bool seedCycles = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime(2026, 9, 1),
    );
    final logging = LoggingProvider(prefs);
    final cycle = CycleProvider(onboarding, logging);
    if (seedCycles) {
      for (final start in [
        DateTime(2026, 7, 1),
        DateTime(2026, 7, 29),
        DateTime(2026, 8, 26),
      ]) {
        logging.setFlow(start, 'Medium');
        // Two days: a single flow day counts as spotting, not as a period.
        logging.setFlow(
          DateTime(start.year, start.month, start.day + 1),
          'Light',
        );
      }
    }
    final settings = await SettingsProvider.load(prefs);
    final reminders = await RemindersProvider.load(prefs);
    final alerts = await AlertProvider.load(prefs);
    final auth = await AuthProvider.load(prefs);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ChangeNotifierProvider<RemindersProvider>.value(value: reminders),
          ChangeNotifierProvider<AlertProvider>.value(value: alerts),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cycle averages read real cycle averages', (tester) async {
    await pumpProfile(tester, seedCycles: true);
    expect(find.text('Average Cycle Length'), findsOneWidget);
    expect(find.text('28 Days'), findsOneWidget);
    expect(find.text('Calculated'), findsOneWidget);
    expect(find.text('Bleeding Phase Length'), findsOneWidget);
    expect(find.text('2 Days'), findsOneWidget);
  });

  testWidgets('empty history shows the estimated setup value', (tester) async {
    await pumpProfile(tester);
    expect(find.text('28 Days'), findsOneWidget);
    expect(find.text('Estimated'), findsOneWidget);
  });

  testWidgets('add past period saves a range', (tester) async {
    await pumpProfile(tester);
    await tester.scrollUntilVisible(find.text('Add past period'), 400);
    await tester.tap(find.text('Add past period'));
    await tester.pumpAndSettle();

    // Pick the first two days of the previous month, so they are always past.
    final month = previousMonth();
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('period-day-${month.year}-${month.month}-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('period-day-${month.year}-${month.month}-2')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save period'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save period'));
    await tester.pumpAndSettle();
    expect(find.text('Past periods'), findsOneWidget);
    expect(find.text('Start only'), findsNothing);
  });

  testWidgets('bell count and version come from real sources', (tester) async {
    await pumpProfile(tester);
    await tester.scrollUntilVisible(find.text('3 of 5 reminders active'), 400);
    expect(find.text('3 of 5 reminders active'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Version'), 400);
    expect(find.textContaining('Version 1.2.4'), findsNothing);
    expect(find.textContaining('Version'), findsOneWidget);
  });

  testWidgets('guest session offers Sign Out, not Switch Account', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.scrollUntilVisible(find.text('Sign Out'), 400);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Switch Account'), findsNothing);
  });

  testWidgets('editing cycle basics persists and updates the card', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.text('Bleeding Phase Length'));
    await tester.pumpAndSettle();
    expect(find.text('Cycle Basics'), findsOneWidget);
    // The second slider is the bleeding phase length; step it up by one day.
    await tester.tap(find.byIcon(Icons.add_circle_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('6 Days'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Cycle Basics'), findsNothing);
    expect(find.text('6 Days'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('witchy_bleed_len'), 6);
  });

  testWidgets('changing a reminder frequency updates the pill and persists', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.scrollUntilVisible(find.text('Each bleed day'), 400);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Each bleed day'));
    await tester.pumpAndSettle();
    expect(find.text('Frequency'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(SimpleDialog),
        matching: find.text('Every day'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Each bleed day'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    final configs =
        jsonDecode(prefs.getString('witchy_reminders')!)
            as Map<String, dynamic>;
    expect(
      (configs['Period Reminder'] as Map<String, dynamic>)['freq'],
      'Every day',
    );
  });
}
