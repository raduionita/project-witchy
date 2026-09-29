import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TrendBars extends StatelessWidget {
  const TrendBars({super.key});

  static const List<double> _heights = [0.58, 0.72, 0.62, 0.78, 0.94, 0.68, 0.74];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 1,
          barGroups: [
            for (var i = 0; i < _heights.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(toY: _heights[i], width: 16, gradient: AppColors.barGradient, borderRadius: BorderRadius.circular(6)),
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
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text('M${value.toInt() + 1}', style: AppText.sans(8.5, c: AppColors.muted)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
