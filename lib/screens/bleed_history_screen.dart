import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../common/log_data.dart';
import '../models/period_span.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/cycle_calculator.dart';
import '../services/period_history.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/stat_card.dart';

/// Bleeding detail page behind Today's "Bleeding In" and Insights'
/// "Average Bleed" stat cards: countdown, today's status, and the flow log.
class BleedHistoryScreen extends StatelessWidget {
  const BleedHistoryScreen({super.key});

  /// Countdown + average duration duo at the top of the page.
  Widget _buildStatsRow(CycleProvider cycle) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? next = cycle.nextPeriodStart(today: now);
    final daysUntil = cycle.daysUntilPeriod(today: now);
    String bleedValue;
    String bleedSub;
    final range = cycle.predictedRange(today: now);
    final late = cycle.daysLate(today: now);
    if (next == null || range == null) {
      bleedValue = 'Log to update';
      bleedSub = 'cycle running long - log to re-anchor';
    } else if (late > 0) {
      bleedValue = '$late ${late == 1 ? 'Day' : 'Days'} Late';
      bleedSub = 'log your period to re-anchor';
    } else if (cycle.showPeriodRange) {
      final dMin = CycleCalculator.daysBetween(today, range.earliest);
      final dMax = CycleCalculator.daysBetween(today, range.latest);
      bleedValue = dMin == dMax ? '$dMin Days' : '$dMin–$dMax Days';
      bleedSub = '${AppDate.range(range.earliest, range.latest)} · range';
    } else {
      bleedValue = daysUntil <= 0 ? 'Today' : 'In $daysUntil Days';
      bleedSub = '${AppDate.short(next)} · predicted';
    }
    final avgBleed = cycle.meanBleedLength;
    return Row(
      children: [
        Expanded(child: StatCard(label: 'Bleeding In', value: bleedValue, sub: bleedSub)),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Average Bleed',
            value: avgBleed == null ? '—' : '${avgBleed.toStringAsFixed(1)} Days',
            sub: cycle.bleeds.isEmpty ? 'No periods logged yet' : 'Across ${cycle.bleeds.length} periods',
          ),
        ),
      ],
    );
  }

  /// Today's bleeding status plus the shortcut into the log sheet.
  Widget _buildTodayCard(BuildContext context, CycleProvider cycle) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bleeding = cycle.hasLoggedBleedOn(today);
    final expected = !bleeding && cycle.isPeriodDay(today);
    final String title = bleeding ? 'Bleeding today' : expected ? 'Bleed expected today' : 'Not bleeding today';
    String detail;
    if (bleeding) {
      final day = cycle.bleedDayOf(today);
      detail = day > 0 ? 'Logged as bleed day $day.' : 'A bleeding day is logged.';
    } else if (expected) {
      detail = 'Your cycle predicts a bleed starting today. Log it once flow starts.';
    } else {
      // The stats row above already carries the next-bleed countdown, so this
      // line answers the other question: where the user is in the cycle now.
      final day = cycle.cycleDay(today: now);
      detail = cycle.projectionStopped(today: now)
          ? 'Cycle day $day. Predictions pause until you log your next period.'
          : 'Cycle day $day, counted from your last period start on ${AppDate.short(cycle.effectiveLastStart)}.';
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.secIn),
          const SizedBox(height: 6),
          Text(detail, style: AppText.sans(11.5, c: AppColors.chipText, h: 1.55)),
          const SizedBox(height: 12),
          AppButton(label: 'Log flow for today', onTap: () => showLogSheet(context, today, scrollTo: LogData.flows)),
        ],
      ),
    );
  }

  /// Newest-first list of logged bleed spans.
  Widget _buildHistoryCard(CycleProvider cycle) {
    final spans = [...cycle.bleeds].reversed.toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Periods', style: AppText.secIn),
          if (spans.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Log a bleeding day and your periods will appear here.', style: AppText.sans(11.5, c: AppColors.muted)),
            )
          else
            for (final span in spans.take(5)) _BleedRow(span: span),
        ],
      ),
    );
  }

  /// Every day with a flow level logged, tapping reopens the log sheet.
  Widget _buildFlowLogCard(BuildContext context, LoggingProvider logging) {
    final entries = logging.snapshot().entries.where((e) => e.value.flow.isNotEmpty).toList()..sort((a, b) => b.key.compareTo(a.key));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flow Log', style: AppText.secIn),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('No flow logged yet. Tap a day to record Light, Medium, Heavy or Spotting.', style: AppText.sans(11.5, c: AppColors.muted)),
            )
          else
            for (final e in entries.take(10)) _FlowRow(date: e.key, flow: e.value.flow, onTap: () => showLogSheet(context, e.key, scrollTo: LogData.flows)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final logging = context.watch<LoggingProvider>();
    return Scaffold(
      appBar: const AppTopBar(title: 'Bleeding'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          const SizedBox(height: 8),
          _buildStatsRow(cycle),
          const SizedBox(height: 12),
          _buildTodayCard(context, cycle),
          const SizedBox(height: 12),
          _buildHistoryCard(cycle),
          const SizedBox(height: 12),
          _buildFlowLogCard(context, logging),
        ],
      ),
    );
  }
}

class _BleedRow extends StatelessWidget {
  final PeriodSpan span;
  const _BleedRow({required this.span});

  @override
  Widget build(BuildContext context) {
    final range = AppDate.range(span.start, span.end);
    // Days seeded from onboarding history are estimates until logged by hand;
    // spans under the period threshold are spotting, never a real period.
    final estimated = span.estimated;
    final spotting = !span.startOnly && span.length < PeriodHistory.minSpanDays;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(child: Text(range, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink))),
                if (estimated) ...[
                  const SizedBox(width: 8),
                  AppTag('Estimated'),
                ],
              ],
            ),
          ),
          Text(span.startOnly ? (span.estimated ? 'Estimated start' : 'Start only') : (spotting ? 'Spotting' : '${span.length} Days'), style: AppText.sans(10.5, c: AppColors.muted)),
        ],
      ),
    );
  }
}

class _FlowRow extends StatelessWidget {
  final DateTime date;
  final Set<String> flow;
  final VoidCallback onTap;
  const _FlowRow({required this.date, required this.flow, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppDate.weekdayShort(date), style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)),
              Text(flow.join(', '), style: AppText.sans(10.5, c: AppColors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
