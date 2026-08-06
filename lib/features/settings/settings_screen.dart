import 'package:flutter/material.dart';

import '../../widgets/app_card.dart';
import '../../utils/app_theme.dart';

/// Settings hub. Concrete controls (privacy, anonymous mode) arrive in later
/// phases; this provides the Phase 0 shell tab.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          const AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy'),
                  subtitle: Text('Your data stays on your device.'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.palette_outlined),
                  title: Text('Appearance'),
                  subtitle: Text('Theme and display options.'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  subtitle: Text('Witchy version and legal info.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}