import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/theme/app_icons.dart';
import 'package:witchy/widgets/quick_action.dart';

void main() {
  testWidgets('renders the label and the logged value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: QuickAction(icon: AppIcons.drop, label: 'Flow', value: 'Medium', filled: true, onTap: () {}))),
    );
    expect(find.text('Flow'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('reports taps and stays inert without a value', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuickAction(icon: AppIcons.drop, label: 'Flow', onTap: () => taps++))));
    expect(find.text('Flow'), findsOneWidget);
    await tester.tap(find.text('Flow'));
    expect(taps, 1);
  });
}
