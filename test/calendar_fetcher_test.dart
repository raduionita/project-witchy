import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/calendar_day.dart';
import 'package:witchy/models/cycle_prediction.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/services/calendar_fetcher.dart';
import 'package:witchy/services/cycle_calculator.dart';

const UserProfile kProfile28 = UserProfile(
  id: 'p1',
  averageCycleLength: 28,
  averagePeriodLength: 5,
  lutealPhaseLength: 14,
);

void main() {
  late CalendarFetcher fetcher;

  setUp(() {
    fetcher = CalendarFetcher();
  });

  test('produces a fixed 42-cell grid', () {
    final grid = fetcher.fetchMonth(
      DateTime(2026, 2),
      prediction: null,
      loggedPeriodDays: <DateTime>{},
      profile: kProfile28,
      today: DateTime(2026, 2, 10),
    );
    expect(grid.length, 42);
  });

  test('grid starts on a Monday', () {
    final grid = fetcher.fetchMonth(
      DateTime(2026, 2),
      prediction: null,
      loggedPeriodDays: <DateTime>{},
      profile: kProfile28,
      today: DateTime(2026, 2, 10),
    );
    expect(grid.first.date.weekday, DateTime.monday);
  });

  test('marks days outside the month as none', () {
    final grid = fetcher.fetchMonth(
      DateTime(2026, 2),
      prediction: null,
      loggedPeriodDays: <DateTime>{},
      profile: kProfile28,
      today: DateTime(2026, 2, 10),
    );
    expect(grid.first.date.month, isNot(2));
    expect(grid.first.state, CalendarDayState.none);
  });

  test('marks logged period days as period', () {
    final grid = fetcher.fetchMonth(
      DateTime(2026, 2),
      prediction: null,
      loggedPeriodDays: {DateTime(2026, 2, 14)},
      profile: kProfile28,
      today: DateTime(2026, 2, 10),
    );
    final CalendarDay feb14 = grid.firstWhere((d) => d.date == DateTime(2026, 2, 14));
    expect(feb14.state, CalendarDayState.period);
  });

  test('marks ovulation and fertile days from the prediction', () {
    final CyclePrediction prediction = CycleCalculator().predict(
      profile: kProfile28,
      loggedPeriodDays: {DateTime(2026, 1, 1)},
      today: DateTime(2026, 1, 15),
    )!;

    final grid = fetcher.fetchMonth(
      DateTime(2026, 1),
      prediction: prediction,
      loggedPeriodDays: <DateTime>{},
      profile: kProfile28,
      today: DateTime(2026, 1, 15),
    );

    final CalendarDay ovulation = grid.firstWhere((d) => d.date == DateTime(2026, 1, 15));
    expect(ovulation.state, CalendarDayState.ovulation);

    final CalendarDay fertile = grid.firstWhere((d) => d.date == DateTime(2026, 1, 12));
    expect(fertile.state, CalendarDayState.fertile);
  });

  test('marks predicted period days', () {
    final CyclePrediction prediction = CycleCalculator().predict(
      profile: kProfile28,
      loggedPeriodDays: {DateTime(2026, 1, 1)},
      today: DateTime(2026, 1, 15),
    )!;

    final grid = fetcher.fetchMonth(
      DateTime(2026, 1),
      prediction: prediction,
      loggedPeriodDays: <DateTime>{},
      profile: kProfile28,
      today: DateTime(2026, 1, 15),
    );

    final CalendarDay predicted = grid.firstWhere((d) => d.date == DateTime(2026, 1, 29));
    expect(predicted.state, CalendarDayState.predictedPeriod);
  });

  test('marks today', () {
    final grid = fetcher.fetchMonth(
      DateTime(2026, 2),
      prediction: null,
      loggedPeriodDays: <DateTime>{},
      profile: kProfile28,
      today: DateTime(2026, 2, 10),
    );
    final CalendarDay today = grid.firstWhere((d) => d.date == DateTime(2026, 2, 10));
    expect(today.isToday, isTrue);
  });
}