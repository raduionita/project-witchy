import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/cycle_stats.dart';
import '../../../utils/app_theme.dart';

/// Line chart of cycle lengths over time with a dashed average reference line.
class CycleLengthChart extends StatelessWidget {
  const CycleLengthChart({super.key, required this.points});

  final List<CycleLengthPoint> points;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (points.length < 2) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            l10n.chartLengthEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ),
      );
    }

    final double average = points.fold<int>(0, (int s, CycleLengthPoint p) => s + p.length) /
        points.length;
    final double maxY = points
            .map((CycleLengthPoint p) => p.length.toDouble())
            .reduce((double a, double b) => a > b ? a : b) +
        2;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) => Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: points.length > 6 ? 2 : 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    DateFormat('M/d').format(points[index].startDate),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: average,
                color: scheme.tertiary,
                strokeWidth: 1,
                dashArray: const <int>[6, 6],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.kSm,
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                  labelResolver: (HorizontalLine line) =>
                      l10n.chartAvg(average.toStringAsFixed(0)),
                ),
              ),
            ],
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) =>
                  scheme.inverseSurface,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  return LineTooltipItem(
                    l10n.chartDays(spot.y.toInt()),
                    TextStyle(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].length.toDouble()),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              color: scheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}