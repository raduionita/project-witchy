import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/settings_row.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';

class BindingScreen extends StatelessWidget {
  const BindingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: const AppTopBar(title: 'Coven Binding'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          AppCard(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppAvatar(initials: 'HS'),
                    SizedBox(width: 12),
                    FaIcon(AppIcons.spark, color: AppColors.gold, size: AppIconSize.lg),
                    SizedBox(width: 12),
                    AppAvatar(initials: 'KP'),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Bind Cosmic Partners', style: AppText.serif(15)),
                const SizedBox(height: 6),
                Text('Invite partners or coven members to sync and visualize predictions on a shared celestial map.', textAlign: TextAlign.center, style: AppText.sub),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite Cosmic Bond', style: AppText.secIn),
                const SizedBox(height: 8),
                const AppTextField(hint: 'partner@cosmic.com', lead: AppIcons.mail),
                const SizedBox(height: 12),
                AppButton(label: 'Send Binding Scroll', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scroll Visibility', style: AppText.secIn),
                SettingsRow(
                  label: 'Share Bleeding Predictions',
                  trailing: Switch(value: s.shareBleed, activeThumbColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setShareBleed(v)),
                  first: true,
                ),
                SettingsRow(label: 'Share Fertile Windows', trailing: Switch(value: s.shareFertile, activeThumbColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setShareFertile(v))),
                SettingsRow(
                  label: 'Share Anonymized Symptom Log',
                  trailing: Switch(value: s.shareSymptoms, activeThumbColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setShareSymptoms(v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
