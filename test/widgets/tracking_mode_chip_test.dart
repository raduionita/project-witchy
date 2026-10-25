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

  testWidgets('lays all three modes out in one proportional row', (tester) async {
    await pumpChips(tester, selected: {TrackingMode.cycle}, onToggle: (_) {});
    final chips = find.byType(AppChip);
    expect(chips, findsNWidgets(3));
    final row = tester.getRect(find.byType(TrackingModeChips));
    final first = tester.getRect(chips.at(0));
    final middle = tester.getRect(chips.at(1));
    final last = tester.getRect(chips.at(2));
    expect(first.top, closeTo(middle.top, 0.1));
    expect(middle.top, closeTo(last.top, 0.1));
    expect(first.left, closeTo(row.left, 0.1));
    expect(last.right, closeTo(row.right, 0.1));
    expect(last.width, greaterThan(first.width));
    expect(last.width, greaterThan(middle.width));
    expect(tester.widget<AppChip>(chips.at(0)).padding, const EdgeInsets.symmetric(horizontal: 10, vertical: 6));
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
