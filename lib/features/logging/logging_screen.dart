import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/flow_intensity.dart';
import '../../models/period_log.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import 'log_period_sheet.dart';

/// The Logging tab: quick entry + history of recent logs.
class LoggingScreen extends StatefulWidget {
  const LoggingScreen({super.key, this.onOpenCalendar});

  /// Invoked when the user asks to log from the calendar, so the shell can
  /// switch to the Calendar tab. Falls back to a hint when null.
  final VoidCallback? onOpenCalendar;

  @override
  State<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends State<LoggingScreen> {
  Future<void> _openSheetForToday() async {
    await LogPeriodSheet.show(context: context, date: DateTime.now());
  }

  void _openCalendar(BuildContext context) {
    final VoidCallback? onOpen = widget.onOpenCalendar;
    if (onOpen != null) {
      onOpen();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).loggingUseCalendar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CycleProvider provider = context.watch<CycleProvider>();
    final List<PeriodLog> recent = provider.recentPeriodLogs;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.loggingLogPeriod),
                  subtitle: Text(l10n.loggingLogPeriodSubtitle),
                  onTap: _openSheetForToday,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit_calendar),
                  title: Text(l10n.loggingLogFromCalendar),
                  subtitle: Text(l10n.loggingLogFromCalendarSubtitle),
                  onTap: () => _openCalendar(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          AppSectionHeader(title: l10n.loggingRecentLogs),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.kLg),
              child: Text(
                l10n.loggingEmpty,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
                      if (log.intensity != null)
                        flowIntensityLabel(l10n, log.intensity!),
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
