import 'package:flutter/foundation.dart';

import '../models/biometric_log.dart';
import '../models/calendar_day.dart';
import '../models/ovulation_test_result.dart';
import '../utils/date_utils.dart';
import 'app_state_provider.dart';

/// Reactive facade over per-day biometric & fertility logs.
///
/// Reads from `BiometricRepository.biometricLogs`, exposes mutations that
/// persist through the repository (one entry per day), and notifies listeners
/// on every change so the calendar/day strip can render data markers.
class BiometricProvider extends ChangeNotifier {
  BiometricProvider(this._state);

  final AppStateProvider _state;

  /// All biometric days, newest first.
  List<BiometricLog> get logs {
    final List<BiometricLog> all =
        List<BiometricLog>.from(_state.biometric.biometricLogs.items)
          ..sort((BiometricLog a, BiometricLog b) => b.date.compareTo(a.date));
    return all;
  }

  /// The biometric log for [date], or null when none exists.
  BiometricLog? logFor(DateTime date) {
    final DateTime day = dateOnly(date);
    for (final BiometricLog log in _state.biometric.biometricLogs.items) {
      if (dateOnly(log.date) == day) return log;
    }
    return null;
  }

  /// Basal body temperature (°C) logged for [date], if any.
  double? bbtOn(DateTime date) => logFor(date)?.bbt?.tempC;

  /// LH (ovulation) test result logged for [date], if any.
  OvulationTestResult? ovulationTestOn(DateTime date) =>
      logFor(date)?.ovulationTest;

  /// Small data markers for [date], in stable order for calendar cells.
  List<CalendarDayMarker> markersFor(DateTime date) {
    final BiometricLog? log = logFor(date);
    if (log == null) return const <CalendarDayMarker>[];
    final List<CalendarDayMarker> markers = <CalendarDayMarker>[];
    if (log.bbt != null) markers.add(CalendarDayMarker.bbt);
    if (log.ovulationTest == OvulationTestResult.peak) {
      markers.add(CalendarDayMarker.lhPeak);
    }
    if (log.intercourse != null) markers.add(CalendarDayMarker.intimacy);
    return markers;
  }

  /// Persists [log] for its date, merging into any existing day entry so the
  /// stable day id survives edits.
  Future<void> saveLog(BiometricLog log) async {
    final DateTime day = dateOnly(log.date);
    final BiometricLog? existing = logFor(day);
    final BiometricLog next = BiometricLog(
      id: existing?.id ?? log.id,
      date: day,
      bbt: log.bbt,
      mucus: log.mucus,
      ovulationTest: log.ovulationTest,
      pregnancyTest: log.pregnancyTest,
      intercourse: log.intercourse,
    );
    if (existing == null) {
      await _state.biometric.biometricLogs.add(next);
    } else {
      await _state.biometric.biometricLogs.update(next);
    }
    notifyListeners();
  }

  /// Clears every biometric field for [date], removing the entry entirely.
  Future<void> removeBiometrics(DateTime date) async {
    final BiometricLog? existing = logFor(date);
    if (existing == null) return;
    await _state.biometric.biometricLogs.remove(existing);
    notifyListeners();
  }
}
