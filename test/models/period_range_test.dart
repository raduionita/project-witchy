import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/period_range.dart';

void main() {
  group('PeriodRange', () {
    test('normalizes both dates to midnight', () {
      final range = PeriodRange(
        start: DateTime(2026, 9, 3, 14, 30),
        end: DateTime(2026, 9, 7, 22, 15),
      );
      expect(range.start, DateTime(2026, 9, 3));
      expect(range.end, DateTime(2026, 9, 7));
    });

    test('counts the days inclusively', () {
      expect(
        PeriodRange(start: DateTime(2026, 9, 3), end: DateTime(2026, 9, 3)).length,
        1,
      );
      expect(
        PeriodRange(start: DateTime(2026, 9, 3), end: DateTime(2026, 9, 7)).length,
        5,
      );
      // A period that crosses a month boundary.
      expect(
        PeriodRange(start: DateTime(2026, 9, 29), end: DateTime(2026, 10, 3)).length,
        5,
      );
    });

    test('knows which days it covers', () {
      final range = PeriodRange(start: DateTime(2026, 9, 3), end: DateTime(2026, 9, 7));
      expect(range.contains(DateTime(2026, 9, 3)), isTrue);
      expect(range.contains(DateTime(2026, 9, 5)), isTrue);
      expect(range.contains(DateTime(2026, 9, 7)), isTrue);
      expect(range.contains(DateTime(2026, 9, 2)), isFalse);
      expect(range.contains(DateTime(2026, 9, 8)), isFalse);
    });

    test('detects overlapping ranges', () {
      final first = PeriodRange(start: DateTime(2026, 9, 3), end: DateTime(2026, 9, 7));
      expect(first.overlaps(PeriodRange(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 9))), isTrue);
      expect(first.overlaps(PeriodRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 4))), isTrue);
      // Touching the same day still overlaps.
      expect(first.overlaps(PeriodRange(start: DateTime(2026, 9, 7), end: DateTime(2026, 9, 9))), isTrue);
      // A gap of one day does not.
      expect(first.overlaps(PeriodRange(start: DateTime(2026, 9, 8), end: DateTime(2026, 9, 10))), isFalse);
    });

    test('copies with a new start or end', () {
      final range = PeriodRange(start: DateTime(2026, 9, 3), end: DateTime(2026, 9, 7));
      final moved = range.copyWith(start: DateTime(2026, 9, 4));
      expect(moved.start, DateTime(2026, 9, 4));
      expect(moved.end, DateTime(2026, 9, 7));
      final shortened = range.copyWith(end: DateTime(2026, 9, 5));
      expect(shortened.start, DateTime(2026, 9, 3));
      expect(shortened.end, DateTime(2026, 9, 5));
    });

    test('compares by dates', () {
      final a = PeriodRange(start: DateTime(2026, 9, 3), end: DateTime(2026, 9, 7));
      final b = PeriodRange(start: DateTime(2026, 9, 3, 9), end: DateTime(2026, 9, 7, 18));
      final c = PeriodRange(start: DateTime(2026, 9, 4), end: DateTime(2026, 9, 7));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('2026-09-03'));
    });
  });
}
