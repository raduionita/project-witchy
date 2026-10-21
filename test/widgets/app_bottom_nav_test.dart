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
}
