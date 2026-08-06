import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/couples/couples_provider.dart';
import 'package:witchy/features/couples/couples_screen.dart';
import 'package:witchy/features/couples/couples_service.dart';
import 'package:witchy/services/storage_service.dart';

Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

Future<CouplesProvider> pumpCouplesScreen(
  WidgetTester tester,
) async {
  final CouplesProvider provider =
      CouplesProvider(CoupleService(await freshStorage()))..load();
  await tester.pumpWidget(
    ChangeNotifierProvider<CouplesProvider>.value(
      value: provider,
      child: const MaterialApp(home: CouplesScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  testWidgets('shows the placeholder and a create-link action',
      (WidgetTester tester) async {
    await pumpCouplesScreen(tester);

    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('Create my share link'), findsOneWidget);
  });

  testWidgets('creating a link shows the generated code',
      (WidgetTester tester) async {
    final CouplesProvider provider = await pumpCouplesScreen(tester);

    await tester.tap(find.text('Create my share link'));
    await tester.pumpAndSettle();

    expect(provider.link, isNotNull);
    expect(find.text(provider.link!.code), findsOneWidget);
    expect(find.textContaining('Local only'), findsOneWidget);
  });
}
