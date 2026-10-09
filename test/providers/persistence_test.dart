import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/day_log.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/reminders_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  test('rhythms round-trip: saveRhythms restores via OnboardingProvider.load', () async {
    await prefs.saveRhythms(32, 7, DateTime(2026, 9, 20));
    await prefs.setOnboarded();

    final onboarding = await OnboardingProvider.load(prefs);

    expect(onboarding.onboarded, isTrue);
    expect(onboarding.cycleLength, 32);
    expect(onboarding.bleedLength, 7);
    expect(onboarding.selectedDay, 20);
  });

  test('OnboardingProvider.finish persists and reloads as onboarded', () async {
    final onboarding = OnboardingProvider(prefs, selectedDay: 21, cycleLength: 30, bleedLength: 6);
    await onboarding.finish();
    await pumpEventQueue();

    final reloaded = await OnboardingProvider.load(prefs);
    expect(reloaded.onboarded, isTrue);
    expect(reloaded.cycleLength, 30);
    expect(reloaded.bleedLength, 6);
    expect(reloaded.selectedDay, 21);
  });

  test('finish with a picked date persists it and the first bleed day logs', () async {
    final onboarding = OnboardingProvider(prefs, cycleLength: 28, bleedLength: 5);
    onboarding.setDate(DateTime(2026, 9, 3));
    final logging = LoggingProvider(prefs);
    await onboarding.finish();
    logging.setFlow(onboarding.lastPeriodStart, 'Medium');
    await pumpEventQueue();

    final reloaded = await OnboardingProvider.load(prefs);
    expect(reloaded.lastPeriodStart, DateTime(2026, 9, 3));
    expect(reloaded.selectedDay, 3);
    final restored = await LoggingProvider.load(prefs);
    expect(restored.peekDay(DateTime(2026, 9, 3))?.flow, {'Medium'});
  });

  test('privacy consent and birth year persist across reload', () async {
    expect(await prefs.isPrivacyAccepted(), isFalse);
    await prefs.setPrivacyAccepted();
    await prefs.setBirthYear(1996);
    expect(await prefs.isPrivacyAccepted(), isTrue);
    expect(await prefs.birthYear(), 1996);
  });

  test('OnboardingProvider.finish persists year of birth', () async {
    final onboarding = OnboardingProvider(prefs, cycleLength: 28, bleedLength: 5);
    onboarding.setYear(1996);
    await onboarding.finish();
    await pumpEventQueue();

    final reloaded = await OnboardingProvider.load(prefs);
    expect(reloaded.yearOfBirth, 1996);
    expect(reloaded.onboarded, isTrue);
  });

  test('SettingsProvider mutations survive reload', () async {
    final settings = await SettingsProvider.load(prefs);
    expect(settings.lunarNotifications, isTrue);
    expect(settings.darkMode, isFalse);
    expect(settings.shareSymptoms, isFalse);

    settings.setLunar(false);
    settings.setDark(true);
    settings.setShareBleed(false);
    settings.setShareFertile(false);
    settings.setShareSymptoms(true);
    await pumpEventQueue();

    final reloaded = await SettingsProvider.load(prefs);
    expect(reloaded.lunarNotifications, isFalse);
    expect(reloaded.darkMode, isTrue);
    expect(reloaded.shareBleed, isFalse);
    expect(reloaded.shareFertile, isFalse);
    expect(reloaded.shareSymptoms, isTrue);
  });

  test('LoggingProvider mutations survive reload per date key', () async {
    final day = DateTime(2026, 9, 28);
    final logging = await LoggingProvider.load(prefs);
    logging.setFlow(day, 'Heavy');
    logging.setPain(day, 9.5);
    logging.toggleMood(day, 'Enchanted');
    logging.setNotes(day, 'Ritual notes.');
    await pumpEventQueue();

    final reloaded = await LoggingProvider.load(prefs);
    final restored = reloaded.day(day);
    expect(restored.flow, {'Heavy'});
    expect(restored.pain, 9.5);
    expect(restored.moods, contains('Enchanted'));
    expect(restored.notes, 'Ritual notes.');
    expect(LoggingProvider.keyFor(day), '2026-09-28');
  });

  test('LoggingProvider day logs persist across a full reload cycle', () async {
    final day = DateTime(2026, 10, 15);
    final logging = LoggingProvider(prefs, days: {
      LoggingProvider.keyFor(day): DayLog(flow: {'Light'}, pain: 2, notes: 'Saved entry.'),
    });
    await prefs.saveDayLogs({LoggingProvider.keyFor(day): logging.day(day)});

    final reloaded = await LoggingProvider.load(prefs);
    final restored = reloaded.day(day);
    expect(restored.flow, {'Light'});
    expect(restored.pain, 2);
    expect(restored.notes, 'Saved entry.');
  });

  test('RemindersProvider toggle survives reload', () async {
    final reminders = await RemindersProvider.load(prefs);
    final initial = reminders.items[0].enabled;
    reminders.toggle(0, !initial);
    await pumpEventQueue();

    final reloaded = await RemindersProvider.load(prefs);
    expect(reloaded.items[0].enabled, !initial);
  });

  test('session save/restore/clear round-trip', () async {
    expect(await prefs.session(), isNull);

    await prefs.saveSession({'method': 'email', 'email': 'selene@moon.co', 'name': 'selene'});
    expect(await prefs.session(), {'method': 'email', 'email': 'selene@moon.co', 'name': 'selene'});

    await prefs.clearSession();
    expect(await prefs.session(), isNull);
  });
}
