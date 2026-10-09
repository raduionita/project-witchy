import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/period_span.dart';
import '../providers/cycle_provider.dart';
import '../services/cycle_calculator.dart';
import '../navigation/app_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_bars.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  static (String, bool) _tagFor(CycleProvider cycle, List<PeriodSpan> spans, int index) {
    // spans are newest-first; index 0 starts the cycle currently in progress.
    if (index == 0) return ('Current', false);
    final span = spans[index];
    final newer = spans[index - 1];
    final cycleLength = CycleCalculator.daysBetween(span.start, newer.start);
    final reference = cycle.effectiveCycleLength;
    if (cycleLength < reference - 2) return ('Short', true);
    if (cycleLength > reference + 2) return ('Long', true);
    return ('On Time', false);
  }

  /// Cycle-length spread card: shortest vs longest observed cycles.
  Widget _buildIrregularityCard(CycleProvider cycle) {
    final spread = cycle.cycleSpread;
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
                AppTag('$spread ${spread == 1 ? 'Day' : 'Days'} variation'),
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
    final avgCycle = cycle.meanCycleLength;
    final avgBleed = cycle.meanBleedLength;
    final observed = cycle.observedCycleLengths;
    final trendValues = [for (final len in observed.skip(observed.length > 7 ? observed.length - 7 : 0)) len.toDouble()];
    final trendLabels = [for (var i = 0; i < trendValues.length; i++) 'C${observed.length - trendValues.length + i + 1}'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        GestureDetector(
          onTap: () => context.go('/chart'),
          child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cycle Trends', style: AppText.secIn), const SizedBox(height: 10), TrendBars(values: trendValues, labels: trendLabels)])),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCard(label: '', value: avgCycle == null ? '—' : '${avgCycle.toStringAsFixed(1)} d', sub: 'Average Cycle')),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: '', value: avgBleed == null ? '—' : '${avgBleed.toStringAsFixed(1)} d', sub: 'Average Bleed')),
          ],
        ),
        const SizedBox(height: 12),
        _buildIrregularityCard(cycle),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chronology of Bleeds', style: AppText.secIn),
              if (spans.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Log a bleeding day and your chronology will bloom here.', style: AppText.sans(11.5, c: AppColors.muted)),
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
  final (String, bool) tag;
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
          tag.$2 ? AppTag.pink(tag.$1) : AppTag(tag.$1),
        ],
      ),
    );
  }
}
