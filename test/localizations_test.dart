import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/l10n/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations resolves English strings via delegates',
      (WidgetTester tester) async {
    String? settings;
    String? anonymous;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            final AppLocalizations l10n = AppLocalizations.of(context);
            settings = l10n.settingsTitle;
            anonymous = l10n.anonymousMode;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
    expect(settings, 'Settings');
    expect(anonymous, 'Anonymous mode');
  });

  testWidgets('AppLocalizations resolves Spanish strings when the locale is es',
      (WidgetTester tester) async {
    String? settings;
    String? anonymous;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            final AppLocalizations l10n = AppLocalizations.of(context);
            settings = l10n.settingsTitle;
            anonymous = l10n.anonymousMode;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(settings, 'Ajustes');
    expect(anonymous, 'Modo anónimo');
  });
}
