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
              Text('What shall we track?', style: AppText.secIn),
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
    final displayName = (name == null || name.isEmpty) ? 'High Priestess Selene' : name;
    final email = auth.identity?.email?.trim();
    final initials =
        (name == null || name.isEmpty)
            ? 'HS'
            : displayName
                .split(' ')
                .where((w) => w.isNotEmpty)
                .map((w) => w[0])
                .take(2)
                .join()
                .toUpperCase();
    return Scaffold(
      appBar: AppTopBar(
        title: 'Witch Profile',
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
                (email == null || email.isEmpty) ? 'SCORPIO MOON · THIRD CYCLE' : email,
                style:
                    (email == null || email.isEmpty)
                        ? AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)
                        : AppText.sans(10, c: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunar Alignments', style: AppText.secIn),
                SettingsRow(label: 'Average Cycle Length', trailing: Text(meanCycle == null ? '—' : '${meanCycle.toStringAsFixed(0)} Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.muted)), first: true),
                SettingsRow(label: 'Bleeding Phase Length', trailing: Text('${cycle.bleedLength} Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.muted))),
                SettingsRow(
                  label: 'Tracking Mode',
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
                  Text('Apothecary Settings', style: AppText.secIn),
                  SettingsRow(
                    label: 'Gestation Spells',
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
                  label: 'Receive Lunar Notifications',
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
                  label: 'Dark Magic Mode',
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
                Text('Amulet Bells', style: AppText.secIn),
                const SizedBox(height: 4),
                Text('$activeBells of ${bells.items.length} bells active', style: AppText.sans(11.5, c: AppColors.muted)),
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
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update bell: $e')));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  if (bells.items[i].enabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [InfoPill(icon: AppIcons.clock, label: bells.items[i].time), InfoPill(icon: AppIcons.spark, label: bells.items[i].freq)],
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
                  label: 'Sign Out',
                  onTap: () async {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) context.reset('/');
                  },
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
                  'Witchy App\nVersion $version · Made with celestial energy',
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
