import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/utils/app_theme.dart';
import 'package:witchy/widgets/app_icon.dart';
import 'package:witchy/widgets/app_text.dart';

void main() {
  group('AppText', () {
    testWidgets('renders the given string', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppText('Hello Witchy'))),
      );

      expect(find.text('Hello Witchy'), findsOneWidget);
    });

    testWidgets('applies the body variant by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: AppText('Body')))),
      );

      final BuildContext context = tester.element(find.byType(AppText));
      final Text text = tester.widget<Text>(find.byType(Text));
      expect(
        text.style!.fontSize,
        Theme.of(context).textTheme.bodyMedium!.fontSize,
      );
    });

    testWidgets('headline variant resolves the headline style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppText('Title', variant: AppTextVariant.headline)),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(AppText));
      final Text text = tester.widget<Text>(find.byType(Text));
      expect(
        text.style!.fontSize,
        Theme.of(context).textTheme.headlineSmall!.fontSize,
      );
    });

    testWidgets('explicit color wins over the variant style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: AppText('Tinted', color: Colors.red)),
          ),
        ),
      );

      final Text text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.color, Colors.red);
    });

    testWidgets('resolves styles from the active theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Center(child: AppText('Themed', variant: AppTextVariant.display)),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(AppText));
      final Text text = tester.widget<Text>(find.byType(Text));
      expect(
        text.style!.fontSize,
        Theme.of(context).textTheme.displaySmall!.fontSize,
      );
    });
  });

  group('AppIcon', () {
    testWidgets('renders the icon with default medium size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AppIcon(Icons.favorite))),
        ),
      );

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.favorite);
      expect(icon.size, AppIconSize.medium.size);
    });

    testWidgets('honors an explicit size token', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppIcon(Icons.water_drop, size: AppIconSize.large)),
          ),
        ),
      );

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, AppIconSize.large.size);
    });

    testWidgets('applies the explicit color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppIcon(Icons.spa, color: Colors.green)),
          ),
        ),
      );

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.green);
    });
  });
}