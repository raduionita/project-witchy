import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/period_range.dart';
import 'package:witchy/widgets/period_range_calendar.dart';

void main() {
  final today = DateTime(2026, 10, 31);

  Future<void> pumpCalendar(
    WidgetTester tester, {
    List<PeriodRange> existing = const [],
    PeriodRange? initial,
    DateTime? initialStart,
    DateTime? todayOverride,
    ValueChanged<PeriodRange?>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PeriodRangeCalendar(
              existing: existing,
              initial: initial,
              initialStart: initialStart,
              today: todayOverride ?? today,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Key dayKey(int year, int month, int day) => Key('period-day-$year-$month-$day');

  String summary(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('period-range-summary'))).data!;

  testWidgets('starts on the current month and waits for a first day', (tester) async {
    await pumpCalendar(tester);
    expect(find.text('October 2026'), findsOneWidget);
    expect(summary(tester), 'Tap a day to choose the first day.');
  });

  testWidgets('picks the first day, then the last day', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(find.byKey(dayKey(2026, 10, 10)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'October 10, 2026 - now tap the last day.');

    await tester.tap(find.byKey(dayKey(2026, 10, 14)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'October 10, 2026 - October 14, 2026 · 5 days');
  });

  testWidgets('reports the picked range through onChanged', (tester) async {
    PeriodRange? picked;
    await pumpCalendar(tester, onChanged: (value) => picked = value);
    await tester.tap(find.byKey(dayKey(2026, 10, 10)));
    await tester.pumpAndSettle();
    expect(picked, isNull);

    await tester.tap(find.byKey(dayKey(2026, 10, 14)));
    await tester.pumpAndSettle();
    expect(picked, PeriodRange(start: DateTime(2026, 10, 10), end: DateTime(2026, 10, 14)));
  });

  testWidgets('a range can span into the next month', (tester) async {
    await pumpCalendar(tester, todayOverride: DateTime(2026, 11, 30));
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(2026, 10, 29)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('period-next-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(2026, 11, 3)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'October 29, 2026 - November 3, 2026 · 6 days');
  });

  testWidgets('tapping an earlier day restarts the selection', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(find.byKey(dayKey(2026, 10, 10)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(2026, 10, 5)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'October 5, 2026 - now tap the last day.');
  });

  testWidgets('a day within fifteen days of an existing start cannot be picked', (tester) async {
    await pumpCalendar(
      tester,
      existing: [PeriodRange(start: DateTime(2026, 10, 5), end: DateTime(2026, 10, 9))],
    );
    await tester.tap(find.byKey(dayKey(2026, 10, 12)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'Tap a day to choose the first day.');

    // Fifteen days after the existing start is allowed.
    await tester.tap(find.byKey(dayKey(2026, 10, 20)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'October 20, 2026 - now tap the last day.');
  });

  testWidgets('a future day cannot be picked', (tester) async {
    await pumpCalendar(tester);
    // November 1 is a spill cell of the October grid.
    await tester.tap(find.byKey(dayKey(2026, 11, 1)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'Tap a day to choose the first day.');
  });

  testWidgets('an edited range is shown when the calendar opens', (tester) async {
    await pumpCalendar(
      tester,
      initial: PeriodRange(start: DateTime(2026, 10, 29), end: DateTime(2026, 11, 3)),
    );
    expect(summary(tester), 'October 29, 2026 - November 3, 2026 · 6 days');
  });

  testWidgets('the edited range does not block its own days', (tester) async {
    await pumpCalendar(
      tester,
      existing: [PeriodRange(start: DateTime(2026, 10, 29), end: DateTime(2026, 11, 3))],
      initial: PeriodRange(start: DateTime(2026, 10, 29), end: DateTime(2026, 11, 3)),
    );
    await tester.tap(find.byKey(dayKey(2026, 10, 30)));
    await tester.pumpAndSettle();
    expect(summary(tester), 'October 30, 2026 - now tap the last day.');
  });

  testWidgets('the month header moves the grid', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('period-next-month')));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
  });
}
