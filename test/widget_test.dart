import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/main.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/reminders_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/services/prefs_service.dart';

Future<App> _buildApp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = PrefsService();
  return App(
    auth: await AuthProvider.load(prefs),
    onboarding: await OnboardingProvider.load(prefs),
    logging: await LoggingProvider.load(prefs),
    settings: await SettingsProvider.load(prefs),
    reminders: await RemindersProvider.load(prefs),
  );
}

void main() {
  testWidgets('Splash renders brand and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    expect(find.text('Witchy'), findsOneWidget);
    expect(find.text('Awaken Your Power'), findsOneWidget);
    expect(find.text('Track your cycle with magic'), findsOneWidget);
  });

  testWidgets('Navigate to Join via Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Join the Coven'), findsOneWidget);
    expect(find.text('Cast Invitation Scroll'), findsOneWidget);
  });
}
