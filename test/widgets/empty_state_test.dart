import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/theme/app_icons.dart';
import 'package:witchy/widgets/empty_state.dart';

void main() {
  testWidgets('renders the badge, title and message without an action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EmptyState(icon: AppIcons.spark, title: 'No articles yet', message: 'Pull down to refresh.'))));
    expect(find.text('No articles yet'), findsOneWidget);
    expect(find.text('Pull down to refresh.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('renders the action only when both label and callback are given', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: EmptyState(icon: AppIcons.alert, title: 'Nothing here', message: 'Try later.', actionLabel: 'Try again', onAction: () => taps++))),
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(taps, 1);
  });

  testWidgets('omits the action when the callback is missing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EmptyState(icon: AppIcons.alert, title: 'Nothing here', message: 'Try later.', actionLabel: 'Try again'))));
    expect(find.text('Try again'), findsNothing);
  });
}
