import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/cycle_provider.dart';
import '../utils/theme_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: WitchyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 16),
              _buildCycleSettings(context, settingsProvider),
              const SizedBox(height: 16),
              _buildNotificationSettings(context, settingsProvider),
              const SizedBox(height: 16),
              _buildPrivacySettings(context, settingsProvider),
              const SizedBox(height: 16),
              _buildDataSection(context),
              const SizedBox(height: 16),
              _buildAboutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [WitchyColors.primary, WitchyColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: WitchyColors.primary),
          ),
          SizedBox(height: 12),
          Text(
            'Anonymous User',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Your data stays private',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleSettings(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cycle Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildSliderSetting(
              context: context,
              label: 'Average Cycle Length',
              value: settingsProvider.settings.averageCycleLength.toStringAsFixed(0),
              unit: ' days',
              min: 14,
              max: 60,
              divisions: 46,
              valueDouble: settingsProvider.settings.averageCycleLength,
              onChanged: (value) {
                context.read<SettingsProvider>().setAverageCycleLength(value);
              },
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              context: context,
              label: 'Average Period Duration',
              value: settingsProvider.settings.averagePeriodDuration.toStringAsFixed(0),
              unit: ' days',
              min: 2,
              max: 10,
              divisions: 8,
              valueDouble: settingsProvider.settings.averagePeriodDuration,
              onChanged: (value) {
                context.read<SettingsProvider>().setAveragePeriodDuration(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required BuildContext context,
    required String label,
    required String value,
    required String unit,
    required double min,
    required double max,
    required int divisions,
    required double valueDouble,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$value$unit', style: TextStyle(color: WitchyColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: valueDouble,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: WitchyColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Period Reminders'),
              subtitle: const Text('Get reminded to log your period'),
              value: settingsProvider.settings.notificationsEnabled,
              activeColor: WitchyColors.primary,
              onChanged: (value) {
                context.read<SettingsProvider>().toggleNotifications(value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Fertility Reminders'),
              subtitle: const Text('Get notified during fertile window'),
              value: settingsProvider.settings.notificationsEnabled,
              activeColor: WitchyColors.primary,
              onChanged: (value) {
                context.read<SettingsProvider>().toggleNotifications(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Anonymous Mode'),
              subtitle: const Text('No personal data linked to your tracking'),
              value: settingsProvider.settings.anonymousMode,
              activeColor: WitchyColors.primary,
              onChanged: (value) {
                context.read<SettingsProvider>().setAnonymousMode(value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Pregnancy Mode'),
              subtitle: const Text('Track pregnancy milestones and due date'),
              value: settingsProvider.settings.isPregnancyMode,
              activeColor: WitchyColors.secondary,
              onChanged: (value) {
                context.read<SettingsProvider>().togglePregnancyMode(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.backup, color: WitchyColors.primary),
              title: const Text('Export Data'),
              subtitle: const Text('Export your tracking data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data export coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: WitchyColors.periodColor),
              title: const Text('Clear All Data'),
              subtitle: const Text('Permanently delete all tracking data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text('This will permanently delete all your tracking data. This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CycleProvider>().cycles.forEach((cycle) {
                            context.read<CycleProvider>().deletePeriod(cycle);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data cleared')),
                          );
                        },
                        child: const Text('Clear', style: TextStyle(color: WitchyColors.periodColor)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('About Witchy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            const Text(
              'Witchy is a comprehensive health tracking application designed to help you understand and monitor your menstrual cycle, fertility window, pregnancy, and overall reproductive health.',
              style: TextStyle(color: WitchyColors.lightText),
            ),
            const SizedBox(height: 12),
            const Text(
              'Developer: qvonyx.com\nEmail: witchy@qvonyx.com\nWebsite: witchy.qvonyx.com',
              style: TextStyle(color: WitchyColors.lightText),
            ),
            const SizedBox(height: 12),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: WitchyColors.lightText),
            ),
            const SizedBox(height: 16),
            const Text(
              'Disclaimer: Witchy is not a diagnostic tool and should not replace professional medical advice. Predictions are for educational purposes only.',
              style: TextStyle(fontSize: 10, color: WitchyColors.lightText),
            ),
          ],
        ),
      ),
    );
  }
}
