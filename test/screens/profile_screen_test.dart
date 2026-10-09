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

void main() {
  Future<void> pumpProfile(WidgetTester tester, {bool seedCycles = false}) async {
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
      logging.setFlow(DateTime(2026, 7, 1), 'Medium');
      logging.setFlow(DateTime(2026, 7, 29), 'Medium');
      logging.setFlow(DateTime(2026, 8, 26), 'Medium');
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

  testWidgets('lunar alignments read real cycle averages', (tester) async {
    await pumpProfile(tester, seedCycles: true);
    expect(find.text('Average Cycle Length'), findsOneWidget);
    expect(find.text('28 Days'), findsOneWidget);
    expect(find.text('Bleeding Phase Length'), findsOneWidget);
    expect(find.text('5 Days'), findsOneWidget);
  });

  testWidgets('empty history shows a dash instead of a fake average', (tester) async {
    await pumpProfile(tester);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('29 Days'), findsNothing);
  });

  testWidgets('bell count and version come from real sources', (tester) async {
    await pumpProfile(tester);
    expect(find.text('3 of 5 bells active'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Version'), 400);
    expect(find.textContaining('Version 1.2.4'), findsNothing);
    expect(find.textContaining('Version'), findsOneWidget);
  });
}
