import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/theme/app_colors.dart';
import 'package:witchy/theme/app_theme.dart';

void main() {
  testWidgets('light theme uses the light token set', (tester) async {
    final theme = buildAppTheme();
    await tester.pumpWidget(MaterialApp(theme: theme));
    expect(AppColors.dark, isFalse);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFAF7FC));
    expect(theme.cardTheme.color, const Color(0xFFFFFFFF));
  });

  testWidgets('dark theme flips tokens to the dark set', (tester) async {
    final theme = buildAppTheme(brightness: Brightness.dark);
    await tester.pumpWidget(MaterialApp(theme: theme));
    expect(AppColors.dark, isTrue);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF1B0A2A));
    expect(theme.cardTheme.color, const Color(0xFF26063F));
    expect(theme.appBarTheme.backgroundColor, const Color(0xFF1B0A2A));
    expect(theme.colorScheme.primary, const Color(0xFF9D5CFF));
    buildAppTheme();
    expect(AppColors.dark, isFalse);
  });

  test('mode-varying tokens resolve per flag', () {
    AppColors.dark = false;
    expect(AppColors.ink, const Color(0xFF2A0A3C));
    expect(AppColors.line, const Color(0xFFECE3F2));
    AppColors.dark = true;
    expect(AppColors.ink, const Color(0xFFF3EAF9));
    expect(AppColors.line, const Color(0xFF3E2A54));
    AppColors.dark = false;
  });
}
