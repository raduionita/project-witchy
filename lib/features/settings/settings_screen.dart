import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tracking_mode.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/symptom_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

/// Settings hub.
///
/// Includes tracking-mode switching persisted through [ProfileRepository].
/// Additional controls (privacy, anonymous mode) arrive in later phases.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setMode(BuildContext context, TrackingMode mode) async {
    final AppStateProvider state = context.read<AppStateProvider>();
    final UserProfile? profile = state.profile.profile;
    if (profile == null) return;

    await state.profile.save(profile.copyWith(mode: mode));
    if (!context.mounted) return;
    context.read<CycleProvider>().recompute();
    context.read<SymptomProvider>().recompute();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${trackingModeLabel(mode)} is now active.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStateProvider state = context.watch<AppStateProvider>();
    final TrackingMode mode = state.profile.profile?.mode ?? TrackingMode.cycle;

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
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.swap_horiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Tracking mode'),
                  subtitle: const Text('Choose what Witchy focuses on.'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd),
                  child: Column(
                    children: [
                      for (final TrackingMode candidate in TrackingMode.values)
                        RadioListTile<TrackingMode>(
                          contentPadding: EdgeInsets.zero,
                          value: candidate,
                          groupValue: mode,
                          title: Text(trackingModeLabel(candidate)),
                          subtitle: Text(trackingModeDescription(candidate)),
                          onChanged: (TrackingMode? value) {
                            if (value != null) _setMode(context, value);
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Logs are shared'),
                  subtitle: Text('Your symptom and period logs stay with you '
                      'across modes.'),
                ),
              ],
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
