import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/calendar/cycle_calendar.dart';
import 'package:witchy/features/logging/log_period_sheet.dart';
import 'package:witchy/features/logging/log_symptom_sheet.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/storage_service.dart';

void main() {
  final DateTime now = DateTime.now();
  final DateTime target = DateTime(now.year, now.month, 15);

  String monthLabel(int delta) =>
      DateFormat('MMMM yyyy').format(DateTime(now.year, now.month + delta, 1));

  Future<CycleProvider> pumpCalendar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
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

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: Scaffold(body: CycleCalendar())),
      ),
    );
    await tester.pumpAndSettle();
    return cycle;
  }

  testWidgets('shows the current month and changes it with the arrows',
      (WidgetTester tester) async {
    await pumpCalendar(tester);

    expect(find.text(monthLabel(0)), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text(monthLabel(1)), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text(monthLabel(0)), findsOneWidget);
  });

  testWidgets('swiping changes the month', (WidgetTester tester) async {
    await pumpCalendar(tester);

    await tester.fling(find.byType(GridView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text(monthLabel(1)), findsOneWidget);

    await tester.fling(find.byType(GridView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text(monthLabel(0)), findsOneWidget);
  });

  testWidgets(
      'tapping a day opens the period sheet, saving logs it, and re-tapping '
      'removes it', (WidgetTester tester) async {
    final CycleProvider cycle = await pumpCalendar(tester);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(find.byType(LogPeriodSheet), findsOneWidget);

    await tester.tap(find.text('Save log'));
    await tester.pumpAndSettle();
    expect(find.byType(LogPeriodSheet), findsNothing);
    expect(cycle.isPeriodDay(target), isTrue);

    // Re-tap the day: it is already a period day, so it should be removed
    // rather than opening the sheet again.
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(find.byType(LogPeriodSheet), findsNothing);
    expect(cycle.isPeriodDay(target), isFalse);
  });

  testWidgets('long pressing a day opens the symptom sheet',
      (WidgetTester tester) async {
    await pumpCalendar(tester);

    await tester.longPress(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.byType(LogSymptomSheet), findsOneWidget);
  });
}