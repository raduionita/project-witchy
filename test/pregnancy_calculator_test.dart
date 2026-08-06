import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/pregnancy_status.dart';
import 'package:witchy/services/pregnancy_calculator.dart';
import 'package:witchy/utils/date_utils.dart';

void main() {
  late PregnancyCalculator calculator;

  setUp(() {
    calculator = PregnancyCalculator(now: () => DateTime(2026, 3, 1));
  });

  test('due date is 40 weeks (280 days) after LMP', () {
    final PregnancyStatus status = calculator.statusFor(DateTime(2026, 1, 1));
    expect(status.dueDate, DateTime(2026, 10, 8));
  });

  test('weeks and days are computed from LMP', () {
    // LMP Jan 1, now Mar 1 = 59 days = 8 weeks + 3 days.
    final PregnancyStatus status = calculator.statusFor(DateTime(2026, 1, 1));
    expect(status.weeks, 8);
    expect(status.days, 3);
    expect(status.totalDays, 59);
  });

  test('trimesterFor splits at 13 and 27 weeks', () {
    expect(calculator.trimesterFor(0), Trimester.first);
    expect(calculator.trimesterFor(12), Trimester.first);
    expect(calculator.trimesterFor(13), Trimester.second);
    expect(calculator.trimesterFor(26), Trimester.second);
    expect(calculator.trimesterFor(27), Trimester.third);
    expect(calculator.trimesterFor(40), Trimester.third);
  });

  test('statusFor uses an injected clock for determinism', () {
    final PregnancyStatus status =
        calculator.statusFor(DateTime(2026, 1, 1), today: DateTime(2026, 1, 29));
    expect(status.totalDays, 28);
    expect(status.weeks, 4);
    expect(status.trimester, Trimester.first);
  });

  test('progressPercent stays within 0-100', () {
    final PregnancyStatus early =
        calculator.statusFor(DateTime(2026, 1, 1), today: DateTime(2026, 1, 1));
    final PregnancyStatus late =
        calculator.statusFor(DateTime(2026, 1, 1), today: DateTime(2026, 10, 8));

    expect(calculator.progressPercent(early), moreOrLessEquals(0, epsilon: 0.01));
    expect(calculator.progressPercent(late), moreOrLessEquals(100, epsilon: 0.01));
  });

  test('isPastDue is true at or after the due date', () {
    final PregnancyStatus status = calculator.statusFor(DateTime(2026, 1, 1));
    expect(calculator.isPastDue(status, today: DateTime(2026, 10, 7)), isFalse);
    expect(calculator.isPastDue(status, today: DateTime(2026, 10, 8)), isTrue);
  });

  test('statusFor never exceeds 40 weeks', () {
    final PregnancyStatus status = calculator.statusFor(
      DateTime(2026, 1, 1),
      today: DateTime(2027, 1, 1),
    );
    expect(status.totalDays, PregnancyCalculator.kGestationDays);
    expect(status.weeks, PregnancyCalculator.kTotalWeeks);
  });

  test('dateOnly strips time components for status fields', () {
    final PregnancyStatus status = calculator.statusFor(
      DateTime(2026, 1, 1, 14, 30),
      today: DateTime(2026, 1, 29, 8, 0),
    );
    expect(status.lmp, dateOnly(DateTime(2026, 1, 1)));
    expect(status.dueDate, dateOnly(DateTime(2026, 10, 8)));
  });
}
