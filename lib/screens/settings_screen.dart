import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Settings screen for app configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildProfileSection(settingsProvider),
          _buildNotificationSettings(settingsProvider),
          _buildAppPreferences(settingsProvider),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(SettingsProvider settingsProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: settingsProvider.setUserName,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Anonymous Mode'),
              subtitle: const Text(
                'Hide your name in the app',
              ),
              value: settingsProvider.isAnonymous,
              onChanged: settingsProvider.setAnonymous,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsProvider settingsProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Reminders'),
              subtitle: const Text(
                'Get daily reminders to log your cycle',
              ),
              value: settingsProvider.notificationsEnabled,
              onChanged: settingsProvider.setNotificationsEnabled,
            ),
            if (settingsProvider.notificationsEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 72),
                child: DropdownButton<int>(
                  value: settingsProvider.reminderTime,
                  items: List.generate(
                    24,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text('$index:00'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setReminderTime(value);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreferences(SettingsProvider settingsProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (listTileContext) => Column(
                children: [
                  ListTile(
                    title: const Text('Cycle Length'),
                    subtitle: const Text('Average: 28 days'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCycleLengthDialog(listTileContext),
                  ),
                  ListTile(
                    title: const Text('Period Duration'),
                    subtitle: const Text('Average: 5 days'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPeriodDurationDialog(listTileContext),
                  ),
                  ListTile(
                    title: const Text('Data & Privacy'),
                    subtitle: const Text('Manage your data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDataManagementDialog(listTileContext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Witchy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Witchy - Period Tracker & Reproductive Health App\n\n'
              'Developer: qvonyx.com\n'
              'Email: witchy@qvonyx.com\n'
              'Website: witchy.qvonyx.com',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Disclaimer: Witchy is not a diagnostic tool and should not '
              'replace professional medical advice. Always consult a '
              'qualified healthcare professional for medical concerns.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCycleLengthDialog(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Average Cycle Length'),
        content: const Text('This feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPeriodDurationDialog(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Average Period Duration'),
        content: const Text('This feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDataManagementDialog(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Data & Privacy'),
        content: const Text('Data management features coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}