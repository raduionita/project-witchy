import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/tracking_mode.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/symptom_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_screen.dart';
import '../auth/models/auth_session.dart';
import '../couples/couples_screen.dart';
import '../reminders/reminders_screen.dart';
import 'legal_content.dart';
import 'legal_document_screen.dart';
import 'locale_provider.dart';
import 'privacy_provider.dart';
import 'theme_provider.dart';

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
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsModeActive(trackingModeLabel(l10n, mode))),
        ),
      );
    }
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).settingsComingSoon(feature)),
      ),
    );
  }

  /// Enables/disables anonymous mode. Enabling also clears any stored account
  /// identity so no name/email remains persisted on this device.
  Future<void> _setAnonymousMode(BuildContext context, bool enabled) async {
    final PrivacyProvider privacy = context.read<PrivacyProvider>();
    final AuthProvider auth = context.read<AuthProvider>();
    await privacy.setAnonymousMode(enabled);
    if (enabled && auth.isSignedIn) await auth.signOut();
    if (!context.mounted) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled ? l10n.settingsAnonymousOn : l10n.settingsAnonymousOff,
        ),
      ),
    );
  }

  void _openLegal(
    BuildContext context, {
    required String title,
    required List<LegalSection> sections,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentScreen(title: title, sections: sections),
      ),
    );
  }

  Widget _privacyCard(BuildContext context, AppLocalizations l10n) {
    final PrivacyProvider privacy = context.watch<PrivacyProvider>();
    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.person_off_outlined),
            title: Text(l10n.anonymousMode),
            subtitle: Text(l10n.anonymousModeDescription),
            value: privacy.anonymousMode,
            onChanged: (bool enabled) => _setAnonymousMode(context, enabled),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            subtitle: Text(l10n.settingsPrivacySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap:
                () => _openLegal(
                  context,
                  title: l10n.privacyPolicyTitle,
                  sections: kPrivacyPolicySections(l10n),
                ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfService),
            subtitle: Text(l10n.settingsTermsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap:
                () => _openLegal(
                  context,
                  title: l10n.termsOfServiceTitle,
                  sections: kTermsOfServiceSections(l10n),
                ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            subtitle: Text(l10n.settingsAboutSubtitle),
            onTap: () => _comingSoon(context, l10n.about),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppStateProvider state = context.watch<AppStateProvider>();
    final TrackingMode mode = state.profile.profile?.mode ?? TrackingMode.cycle;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PrivacyProvider privacy = context.watch<PrivacyProvider>();
    final bool anonymous = privacy.anonymousMode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kMd),
          children: [
            if (!anonymous) ...[
              _accountCard(context),
              const SizedBox(height: AppSpacing.kMd),
            ],
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.swap_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(l10n.settingsTrackingModeTitle),
                    subtitle: Text(l10n.settingsTrackingModeSubtitle),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.kMd,
                    ),
                    child: Column(
                      children: [
                        for (final TrackingMode candidate
                            in TrackingMode.values)
                          RadioListTile<TrackingMode>(
                            contentPadding: EdgeInsets.zero,
                            value: candidate,
                            groupValue: mode,
                            title: Text(trackingModeLabel(l10n, candidate)),
                            subtitle: Text(
                              trackingModeDescription(l10n, candidate),
                            ),
                            onChanged: (TrackingMode? value) {
                              if (value != null) _setMode(context, value);
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.settingsLogsShared),
                    subtitle: Text(l10n.settingsLogsSharedSubtitle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            _privacyCard(context, l10n),
            const SizedBox(height: AppSpacing.kMd),
            _languageCard(context, l10n),
            const SizedBox(height: AppSpacing.kMd),
            _appearanceCard(context),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: Icon(
                  Icons.alarm_add,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.settingsRemindersTitle),
                subtitle: Text(l10n.settingsRemindersSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RemindersScreen(),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.settingsCouplesTitle),
                subtitle: Text(l10n.settingsCouplesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CouplesScreen(),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageCard(BuildContext context, AppLocalizations l10n) {
    final LocaleProvider locale = context.watch<LocaleProvider>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              Icons.translate,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l10n.language),
            subtitle: Text(l10n.settingsLanguageSubtitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd),
            child: Column(
              children: [
                for (final AppLocaleOption option in AppLocaleOption.values)
                  RadioListTile<AppLocaleOption>(
                    contentPadding: EdgeInsets.zero,
                    value: option,
                    groupValue: locale.option,
                    title: Text(_localeLabel(option, l10n)),
                    subtitle:
                        option.isSystem
                            ? Text(l10n.systemDefaultDescription)
                            : null,
                    onChanged: (AppLocaleOption? value) {
                      if (value != null) {
                        context.read<LocaleProvider>().setOption(value);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localeLabel(AppLocaleOption option, AppLocalizations l10n) {
    return switch (option) {
      AppLocaleOption.system => l10n.systemDefault,
      AppLocaleOption.english => 'English',
      AppLocaleOption.spanish => 'Español',
    };
  }

  Widget _appearanceCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsThemeTitle),
            subtitle: Text(l10n.settingsThemeSubtitle),
          ),
          for (final AppThemeOption option in AppThemeOption.values)
            RadioListTile<AppThemeOption>(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.kMd,
              ),
              value: option,
              groupValue: themeProvider.option,
              title: Text(option.label(l10n)),
              onChanged: (AppThemeOption? value) {
                if (value != null) {
                  context.read<ThemeProvider>().setOption(value);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _accountCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    final AuthSession? session = auth.session;

    if (session != null) {
      return AppCard(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: Text(
              session.displayName.isEmpty
                  ? '?'
                  : session.displayName.substring(0, 1).toUpperCase(),
            ),
          ),
          title: Text(session.displayName),
          subtitle: Text(
            session.email ?? authProviderLabel(l10n, session.provider),
          ),
          trailing: TextButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            child: Text(l10n.settingsSignOut),
          ),
        ),
      );
    }

    return AppCard(
      child: ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: Text(l10n.settingsAccountTitle),
        subtitle: Text(l10n.settingsAccountSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const AuthScreen())),
      ),
    );
  }
}
