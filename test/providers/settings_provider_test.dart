import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_goal.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('goal defaults to tracking and persists across loads', () async {
    final settings = await SettingsProvider.load(PrefsService());
    expect(settings.goal, CycleGoal.track);
    settings.setGoal(CycleGoal.conceive);
    await Future<void>.delayed(Duration.zero);
    final reloaded = await SettingsProvider.load(PrefsService());
    expect(reloaded.goal, CycleGoal.conceive);
  });

  test('resetToDefaults returns the goal to tracking', () async {
    final settings = await SettingsProvider.load(PrefsService());
    settings.setGoal(CycleGoal.conceive);
    settings.resetToDefaults();
    expect(settings.goal, CycleGoal.track);
  });
}
