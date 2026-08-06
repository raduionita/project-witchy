import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pregnancy_status.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/pregnancy_calculator.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_section_header.dart';
import '../trackers/shared_tracker_text.dart';
import 'pregnancy_guidance.dart';

/// Home content for pregnancy tracking mode.
///
/// Shows gestational weeks/trimester, due date, progress and phase-based
/// guidance. Requires a last-menstrual-period date; prompts the user when
/// it is missing.
class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  Future<void> _pickLmp() async {
    final AppStateProvider state = context.read<AppStateProvider>();
    final UserProfile? profile = state.profile.profile;
    final DateTime initial = profile?.pregnancyLmp ??
        dateOnly(DateTime.now()).subtract(const Duration(days: 70));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2),
      lastDate: dateOnly(DateTime.now()),
      helpText: AppLocalizations.of(context).pregnancyPickerHelp,
    );
    if (picked == null || !mounted) return;

    final UserProfile updated = (profile ?? const UserProfile(id: ''))
        .copyWith(pregnancyLmp: dateOnly(picked));
    await state.profile.save(updated);
    if (!mounted) return;
    context.read<CycleProvider>().recompute();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile? profile = context.watch<AppStateProvider>().profile.profile;
    final DateTime? lmp = profile?.pregnancyLmp;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          Text(
            l10n.pregnancyTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kMd),
          if (lmp == null)
            _setupCard(context)
          else
            _statusCards(context, PregnancyCalculator().statusFor(lmp)),
          const SizedBox(height: AppSpacing.kMd),
          _disclaimerCard(context),
        ],
      ),
    );
  }

  Widget _setupCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.pregnant_woman, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            l10n.pregnancySetupTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kXs),
          Text(
            l10n.pregnancySetupBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.kMd),
          AppButton(label: l10n.pregnancyChooseDate, onPressed: _pickLmp),
        ],
      ),
    );
  }

  Widget _statusCards(BuildContext context, PregnancyStatus status) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress =
        PregnancyCalculator().progressPercent(status).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeToday,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.kSm),
              Text(
                TrackerInsightText.pregnancyHeadline(l10n, status),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.kSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.kRadiusSm),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: AppSpacing.kXs),
              Text(
                l10n.pregnancyProgress(progress.round()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                    ),
              ),
              const SizedBox(height: AppSpacing.kMd),
              Text(
                TrackerInsightText.pregnancyDueLine(l10n, status),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.kMd),
        AppSectionHeader(title: l10n.pregnancyThisStage),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PregnancyGuidance.trimesterTitle(l10n, status.trimester),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.kSm),
              Text(
                PregnancyGuidance.stageSummary(l10n, status.trimester),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.kMd),
              for (final String tip
                  in PregnancyGuidance.tipsFor(l10n, status.trimester))
                _tipRow(context, tip),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tipRow(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.kXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.kSm),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimerCard(BuildContext context) {
    return Text(
      TrackerInsightText.disclaimer(AppLocalizations.of(context)),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}
