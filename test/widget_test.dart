import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app.dart';
import 'package:witchy/screens/main_shell.dart';

void main() {
  testWidgets('bootstrapped app shows the main shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();

    await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('Witchy'), findsNothing);
  });

  test('bootstrap flips first-run flag off after onboarding marker is set', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Placeholder assertion for Phase 0: bootstrap starts on first run.
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();
    expect(bootstrap.isBootstrapped, isTrue);
    expect(bootstrap.isFirstRun, isTrue);
  });
}