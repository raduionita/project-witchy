import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/theme/app_colors.dart';
import 'package:witchy/widgets/stat_card.dart';

void main() {
  group('StatCard', () {
    testWidgets('renders its label, value and sub', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatCard(label: 'Bleeding In', value: '5 Days', sub: 'Oct 17 · predicted'))),
      );
      expect(find.text('BLEEDING IN'), findsOneWidget);
      expect(find.text('5 Days'), findsOneWidget);
      expect(find.text('Oct 17 · predicted'), findsOneWidget);
    });

    testWidgets('stays inert without an onTap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatCard(label: 'a', value: 'b', sub: 'c'))),
      );
      expect(find.byWidgetPredicate((w) => w is MouseRegion && w.cursor == SystemMouseCursors.click), findsNothing);
    });

    testWidgets('shows a pointer cursor and reports taps with an onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatCard(label: 'a', value: 'b', sub: 'c', onTap: () => taps++))),
      );
      expect(find.byWidgetPredicate((w) => w is MouseRegion && w.cursor == SystemMouseCursors.click), findsOneWidget);
      await tester.tap(find.text('b'));
      expect(taps, 1);
    });

    testWidgets('keeps the default value colour', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatCard(label: 'a', value: 'b', sub: 'c'))),
      );
      expect(tester.widget<Text>(find.text('b')).style?.color, AppColors.pur);
    });
  });
}
