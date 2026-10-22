import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/day_log.dart';
import 'package:witchy/models/period_record.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/services/period_history.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  group('PeriodRecord', () {
    test('round-trips a start-only estimated record', () {
      final record = PeriodRecord(
        start: DateTime(2026, 9, 1),
        source: PeriodSource.onboarding,
        estimated: true,
      );
      final copy = PeriodRecord.fromJson(
        jsonDecode(jsonEncode(record.toJson())) as Map<String, dynamic>,
      );

      expect(copy.start, DateTime(2026, 9, 1));
      expect(copy.end, isNull);
      expect(copy.startOnly, isTrue);
      expect(copy.source, PeriodSource.onboarding);
      expect(copy.estimated, isTrue);
    });
  });

  group('PeriodHistory records', () {
    test('real flow overrides an overlapping record', () {
      final logs = {
        DateTime(2026, 10, 1): DayLog()..flow.add('Medium'),
        DateTime(2026, 10, 2): DayLog()..flow.add('Light'),
      };
      final spans = PeriodHistory.spansFrom(logs, [
        PeriodRecord(start: DateTime(2026, 9, 1)),
        PeriodRecord(
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 4),
          estimated: true,
        ),
      ]);

      expect(spans, hasLength(2));
      expect(spans.first.start, DateTime(2026, 9, 1));
      expect(spans.first.startOnly, isTrue);
      expect(spans.last.start, DateTime(2026, 10, 1));
      expect(spans.last.end, DateTime(2026, 10, 2));
      expect(spans.last.estimated, isFalse);
    });

    test('short or spotting days do not replace explicit period starts', () {
      final logs = {
        DateTime(2026, 9, 1): DayLog()..flow.add('Spotting'),
        DateTime(2026, 10, 1): DayLog()..flow.add('Light'),
      };
      final spans = PeriodHistory.spansFrom(logs, [
        PeriodRecord(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 5)),
        PeriodRecord(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 4)),
      ]);

      expect(spans, hasLength(2));
      expect(PeriodHistory.periods(spans), hasLength(2));
      expect(spans.first.end, DateTime(2026, 9, 5));
      expect(spans.last.end, DateTime(2026, 10, 4));
    });

    test('migrates assumed flow into an estimated record and clears it', () async {
      final first = DayLog()..flow.add('Medium');
      first.assumed = true;
      final second = DayLog()..flow.add('Medium');
      second.assumed = true;
      SharedPreferences.setMockInitialValues({
        'witchy_day_logs': jsonEncode({
          '2026-09-01': first.toJson(),
          '2026-09-02': second.toJson(),
        }),
        'witchy_last_period': DateTime(2026, 9, 1).toIso8601String(),
      });
      final logging = await LoggingProvider.load(PrefsService());

      expect(logging.periodRecords, hasLength(1));
      expect(logging.periodRecords.single.start, DateTime(2026, 9, 1));
      expect(logging.periodRecords.single.end, DateTime(2026, 9, 2));
      expect(logging.periodRecords.single.estimated, isTrue);
      expect(logging.peekDay(DateTime(2026, 9, 1)), isNull);
      expect(logging.peekDay(DateTime(2026, 9, 2)), isNull);
    });
  });
}
