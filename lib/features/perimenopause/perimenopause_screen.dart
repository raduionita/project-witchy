import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/symptom_log.dart';
import '../../providers/symptom_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import '../trackers/shared_tracker_text.dart';
import 'perimenopause_catalog.dart';

/// Home content for perimenopause tracking mode.
///
/// Uses the shared symptom logger but with a curated, stage-specific symptom
/// catalog. Insights reuse the existing symptom pattern analysis.
class PerimenopauseScreen extends StatelessWidget {
  const PerimenopauseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SymptomProvider provider = context.watch<SymptomProvider>();
    final List<SymptomLog> recent = provider.recentLogs.take(5).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          Text(
            'Perimenopause',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          _logCard(context),
          const SizedBox(height: AppSpacing.kMd),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your summary',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.kSm),
                Text(
                  TrackerInsightText.perimenopauseSummary(provider.insights),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          const AppSectionHeader(title: 'Recent logs'),
          if (recent.isEmpty)
            Text(
              'No symptom logs yet in this stage.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            )
          else
            for (final SymptomLog log in recent)
              _logTile(context, log),
          const SizedBox(height: AppSpacing.kMd),
          Text(
            TrackerInsightText.disclaimer(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _logCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log today',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            'Tap a symptom to log it for today.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          for (final PerimenopauseCategory category in kPerimenopauseCategories)
            _categorySection(context, category),
        ],
      ),
    );
  }

  Widget _categorySection(BuildContext context, PerimenopauseCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.kMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          Wrap(
            spacing: AppSpacing.kSm,
            runSpacing: AppSpacing.kSm,
            children: category.symptoms
                .map(
                  (String symptom) => ActionChip(
                    avatar: Icon(
                      Icons.add,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(symptom),
                    onPressed: () async {
                      final SymptomProvider provider =
                          context.read<SymptomProvider>();
                      await provider.logSymptoms(
                        dateOnly(DateTime.now()),
                        symptoms: <String>[symptom],
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('"$symptom" logged for today.')),
                        );
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _logTile(BuildContext context, SymptomLog log) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.kMd,
        vertical: AppSpacing.kSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: AppSpacing.kMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(log.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (log.symptoms.isNotEmpty)
                  Text(
                    log.symptoms.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
