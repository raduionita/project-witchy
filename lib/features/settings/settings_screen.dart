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
import 'legal_content.dart';
import 'legal_document_screen.dart';
import 'locale_provider.dart';
import 'theme_provider.dart';

/// Settings hub.
///
/// Includes tracking-mode switching persisted through [ProfileRepository].
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

  String _localeLabel(AppLocaleOption option, AppLocalizations l10n) {
    return switch (option) {
      AppLocaleOption.system => l10n.systemDefault,
      AppLocaleOption.english => 'English',
      AppLocaleOption.spanish => 'Español',
    };
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

  @override
  Widget build(BuildContext context) {
    final AppStateProvider state = context.watch<AppStateProvider>();
    final TrackingMode mode = state.profile.profile?.mode ?? TrackingMode.cycle;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocaleProvider locale = context.watch<LocaleProvider>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kMd),
          children: [
            _accountCard(context),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: Icon(Icons.swap_horiz, color: scheme.primary),
                title: Text(l10n.settingsTrackingModeTitle),
                subtitle: Text(l10n.settingsTrackingModeSubtitle),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.kMd),
                child: DropdownButtonFormField<TrackingMode>(
                  value: mode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.kRadiusMd),
                    ),
                  ),
                  items: <DropdownMenuItem<TrackingMode>>[
                    for (final TrackingMode candidate in TrackingMode.values)
                      DropdownMenuItem<TrackingMode>(
                        value: candidate,
                        child: Text(trackingModeLabel(l10n, candidate)),
                      ),
                  ],
                  onChanged: (TrackingMode? value) {
                    if (value != null) _setMode(context, value);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsLogsShared),
                subtitle: Text(l10n.settingsLogsSharedSubtitle),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
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
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
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
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                subtitle: Text(l10n.settingsAboutSubtitle),
                onTap: () => _comingSoon(context, l10n.about),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: Icon(Icons.translate, color: scheme.primary),
                title: Text(l10n.language),
                subtitle: Text(l10n.settingsLanguageSubtitle),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.kMd),
                child: DropdownButtonFormField<AppLocaleOption>(
                  value: locale.option,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.kRadiusMd),
                    ),
                  ),
                  items: <DropdownMenuItem<AppLocaleOption>>[
                    for (final AppLocaleOption option in AppLocaleOption.values)
                      DropdownMenuItem<AppLocaleOption>(
                        value: option,
                        child: Text(_localeLabel(option, l10n)),
                      ),
                  ],
                  onChanged: (AppLocaleOption? value) {
                    if (value != null) {
                      context.read<LocaleProvider>().setOption(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.settingsThemeTitle),
                subtitle: Text(l10n.settingsThemeSubtitle),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.kMd),
                child: DropdownButtonFormField<AppThemeOption>(
                  value: themeProvider.option,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.kRadiusMd),
                    ),
                  ),
                  items: <DropdownMenuItem<AppThemeOption>>[
                    for (final AppThemeOption option in AppThemeOption.values)
                      DropdownMenuItem<AppThemeOption>(
                        value: option,
                        child: Text(option.label(l10n)),
                      ),
                  ],
                  onChanged: (AppThemeOption? value) {
                    if (value != null) {
                      context.read<ThemeProvider>().setOption(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}