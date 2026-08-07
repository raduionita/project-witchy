import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/symptom_insights.dart';
import '../../providers/symptom_provider.dart';
import '../../services/symptom_pattern_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import 'cycle_history_screen.dart';
import 'monthly_report_screen.dart';
import 'widgets/phase_distribution_chart.dart';
import 'widgets/symptom_frequency_bar_chart.dart';
import 'widgets/symptoms_over_time_chart.dart';

/// The Insights tab: symptom patterns, phase breakdowns and reports.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String? _selectedSymptom;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SymptomProvider provider = context.watch<SymptomProvider>();
    final SymptomInsights insights = provider.insights;

    final List<String> symptoms = insights.topSymptoms
        .map((SymptomFrequency f) => f.symptom)
        .toList();
    // A previously selected symptom may fall out of the top list after new
    // logs; DropdownButton asserts when its value isn't among the items.
    final String? selected = symptoms.isEmpty
        ? null
        : (symptoms.contains(_selectedSymptom) ? _selectedSymptom! : symptoms.first);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          Text(
            insights.totalLogs == 0
                ? l10n.insightsEmpty
                : l10n.insightsSummary(
                    insights.totalLogs,
                    insights.totalSymptomCount,
                  ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CycleHistoryScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: Text(l10n.cycleHistoryTitle),
                ),
              ),
              const SizedBox(width: AppSpacing.kSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MonthlyReportScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long),
                  label: Text(l10n.monthlyReportTitle),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.kMd),
          AppSectionHeader(title: l10n.insightsTopSymptoms),
          AppCard(
            child: SymptomFrequencyBarChart(frequencies: insights.topSymptoms),
          ),
          const SizedBox(height: AppSpacing.kMd),
          AppSectionHeader(title: l10n.insightsSymptomsOverTime),
          AppCard(
            child: SymptomsOverTimeChart(logs: provider.recentLogs),
          ),
          const SizedBox(height: AppSpacing.kMd),
          if (selected != null) ...[
            AppSectionHeader(
              title: l10n.insightsWhen(selected),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  items: [
                    for (final String symptom in symptoms)
                      DropdownMenuItem<String>(
                        value: symptom,
                        child: Text(symptom),
                      ),
                  ],
                  onChanged: (String? value) => setState(() {
                    _selectedSymptom = value;
                  }),
                ),
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrendLine(provider: provider, symptom: selected),
                  const SizedBox(height: AppSpacing.kMd),
                  PhaseDistributionChart(
                    breakdown: provider.breakdownFor(selected),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            _DayIndexCard(provider: provider, symptom: selected),
          ],
        ],
      ),
    );
  }
}

class _TrendLine extends StatelessWidget {
  const _TrendLine({required this.provider, required this.symptom});

  final SymptomProvider provider;
  final String symptom;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SymptomTrend trend = provider.trendFor(symptom);
    final (IconData icon, String label) = switch (trend) {
      SymptomTrend.increasing => (Icons.trending_up, l10n.trendRising),
      SymptomTrend.decreasing => (Icons.trending_down, l10n.trendFalling),
      SymptomTrend.stable => (Icons.trending_flat, l10n.trendConsistent),
      SymptomTrend.insufficient => (
          Icons.info_outline,
          l10n.trendInsufficient,
        ),
    };

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: AppSpacing.kSm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

class _DayIndexCard extends StatelessWidget {
  const _DayIndexCard({required this.provider, required this.symptom});

  final SymptomProvider provider;
  final String symptom;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<int> dayIndexes = provider.dayIndexesFor(symptom);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.insightsTypicalDay,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          if (dayIndexes.isEmpty)
            Text(
              l10n.insightsNoPattern,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            )
          else
            _strip(context, dayIndexes),
        ],
      ),
    );
  }

  Widget _strip(BuildContext context, List<int> dayIndexes) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int average =
        dayIndexes.fold<int>(0, (int sum, int v) => sum + v) ~/ dayIndexes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.insightsAverage(average, dayIndexes.first, dayIndexes.last),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.kSm),
        Wrap(
          spacing: AppSpacing.kXs,
          runSpacing: AppSpacing.kXs,
          children: [
            for (final int index in dayIndexes)
              Chip(
                label: Text(l10n.insightsDay(index)),
                labelStyle: Theme.of(context).textTheme.labelSmall,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}
