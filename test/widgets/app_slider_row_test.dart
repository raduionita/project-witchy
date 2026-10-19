import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/widgets/app_slider_row.dart';
import 'package:witchy/widgets/number_entry_dialog.dart';

void main() {
  Future<void> pumpRow(WidgetTester tester, {required ValueChanged<double> onChanged, double current = 28}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AppSliderRow(label: 'Cycle length', value: '${current.round()} Days', min: 15, max: 60, current: current, onChanged: onChanged)),
      ),
    );
  }

  testWidgets('tapping the value opens the type-a-number dialog', (tester) async {
    double? changed;
    await pumpRow(tester, onChanged: (v) => changed = v);
    await tester.tap(find.text('28 Days'));
    await tester.pumpAndSettle();
    expect(find.byType(NumberEntryDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();
    expect(changed, 42);
  });

  testWidgets('a typed number outside the range is clamped', (tester) async {
    double? changed;
    await pumpRow(tester, onChanged: (v) => changed = v);
    await tester.tap(find.text('28 Days'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '99');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();
    expect(changed, 60);
  });

  testWidgets('retyping the current value reports no change', (tester) async {
    var calls = 0;
    await pumpRow(tester, onChanged: (_) => calls++);
    await tester.tap(find.text('28 Days'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '28');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('cancelling reports no change', (tester) async {
    var calls = 0;
    await pumpRow(tester, onChanged: (_) => calls++);
    await tester.tap(find.text('28 Days'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
}
