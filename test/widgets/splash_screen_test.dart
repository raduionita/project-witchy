import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/screens/splash_screen.dart';
import 'package:witchy/theme/app_colors.dart';

void main() {
  testWidgets('SplashScreen shows plum background and gold emblem', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.plum);
    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('Splash'), findsNothing);
  });
}
