// Settings screen - app preferences and privacy controls

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: AppColors.primary),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('Cycle Settings', [
            SettingItem(
              title: 'Average Cycle Length',
              subtitle: '28 days (customizable)',
              icon: Icons.calendar_month,
            ),
            SettingItem(
              title: 'Period Length',
              subtitle: '5 days (customizable)',
              icon: Icons.circle,
            ),
          ]),
          const Divider(height: 8),
          _buildSection('Fertility Tracking', [
            SettingItem(
              title: 'Enable Fertility Predictions',
              subtitle: 'Show fertile window and ovulation dates',
              icon: Icons.auto_aviation,
            ),
            SettingItem(
              title: 'Fertility Reminders',
              subtitle: 'Get notified when fertile window starts',
              icon: Icons.notifications,
            ),
          ]),
          const Divider(height: 8),
          _buildSection('Privacy & Data', [
            SettingItem(
              title: 'Anonymous Mode',
              subtitle: 'Track without personal identifiers',
              icon: Icons.lock,
            ),
            SettingItem(
              title: 'Export Data',
              subtitle: 'Download your health data as CSV',
              icon: Icons.download,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        ...items.map((item) => item.toWidget()),
      ],
    );
  }

}

class SettingItem {
  final String title;
  final String subtitle;
  final IconData icon;

  SettingItem({required this.title, required this.subtitle, required this.icon});

  Widget toWidget() {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }

}
