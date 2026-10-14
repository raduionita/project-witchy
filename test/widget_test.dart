import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/main.dart';
import 'package:witchy/providers/alert_provider.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/reminders_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/services/prefs_service.dart';

Future<App> _buildApp({Map<String, Object> initial = const {}}) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = PrefsService();
  final onboarding = await OnboardingProvider.load(prefs);
  final logging = await LoggingProvider.load(prefs);
  return App(
    prefs: prefs,
    auth: await AuthProvider.load(prefs),
    onboarding: onboarding,
    logging: logging,
    settings: await SettingsProvider.load(prefs),
    reminders: await RemindersProvider.load(prefs),
    cycle: CycleProvider(onboarding, logging),
    alerts: await AlertProvider.load(prefs),
    gestation: await GestationProvider.load(prefs),
  );
}

void main() {
  testWidgets('Welcome renders brand and CTA without Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    expect(find.text('Witchy'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Track your cycle and health'), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('Awaken opens the privacy gate; Accept needs all three consents', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('A Note on Privacy'), findsOneWidget);

    // Accept is inert until every box is checked.
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('A Note on Privacy'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    // Auth stays hidden: the gate hands over straight to onboarding.
    expect(find.text('Set Your Cycle'), findsOneWidget);
  });

  testWidgets('Refuse returns to the welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refuse'));
    await tester.pumpAndSettle();
    expect(find.text('Witchy'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Saved consent skips the gate straight to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp(initial: {'witchy_privacy_accepted': true}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Set Your Cycle'), findsOneWidget);
  });

  testWidgets('Onboarding ready with default birth year', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp(initial: {'witchy_privacy_accepted': true}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Set Your Cycle'), findsOneWidget);

    // Default birth year (now − 25) is preselected, so the CTA is active immediately.
    expect(find.text('${DateTime.now().year - 25}'), findsWidgets);

    await tester.tap(find.text('Get Started').last);
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsNWidgets(2));
    // Finishing onboarding marks the device as logged in (local session).
    final stored = await SharedPreferences.getInstance();
    expect(stored.getString('witchy_session'), isNotNull);
  });

  testWidgets('Tracking modes are multi-toggle and show together in Profile', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp(initial: {'witchy_privacy_accepted': true}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started').first);
    await tester.pumpAndSettle();
    expect(find.text('What shall we track?'), findsOneWidget);

    // Pregnancy joins the default Cycle mode instead of replacing it.
    await tester.tap(find.text('Pregnancy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started').last);
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsNWidgets(2));
    // Cycle stays active, so the fertility predictions remain visible.
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Tracking Modes'), findsOneWidget);
    expect(find.text('Cycle, Pregnancy'), findsOneWidget);
    // Pregnancy in the set exposes the pregnancy tracker entry point.
    expect(find.text('Pregnancy Tracker'), findsOneWidget);

    final stored = await SharedPreferences.getInstance();
    final modes = (jsonDecode(stored.getString('witchy_tracking_modes')!) as List<dynamic>).toSet();
    expect(modes, {'cycle', 'pregnancy'});
    // LMP is decoupled: onboarding never auto-seeds the pregnancy tracker.
    expect(stored.getString('witchy_pregnancy_lmp'), isNull);
  });

  testWidgets('Cycle mode keeps fertility visible and hides Pregnancy Tracker', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp(initial: {'witchy_privacy_accepted': true}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started').last);
    await tester.pumpAndSettle();
    // Default Cycle mode shows the fertility stat card (labels render uppercase).
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Pregnancy Tracker'), findsNothing);
  });

  testWidgets('Sign Out clears the session and shows identity first', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'witchy_onboarded': true,
      'witchy_privacy_accepted': true,
      'witchy_session': jsonEncode({'method': 'email', 'email': 'selene@moon.co', 'name': 'Selene Moon'}),
    });
    final prefs = PrefsService();
    final onboarding = await OnboardingProvider.load(prefs);
    final logging = await LoggingProvider.load(prefs);
    await tester.pumpWidget(
      App(
        prefs: prefs,
        auth: await AuthProvider.load(prefs),
        onboarding: onboarding,
        logging: logging,
        settings: await SettingsProvider.load(prefs),
        reminders: await RemindersProvider.load(prefs),
        cycle: CycleProvider(onboarding, logging),
        alerts: await AlertProvider.load(prefs),
        gestation: await GestationProvider.load(prefs),
      ),
    );
    await tester.pumpAndSettle();
    // Onboarded startup redirects welcome -> dashboard shell.
    expect(find.text('Today'), findsNWidgets(2));

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Selene Moon'), findsOneWidget);
    expect(find.text('selene@moon.co'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    // Confirm dialog spells out the consequences before signing out.
    expect(find.text('Sign out?'), findsOneWidget);
    await tester.tap(find.text('Sign Out').last);
    await tester.pumpAndSettle();

    final stored = await SharedPreferences.getInstance();
    expect(stored.getString('witchy_session'), isNull);
    // Logged out: welcome stays put instead of redirecting to the dashboard.
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('Delete All Data wipes app prefs and lands on welcome', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'witchy_onboarded': true,
      'witchy_privacy_accepted': true,
      'witchy_session': jsonEncode({'method': 'local'}),
      'witchy_dark_mode': true,
      'other_app_key': 'keep me',
    });
    final prefs = PrefsService();
    final onboarding = await OnboardingProvider.load(prefs);
    final logging = await LoggingProvider.load(prefs);
    await tester.pumpWidget(
      App(
        prefs: prefs,
        auth: await AuthProvider.load(prefs),
        onboarding: onboarding,
        logging: logging,
        settings: await SettingsProvider.load(prefs),
        reminders: await RemindersProvider.load(prefs),
        cycle: CycleProvider(onboarding, logging),
        alerts: await AlertProvider.load(prefs),
        gestation: await GestationProvider.load(prefs),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsNWidgets(2));

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete All Data'));
    await tester.pumpAndSettle();
    expect(find.text('Delete all data?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Wiped: welcome stays put (not signed in, not onboarded).
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Today'), findsNothing);

    final stored = await SharedPreferences.getInstance();
    expect(stored.getKeys().where((k) => k.startsWith('witchy_')), isEmpty);
    expect(stored.getString('other_app_key'), 'keep me');
  });
}
