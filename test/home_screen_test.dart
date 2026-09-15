import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app.dart';
import 'package:witchy/features/onboarding/onboarding_screen.dart';
import 'package:witchy/screens/main_shell.dart';

Map<String, Object> _prefs({bool onboarded = true}) {
  return <String, Object>{
    'witchy.profile': jsonEncode(<String, Object>{
      'id': 'p1',
      'averageCycleLength': 28,
      'averagePeriodLength': 5,
      'lutealPhaseLength': 14,
      'firstPeriodDate': DateTime(2026, 6, 1).toIso8601String(),
      'onboarded': onboarded,
    }),
  };
}

Future<void> _launch(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final AppBootstrap bootstrap = AppBootstrap();
  await bootstrap.initialize();
  await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an onboarded cycle-mode user sees today\'s prediction cards',
      (WidgetTester tester) async {
    await _launch(tester, _prefs());

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('${DateTime.now().day}'), findsWidgets);
    expect(find.text(DateFormat('MMMM').format(DateTime.now())), findsWidgets);
    expect(find.text(DateFormat('EEEE').format(DateTime.now())), findsWidgets);
    expect(find.text('Today'), findsNWidgets(2));
    expect(find.text('Period in'), findsOneWidget);
    expect(find.text('Cycle Day'), findsOneWidget);
    expect(find.text('Fertile window'), findsOneWidget);
    expect(find.text('Set up your cycle'), findsNothing);
  });

  testWidgets('a not-onboarded user gets the setup card and tapping it opens '
      'onboarding', (WidgetTester tester) async {
    await _launch(tester, _prefs(onboarded: false));

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('Set up your cycle'), findsOneWidget);
    expect(find.text('Today'), findsNWidgets(2));

    await tester.tap(find.text('Set up your cycle'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}