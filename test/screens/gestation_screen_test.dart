import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/screens/gestation_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<GestationProvider> provider({DateTime? lmp}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    return GestationProvider(prefs, lmpDate: lmp);
  }

  Future<void> pumpScreen(WidgetTester tester, GestationProvider gestation) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<GestationProvider>.value(value: gestation)],
        child: const MaterialApp(home: GestationScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state prompts for the last period date without LMP', (tester) async {
    await pumpScreen(tester, await provider());
    expect(find.text('Your gestation journey awaits'), findsOneWidget);
    expect(find.text('Set last period date'), findsOneWidget);
    expect(find.textContaining('Week'), findsNothing);
    expect(find.text('Spiritual Comparison'), findsNothing);
  });

  testWidgets('seeded LMP renders computed week, countdown and content', (tester) async {
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 84));
    await pumpScreen(tester, await provider(lmp: lmp));
    expect(find.text('Week 12 (Day 0)'), findsOneWidget);
    expect(find.text('196 days until arrival portal opens'), findsOneWidget);
    expect(find.text('Apple Size'), findsOneWidget);
    expect(find.text('Astral Gestation Tips'), findsOneWidget);
    expect(find.text('Set last period date'), findsNothing);
    expect(find.text('Last bleeding phase'), findsOneWidget);
  });

  testWidgets('LMP row is tappable and keeps the screen alive', (tester) async {
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 10));
    await pumpScreen(tester, await provider(lmp: lmp));
    expect(find.textContaining('Week 1 (Day 3)'), findsOneWidget);
    expect(find.text('Poppy Seed'), findsOneWidget);
  });
}
