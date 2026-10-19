import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/theme/app_colors.dart';
import 'package:witchy/widgets/cycle_orb.dart';

void main() {
  Future<void> pumpOrb(WidgetTester tester, {bool showLegend = true, double progress = 0.5}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: CycleOrb(day: '14', phase: 'Ovulation', progress: progress, cycleLength: 28, bleedLength: 5, fertileStartDay: 10, fertileEndDay: 16, showLegend: showLegend)),
        ),
      ),
    );
  }

  testWidgets('the ring carries a period segment, a fertile segment and track', (tester) async {
    await pumpOrb(tester);
    final rings = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.gradient)
        .whereType<SweepGradient>()
        .toList();
    expect(rings, isNotEmpty);
    final ring = rings.first;
    // Day 1 is the period start, so the sweep opens on the period colour.
    expect(ring.colors.first, AppColors.pink);
    expect(ring.colors, contains(AppColors.pur));
    expect(ring.colors, contains(AppColors.lav2));
  });

  testWidgets('shows the day, phase, progress and a legend', (tester) async {
    await pumpOrb(tester);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('Ovulation'), findsOneWidget);
    expect(find.text('50% through'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Fertile'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('the legend can be turned off', (tester) async {
    await pumpOrb(tester, showLegend: false);
    expect(find.text('Period'), findsNothing);
    expect(find.text('Fertile'), findsNothing);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('exposes one label describing the whole orb', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpOrb(tester);
    expect(find.bySemanticsLabel(RegExp('Cycle day 14, Ovulation')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('fertile window days 10-16')), findsOneWidget);
    handle.dispose();
  });
}
