import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_nav.dart';
import '../providers/auth_provider.dart';
import '../providers/reminders_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/settings_row.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bells = context.watch<RemindersProvider>().items.where((r) => r.enabled).length;
    final auth = context.watch<AuthProvider>();
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
        action: AppIcons.gear,
        onAction: () => context.go('/settings'),
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
                SettingsRow(label: 'Average Cycle Length', trailing: Text('29 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.muted)), first: true),
                SettingsRow(label: 'Bleeding Phase Length', trailing: Text('5 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.muted))),
                SettingsRow(
                  label: 'Notification Preferences',
                  trailing: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => context.go('/settings'), child: Text('Manage', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apothecary Settings', style: AppText.secIn),
                SettingsRow(
                  label: 'Appearance',
                  trailing: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => context.go('/settings'), child: Text('Manage', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)))),
                  first: true,
                ),
                SettingsRow(
                  label: 'Gestation Spells',
                  trailing: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => context.go('/pregnancy'), child: Text('View', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)))),
                ),
                SettingsRow(
                  label: 'Cosmic Partner Bond',
                  trailing: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => context.go('/binding'), child: Text('1 Active', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)))),
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
                Text('$bells of 5 bells active', style: AppText.sans(11.5, c: AppColors.muted)),
                const SizedBox(height: 10),
                AppButton(label: 'Open Amulet Reminders', onTap: () => context.go('/reminders')),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('Witchy App\nVersion 1.2.4 · Made with celestial energy', textAlign: TextAlign.center, style: AppText.sans(9.5, c: AppColors.placeholder, h: 1.6))),
        ],
      ),
    );
  }
}
