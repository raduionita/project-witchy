import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bar chart of observed cycle lengths. Renders an empty-state hint until
/// at least two completed cycles are logged.
class TrendBars extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const TrendBars({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: 112,
        child: Center(
          child: Text('Log two completed cycles to grow your trends.', style: AppText.sans(11.5, c: AppColors.muted), textAlign: TextAlign.center),
        ),
      );
    }
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final span = hi - lo;
    // Pad the range so differing lengths stay visually distinguishable.
    final pad = span < 2 ? 1.0 : span * 0.2;
    final minY = span < 2 ? lo - 1 : lo - pad;
    final maxY = span < 2 ? hi + 1 : hi + pad;
    return SizedBox(
      height: 112,
      child: BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(toY: values[i], width: 16, gradient: AppColors.barGradient, borderRadius: BorderRadius.circular(6)),
                ],
              ),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 18,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 7), child: Text(labels[i], style: AppText.sans(8.5, c: AppColors.muted)));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
