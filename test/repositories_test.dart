import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/models/cycle.dart';
import 'package:witchy/models/flow_intensity.dart';
import 'package:witchy/models/period_log.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';
import 'package:witchy/models/symptom_log.dart';
import 'package:witchy/models/time_of_day_model.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/services/storage_service.dart';

/// Builds a fresh [StorageService] backed by mocked preferences.
Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

void main() {
  late AppStateProvider state;

  setUp(() async {
    state = AppStateProvider(await freshStorage());
    state.load();
  });

  group('ProfileRepository', () {
    test('returns null before any profile is saved', () {
      expect(state.profile.profile, isNull);
    });

    test('saves and reloads the profile', () async {
      const UserProfile profile = UserProfile(id: 'p1', onboarded: true);
      await state.profile.save(profile);

      expect(state.profile.profile, profile);
    });

    test('clear removes the profile', () async {
      await state.profile.save(const UserProfile(id: 'p1'));
      await state.profile.clear();
      expect(state.profile.profile, isNull);
    });
  });

  group('CycleRepository', () {
    test('adds cycles and exposes them newest-first', () async {
      final Cycle older =
          Cycle(id: 'c1', startDate: DateTime(2026, 1, 1), length: 28);
      final Cycle newer =
          Cycle(id: 'c2', startDate: DateTime(2026, 2, 1), length: 27);

      await state.cycles.add(older);
      await state.cycles.add(newer);

      expect(state.cycles.items.length, 2);
      expect(state.cycles.latest!.id, 'c2');
    });
  });

  group('LogsRepository', () {
    test('persists period and symptom logs independently', () async {
      final PeriodLog period = PeriodLog(
        id: 'pl1',
        date: DateTime(2026, 1, 5),
        intensity: FlowIntensity.light,
      );
      final SymptomLog symptom = SymptomLog(
        id: 'sl1',
        date: DateTime(2026, 1, 5),
        symptoms: const ['fatigue'],
      );

      await state.logs.periodLogs.add(period);
      await state.logs.symptomLogs.add(symptom);

      expect(state.logs.periodLogs.items.map((e) => e.id), ['pl1']);
      expect(state.logs.symptomLogs.items.map((e) => e.id), ['sl1']);
    });
  });

  group('ReminderRepository', () {
    test('filters enabled reminders', () async {
      await state.reminders.add(
        Reminder(
          id: 'r1',
          type: ReminderType.water,
          title: 'Hydrate',
          time: const TimeOfDayModel(hour: 12, minute: 0),
          enabled: true,
        ),
      );
      await state.reminders.add(
        Reminder(
          id: 'r2',
          type: ReminderType.sleep,
          title: 'Wind down',
          time: const TimeOfDayModel(hour: 22, minute: 0),
          enabled: false,
        ),
      );

      expect(state.reminders.enabled.map((e) => e.id), ['r1']);
    });
  });
}
