import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/common/log_data.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/services/prefs_service.dart';
import 'package:witchy/widgets/log_bottom_sheet.dart';

void main() {
  final day = DateTime(2026, 10, 19);

  Future<void> pumpSheet(WidgetTester tester, {LogCategory? scrollTo}) async {
    SharedPreferences.setMockInitialValues({});
    final logging = await LoggingProvider.load(PrefsService());
    await tester.pumpWidget(
      ChangeNotifierProvider<LoggingProvider>.value(
        value: logging,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showLogSheet(context, day, scrollTo: scrollTo),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    // Let the sheet route and the highlight timers settle.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1500));
  }

  testWidgets('hides the collection method until a flow level is logged', (tester) async {
    await pumpSheet(tester);
    expect(find.text('Collection method'), findsNothing);

    await tester.tap(find.text('Light').first);
    await tester.pumpAndSettle();

    expect(find.text('Collection method'), findsOneWidget);
  });

  testWidgets('asks before discarding edits', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Light').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Light'), findsWidgets);
  });

  testWidgets('opens scrolled to a later category', (tester) async {
    await pumpSheet(tester, scrollTo: LogData.sleep);
    await tester.pumpAndSettle();

    expect(find.text('Sleep'), findsOneWidget);
  });
}
