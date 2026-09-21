import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/main.dart';

void main() {
  testWidgets('Splash renders brand and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const WitchyApp());
    await tester.pumpAndSettle();
    expect(find.text('Witchy'), findsOneWidget);
    expect(find.text('Awaken Your Power'), findsOneWidget);
    expect(find.text('Track your cycle with magic'), findsOneWidget);
  });

  testWidgets('Navigate to Join via Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(const WitchyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Join the Coven'), findsOneWidget);
    expect(find.text('Cast Invitation Scroll'), findsOneWidget);
  });
}
