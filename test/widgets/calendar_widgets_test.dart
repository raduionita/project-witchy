import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/main.dart';
import 'package:witchy/models/calendar_day_cell.dart';
import 'package:witchy/models/month_cells.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/reminders_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/services/prefs_service.dart';
import 'package:witchy/theme/app_colors.dart';
import 'package:witchy/widgets/calendar_legend.dart';
import 'package:witchy/widgets/cycle_calendar.dart';
import 'package:witchy/widgets/month_picker_sheet.dart';

MonthCells _september() {
  // Sep 1 2026 is a Tuesday → one leading adjacent cell (Mon Aug 31).
  final cells = <CalendarDayCell>[
    const CalendarDayCell(day: 31, inMonth: false),
    for (var d = 1; d <= 30; d++) CalendarDayCell(day: d, cycleDay: 99),
    for (var d = 1; d <= 11; d++) CalendarDayCell(day: d, inMonth: false),
  ];
  return MonthCells(month: DateTime(2026, 9, 1), cells: cells);
}

void main() {
  group('CycleCalendar', () {
    testWidgets('tapping an in-month day reports the day number', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CycleCalendar(cells: _september(), onDayTap: (d) => tapped = d)))),
      );
      await tester.tap(find.text('15'));
      expect(tapped, 15);
      expect(find.text('99'), findsNWidgets(30));
    });

    testWidgets('adjacent days render muted, label outside the month, and never fire onDayTap', (tester) async {
      final semantics = tester.ensureSemantics();
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CycleCalendar(cells: _september(), onDayTap: (d) => tapped = d)))),
      );
      final adjacent = tester.widget<Text>(find.text('31'));
      expect(adjacent.style?.color, AppColors.placeholder);
      expect(find.bySemanticsLabel(RegExp('outside this month')), findsWidgets);
      await tester.tap(find.text('31'));
      expect(tapped, isNull);
      semantics.dispose();
    });
  });

  testWidgets('CalendarLegend lists every marker type', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CalendarLegend())));
    for (final label in ['period', 'predicted', 'fertile', 'ovulation', 'logged']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  group('showMonthPicker', () {
    testWidgets('returns the tapped month for the displayed year', (tester) async {
      DateTime? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async => result = await showMonthPicker(context, DateTime(2026, 9)),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('2026'), findsOneWidget);

      await tester.tap(find.text('Dec'));
      await tester.pumpAndSettle();
      expect(result, DateTime(2026, 12, 1));
    });

    testWidgets('year chevrons step and clamp the range', (tester) async {
      DateTime? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async => result = await showMonthPicker(context, DateTime(2026, 9)),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('2027'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('2025'), findsOneWidget);

      await tester.tap(find.text('Sep'));
      await tester.pumpAndSettle();
      expect(result, DateTime(2025, 9, 1));
    });
  });

  testWidgets('calendar tab shows the legend and the label opens the picker', (tester) async {
    SharedPreferences.setMockInitialValues({'witchy_onboarded': true, 'witchy_privacy_accepted': true});
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

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('predicted'), findsOneWidget);

    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime(now.year, now.month, 1));
    expect(find.text(monthLabel), findsOneWidget);

    await tester.tap(find.text(monthLabel));
    await tester.pumpAndSettle();
    expect(find.text('${now.year}'), findsOneWidget);
    expect(find.text('Jan'), findsOneWidget);
  });
}
