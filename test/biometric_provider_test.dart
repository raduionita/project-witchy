import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/models/bbt_reading.dart';
import 'package:witchy/models/biometric_log.dart';
import 'package:witchy/models/calendar_day.dart';
import 'package:witchy/models/cervical_mucus_type.dart';
import 'package:witchy/models/intercourse_log.dart';
import 'package:witchy/models/ovulation_test_result.dart';
import 'package:witchy/models/pregnancy_test_result.dart';
import 'package:witchy/models/time_of_day_model.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/biometric_provider.dart';
import 'package:witchy/services/storage_service.dart';

Future<BiometricProvider> freshProvider() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppStateProvider state = AppStateProvider(StorageService(prefs))..load();
  return BiometricProvider(state);
}

void main() {
  group('BiometricLog serialization', () {
    test('round-trips nested BBT and intercourse records', () {
      final DateTime day = DateTime(2026, 3, 5);
      final BiometricLog original = BiometricLog(
        id: 'b1',
        date: day,
        bbt: BbtReading(
          id: 'br1',
          date: day,
          tempC: 36.45,
          takenAt: const TimeOfDayModel(hour: 7, minute: 5),
        ),
        mucus: CervicalMucusType.eggwhite,
        ovulationTest: OvulationTestResult.peak,
        pregnancyTest: PregnancyTestResult.positive,
        intercourse: IntercourseLog(id: 'i1', date: day),
      );

      final BiometricLog restored =
          BiometricLog.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.bbt!.tempC, 36.45);
      expect(restored.bbt!.takenAt, const TimeOfDayModel(hour: 7, minute: 5));
      expect(restored.mucus, CervicalMucusType.eggwhite);
      expect(restored.ovulationTest, OvulationTestResult.peak);
      expect(restored.pregnancyTest, PregnancyTestResult.positive);
      expect(restored.intercourse!.id, 'i1');
    });

    test('round-trips an entry with only a mucus value', () {
      final BiometricLog original = BiometricLog(
        id: 'b2',
        date: DateTime(2026, 3, 6),
        mucus: CervicalMucusType.watery,
      );

      final BiometricLog restored =
          BiometricLog.fromJson(original.toJson());
      expect(restored.mucus, CervicalMucusType.watery);
      expect(restored.bbt, isNull);
      expect(restored.intercourse, isNull);
    });
  });

  group('BiometricProvider', () {
    test('saveLog persists a day entry', () async {
      final BiometricProvider provider = await freshProvider();
      final DateTime day = DateTime(2026, 3, 5);

      await provider.saveLog(
        BiometricLog(
          id: 'b1',
          date: day,
          bbt: BbtReading(id: 'br1', date: day, tempC: 36.4),
          mucus: CervicalMucusType.creamy,
        ),
      );

      expect(provider.logs, hasLength(1));
      expect(provider.bbtOn(day), 36.4);
      expect(provider.logFor(day)!.mucus, CervicalMucusType.creamy);
    });

    test('saveLog upserts by date, preserving the day id', () async {
      final BiometricProvider provider = await freshProvider();
      final DateTime day = DateTime(2026, 3, 5);

      await provider.saveLog(
        BiometricLog(id: 'b1', date: day, mucus: CervicalMucusType.dry),
      );
      await provider.saveLog(
        BiometricLog(
          id: 'b2',
          date: day,
          mucus: CervicalMucusType.watery,
          ovulationTest: OvulationTestResult.high,
        ),
      );

      expect(provider.logs, hasLength(1));
      final BiometricLog log = provider.logFor(day)!;
      expect(log.id, 'b1');
      expect(log.mucus, CervicalMucusType.watery);
      expect(log.ovulationTest, OvulationTestResult.high);
    });

    test('removeBiometrics clears the whole day', () async {
      final BiometricProvider provider = await freshProvider();
      final DateTime day = DateTime(2026, 3, 5);

      await provider.saveLog(
        BiometricLog(
          id: 'b1',
          date: day,
          bbt: BbtReading(id: 'br1', date: day, tempC: 36.5),
        ),
      );
      await provider.removeBiometrics(day);

      expect(provider.logs, isEmpty);
      expect(provider.logFor(day), isNull);
    });

    test('markersFor reports bbt, lh peak and intimacy markers', () async {
      final BiometricProvider provider = await freshProvider();
      final DateTime day = DateTime(2026, 3, 5);

      await provider.saveLog(
        BiometricLog(
          id: 'b1',
          date: day,
          bbt: BbtReading(id: 'br1', date: day, tempC: 36.6),
          ovulationTest: OvulationTestResult.peak,
          intercourse: IntercourseLog(id: 'i1', date: day),
        ),
      );

      expect(provider.markersFor(day), containsAll(<CalendarDayMarker>[
        CalendarDayMarker.bbt,
        CalendarDayMarker.lhPeak,
        CalendarDayMarker.intimacy,
      ]));
      expect(provider.ovulationTestOn(day), OvulationTestResult.peak);
    });

    test('markersFor is empty for days without a log', () async {
      final BiometricProvider provider = await freshProvider();
      expect(
        provider.markersFor(DateTime(2026, 3, 5)),
        isEmpty,
      );
    });
  });
}
