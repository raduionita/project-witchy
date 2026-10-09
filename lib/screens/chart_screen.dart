import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/log_bottom_sheet.dart';

/// Biphasic BBT chart: last 30 calendar days of logged temperatures with
/// gaps for unlogged days, a predicted ovulation marker, and shift averages.
class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  static const int _windowDays = 30;

  ({List<FlSpot> spots, List<List<FlSpot>> segments, double? preShift, double? postShift, int? ovulationX}) _series(List<({DateTime date, double temp})> readings, DateTime start, DateTime? ovulationDay) {
    if (readings.isEmpty) return (spots: [], segments: [], preShift: null, postShift: null, ovulationX: null);
    // Split into runs of consecutive days so unlogged days render as gaps.
    final segments = <List<FlSpot>>[];
    var current = <FlSpot>[];
    for (final r in readings) {
      final x = CycleCalculator.daysBetween(start, r.date);
      if (current.isNotEmpty && x - current.last.x > 1) {
        segments.add(current);
        current = [];
      }
      current.add(FlSpot(x.toDouble(), r.temp));
    }
    if (current.isNotEmpty) segments.add(current);
    final ovulationX = ovulationDay == null ? null : CycleCalculator.daysBetween(start, ovulationDay);
    double? pre;
    double? post;
    if (ovulationX != null) {
      final before = readings.where((r) => CycleCalculator.daysBetween(start, r.date) < ovulationX).map((r) => r.temp).toList();
      final after = readings.where((r) => CycleCalculator.daysBetween(start, r.date) >= ovulationX).map((r) => r.temp).toList();
      if (before.isNotEmpty) pre = before.reduce((a, b) => a + b) / before.length;
      if (after.isNotEmpty) post = after.reduce((a, b) => a + b) / after.length;
    }
    return (spots: segments.expand((s) => s).toList(), segments: segments, preShift: pre, postShift: post, ovulationX: ovulationX);
  }

  Widget _emptyPrompt(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text('No temperatures yet', style: AppText.secIn),
          const SizedBox(height: 8),
          Text('Log your waking temperature each morning to reveal your biphasic pattern.', style: AppText.sans(11.5, c: AppColors.muted), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          AppButton(label: 'Log your temperature', onTap: () => showLogSheet(context, DateTime.now())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logging = context.watch<LoggingProvider>();
    final cycle = context.watch<CycleProvider>();
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day - (_windowDays - 1));
    final readings = <({DateTime date, double temp})>[];
    for (final e in logging.snapshot().entries) {
      final day = DateTime(e.key.year, e.key.month, e.key.day);
      final temp = e.value.temperature;
      if (temp == null || day.isBefore(start) || day.isAfter(DateTime(today.year, today.month, today.day))) continue;
      readings.add((date: day, temp: temp));
    }
    readings.sort((a, b) => a.date.compareTo(b.date));
    final ovulationDay = cycle.showFertilityPredictions ? cycle.ovulationDay(today: today) : null;
    final inWindow = ovulationDay != null && !ovulationDay.isBefore(start) && !ovulationDay.isAfter(DateTime(today.year, today.month, today.day));
    final series = _series(readings, start, inWindow ? ovulationDay : null);

    return Scaffold(
      appBar: const AppTopBar(title: 'BBT Chart'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          if (readings.isEmpty)
            _emptyPrompt(context)
          else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biphasic Temperature Shift', style: AppText.secIn),
                  const SizedBox(height: 10),
                  _BbtPlot(series: series, start: start, today: today),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(label: '', value: series.preShift == null ? '—' : '${series.preShift!.toStringAsFixed(1)}°', sub: 'Pre-shift average')),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: '',
                    value: series.preShift == null || series.postShift == null ? '—' : '+${(series.postShift! - series.preShift!).toStringAsFixed(1)}°',
                    sub: 'Post-shift rise',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              dark: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to read this', style: AppText.serif(13.5, c: Colors.white)),
                  const SizedBox(height: 8),
                  Text('A sustained rise across three mornings confirms ovulation. Log your waking temperature daily for a clear biphasic pattern.',
                      style: AppText.sans(11.5, c: const Color(0xFFE9D9F5), h: 1.55)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Line chart plot of the temperature series with the ovulation marker.
class _BbtPlot extends StatelessWidget {
  final ({List<FlSpot> spots, List<List<FlSpot>> segments, double? preShift, double? postShift, int? ovulationX}) series;
  final DateTime start;
  final DateTime today;
  const _BbtPlot({required this.series, required this.start, required this.today});

  @override
  Widget build(BuildContext context) {
    final temps = [for (final s in series.segments) ...s.map((p) => p.y)];
    final dataMin = temps.reduce((a, b) => a < b ? a : b);
    final dataMax = temps.reduce((a, b) => a > b ? a : b);
    final minY = ((dataMin - 0.15) * 2).floor() / 2;
    final maxY = ((dataMax + 0.15) * 2).ceil() / 2;
    final dayCount = CycleCalculator.daysBetween(start, today);
    final ovulationX = series.ovulationX;
    return SizedBox(
      height: 172,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: const LineTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            for (final segment in series.segments)
              LineChartBarData(
                spots: segment,
                isCurved: false,
                barWidth: 2,
                color: AppColors.pur,
                dotData: FlDotData(show: segment.length <= 16),
                belowBarData: BarAreaData(show: false),
              ),
          ],
          extraLinesData: ovulationX == null
              ? null
              : ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: ovulationX.toDouble(),
                      color: AppColors.gold,
                      strokeWidth: 1.5,
                      dashArray: const [4, 4],
                      label: VerticalLineLabel(show: true, labelResolver: (_) => 'Ovulation', style: AppText.sans(8.5, c: AppColors.gold), padding: const EdgeInsets.only(bottom: 6)),
                    ),
                  ],
                ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: (maxY - minY) / 4 < 0.49 ? null : 0.5,
                getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(right: 6), child: Text(value.toStringAsFixed(1), style: AppText.sans(8.5, c: AppColors.muted))),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 18,
                interval: dayCount > 0 ? (dayCount / 4).ceilToDouble() : null,
                getTitlesWidget: (value, meta) {
                  final date = start.add(Duration(days: value.toInt()));
                  return Padding(padding: const EdgeInsets.only(top: 7), child: Text(DateFormat('d MMM').format(date), style: AppText.sans(8.5, c: AppColors.muted)));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
