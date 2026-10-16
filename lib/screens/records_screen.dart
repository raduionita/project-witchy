import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/period_span.dart';
import '../providers/cycle_provider.dart';
import '../services/cycle_calculator.dart';
import '../services/period_history.dart';
import '../navigation/app_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_dims.dart';
import '../theme/app_text_styles.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_bars.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  /// Short/Long vs a robust reference: median of the other observed cycles,
  /// so one outlier (e.g. a 49-day cycle) does not drag its own tag threshold.
  static (String, Color?, Color?) _tagFor(CycleProvider cycle, List<PeriodSpan> spans, int index) {
    // spans are newest-first; index 0 starts the cycle currently in progress.
    if (index == 0) return ('Current', null, null);
    final span = spans[index];
    final newer = spans[index - 1];
    final cycleLength = CycleCalculator.daysBetween(span.start, newer.start);
    final others = [...cycle.observedCycleLengths];
    // Remove one instance of this cycle's length (it may appear multiple times).
    others.remove(cycleLength);
    final reference = others.isNotEmpty ? PeriodHistory.median(others) ?? cycle.effectiveCycleLength : cycle.effectiveCycleLength;
    if (cycleLength < reference - 2) return ('Short - $cycleLength days', AppColors.goldBg, AppColors.readableOn(AppColors.gold, AppColors.goldBg));
    if (cycleLength > reference + 2) return ('Long - $cycleLength days', AppColors.pinkBg, AppColors.pinkDark);
    return ('On Time - $cycleLength days', null, null);
  }

  /// Cycle-length spread card: shortest vs longest observed cycles + status.
  Widget _buildIrregularityCard(CycleProvider cycle) {
    final spread = cycle.cycleSpread;
    final irregular = (spread ?? 0) > 7;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Irregularity', style: AppText.secIn),
          const SizedBox(height: 8),
          if (spread == null)
            Text('Log two completed cycles to see your spread.', style: AppText.sans(11.5, c: AppColors.muted))
          else
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

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final spans = [...cycle.bleeds].reversed.toList();
    final avgCycle = cycle.medianRecentCycleLength;
    final avgBleed = cycle.meanBleedLength;
    final observed = cycle.observedCycleLengths;
    final starts = PeriodHistory.startsOf(cycle.bleeds);
    final trendValues = [for (final len in observed.skip(observed.length > 7 ? observed.length - 7 : 0)) len.toDouble()];
    // Month label of the cycle start for each observed length.
    final monthFmt = DateFormat('MMM');
    final skip = observed.length - trendValues.length;
    final trendLabels = [
      for (var i = 0; i < trendValues.length; i++)
        monthFmt.format(starts[skip + i]),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, AppDims.fabClearance),
      children: [
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCard(label: '', value: avgCycle == null ? '—' : '$avgCycle days', sub: 'Average Cycle', onTap: () => context.go('/chart'))),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: '', value: avgBleed == null ? '—' : '${avgBleed.round()} days', sub: 'Average Bleeding', onTap: () => context.go('/bleeding'))),
          ],
        ),
        const SizedBox(height: 12),
        _buildIrregularityCard(cycle),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Period History', style: AppText.secIn),
              if (spans.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Log a bleeding day and your period history will appear here.', style: AppText.sans(11.5, c: AppColors.muted)),
                )
              else
                for (var i = 0; i < spans.length; i++) _BleedRow(span: spans[i], tag: _tagFor(cycle, spans, i)),
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
  const _BleedRow({required this.span, required this.tag});

  @override
  Widget build(BuildContext context) {
    final range = '${DateFormat('MMM d').format(span.start)} – ${DateFormat('MMM d').format(span.end)}';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(range, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)), Text('${span.length} Days', style: AppText.sans(9.5, c: AppColors.muted))],
          ),
          const SizedBox(width: 8),
          Flexible(child: Align(alignment: Alignment.centerRight, child: AppTag(tag.$1, bg: tag.$2, fg: tag.$3))),
        ],
      ),
    );
  }
}
