import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app.dart';
import 'package:witchy/features/onboarding/onboarding_screen.dart';
import 'package:witchy/screens/main_shell.dart';
import 'package:witchy/widgets/cycle_orb.dart';

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
    expect(find.byType(CycleOrb), findsOneWidget);
    expect(find.text('PERIOD IN'), findsOneWidget);
    expect(find.text('FERTILE WINDOW'), findsOneWidget);
    expect(find.text('Set up your cycle'), findsNothing);
  });

  testWidgets('a not-onboarded user gets the setup card and tapping it opens '
      'onboarding', (WidgetTester tester) async {
    await _launch(tester, _prefs(onboarded: false));

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('Set up your cycle'), findsOneWidget);

    await tester.tap(find.text('Set up your cycle'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}