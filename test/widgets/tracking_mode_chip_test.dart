import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/widgets/app_chip.dart';
import 'package:witchy/widgets/tracking_mode_chip.dart';

void main() {
  Future<void> pumpChips(WidgetTester tester, {required Set<TrackingMode> selected, required ValueChanged<TrackingMode> onToggle}) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: TrackingModeChips(selected: selected, onToggle: onToggle)))),
    );
  }

  testWidgets('lays all three modes out in one row of equal widths', (tester) async {
    await pumpChips(tester, selected: {TrackingMode.cycle}, onToggle: (_) {});
    expect(find.byType(AppChip), findsNWidgets(3));
    final widths = [for (var i = 0; i < 3; i++) tester.getSize(find.byType(AppChip).at(i)).width];
    expect(widths[0], greaterThan(0));
    expect(widths[1], widths[0]);
    expect(widths[2], widths[0]);
    // All three sit on the same line.
    final tops = [for (var i = 0; i < 3; i++) tester.getTopLeft(find.byType(AppChip).at(i)).dy];
    expect(tops[1], tops[0]);
    expect(tops[2], tops[0]);
  });

  testWidgets('every mode label is on screen and taps report the mode', (tester) async {
    final tapped = <TrackingMode>[];
    await pumpChips(tester, selected: {TrackingMode.cycle}, onToggle: tapped.add);
    for (final mode in TrackingMode.values) {
      expect(find.text(mode.label), findsOneWidget);
    }
    await tester.tap(find.text('Pregnancy'));
    expect(tapped, [TrackingMode.pregnancy]);
  });

  testWidgets('clips a long label instead of wrapping it', (tester) async {
    await pumpChips(tester, selected: {TrackingMode.perimenopause}, onToggle: (_) {});
    final label = tester.widget<Text>(find.text('Perimenopause'));
    expect(label.maxLines, 1);
    expect(label.softWrap, isFalse);
    expect(label.overflow, TextOverflow.clip);
  });
}
