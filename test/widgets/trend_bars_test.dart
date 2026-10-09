import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/widgets/trend_bars.dart';

void main() {
  testWidgets('shows empty state below two cycles', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TrendBars(values: [28], labels: ['C1']))));

    expect(find.text('Log two completed cycles to grow your trends.'), findsOneWidget);
    expect(find.text('C1'), findsNothing);
  });

  testWidgets('renders one bar per observed cycle with labels', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TrendBars(values: [28, 30, 27], labels: ['C1', 'C2', 'C3']))));

    expect(find.text('Log two completed cycles to grow your trends.'), findsNothing);
    expect(find.text('C1'), findsOneWidget);
    expect(find.text('C2'), findsOneWidget);
    expect(find.text('C3'), findsOneWidget);
  });
}
