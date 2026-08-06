import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/cycle.dart';
import '../../models/cycle_stats.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/cycle_history_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import 'widgets/cycle_length_chart.dart';

/// Lists every tracked cycle with aggregate metrics and a length trend chart.
class CycleHistoryScreen extends StatelessWidget {
  const CycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppStateProvider state = context.watch<AppStateProvider>();
    final CycleProvider cycleProvider = context.watch<CycleProvider>();

    final CycleHistoryService service = CycleHistoryService();
    final List<Cycle> cycles = service.deriveCycles(state.logs.periodLogs.items);
    final CycleMetrics metrics = service.computeMetrics(cycles);
    final PredictionAccuracy accuracy =
        service.computePredictionAccuracy(cycles);
    final List<CycleLengthPoint> points = service.cycleLengthPoints(cycles);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cycleHistoryTitle)),
      body: cycles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.kLg),
                child: Text(
                  l10n.cycleHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.kMd),
              children: [
                _metricsCard(context, metrics, accuracy),
                const SizedBox(height: AppSpacing.kMd),
                AppSectionHeader(title: l10n.cycleLengthTrendTitle),
                _chartCard(context, points),
                const SizedBox(height: AppSpacing.kMd),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.kMd,
                    vertical: AppSpacing.kSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.nextPeriodPredicted,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        cycleProvider.prediction == null
                            ? '—'
                            : DateFormat('MMM d').format(
                                cycleProvider.prediction!.nextPeriodStart),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.kMd),
                AppSectionHeader(title: l10n.cycleHistoryCycles),
                for (final Cycle cycle in cycles) _cycleCard(context, cycle),
              ],
            ),
    );
  }

  Widget _metricsCard(
    BuildContext context,
    CycleMetrics metrics,
    PredictionAccuracy accuracy,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cycleHistoryGlance,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          _metric(l10n, _round(l10n, metrics.averageLength), l10n.metricAverageLength),
          _metric(
            l10n,
            metrics.cycleCount.toString(),
            l10n.metricCompletedCycles,
          ),
          _metric(
            l10n,
            '${metrics.shortestLength}–${metrics.longestLength}',
            l10n.metricRange,
          ),
          _metric(
            l10n,
            accuracy.averageErrorDays == null
                ? '—'
                : l10n.metricAccuracyDays(
                    accuracy.averageErrorDays!.round(),
                  ),
            l10n.metricPredictionAccuracy,
          ),
        ],
      ),
    );
  }

  Widget _metric(AppLocalizations l10n, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context, List<CycleLengthPoint> points) {
    return AppCard(child: CycleLengthChart(points: points));
  }

  Widget _cycleCard(BuildContext context, Cycle cycle) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int? length = cycle.length;
    final String start = DateFormat('MMM d, yyyy').format(cycle.startDate);
    final String range = cycle.endDate == null
        ? start
        : '$start – ${DateFormat('MMM d, yyyy').format(cycle.endDate!)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.kSm),
      child: AppCard(
        child: ListTile(
          leading: Icon(
            Icons.calendar_view_day,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            length == null ? l10n.cycleCurrent : l10n.cycleLengthDays(length),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(range),
        ),
      ),
    );
  }

  String _round(AppLocalizations l10n, double? value) =>
      value == null ? '—' : l10n.cycleLengthDays(value.round());
}