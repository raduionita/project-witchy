import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/insights/insights_screen.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/symptom_provider.dart';
import 'package:witchy/services/storage_service.dart';

void main() {
  Future<SymptomProvider> pumpInsights(
    WidgetTester tester, {
    bool withLogs = true,
  }) async {
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

    if (withLogs) {
      await symptom.logSymptoms(DateTime(2026, 1, 1), symptoms: <String>['Cramps']);
      await symptom.logSymptoms(DateTime(2026, 1, 3), symptoms: <String>['Cramps']);
      await symptom.logSymptoms(DateTime(2026, 1, 5), symptoms: <String>['Cramps']);
      await symptom.logSymptoms(
        DateTime(2026, 1, 7),
        symptoms: <String>['Cramps', 'Bloating'],
      );
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SymptomProvider>.value(value: symptom),
        ],
        child: const MaterialApp(
          home: Scaffold(body: InsightsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return symptom;
  }

  testWidgets('shows the empty start state when nothing is logged',
      (WidgetTester tester) async {
    await pumpInsights(tester, withLogs: false);

    expect(
      find.text('Log symptoms from the calendar to unlock personalized '
          'insights.'),
      findsOneWidget,
    );
    expect(find.text('Top symptoms'), findsOneWidget);
  });

  testWidgets('shows the top-symptom section and lets you change the selected '
      'symptom via the dropdown', (WidgetTester tester) async {
    await pumpInsights(tester);

    // Cramps is the most frequent symptom and is selected by default.
    expect(find.text('When does "Cramps" happen?'), findsOneWidget);

    final Finder dropdown = find.byType(DropdownButton<String>);
    await tester.scrollUntilVisible(dropdown, 200);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bloating').last);
    await tester.pumpAndSettle();

    expect(find.text('When does "Bloating" happen?'), findsOneWidget);
  });
}