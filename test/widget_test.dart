import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/main.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
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
  );
}

void main() {
  testWidgets('Welcome renders brand and CTA without Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    expect(find.text('Witchy'), findsOneWidget);
    expect(find.text('Awaken Your Power'), findsOneWidget);
    expect(find.text('Track your cycle with magic'), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('Awaken opens the privacy gate; Accept needs all three consents', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Awaken Your Power'));
    await tester.pumpAndSettle();
    expect(find.text('Your Privacy Promise'), findsOneWidget);

    // Accept is inert until every box is checked.
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Your Privacy Promise'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Join Witchy'), findsOneWidget);
  });

  testWidgets('Refuse returns to the welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Awaken Your Power'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refuse'));
    await tester.pumpAndSettle();
    expect(find.text('Witchy'), findsOneWidget);
    expect(find.text('Awaken Your Power'), findsOneWidget);
  });

  testWidgets('Saved consent skips the gate straight to join', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp(initial: {'witchy_privacy_accepted': true}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Awaken Your Power'));
    await tester.pumpAndSettle();
    expect(find.text('Join Witchy'), findsOneWidget);
  });

  testWidgets('Join skip enters onboarding; journey needs a birth year', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp(initial: {'witchy_privacy_accepted': true}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Awaken Your Power'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Set Your Rhythms'), findsOneWidget);

    // CTA stays inert until a year of birth is chosen.
    await tester.tap(find.text('Begin the Journey'));
    await tester.pumpAndSettle();
    expect(find.text('Set Your Rhythms'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin the Journey'));
    await tester.pumpAndSettle();
    expect(find.text('Sanctuary'), findsOneWidget);
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
      ),
    );
    await tester.pumpAndSettle();
    // Onboarded startup redirects welcome -> dashboard shell.
    expect(find.text('Sanctuary'), findsOneWidget);

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Witch Profile'), findsOneWidget);
    expect(find.text('Selene Moon'), findsOneWidget);
    expect(find.text('selene@moon.co'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    final stored = await SharedPreferences.getInstance();
    expect(stored.getString('witchy_session'), isNull);
    // reset('/') passes through welcome, which redirects to the dashboard while onboarded.
    expect(find.text('Sanctuary'), findsOneWidget);
  });
}
