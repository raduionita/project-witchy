import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/cycle.dart';
import '../../models/cycle_prediction.dart';
import '../../models/cycle_stats.dart';
import '../../models/flow_intensity.dart';
import '../../models/period_log.dart';
import '../../models/symptom_insights.dart';
import '../../models/symptom_log.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/symptom_provider.dart';
import '../../services/cycle_history_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';

/// Summary of the current month: period, predicted next period, top symptoms.
class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppStateProvider state = context.watch<AppStateProvider>();
    final CycleProvider cycleProvider = context.watch<CycleProvider>();
    final SymptomProvider symptomProvider = context.watch<SymptomProvider>();

    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1);
    final DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final List<PeriodLog> periodLogs = _logsInRange(
      state.logs.periodLogs.items,
      monthStart,
      nextMonthStart,
    );
    final List<SymptomLog> symptomLogs = _logsInRange(
      state.logs.symptomLogs.items,
      monthStart,
      nextMonthStart,
    );

    final int periodDays = periodLogs.length;
    final int symptomDays = symptomLogs.length;

    final CycleHistoryService history = CycleHistoryService();
    final List<Cycle> cycles =
        history.deriveCycles(state.logs.periodLogs.items);
    final CycleMetrics metrics = history.computeMetrics(cycles);
    final PredictionAccuracy accuracy =
        history.computePredictionAccuracy(cycles);
    final List<String> topSymptoms = symptomProvider.insights.topSymptoms
        .take(3)
        .map((SymptomFrequency f) => f.symptom)
        .toList();
    final Set<DateTime> periodDaysSet = {
      for (final PeriodLog log in periodLogs) dateOnly(log.date),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(now)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportThisMonth,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.kSm),
                _row(
                  context,
                  Icons.water_drop,
                  l10n.reportPeriodDays,
                  '$periodDays',
                ),
                _row(
                  context,
                  Icons.track_changes,
                  l10n.nextPeriodPredicted,
                  cycleProvider.prediction == null
                      ? '—'
                      : DateFormat('MMM d')
                          .format(cycleProvider.prediction!.nextPeriodStart),
                ),
                _row(
                  context,
                  Icons.insights,
                  l10n.reportDaysLogged,
                  '$symptomDays',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportCycleMetrics,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.kSm),
                _row(
                  context,
                  Icons.timelapse,
                  l10n.reportAverageCycleLength,
                  metrics.averageLength == null
                      ? '—'
                      : l10n.cycleLengthDays(metrics.averageLength!.round()),
                ),
                _row(
                  context,
                  Icons.link,
                  l10n.metricCompletedCycles,
                  '${metrics.cycleCount}',
                ),
                _row(
                  context,
                  Icons.gps_fixed,
                  l10n.metricPredictionAccuracy,
                  accuracy.averageErrorDays == null
                      ? '—'
                      : l10n.metricAccuracyDays(
                          accuracy.averageErrorDays!.round(),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          if (topSymptoms.isNotEmpty) ...[
            _section(context, l10n.reportMostLogged),
            const SizedBox(height: AppSpacing.kSm),
            Wrap(
              spacing: AppSpacing.kSm,
              runSpacing: AppSpacing.kSm,
              children: [
                for (final String symptom in topSymptoms)
                  Chip(label: Text(symptom)),
              ],
            ),
            const SizedBox(height: AppSpacing.kMd),
          ],
          _section(context, l10n.reportLogs),
          const SizedBox(height: AppSpacing.kSm),
          if (periodLogs.isEmpty && symptomLogs.isEmpty)
            Text(
              l10n.reportNoLogs,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            )
          else
            for (final PeriodLog log in periodLogs)
              _periodTile(context, log),
          for (final SymptomLog log in symptomLogs)
            if (!periodDaysSet.contains(dateOnly(log.date)))
              _symptomTile(context, log),
          const SizedBox(height: AppSpacing.kMd),
          AppCard(
            child: Text(
              _predictionBlurb(context, cycleProvider.prediction),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 14,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: AppSpacing.kXs),
              Flexible(
                child: Text(
                  l10n.reportLocalOnly,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<T> _logsInRange<T>(Iterable<T> items, DateTime start, DateTime end) {
    return items.where(
      (T item) {
        final DateTime date = item is PeriodLog
            ? item.date
            : (item as SymptomLog).date;
        return !date.isBefore(start) && date.isBefore(end);
      },
    ).toList();
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.kSm),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _periodTile(BuildContext context, PeriodLog log) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.water_drop,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(DateFormat('EEE, MMM d').format(log.date)),
      subtitle: Text([
        if (log.intensity != null) flowIntensityLabel(l10n, log.intensity!),
        ...log.symptoms,
      ].join(' · ')),
    );
  }

  Widget _symptomTile(BuildContext context, SymptomLog log) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.savings_outlined),
      title: Text(DateFormat('EEE, MMM d').format(log.date)),
      subtitle: Text(log.symptoms.join(' · ')),
    );
  }

  String _predictionBlurb(BuildContext context, CyclePrediction? prediction) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return prediction == null
        ? l10n.reportPredictionEmpty
        : l10n.reportPrediction(
            DateFormat('MMMM d').format(prediction.nextPeriodStart),
            DateFormat('MMM d').format(prediction.fertileWindow.start),
            DateFormat('MMM d').format(prediction.fertileWindow.end),
          );
  }
}