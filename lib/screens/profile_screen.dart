import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../navigation/app_nav.dart';
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
import '../widgets/app_tag.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/danger_button.dart';
import '../widgets/icon_badge.dart';
import '../widgets/info_pill.dart';
import '../widgets/tracking_mode_chip.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openTrackingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
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
                builder: (consumerContext, ob, _) => TrackingModeChips(
                  selected: ob.trackingModes,
                  onToggle: (mode) => consumerContext.read<OnboardingProvider>().toggleTrackingMode(mode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      await NotificationService.syncReminder(
        bells.items[index],
        predictedStart: cycle.nextPeriodStart(),
        fertileStart: cycle.fertileWindowStart(),
        bleedLength: cycle.bleedLength,
      );
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
    const options = [
      'Every day',
      'Each bleed day',
      'Window start',
      '3 days prior',
      'Hourly · 8 AM - 8 PM',
    ];
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text('Frequency', style: AppText.serif(15)),
        children: [
          for (final option in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Text(option, style: AppText.sans(13, c: AppColors.ink)),
            ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;
    context.read<RemindersProvider>().setFrequency(index, selected);
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Sign out?', style: AppText.serif(16)),
        content: Text(
          'You will return to the welcome screen. Your logs and settings stay on this device, and you can sign back in at any time.',
          style: AppText.sans(13, c: AppColors.body),
        ),
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
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete all data?', style: AppText.serif(16)),
        content: Text(
          'This erases every log, setting and session on this device. It cannot be undone.',
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
      await NotificationService.syncPeriodPrediction(
        enabled: settings.lunarNotifications,
        predictedStart: cycle.nextPeriodStart(),
      );
      await NotificationService.syncAll(
        reminders.items,
        predictedStart: cycle.nextPeriodStart(),
        fertileStart: cycle.fertileWindowStart(),
        bleedLength: cycle.bleedLength,
      );
    } catch (e) {
      debugPrint('Notification resync after data wipe failed: $e');
    }

    if (context.mounted) context.reset('/');
  }

  @override
  Widget build(BuildContext context) {
    final bells = context.watch<RemindersProvider>();
    final activeBells = bells.items.where((r) => r.enabled).length;
    final cycle = context.watch<CycleProvider>();
    final meanCycle = cycle.meanCycleLength;
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final name = auth.identity?.name?.trim();
    final displayName = (name == null || name.isEmpty) ? 'Guest' : name;
    final email = auth.identity?.email?.trim();
    final initials =
        (name == null || name.isEmpty)
            ? 'G'
            : displayName
                .split(' ')
                .where((w) => w.isNotEmpty)
                .map((w) => w[0])
                .take(2)
                .join()
                .toUpperCase();
    return Scaffold(
      appBar: AppTopBar(
        title: 'Profile',
        leading: AppIcons.back,
        onLeading: () => context.back(),
        action: AppIcons.alerts,
        onAction: () => context.go('/alerts'),
        badge: context.watch<AlertProvider>().unreadCount > 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Column(
            children: [
              AppAvatar(initials: initials, big: true),
              const SizedBox(height: 6),
              Text(displayName, style: AppText.serif(18)),
              const SizedBox(height: 2),
              Text(
                (email == null || email.isEmpty) ? 'LOCAL · CYCLE TRACKING' : email,
                style:
                    (email == null || email.isEmpty)
                        ? AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)
                        : AppText.sans(10, c: AppColors.muted),
              ),
              if (email == null || email.isEmpty) ...[
                const SizedBox(height: 4),
                Text('Data stored on this device only', style: AppText.sans(10, c: AppColors.muted)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cycle Averages', style: AppText.secIn),
                SettingsRow(
                  label: 'Average Cycle Length',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cycle.isCycleLengthAuto) ...[
                        AppTag.gold('Calculated'),
                        const SizedBox(width: 6),
                      ],
                      Text(meanCycle == null ? '—' : '${meanCycle.round()} Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.muted)),
                    ],
                  ),
                  first: true,
                ),
                SettingsRow(label: 'Bleeding Phase Length', trailing: Text('${cycle.bleedLength} Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.muted))),
                SettingsRow(
                  label: 'Tracking Modes',
                  trailing: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _openTrackingSheet(context),
                      child: Text(
                        onboarding.trackingModes.map((m) => m.label).join(', '),
                        style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (onboarding.trackingModes.contains(TrackingMode.pregnancy)) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pregnancy Settings', style: AppText.secIn),
                  SettingsRow(
                    label: 'Pregnancy Tracker',
                    trailing: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => context.go('/pregnancy'), child: Text('View', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)))),
                    first: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('App Settings', style: AppText.secIn),
                SettingsRow(
                  label: 'Cycle Notifications',
                  trailing: Switch(
                    value: settings.lunarNotifications,
                    activeThumbColor: const Color(0xFF7B2CBF),
                    onChanged: (v) async {
                      context.read<SettingsProvider>().setLunar(v);
                      final cycle = context.read<CycleProvider>();
                      try {
                        await NotificationService.syncPeriodPrediction(
                          enabled: v,
                          predictedStart: cycle.nextPeriodStart(),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update notifications: $e')));
                        }
                      }
                    },
                  ),
                  first: true,
                ),
                SettingsRow(
                  label: 'Dark Mode',
                  trailing: Switch(value: settings.darkMode, activeThumbColor: const Color(0xFF7B2CBF), onChanged: (v) => context.read<SettingsProvider>().setDark(v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reminders', style: AppText.secIn),
                const SizedBox(height: 4),
                Text('$activeBells of ${bells.items.length} reminders active', style: AppText.sans(11.5, c: AppColors.muted)),
                const SizedBox(height: 8),
                for (var i = 0; i < bells.items.length; i++) ...[
                  if (i > 0) Divider(height: 12, color: AppColors.line),
                  Row(
                    children: [
                      IconBadge(icon: bells.items[i].icon, bg: bells.items[i].badgeBg, fg: bells.items[i].badgeFg),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(bells.items[i].title, style: AppText.serif(12.5)), Text(bells.items[i].subtitle, style: AppText.sans(9.5, c: AppColors.muted))],
                        ),
                      ),
                      Switch(
                        value: bells.items[i].enabled,
                        activeThumbColor: AppColors.pur,
                        onChanged: (v) async {
                          context.read<RemindersProvider>().toggle(i, v);
                          final cycle = context.read<CycleProvider>();
                          try {
                            await NotificationService.syncReminder(
                              bells.items[i],
                              predictedStart: cycle.nextPeriodStart(),
                              fertileStart: cycle.fertileWindowStart(),
                              bleedLength: cycle.bleedLength,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update reminder: $e')));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  if (bells.items[i].enabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Hourly bells ignore the time field; show frequency only.
                        if (!NotificationService.isHourly(bells.items[i])) ...[
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _pickReminderTime(context, i),
                              child: InfoPill(icon: AppIcons.clock, label: bells.items[i].time),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _pickReminderFrequency(context, i),
                            child: InfoPill(icon: bells.items[i].icon, label: bells.items[i].freq),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session', style: AppText.secIn),
                const SizedBox(height: 10),
                AppButton(
                  label: (email == null || email.isEmpty) ? 'Switch Account' : 'Sign Out',
                  onTap: () => _confirmSignOut(context),
                ),
                const SizedBox(height: 10),
                DangerButton(label: 'Delete All Data', onTap: () => _confirmDeleteData(context)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final version = snap.data?.version ?? '1.0.0';
                return Text(
                  'Witchy\nVersion $version',
                  textAlign: TextAlign.center,
                  style: AppText.sans(9.5, c: AppColors.placeholder, h: 1.6),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
