import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PrefsService prefs;
  late OnboardingProvider onboarding;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(prefs);
  });

  group('previous period history', () {
    test('stores newest first and ignores duplicates', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.addPreviousPeriod(DateTime(2026, 9, 10));
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.previousPeriodStarts, [DateTime(2026, 9, 10), DateTime(2026, 8, 5)]);

      onboarding.removePreviousPeriod(DateTime(2026, 9, 10));
      expect(onboarding.previousPeriodStarts, [DateTime(2026, 8, 5)]);
    });

    test('resetToDefaults clears entered history', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.resetToDefaults();
      expect(onboarding.previousPeriodStarts, isEmpty);
    });
  });

  group('deriveCycleLengthFromHistory', () {
    test('is null until two starts exist', () {
      expect(onboarding.deriveCycleLengthFromHistory(), isNull);
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      expect(onboarding.deriveCycleLengthFromHistory(), isNull);
    });

    test('returns the single known gap from two starts', () {
      onboarding.addPreviousPeriod(DateTime(2026, 8, 10));
      onboarding.setDate(DateTime(2026, 9, 5));
      expect(onboarding.deriveCycleLengthFromHistory(), 26);
    });

    test('returns the median across three completed cycles', () {
      onboarding.addPreviousPeriod(DateTime(2026, 7, 10));
      onboarding.addPreviousPeriod(DateTime(2026, 8, 5));
      onboarding.setDate(DateTime(2026, 8, 31));
      // Gaps: 26, 26 -> median 26.
      expect(onboarding.deriveCycleLengthFromHistory(), 26);

      onboarding.addPreviousPeriod(DateTime(2026, 6, 15));
      // Gaps: 25, 26, 26 -> median 26.
      expect(onboarding.deriveCycleLengthFromHistory(), 26);
    });
  });
}
