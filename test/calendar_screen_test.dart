import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/calendar/cycle_calendar.dart';
import 'package:witchy/features/logging/log_period_sheet.dart';
import 'package:witchy/features/logging/log_symptom_sheet.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/models/bbt_reading.dart';
import 'package:witchy/models/biometric_log.dart';
import 'package:witchy/models/calendar_day.dart';
import 'package:witchy/models/intercourse_log.dart';
import 'package:witchy/models/ovulation_test_result.dart';
import 'package:witchy/models/time_of_day_model.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/biometric_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/calendar_fetcher.dart';
import 'package:witchy/services/storage_service.dart';

void main() {
  final DateTime now = DateTime.now();
  final DateTime target = DateTime(now.year, now.month, 15);

  String monthLabel(int delta) =>
      DateFormat('MMMM yyyy').format(DateTime(now.year, now.month + delta, 1));

  Future<(CycleProvider, BiometricProvider)> pumpCalendar(WidgetTester tester, {int firstDayOfWeek = DateTime.monday}) async {
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
      ).copyWith(firstDayOfWeek: firstDayOfWeek),
    );
    final CycleProvider cycle = CycleProvider(state)..recompute();
    final BiometricProvider biometrics = BiometricProvider(state);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<BiometricProvider>.value(value: biometrics),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CycleCalendar()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (cycle, biometrics);
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
    final (CycleProvider cycle, _) = await pumpCalendar(tester);

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

  testWidgets(
      'days with biometric logs render thermometer, peak and intimacy '
      'markers in the grid', (WidgetTester tester) async {
    final (_, BiometricProvider biometrics) = await pumpCalendar(tester);

    await biometrics.saveLog(
      BiometricLog(
        id: 'b1',
        date: target,
        bbt: BbtReading(
          id: 'br1',
          date: target,
          tempC: 36.45,
          takenAt: const TimeOfDayModel(hour: 7, minute: 5),
        ),
        ovulationTest: OvulationTestResult.peak,
        intercourse: IntercourseLog(id: 'i1', date: target),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.byIcon(Icons.thermostat),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.byIcon(Icons.auto_awesome),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.byIcon(Icons.favorite),
      ),
      findsOneWidget,
    );
  });

  testWidgets('weekday header aligns with the grid for a Monday start',
      (WidgetTester tester) async {
    await pumpCalendar(tester, firstDayOfWeek: DateTime.monday);
    final MaterialLocalizations l10n = MaterialLocalizations.of(tester.element(find.byType(CycleCalendar)));

    final CalendarFetcher fetcher = CalendarFetcher();
    final DateTime month = DateTime(now.year, now.month, 1);
    final List<CalendarDay> grid = fetcher.fetchMonth(
      month,
      prediction: null,
      loggedPeriodDays: <DateTime>{},
      profile: const UserProfile(id: 'p1'),
      today: now,
      firstDayOfWeek: DateTime.monday,
    );

    final List<String> headerLabels =
        tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const ValueKey<String>('calendar-weekday-row')),
                matching: find.byType(Text),
              ),
            )
            .map((Text t) => t.data ?? '')
            .toList();

    expect(headerLabels, hasLength(7));
    for (int i = 0; i < 7; i++) {
      expect(headerLabels[i], l10n.narrowWeekdays[grid[i].date.weekday % 7]);
    }
  });

  testWidgets('weekday header aligns with the grid for a Sunday start',
      (WidgetTester tester) async {
    await pumpCalendar(tester, firstDayOfWeek: DateTime.sunday);
    final MaterialLocalizations l10n = MaterialLocalizations.of(tester.element(find.byType(CycleCalendar)));

    final CalendarFetcher fetcher = CalendarFetcher();
    final DateTime month = DateTime(now.year, now.month, 1);
    final List<CalendarDay> grid = fetcher.fetchMonth(
      month,
      prediction: null,
      loggedPeriodDays: <DateTime>{},
      profile: const UserProfile(id: 'p1'),
      today: now,
      firstDayOfWeek: DateTime.sunday,
    );

    expect(grid.first.date.weekday, DateTime.sunday);

    final List<String> headerLabels =
        tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const ValueKey<String>('calendar-weekday-row')),
                matching: find.byType(Text),
              ),
            )
            .map((Text t) => t.data ?? '')
            .toList();

    expect(headerLabels, hasLength(7));
    for (int i = 0; i < 7; i++) {
      expect(headerLabels[i], l10n.narrowWeekdays[grid[i].date.weekday % 7]);
    }
  });
}