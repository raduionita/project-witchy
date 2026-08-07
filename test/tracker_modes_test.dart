import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app.dart';
import 'package:witchy/features/perimenopause/perimenopause_screen.dart';
import 'package:witchy/features/pregnancy/pregnancy_screen.dart';
import 'package:witchy/models/tracking_mode.dart';

Map<String, Object> _prefs({
  TrackingMode mode = TrackingMode.cycle,
  String? pregnancyLmp,
}) {
  return <String, Object>{
    'witchy.profile': jsonEncode(<String, Object>{
      'id': 'p1',
      'averageCycleLength': 28,
      'averagePeriodLength': 5,
      'lutealPhaseLength': 14,
      'onboarded': true,
      'mode': mode.name,
      if (pregnancyLmp != null)
        'pregnancyLmp': DateTime.parse(pregnancyLmp).toIso8601String(),
    }),
  };
}

void main() {
  Future<void> launch(WidgetTester tester, Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();
    await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();
  }

  testWidgets('cycle mode home shows cycle predictions',
      (WidgetTester tester) async {
    await launch(tester, _prefs());
    expect(find.text('Welcome to Witchy'), findsOneWidget);
  });

  testWidgets('pregnancy mode home shows the pregnancy screen',
      (WidgetTester tester) async {
    await launch(
      tester,
      _prefs(mode: TrackingMode.pregnancy, pregnancyLmp: '2026-01-01'),
    );
    expect(find.byType(PregnancyScreen), findsOneWidget);
    expect(find.text('Pregnancy'), findsOneWidget);
  });

  testWidgets('perimenopause mode home shows the perimenopause screen',
      (WidgetTester tester) async {
    await launch(tester, _prefs(mode: TrackingMode.perimenopause));
    expect(find.byType(PerimenopauseScreen), findsOneWidget);
    expect(find.text('Perimenopause'), findsOneWidget);
    expect(find.textContaining('Hot flashes', findRichText: true),
        findsWidgets);
  });

  testWidgets('switching mode in settings persists and updates the home tab',
      (WidgetTester tester) async {
    await launch(tester, _prefs());

    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<TrackingMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pregnancy').last);
    await tester.pumpAndSettle();

    expect(find.text('Pregnancy is now active.'), findsOneWidget);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> stored =
        jsonDecode(prefs.getString('witchy.profile')!) as Map<String, dynamic>;
    expect(stored['mode'], TrackingMode.pregnancy.name);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PregnancyScreen), findsOneWidget);
  });
}
