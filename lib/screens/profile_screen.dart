import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../common/date_format.dart';
import '../common/legal_links.dart';
import '../navigation/app_nav.dart';
import '../models/period_record.dart';
import '../models/period_span.dart';
import '../models/reminder_item.dart';
import '../models/cycle_condition.dart';
import '../models/tracking_mode.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/gestation_provider.dart';
import '../providers/logging_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/prefs_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/settings_row.dart';
import '../widgets/app_glyph.dart';
import '../widgets/app_slider_row.dart';
import '../widgets/app_tag.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/danger_button.dart';
import '../widgets/icon_badge.dart';
import '../widgets/info_pill.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/period_range_sheet.dart';
import '../widgets/tracking_mode_chip.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Resolved once - the screen rebuilds on every watched provider change.
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  /// Period anchor for notification scheduling; null while a pregnancy is active.
  static DateTime? _periodStart(CycleProvider cycle) => cycle.pregnancyActive ? null : cycle.nextPeriodStart();

  void _openTrackingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tracking Modes', style: AppText.secIn),
                  const SizedBox(height: 4),
                  Text('Toggle every mode you track - they can all be active at once.', style: AppText.sans(11, c: AppColors.muted)),
                  const SizedBox(height: 12),
                  Consumer<OnboardingProvider>(
                    builder: (consumerContext, ob, _) => TrackingModeChips(selected: ob.trackingModes, onToggle: (mode) => consumerContext.read<OnboardingProvider>().toggleTrackingMode(mode)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _openConditionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cycle Conditions', style: AppText.secIn),
                  const SizedBox(height: 4),
                  Text('These change how predictions are framed, never the dates you logged.', style: AppText.sans(11, c: AppColors.muted)),
                  const SizedBox(height: 12),
                  Consumer<OnboardingProvider>(
                    builder:
                        (consumerContext, ob, _) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final condition in CycleCondition.values)
                              FilterChip(
                                label: Text(condition.label),
                                selected: ob.cycleConditions.contains(condition),
                                onSelected: (_) => consumerContext.read<OnboardingProvider>().toggleCycleCondition(condition),
                              ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Edits the base cycle and bleeding lengths, then persists them; the sheet
  /// keeps a local draft so a dismissed sheet changes nothing.
  Future<void> _openRhythmSheet(BuildContext context) async {
    final onboarding = context.read<OnboardingProvider>();
    var cycleLength = onboarding.cycleLength;
    var bleedLength = onboarding.bleedLength;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => StatefulBuilder(
            builder:
                (builderContext, setSheetState) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cycle Basics', style: AppText.secIn),
                        const SizedBox(height: 4),
                        Text('Base values seed predictions until your logged cycles take over.', style: AppText.sans(11, c: AppColors.muted)),
                        const SizedBox(height: 12),
                        AppSliderRow(
                          label: 'Cycle length',
                          value: '$cycleLength Days',
                          min: OnboardingProvider.minCycleLength.toDouble(),
                          max: OnboardingProvider.maxCycleLength.toDouble(),
                          current: cycleLength.toDouble(),
                          onChanged: (v) => setSheetState(() => cycleLength = v.round()),
                        ),
                        const SizedBox(height: 4),
                        AppSliderRow(
                          label: 'Bleeding phase length',
                          value: '$bleedLength Days',
                          min: 2,
                          max: 10,
                          current: bleedLength.toDouble(),
                          onChanged: (v) => setSheetState(() => bleedLength = v.round()),
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Save',
                          onTap: () async {
                            onboarding.setCycle(cycleLength);
                            onboarding.setBleed(bleedLength);
                            await onboarding.persistRhythms();
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cycle basics updated')));
    }
  }

  Future<void> _pickReminderTime(BuildContext context, int index) async {
    final bells = context.read<RemindersProvider>();
    final item = bells.items[index];
    final parsed = _parseTime(item.time);
    final picked = await showTimePicker(context: context, initialTime: parsed);
    if (picked == null || !context.mounted) return;
    final label = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final suffix = picked.period == DayPeriod.am ? 'AM' : 'PM';
    final formatted = '${label.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $suffix';
    bells.setTime(index, formatted);
    try {
      final cycle = context.read<CycleProvider>();
      await NotificationService.syncReminder(bells.items[index], predictedStart: _periodStart(cycle), fertileStart: cycle.fertileWindowStart(), bleedLength: cycle.bleedLength);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update reminder: $e')));
      }
    }
  }

  static TimeOfDay _parseTime(String raw) {
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false).firstMatch(raw);
    if (match == null) return const TimeOfDay(hour: 9, minute: 0);
    var h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final pm = match.group(3)!.toUpperCase() == 'PM';
    if (pm && h != 12) h += 12;
    if (!pm && h == 12) h = 0;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _pickReminderFrequency(BuildContext context, int index) async {
    const options = ['Every day', 'Each bleed day', 'Window start', '3 days prior', 'Hourly · 8 AM - 8 PM'];
    final selected = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: Text('Frequency', style: AppText.serif(15)),
            children: [for (final option in options) SimpleDialogOption(onPressed: () => Navigator.of(dialogContext).pop(option), child: Text(option, style: AppText.sans(13, c: AppColors.ink)))],
          ),
    );
    if (selected == null || !context.mounted) return;
    final bells = context.read<RemindersProvider>();
    bells.setFrequency(index, selected);
    try {
      final cycle = context.read<CycleProvider>();
      await NotificationService.syncReminder(bells.items[index], predictedStart: _periodStart(cycle), fertileStart: cycle.fertileWindowStart(), bleedLength: cycle.bleedLength);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update reminder: $e')));
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Sign out?', style: AppText.serif(16)),
            content: Text('You will return to the welcome screen. Your logs and settings stay on this device, and you can sign back in at any time.', style: AppText.sans(13, c: AppColors.body)),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text('Cancel', style: AppText.sans(13, w: FontWeight.w600, c: AppColors.muted))),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text('Sign Out', style: AppText.sans(13, w: FontWeight.w700, c: AppColors.danger))),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().signOut();
    if (context.mounted) context.reset('/');
  }

  Future<void> _confirmDeleteData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Delete all data?', style: AppText.serif(16)),
            content: Text(
              'This removes every cycle log, saved setting, reminder and sign-in on this device. Witchy keeps no copy anywhere else, so it cannot be undone.',
              style: AppText.sans(13, c: AppColors.body),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text('Cancel', style: AppText.sans(13, w: FontWeight.w600, c: AppColors.muted))),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text('Delete', style: AppText.sans(13, w: FontWeight.w700, c: AppColors.danger))),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    final prefs = context.read<PrefsService>();
    final settings = context.read<SettingsProvider>();
    final reminders = context.read<RemindersProvider>();
    final cycle = context.read<CycleProvider>();

    // In-memory resets; alerts last so cycle-triggered regeneration happens first.
    context.read<AuthProvider>().resetToDefaults();
    context.read<OnboardingProvider>().resetToDefaults();
    context.read<LoggingProvider>().resetToDefaults();
    settings.resetToDefaults();
    reminders.resetToDefaults();
    context.read<GestationProvider>().resetToDefaults();
    context.read<AlertProvider>().resetToDefaults();
    // Wipe after resets too - alert regeneration may have re-saved keys.
    await prefs.clearAllData();

    try {
      await NotificationService.syncPeriodPrediction(enabled: settings.lunarNotifications, predictedStart: _periodStart(cycle));
      await NotificationService.syncAll(reminders.items, predictedStart: _periodStart(cycle), fertileStart: cycle.fertileWindowStart(), bleedLength: cycle.bleedLength);
    } catch (e) {
      debugPrint('Notification resync after data wipe failed: $e');
    }

    if (context.mounted) context.reset('/');
  }

  Widget _buildTapTarget({required VoidCallback onTap, required Widget child}) {
    return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child));
  }

  Widget _buildIdentityHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.identity?.name?.trim();
    final displayName = (name == null || name.isEmpty) ? 'Guest' : name;
    final email = auth.identity?.email?.trim();
    final local = email == null || email.isEmpty;
    final initials = (name == null || name.isEmpty) ? 'G' : displayName.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase();
    return Column(
      children: [
        AppAvatar(initials: initials, big: true),
        const SizedBox(height: 6),
        Text(displayName, style: AppText.serif(18)),
        const SizedBox(height: 2),
        if (local)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('LOCAL · CYCLE TRACKING', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
              const SizedBox(width: 5),
              AppGlyph(AppIcons.star, size: 9, color: AppColors.gold),
            ],
          )
        else
          Text(email, style: AppText.sans(10, c: AppColors.muted)),
        if (local) ...[const SizedBox(height: 4), Text('Data stored on this device only', style: AppText.sans(10, c: AppColors.muted))],
      ],
    );
  }

  Widget _buildEditableRow({required String label, required String value, required VoidCallback onTap, Widget? tag, bool first = false}) {
    return _buildTapTarget(
      onTap: onTap,
      child: SettingsRow(
        label: label,
        first: first,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tag != null) ...[tag, const SizedBox(width: 6)],
            Text(value, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)),
            const SizedBox(width: 4),
            Icon(AppIcons.right, size: 13, color: AppColors.pur),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleAveragesCard(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final conditions = onboarding.cycleConditions.isEmpty ? 'None' : onboarding.cycleConditions.map((c) => c.label).join(', ');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cycle Averages', style: AppText.secIn),
          _buildEditableRow(
            label: 'Average Cycle Length',
            value: '${cycle.effectiveCycleLength} Days',
            tag: AppTag.gold(cycle.isCycleLengthClamped ? 'Clamped' : (cycle.isCycleLengthAuto ? 'Calculated' : 'Estimated')),
            onTap: () => _openRhythmSheet(context),
            first: true,
          ),
          if (cycle.isCycleLengthClamped)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6),
              child: Text('Predictions use a 15-60 day range.', style: AppText.sans(9.5, c: AppColors.muted)),
            ),
          _buildEditableRow(label: 'Bleeding Phase Length', value: '${cycle.bleedLength} Days', onTap: () => _openRhythmSheet(context)),
          _buildEditableRow(label: 'Tracking Modes', value: onboarding.trackingModes.map((m) => m.label).join(', '), onTap: () => _openTrackingSheet(context)),
          _buildEditableRow(label: 'Cycle Conditions', value: conditions, onTap: () => _openConditionsSheet(context)),
        ],
      ),
    );
  }

  void _openPeriod(BuildContext context, LoggingProvider logging, PeriodSpan span, PeriodRecord? record) {
    if (record != null) {
      showPeriodRangeSheet(context, logging: logging, record: record);
    } else {
      showLogSheet(context, span.start);
    }
  }

  Widget _buildPeriodsCard(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final logging = context.watch<LoggingProvider>();
    final spans = [...cycle.bleeds].reversed.toList();
    final records = {for (final record in logging.periodRecords) LoggingProvider.keyFor(record.start): record};
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Past periods', style: AppText.secIn),
              TextButton(
                onPressed: () => showPeriodRangeSheet(context, logging: logging),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Add past period'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Add or edit dates you remember. Flow logs stay untouched.', style: AppText.sans(11, c: AppColors.muted)),
          const SizedBox(height: 2),
          Text('Estimated dates guide predictions but stay out of measured bleed averages.', style: AppText.sans(11, c: AppColors.muted)),
          if (spans.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 10), child: Text('No periods yet. Add one above.', style: AppText.sans(11.5, c: AppColors.muted)))
          else
            for (final span in spans.take(5)) _buildPeriodRow(context, logging, span, records[LoggingProvider.keyFor(span.start)]),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(BuildContext context, LoggingProvider logging, PeriodSpan span, PeriodRecord? record) {
    final detail = span.startOnly ? (span.estimated ? 'Estimated start' : 'Start only') : '${span.length} days';
    return GestureDetector(
      onTap: () => _openPeriod(context, logging, span, record),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(span.startOnly ? AppDate.short(span.start) : AppDate.range(span.start, span.end), style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)),
                  Text(detail, style: AppText.sans(9.5, c: AppColors.muted)),
                ],
              ),
            ),
            if (span.estimated) ...[AppTag.gold('Estimated'), const SizedBox(width: 6)],
            Icon(AppIcons.right, size: 13, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pregnancy Settings', style: AppText.secIn),
          SettingsRow(
            label: 'Pregnancy Tracker',
            trailing: _buildTapTarget(
              onTap: () => context.go('/pregnancy'),
              child: Text('View', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)),
            ),
            first: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App Settings', style: AppText.secIn),
          SettingsRow(
            label: 'Cycle Notifications',
            trailing: Switch(
              value: settings.lunarNotifications,
              activeThumbColor: AppColors.pur,
              onChanged: (v) async {
                context.read<SettingsProvider>().setLunar(v);
                final cycle = context.read<CycleProvider>();
                try {
                  await NotificationService.syncPeriodPrediction(enabled: v, predictedStart: _periodStart(cycle));
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update notifications: $e')));
                  }
                }
              },
            ),
            first: true,
          ),
          SettingsRow(label: 'Dark Mode', trailing: Switch(value: settings.darkMode, activeThumbColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setDark(v))),
        ],
      ),
    );
  }

  Widget _buildRemindersCard(BuildContext context) {
    final bells = context.watch<RemindersProvider>();
    final activeBells = bells.items.where((r) => r.enabled).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reminders', style: AppText.secIn),
          const SizedBox(height: 4),
          Text('$activeBells of ${bells.items.length} reminders active', style: AppText.sans(11.5, c: AppColors.muted)),
          const SizedBox(height: 8),
          for (var i = 0; i < bells.items.length; i++) ...[
            if (i > 0) Divider(height: 12, color: AppColors.line),
            _buildReminderRow(context, bells.items[i], i),
            if (bells.items[i].enabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  // Hourly bells ignore the time field; show frequency only.
                  if (!NotificationService.isHourly(bells.items[i])) ...[
                    _buildTapTarget(onTap: () => _pickReminderTime(context, i), child: InfoPill(icon: AppIcons.clock, label: bells.items[i].time)),
                    const SizedBox(width: 8),
                  ],
                  _buildTapTarget(onTap: () => _pickReminderFrequency(context, i), child: InfoPill(icon: bells.items[i].icon, label: bells.items[i].freq)),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReminderRow(BuildContext context, ReminderItem item, int index) {
    return Row(
      children: [
        IconBadge(icon: item.icon, bg: item.badgeBg, fg: item.badgeFg),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: AppText.serif(12.5)), Text(item.subtitle, style: AppText.sans(9.5, c: AppColors.muted))]),
        ),
        Switch(
          value: item.enabled,
          activeThumbColor: AppColors.orbSub,
          onChanged: (v) async {
            context.read<RemindersProvider>().toggle(index, v);
            final cycle = context.read<CycleProvider>();
            try {
              await NotificationService.syncReminder(item, predictedStart: _periodStart(cycle), fertileStart: cycle.fertileWindowStart(), bleedLength: cycle.bleedLength);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update reminder: $e')));
              }
            }
          },
        ),
      ],
    );
  }

  /// Plain-language answer to "where is my data and who sees it", with the one
  /// next step that matters when someone is worried: read the policy.
  Widget _buildDataCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data', style: AppText.secIn),
          SettingsRow(label: 'Where it lives', first: true, trailing: Text('On this device', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.muted))),
          SettingsRow(label: 'Shared with', trailing: Text('No one', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.muted))),
          SettingsRow(
            label: 'Your privacy policy',
            trailing: _buildTapTarget(
              onTap: () => context.go(LegalLinks.route('Privacy Policy', LegalLinks.privacy)),
              child: Text('Read', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session', style: AppText.secIn),
          const SizedBox(height: 10),
          AppButton(label: 'Sign Out', onTap: () => _confirmSignOut(context)),
          const SizedBox(height: 10),
          DangerButton(label: 'Delete All Data', onTap: () => _confirmDeleteData(context)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snap) {
          final version = snap.data?.version ?? '1.0.0';
          return Text('Witchy\nVersion $version', textAlign: TextAlign.center, style: AppText.sans(9.5, c: AppColors.placeholder, h: 1.6));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    return Scaffold(
      appBar: AppTopBar(title: 'Profile', action: AppIcons.alerts, onAction: () => context.go('/alerts'), badge: context.watch<AlertProvider>().unreadCount > 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          _buildIdentityHeader(context),
          const SizedBox(height: 12),
          _buildCycleAveragesCard(context),
          const SizedBox(height: 12),
          _buildPeriodsCard(context),
          const SizedBox(height: 12),
          if (onboarding.trackingModes.contains(TrackingMode.pregnancy)) ...[_buildPregnancyCard(context), const SizedBox(height: 12)],
          _buildAppSettingsCard(context),
          const SizedBox(height: 12),
          _buildRemindersCard(context),
          const SizedBox(height: 12),
          _buildDataCard(context),
          const SizedBox(height: 12),
          _buildSessionCard(context),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }
}
