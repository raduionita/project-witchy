import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/symptom_log.dart';
import '../../../utils/date_utils.dart';

/// Line chart of symptom entries per month over the last [months] months.
class SymptomsOverTimeChart extends StatelessWidget {
  const SymptomsOverTimeChart({super.key, required this.logs, this.months = 6});

  final List<SymptomLog> logs;
  final int months;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final DateTime now = dateOnly(DateTime.now());

    // Month buckets, oldest first.
    final List<DateTime> buckets = <DateTime>[];
    for (int i = months - 1; i >= 0; i--) {
      buckets.add(DateTime(now.year, now.month - i, 1));
    }

    final List<int> counts = buckets.map((DateTime bucket) {
      final DateTime next = DateTime(bucket.year, bucket.month + 1, 1);
      return logs
          .where((SymptomLog log) {
            final DateTime day = dateOnly(log.date);
            return !day.isBefore(bucket) && day.isBefore(next);
          })
          .length;
    }).toList();

    if (counts.every((int c) => c == 0)) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            l10n.chartOverTimeEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ),
      );
    }

    final double maxY = counts.fold<int>(0, (int m, int v) => v > m ? v : m) + 1;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (buckets.length - 1).toDouble(),
          minY: 0,
          maxY: maxY.toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
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
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    DateFormat('MMM').format(buckets[index]),
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) =>
                  scheme.inverseSurface,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  return LineTooltipItem(
                    l10n.chartEntries(spot.y.toInt()),
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
                for (int i = 0; i < buckets.length; i++)
                  FlSpot(i.toDouble(), counts[i].toDouble()),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              color: scheme.tertiary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: scheme.tertiary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}