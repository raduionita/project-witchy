/// Settings screen for Witchy.
/// Manages notifications, theme preferences, and app information.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

/// Settings screen with notifications toggle and app info.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 32),

              // Notifications toggle.
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Receive reminders for your cycle'),
                value: context.watch<AppProvider>().userProfile.notificationsEnabled,
                onChanged: (value) async {
                  await context.read<AppProvider>().saveEntries([]);
                },
              ),

              const Divider(),

              // Dark mode toggle.
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme throughout the app'),
                value: context.watch<AppProvider>().isDarkMode,
                onChanged: (value) {
                  context.read<AppProvider>().toggleDarkMode();
                },
              ),

              const Divider(),

              // Anonymous mode info.
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text('Anonymous Mode'),
                subtitle: const Text('Your data is never shared with third parties'),
                trailing: const Icon(Icons.check_circle, color: Color(0xFF7CB342)),
              ),

              const Spacer(),

              // App info.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Witchy v1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Built with Flutter & Provider',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
