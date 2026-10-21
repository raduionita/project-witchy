import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/common/date_format.dart';

void main() {
  test('formats every shared display pattern', () {
    final d = DateTime(2026, 9, 10, 14, 5);
    expect(AppDate.long(d), 'September 10, 2026');
    expect(AppDate.monthDay(d), 'September 10');
    expect(AppDate.short(d), 'Sep 10');
    expect(AppDate.shortYear(d), 'Sep 10, 2026');
    expect(AppDate.dayMonth(d), '10 Sep');
    expect(AppDate.dayMonthYear(d), '10 Sep 2026');
    expect(AppDate.monthYear(d), 'September 2026');
    expect(AppDate.monthShort(d), 'Sep');
    expect(AppDate.weekdayLong(d), 'Thursday, September 10');
    expect(AppDate.weekdayShort(d), 'Thursday, Sep 10');
  });

  test('keeps single-digit days unpadded', () {
    final d = DateTime(2026, 1, 5);
    expect(AppDate.long(d), 'January 5, 2026');
    expect(AppDate.dayMonth(d), '5 Jan');
    expect(AppDate.dayMonthYear(d), '5 Jan 2026');
  });

  test('joins a range with a hyphen', () {
    expect(AppDate.range(DateTime(2026, 9, 10), DateTime(2026, 9, 16)), 'Sep 10 - Sep 16');
  });

  test('joins a long range with a hyphen', () {
    expect(
      AppDate.longRange(DateTime(2026, 10, 29), DateTime(2026, 11, 3)),
      'October 29, 2026 - November 3, 2026',
    );
  });
}
