import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/settings/settings_screen.dart';
import 'package:witchy/features/settings/theme_provider.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/services/storage_service.dart';

Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

Future<ThemeProvider> pumpSettingsScreen(WidgetTester tester) async {
  final StorageService storage = await freshStorage();
  final ThemeProvider themeProvider = ThemeProvider(storage)..load();
  final AppStateProvider state = AppStateProvider(storage)..load();
  final AuthProvider authProvider = AuthProvider(
    AuthService(storage: storage, gateway: NativeAuthGateway()),
  )..load();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>.value(value: state),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return themeProvider;
}

void main() {
  test('load defaults to light and persists a selection', () async {
    final StorageService storage = await freshStorage();
    final ThemeProvider provider = ThemeProvider(storage)..load();

    expect(provider.option, AppThemeOption.light);
    expect(provider.themeMode, ThemeMode.light);

    await provider.setOption(AppThemeOption.light);

    final ThemeProvider reloaded = ThemeProvider(storage)..load();
    expect(reloaded.option, AppThemeOption.light);
  });

  testWidgets('settings shows the default theme option selected',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ThemeProvider provider = await pumpSettingsScreen(tester);

    await tester.scrollUntilVisible(find.text('Theme'), 200);
    expect(find.text('Theme'), findsOneWidget);
    final RadioListTile<AppThemeOption> radio = tester
        .widget<RadioListTile<AppThemeOption>>(
      find.widgetWithText(RadioListTile<AppThemeOption>, 'Default (light)'),
    );
    expect(radio.value, provider.option);
    expect(radio.groupValue, AppThemeOption.light);
  });
}