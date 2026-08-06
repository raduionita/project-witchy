import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/period_log.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import 'log_period_sheet.dart';

/// The Logging tab: quick entry + history of recent logs.
class LoggingScreen extends StatefulWidget {
  const LoggingScreen({super.key});

  @override
  State<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends State<LoggingScreen> {
  Future<void> _openSheetForToday() async {
    await LogPeriodSheet.show(context: context, date: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final CycleProvider provider = context.watch<CycleProvider>();
    final List<PeriodLog> recent = provider.recentPeriodLogs;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          Text(
            'Logging',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Log period'),
                  subtitle: const Text('Flow, symptoms, mood and notes'),
                  onTap: _openSheetForToday,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit_calendar),
                  title: const Text('Log from calendar'),
                  subtitle: const Text('Pick a day to log or edit'),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use the Calendar tab to pick a day.')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          const AppSectionHeader(title: 'Recent logs'),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.kLg),
              child: Text(
                'No logs yet. Tap "Log period" to get started.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final PeriodLog log in recent) _logTile(context, log),
        ],
      ),
    );
  }

  Widget _logTile(BuildContext context, PeriodLog log) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd, vertical: AppSpacing.kSm),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.kMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(log.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (log.intensity != null || log.symptoms.isNotEmpty)
                  Text(
                    [
                      if (log.intensity != null) log.intensity!.name,
                      ...log.symptoms,
                    ].join(' · '),
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