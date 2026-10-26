import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../models/period_record.dart';
import '../models/period_span.dart';
import '../models/trend_direction.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/cycle_calculator.dart';
import '../services/period_history.dart';
import '../navigation/app_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_dims.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_bars.dart';
import '../widgets/add_past_period_button.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';
import '../widgets/period_range_sheet.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  /// Absolute clinical bands keep a 23-day cycle from being called Short just
  /// because it is shorter than the surrounding cycles.
  static (String, Color?, Color?) _tagFor(List<PeriodSpan> spans, int index) {
    // spans are newest-first; index 0 starts the cycle currently in progress.
    if (index == 0) return ('Current', null, null);
    final span = spans[index];
    final newer = spans[index - 1];
    final cycleLength = CycleCalculator.daysBetween(span.start, newer.start);
    if (cycleLength < 21) {
      return ('Short - $cycleLength days', AppColors.goldBg, AppColors.readableOn(AppColors.gold, AppColors.goldBg));
    }
    if (cycleLength > 35) {
      return ('Long - $cycleLength days', AppColors.pinkBg, AppColors.pinkDark);
    }
    return ('Typical - $cycleLength days', null, null);
  }

  /// Cycle-length spread card: shortest vs longest observed cycles + status.
  Widget _buildIrregularityCard(BuildContext context, CycleProvider cycle) {
    final spread = cycle.cycleSpread;
    final irregular = (spread ?? 0) > 7;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Irregularity', style: AppText.secIn),
          const SizedBox(height: 8),
          if (spread == null) ...[
            Text('Log two completed cycles to see your spread.', style: AppText.sans(11.5, c: AppColors.muted)),
            if (cycle.bleeds.isNotEmpty)
              TextButton(
                key: const Key('irregularity-cta'),
                onPressed: () => showLogSheet(context, DateTime.now()),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Log a period'),
              ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${cycle.shortestCycleLength}–${cycle.longestCycleLength} Days', style: AppText.serif(16)),
                      const SizedBox(height: 2),
                      Text('Shortest to longest cycle', style: AppText.sans(10.5, c: AppColors.muted)),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Variation is longest minus shortest over your last 6 cycles. Above 7 days is marked Irregular.',
                  child: AppTag.gold('${irregular ? 'Irregular' : 'Regular'} · $spread Days'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Directional card that compares recent values with the prior window.
  Widget _buildTrendsCard(CycleProvider cycle) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What Changed', style: AppText.secIn),
          const SizedBox(height: 4),
          Text('Last three compared with the three before.', style: AppText.sans(10.5, c: AppColors.muted)),
          const SizedBox(height: 6),
          for (final trend in cycle.trends)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trend.label, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)),
                        const SizedBox(height: 2),
                        Text(trend.detail, style: AppText.sans(9.5, c: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _trendTag(trend.direction),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _trendTag(TrendDirection direction) {
    return switch (direction) {
      TrendDirection.up => AppTag.gold(direction.label),
      TrendDirection.down => AppTag(direction.label, bg: AppColors.pinkBg, fg: AppColors.pinkDark),
      TrendDirection.stable => AppTag(direction.label),
      TrendDirection.insufficient => AppTag(direction.label),
    };
  }

  Widget _buildSnapshotCard(CycleProvider cycle) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prediction History', style: AppText.secIn),
          const SizedBox(height: 4),
          Text('Saved when each cycle began. Later logs do not rewrite them.', style: AppText.sans(10.5, c: AppColors.muted)),
          const SizedBox(height: 6),
          for (final snapshot in cycle.predictionHistory.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppDate.range(snapshot.earliest, snapshot.latest), style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)),
                        const SizedBox(height: 2),
                        Text('Cycle started ${AppDate.short(snapshot.cycleStart)}', style: AppText.sans(9.5, c: AppColors.muted)),
                      ],
                    ),
                  ),
                  if (snapshot.peak != null) AppTag.gold('Peak ${AppDate.short(snapshot.peak!)}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Hero empty state for a brand-new tracker: states the two-cycle
  /// requirement and gives one clear next step instead of four grey
  /// placeholders. The preview cards below stay so the user can see what will
  /// fill in.
  Widget _buildNeedsDataState(BuildContext context) {
    return EmptyState(
      icon: AppIcons.cal,
      title: 'No cycles yet',
      message: 'Insights build from your bleeding days. Two completed cycles unlock your trends, averages and cycle spread.',
      actionLabel: 'Log your period',
      onAction: () => showLogSheet(context, DateTime.now()),
      compact: true,
    );
  }

  void _openPeriod(
    BuildContext context,
    LoggingProvider logging,
    PeriodSpan span,
    PeriodRecord? record,
  ) {
    if (record != null) {
      showPeriodRangeSheet(context, logging: logging, record: record);
    } else {
      showLogSheet(context, span.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final logging = context.watch<LoggingProvider>();
    final records = {
      for (final record in logging.periodRecords)
        LoggingProvider.keyFor(record.start): record,
    };
    final spans = [...cycle.bleeds].reversed.toList();
    final avgCycle = cycle.effectiveCycleLength;
    final typicalBleed = cycle.medianBleedLength;
    final observed = cycle.observedCycleLengths;
    final starts = PeriodHistory.startsOf(cycle.bleeds);
    final trendValues = [for (final len in observed.skip(observed.length > 7 ? observed.length - 7 : 0)) len.toDouble()];
    // Start date of each observed cycle keeps repeated months distinguishable.
    final skip = observed.length - trendValues.length;
    final trendLabels = [
      for (var i = 0; i < trendValues.length; i++)
        AppDate.short(starts[skip + i]),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, AppDims.fabClearance),
      children: [
        if (spans.isEmpty) ...[_buildNeedsDataState(context), const SizedBox(height: 16)],
        GestureDetector(
          onTap: () => context.go('/chart'),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Cycle Trends', style: AppText.secIn), Text('Days', style: AppText.sans(10, c: AppColors.muted))],
                ),
                const SizedBox(height: 10),
                TrendBars(values: trendValues, labels: trendLabels),
                if (trendValues.length < 2 && spans.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AppButton(
                      key: const Key('cycle-trends-cta'),
                      label: 'Log your period',
                      onTap: () => showLogSheet(context, DateTime.now()),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: '',
                value: '$avgCycle days',
                sub: cycle.isCycleLengthAuto ? 'Average Cycle' : 'Average Cycle - Estimated',
                onTap: () => context.go('/chart'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: '', value: typicalBleed == null ? '-' : '$typicalBleed days', sub: 'Typical Bleeding', onTap: () => context.go('/bleed-history'))),
          ],
        ),
        const SizedBox(height: 12),
        _buildIrregularityCard(context, cycle),
        const SizedBox(height: 12),
        _buildTrendsCard(cycle),
        if (cycle.predictionHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSnapshotCard(cycle),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Period History', style: AppText.secIn),
                  AddPastPeriodButton(onTap: () => showPeriodRangeSheet(context, logging: logging)),
                ],
              ),
              const SizedBox(height: 6),
              if (spans.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Log a bleeding day and your period history will appear here.', style: AppText.sans(11.5, c: AppColors.muted)),
                )
              else
                for (var i = 0; i < spans.length; i++)
                  _BleedRow(
                    span: spans[i],
                    tag: _tagFor(spans, i),
                    onTap: () => _openPeriod(context, logging, spans[i], records[LoggingProvider.keyFor(spans[i].start)]),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BleedRow extends StatelessWidget {
  final PeriodSpan span;
  final (String, Color?, Color?) tag;
  final VoidCallback onTap;
  const _BleedRow({required this.span, required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final range = span.startOnly ? AppDate.short(span.start) : AppDate.range(span.start, span.end);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(range, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)),
                Text(
                  span.startOnly ? (span.estimated ? 'Estimated start' : 'Start only') : '${span.length} Days',
                  style: AppText.sans(9.5, c: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: AppTag(tag.$1, bg: tag.$2, fg: tag.$3)),
                    const SizedBox(width: 4),
                    Icon(AppIcons.right, size: 13, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
