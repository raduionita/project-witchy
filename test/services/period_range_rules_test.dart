import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/period_range.dart';
import 'package:witchy/services/period_range_rules.dart';

void main() {
  final today = DateTime(2026, 10, 21);

  PeriodRange range(int startDay, int endDay) => PeriodRange(
        start: DateTime(2026, 9, startDay),
        end: DateTime(2026, 9, endDay),
      );

  group('validate', () {
    test('accepts a valid range', () {
      expect(
        PeriodRangeRules.validate(range: range(3, 7), existing: [], today: today),
        isNull,
      );
    });

    test('rejects a last day before the first day', () {
      expect(
        PeriodRangeRules.validate(range: range(7, 3), existing: [], today: today),
        'The last day cannot be before the first day.',
      );
    });

    test('rejects a period shorter than two days', () {
      expect(
        PeriodRangeRules.validate(range: range(3, 3), existing: [], today: today),
        'A period must be at least 2 days long.',
      );
    });

    test('rejects a period longer than ten days', () {
      expect(
        PeriodRangeRules.validate(range: range(3, 13), existing: [], today: today),
        'A period can be at most 10 days long.',
      );
    });

    test('rejects days in the future', () {
      expect(
        PeriodRangeRules.validate(
          range: PeriodRange(start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 3)),
          existing: [],
          today: today,
        ),
        'Periods cannot be in the future.',
      );
    });

    test('rejects days older than two years', () {
      expect(
        PeriodRangeRules.validate(
          range: PeriodRange(start: DateTime(2024, 1, 10), end: DateTime(2024, 1, 14)),
          existing: [],
          today: today,
        ),
        'Only the last two years can be edited.',
      );
    });

    test('rejects an overlapping range', () {
      expect(
        PeriodRangeRules.validate(
          range: range(5, 9),
          existing: [range(3, 7)],
          today: today,
        ),
        'That range overlaps a period you already added.',
      );
    });

    test('rejects a start within fifteen days of an existing start', () {
      expect(
        PeriodRangeRules.validate(
          range: range(10, 14),
          existing: [range(3, 7)],
          today: today,
        ),
        'Keep at least 15 days between period starts.',
      );
    });

    test('accepts a start exactly fifteen days after an existing start', () {
      expect(
        PeriodRangeRules.validate(
          range: range(18, 22),
          existing: [range(3, 7)],
          today: today,
        ),
        isNull,
      );
    });

    test('rejects more than seven periods', () {
      final existing = <PeriodRange>[
        for (var i = 0; i < 7; i++)
          PeriodRange(
            start: DateTime(2026, 1, 1 + i * 15),
            end: DateTime(2026, 1, 5 + i * 15),
          ),
      ];
      expect(
        PeriodRangeRules.validate(
          range: PeriodRange(start: DateTime(2026, 4, 16), end: DateTime(2026, 4, 20)),
          existing: existing,
          today: today,
        ),
        'You can add up to 7 periods.',
      );
    });

    test('ignores the range that is being edited', () {
      final existing = [range(3, 7)];
      expect(
        PeriodRangeRules.validate(
          range: range(3, 8),
          existing: existing,
          editing: range(3, 7),
          today: today,
        ),
        isNull,
      );
    });
  });

  group('canStartOn', () {
    test('allows a free day in the past', () {
      expect(PeriodRangeRules.canStartOn(DateTime(2026, 9, 3), today: today), isTrue);
    });

    test('blocks a future day', () {
      expect(PeriodRangeRules.canStartOn(DateTime(2026, 10, 22), today: today), isFalse);
    });

    test('blocks a day older than two years', () {
      expect(PeriodRangeRules.canStartOn(DateTime(2024, 1, 10), today: today), isFalse);
    });

    test('blocks a day within fourteen days of an existing start', () {
      final existing = [range(3, 7)];
      // Thirteen and fourteen days after the existing start are too close.
      expect(PeriodRangeRules.canStartOn(DateTime(2026, 9, 16), existing: existing, today: today), isFalse);
      expect(PeriodRangeRules.canStartOn(DateTime(2026, 9, 17), existing: existing, today: today), isFalse);
      // Exactly fifteen days later is allowed.
      expect(PeriodRangeRules.canStartOn(DateTime(2026, 9, 18), existing: existing, today: today), isTrue);
    });

    test('blocks a day inside an existing range', () {
      final existing = [range(3, 7)];
      expect(PeriodRangeRules.canStartOn(DateTime(2026, 9, 5), existing: existing, today: today), isFalse);
    });

    test('ignores the range that is being edited', () {
      final existing = [range(3, 7)];
      expect(
        PeriodRangeRules.canStartOn(DateTime(2026, 9, 5), existing: existing, editing: range(3, 7), today: today),
        isTrue,
      );
    });
  });

  group('canEndOn', () {
    test('allows the day after the start', () {
      expect(
        PeriodRangeRules.canEndOn(DateTime(2026, 9, 4), start: DateTime(2026, 9, 3), today: today),
        isTrue,
      );
    });

    test('blocks the start day itself, which is too short', () {
      expect(
        PeriodRangeRules.canEndOn(DateTime(2026, 9, 3), start: DateTime(2026, 9, 3), today: today),
        isFalse,
      );
    });

    test('blocks a day further than ten days after the start', () {
      expect(
        PeriodRangeRules.canEndOn(DateTime(2026, 9, 14), start: DateTime(2026, 9, 3), today: today),
        isFalse,
      );
    });

    test('blocks a future day', () {
      expect(
        PeriodRangeRules.canEndOn(DateTime(2026, 10, 22), start: DateTime(2026, 10, 20), today: today),
        isFalse,
      );
    });

    test('blocks a day that overlaps another period', () {
      expect(
        PeriodRangeRules.canEndOn(
          DateTime(2026, 9, 5),
          start: DateTime(2026, 9, 4),
          existing: [range(3, 7)],
          today: today,
        ),
        isFalse,
      );
    });

    test('delegates an earlier day to the start rules so a tap can restart', () {
      // The day before the start is a valid start day, so it may be picked.
      expect(
        PeriodRangeRules.canEndOn(DateTime(2026, 9, 2), start: DateTime(2026, 9, 3), today: today),
        isTrue,
      );
      // A day in the future is never a valid restart either.
      expect(
        PeriodRangeRules.canEndOn(DateTime(2026, 10, 22), start: DateTime(2026, 9, 3), today: today),
        isFalse,
      );
    });
  });
}
