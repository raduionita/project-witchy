import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app.dart';
import 'package:witchy/features/insights/insights_screen.dart';

void main() {
  Future<Map<String, Object>> onboardedPrefs() async {
    final Map<String, Object> prefs = <String, Object>{
      'witchy.profile': jsonEncode(<String, Object>{
        'id': 'p1',
        'averageCycleLength': 28,
        'averagePeriodLength': 5,
        'lutealPhaseLength': 14,
        'onboarded': true,
      }),
    };
    return prefs;
  }

  testWidgets('insights tab shows the empty start state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(await onboardedPrefs());
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();

    await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();

    // Switch to the Insights tab (index 3).
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(InsightsScreen), findsOneWidget);
    expect(
      find.textContaining('Log symptoms', findRichText: true),
      findsWidgets,
    );
  });

  testWidgets('insights tab opens cycle history and monthly report',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(await onboardedPrefs());
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();

    await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cycle history'));
    await tester.pumpAndSettle();
    expect(find.text('Cycle history'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Monthly report'));
    await tester.pumpAndSettle();
    expect(find.text('This month'), findsOneWidget);
  });
}