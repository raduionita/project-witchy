import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';
import '../../models/reminder_type.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import 'reminder_defaults.dart';
import 'reminder_provider.dart';
import 'widgets/reminder_editor_sheet.dart';

/// Manages the user's reminders and their notification permissions.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Best-effort permission request so the fallback UI can reflect the real
    // platform state on first open.
    context.read<ReminderProvider>().ensurePermissions();
  }

  Future<void> _create() async {
    final ReminderProvider provider = context.read<ReminderProvider>();
    final Reminder? result = await ReminderEditorSheet.show(context);
    if (result == null) return;
    await provider.save(result);
  }

  Future<void> _edit(Reminder reminder) async {
    final ReminderProvider provider = context.read<ReminderProvider>();
    final Reminder? result =
        await ReminderEditorSheet.show(context, reminder: reminder);
    if (result == null) return;
    await provider.save(result);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ReminderProvider provider = context.watch<ReminderProvider>();
    final List<Reminder> reminders = provider.reminders;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add_alarm),
        label: Text(l10n.remindersNew),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kMd),
          children: [
            if (!provider.permissionGranted)
              _permissionCard(context, provider)
            else
              _hintCard(context),
            const SizedBox(height: AppSpacing.kMd),
            if (reminders.isEmpty)
              _emptyState(context)
            else ...[
              AppSectionHeader(title: l10n.remindersYour),
              const SizedBox(height: AppSpacing.kSm),
              for (final Reminder reminder in reminders)
                _reminderTile(context, reminder),
            ],
          ],
        ),
      ),
    );
  }

  Widget _permissionCard(BuildContext context, ReminderProvider provider) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_off_outlined, color: scheme.error),
              const SizedBox(width: AppSpacing.kMd),
              Expanded(
                child: Text(
                  l10n.remindersNotificationsOff,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            l10n.remindersNotificationsOffBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.kMd),
          FilledButton.icon(
            onPressed: () => provider.requestPermissions(),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(l10n.remindersEnable),
          ),
        ],
      ),
    );
  }

  Widget _hintCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.kMd),
          Expanded(
            child: Text(
              l10n.remindersHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add_alarm,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            l10n.remindersEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kXs),
          Text(
            l10n.remindersEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _reminderTile(BuildContext context, Reminder reminder) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ReminderProvider provider = context.read<ReminderProvider>();
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SwitchListTile(
            value: reminder.enabled,
            onChanged: (bool enabled) => provider.setEnabled(reminder.id, enabled),
            secondary: Icon(
              _typeIcon(reminder.type),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              reminder.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _subtitle(context, reminder),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => _edit(reminder),
                child: Text(l10n.remindersEdit),
              ),
              TextButton(
                onPressed: () => provider.remove(reminder.id),
                child: Text(
                  l10n.remindersDelete,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle(BuildContext context, Reminder reminder) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (ReminderDefaults.isPeriodBased(reminder.type)) {
      final DateTime? next = context
          .watch<CycleProvider>()
          .prediction
          ?.nextPeriodStart;
      if (next != null) {
        return l10n.remindersBasedOnPrediction(DateFormat('MMM d').format(next));
      }
      return l10n.remindersFollowsPrediction;
    }
    final List<String> days =
        reminder.weekday.map((int day) => _dayLabel(l10n, day)).toList();
    final String time = DateFormat('h:mm a').format(
      DateTime(2000, 1, 1, reminder.time.hour, reminder.time.minute),
    );
    return l10n.remindersEveryAt(days.join(', '), time);
  }

  String _dayLabel(AppLocalizations l10n, int weekday) => switch (weekday) {
        1 => l10n.weekdayMon,
        2 => l10n.weekdayTue,
        3 => l10n.weekdayWed,
        4 => l10n.weekdayThu,
        5 => l10n.weekdayFri,
        6 => l10n.weekdaySat,
        _ => l10n.weekdaySun,
      };

  IconData _typeIcon(ReminderType type) => switch (type) {
        ReminderType.periodStart => Icons.water_drop,
        ReminderType.periodEnd => Icons.water_drop_outlined,
        ReminderType.medication => Icons.medication_outlined,
        ReminderType.water => Icons.local_drink_outlined,
        ReminderType.sleep => Icons.bedtime_outlined,
        ReminderType.custom => Icons.alarm,
      };
}
