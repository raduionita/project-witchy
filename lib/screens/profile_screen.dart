import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      appBar: AppTopBar(
        title: 'Witch Profile',
        leading: AppIcons.back,
        onLeading: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, '/dashboard');
          }
        },
        action: AppIcons.gear,
        onAction: () => Navigator.pushNamed(context, '/settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Column(
            children: [
              const AppAvatar(initials: 'HS', big: true),
              const SizedBox(height: 6),
              Text('High Priestess Selene', style: AppText.serif(18)),
              const SizedBox(height: 2),
              Text('SCORPIO MOON · THIRD CYCLE', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunar Alignments', style: AppText.secIn),
                SettingsRow(label: 'Average Cycle Length', trailing: Text('29 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur)), first: true),
                SettingsRow(label: 'Bleeding Phase Length', trailing: Text('5 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur))),
                SettingsRow(
                  label: 'Notification Preferences',
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/settings'), child: Text('Manage', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
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
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/settings'), child: Text('Manage', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                  first: true,
                ),
                SettingsRow(
                  label: 'Gestation Spells',
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/pregnancy'), child: Text('View', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                ),
                SettingsRow(
                  label: 'Cosmic Partner Bond',
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/binding'), child: Text('1 Active', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
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
                AppButton(label: 'Open Amulet Reminders', onTap: () => Navigator.pushNamed(context, '/reminders')),
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
