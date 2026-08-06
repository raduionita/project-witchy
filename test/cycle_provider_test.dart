import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/storage_service.dart';
import 'package:witchy/utils/date_utils.dart';

void main() {
  late AppStateProvider state;
  late CycleProvider cycleProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    state = AppStateProvider(storage);
    state.load();
    cycleProvider = CycleProvider(
      state,
      now: () => DateTime(2026, 1, 15),
    );

    await state.profile.save(
      const UserProfile(
        id: 'p1',
        averageCycleLength: 28,
        averagePeriodLength: 5,
        lutealPhaseLength: 14,
      ),
    );
    cycleProvider.recompute();
  });

  test('logPeriodDay records a day and triggers a recompute', () async {
    expect(cycleProvider.periodDays, isEmpty);
    expect(cycleProvider.prediction, isNull);

    await cycleProvider.logPeriodDay(DateTime(2026, 1, 1));

    expect(cycleProvider.isPeriodDay(DateTime(2026, 1, 1)), isTrue);
    expect(dateOnly(cycleProvider.prediction!.nextPeriodStart),
        DateTime(2026, 1, 29));
  });

  test('logPeriodDay updates an existing day instead of duplicating', () async {
    await cycleProvider.logPeriodDay(DateTime(2026, 1, 1));
    await cycleProvider.logPeriodDay(
      DateTime(2026, 1, 1),
      intensity: null,
      notes: 'updated',
    );

    final periodDays = cycleProvider.periodDays;
    expect(periodDays, {DateTime(2026, 1, 1)});
    final logs = state.logs.periodLogs.items;
    expect(logs.length, 1);
    expect(logs.single.notes, 'updated');
  });

  test('removePeriodDay clears the day and recomputes', () async {
    await cycleProvider.logPeriodDay(DateTime(2026, 1, 1));
    await cycleProvider.removePeriodDay(DateTime(2026, 1, 1));

    expect(cycleProvider.isPeriodDay(DateTime(2026, 1, 1)), isFalse);
    expect(state.logs.periodLogs.items, isEmpty);
  });
}