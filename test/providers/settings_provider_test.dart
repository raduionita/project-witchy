import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('resetToDefaults returns notification and theme settings to defaults', () async {
    final settings = await SettingsProvider.load(PrefsService());
    settings.setLunar(false);
    settings.setDark(true);
    settings.resetToDefaults();
    expect(settings.lunarNotifications, isTrue);
    expect(settings.darkMode, isFalse);
    expect(settings.startTab, 0);

    settings.setStartTab(2);
    expect(settings.startTab, 2);
    settings.resetToDefaults();
    expect(settings.startTab, 0);
  });
}
