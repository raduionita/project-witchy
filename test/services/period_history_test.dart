import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/day_log.dart';
import 'package:witchy/services/period_history.dart';

void main() {
  Map<DateTime, DayLog> logs(Iterable<DateTime> days, {String flow = 'Medium'}) =>
      {for (final d in days) d: DayLog(flow: {flow})};

  group('PeriodHistory.spans', () {
    test('groups consecutive bleed days and splits across gaps', () {
      final spans = PeriodHistory.spans(logs([
        DateTime(2026, 8, 16),
        DateTime(2026, 8, 17),
        DateTime(2026, 9, 14),
        DateTime(2026, 9, 15),
        DateTime(2026, 9, 16),
      ]));
      expect(spans, hasLength(2));
      expect(spans.first.start, DateTime(2026, 8, 16));
      expect(spans.first.end, DateTime(2026, 8, 17));
      expect(spans.first.length, 2);
      expect(spans.last.start, DateTime(2026, 9, 14));
      expect(spans.last.end, DateTime(2026, 9, 16));
      expect(spans.last.length, 3);
    });

    test('ignores empty-flow entries and missing logs', () {
      final spans = PeriodHistory.spans({
        DateTime(2026, 9, 14): DayLog(flow: {'Medium'}),
        DateTime(2026, 9, 15): DayLog(),
      });
      expect(spans, hasLength(1));
      expect(spans.single.length, 1);
      expect(PeriodHistory.spans(const {}), isEmpty);
    });

    test('bridges a single missing day inside a period', () {
      final spans = PeriodHistory.spans({
        DateTime(2026, 9, 1): DayLog(flow: {'Medium'}),
        DateTime(2026, 9, 2): DayLog(flow: {'Light'}),
        DateTime(2026, 9, 4): DayLog(flow: {'Light'}),
        DateTime(2026, 9, 5): DayLog(flow: {'Light'}),
      });
      expect(spans, hasLength(1));
      expect(spans.single.start, DateTime(2026, 9, 1));
      expect(spans.single.end, DateTime(2026, 9, 5));
      expect(spans.single.length, 5);
    });

    test('spotting-only spans stay out of periods', () {
      final spans = PeriodHistory.spans({
        DateTime(2026, 9, 1): DayLog(flow: {'Medium'}),
        DateTime(2026, 9, 2): DayLog(flow: {'Light'}),
        DateTime(2026, 9, 15): DayLog(flow: {'Spotting'}),
        DateTime(2026, 9, 16): DayLog(flow: {'Spotting'}),
      });
      expect(spans, hasLength(2));
      expect(spans.last.spottingOnly, isTrue);
      expect(PeriodHistory.periods(spans), hasLength(1));
      expect(PeriodHistory.spotting(spans).single.start, DateTime(2026, 9, 15));
    });
  });

  group('PeriodHistory stats', () {
    test('cycleLengths are diffs between consecutive starts', () {
      final starts = [DateTime(2026, 7, 1), DateTime(2026, 7, 29), DateTime(2026, 8, 27)];
      expect(PeriodHistory.cycleLengths(starts), [28, 29]);
    });

    test('cycleLengths rejects implausible gaps from split periods', () {
      final starts = [DateTime(2026, 9, 1), DateTime(2026, 9, 4), DateTime(2026, 10, 1)];
      expect(PeriodHistory.cycleLengths(starts), [27]);
    });

    test('median handles odd, even and empty lists', () {
      expect(PeriodHistory.median([28, 30, 29]), 29);
      expect(PeriodHistory.median([28, 30]), 29);
      expect(PeriodHistory.median([27]), 27);
      expect(PeriodHistory.median([]), isNull);
    });

    test('mean averages values and returns null when empty', () {
      expect(PeriodHistory.mean([28, 30]), 29.0);
      expect(PeriodHistory.mean([]), isNull);
    });
  });
}
