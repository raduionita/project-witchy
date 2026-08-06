import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/symptom_insights.dart';
import '../../../utils/app_theme.dart';

/// Horizontal-friendly vertical bar chart of the most frequent symptoms.
class SymptomFrequencyBarChart extends StatelessWidget {
  const SymptomFrequencyBarChart({super.key, required this.frequencies});

  final List<SymptomFrequency> frequencies;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (frequencies.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Log symptoms to see patterns here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ),
      );
    }

    final double maxCount = frequencies
        .map((SymptomFrequency f) => f.count.toDouble())
        .reduce((double a, double b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount + 1).toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (double value, TitleMeta meta) => Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= frequencies.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.kXs),
                    child: Text(
                      _shortLabel(frequencies[index].symptom),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData group) => scheme.inverseSurface,
              getTooltipItem: (BarChartGroupData group, int groupIndex,
                      BarChartRodData rod, int rodIndex) =>
                  BarTooltipItem(
                '${frequencies[groupIndex].count}× ${frequencies[groupIndex].symptom}',
                TextStyle(
                  color: scheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          barGroups: List<BarChartGroupData>.generate(
            frequencies.length,
            (int index) => BarChartGroupData(
              x: index,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: frequencies[index].count.toDouble(),
                  color: _barColor(scheme, index),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.kXs),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _barColor(ColorScheme scheme, int index) {
    const List<Color> palette = <Color>[
      AppColors.kPrimary,
      AppColors.kTertiary,
      AppColors.kSecondary,
      Color(0xFF27AE60),
      Color(0xFF2E86C1),
    ];
    return index < palette.length
        ? palette[index]
        : scheme.primary.withValues(alpha: 0.5);
  }

  String _shortLabel(String symptom) =>
      symptom.length > 14 ? '${symptom.substring(0, 13)}…' : symptom;
}
