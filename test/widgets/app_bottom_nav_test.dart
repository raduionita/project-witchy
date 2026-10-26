import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('bottom nav shows the four shipped sections including Articles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(bottomNavigationBar: AppBottomNav(index: 0, onTap: (_) {})),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);
  });

  testWidgets('whole quarter of each tab is tappable', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: const SizedBox.expand(), bottomNavigationBar: AppBottomNav(index: 0, onTap: taps.add))));
    final nav = tester.getRect(find.byType(AppBottomNav));
    for (var i = 0; i < 4; i++) {
      await tester.tapAt(Offset(nav.left + nav.width * (i + 0.5) / 4, nav.center.dy));
      await tester.pump();
    }
    expect(taps, [0, 1, 2, 3]);
  });
}
