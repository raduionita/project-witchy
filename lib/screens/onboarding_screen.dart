import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../common/date_format.dart';
import '../models/cycle_goal.dart';
import '../models/period_record.dart';
import '../navigation/app_nav.dart';
import '../providers/auth_provider.dart';
import '../providers/logging_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_slider_row.dart';
import '../widgets/app_tag.dart';
import '../widgets/tracking_mode_chip.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _pickDate() async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showDatePicker(context: context, initialDate: ob.pickedDate ?? DateTime.now(), firstDate: DateTime(DateTime.now().year - 2), lastDate: DateTime.now());
    if (picked != null && mounted) ob.setDate(picked);
  }

  Future<void> _complete() async {
    final onboarding = context.read<OnboardingProvider>();
    await onboarding.finish();
    if (!mounted) return;
    await context.read<AuthProvider>().markLocalSession();
    if (!mounted) return;
    // Save only the start dates the user actually entered. No flow days or end
    // dates are invented from the onboarding sliders; those records stay
    // start-only and are labelled Estimated until real flow is logged.
    final logging = context.read<LoggingProvider>();
    final picked = onboarding.pickedDate;
    if (picked == null) return;
    logging.wipeAssumed();
    final today = DateTime.now();
    final records = <PeriodRecord>[
      PeriodRecord(start: picked, source: PeriodSource.onboarding, estimated: true),
      for (final previous in onboarding.previousPeriodStarts)
        if (!previous.isAfter(today)) PeriodRecord(start: previous, source: PeriodSource.onboarding, estimated: true),
    ];
    logging.replaceOnboardingRecords(records);
    if (!mounted) return;
    // Pregnancy tracker stays decoupled: its LMP is set on the pregnancy screen
    // itself, never auto-seeded from the cycle anchor.
    context.reset('/today');
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    // The last period is required because predictions need a real anchor.
    final canFinish = ob.yearOfBirth != null && ob.pickedDate != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const _Header(),
                    const SizedBox(height: 12),
                    const _GoalCard(),
                    const SizedBox(height: 12),
                    const _TrackingModeCard(),
                    const SizedBox(height: 12),
                    const _YearOfBirthCard(),
                    const SizedBox(height: 12),
                    _PastPeriodsCard(onPickLast: _pickDate),
                    const SizedBox(height: 12),
                    const _CycleLengthCard(),
                    const SizedBox(height: 12),
                    const _BleedLengthCard(),
                    // Keep the last card clear of the sticky Get Started button.
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (!canFinish)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Pick your last period date to continue.', style: AppText.sans(10.5, c: AppColors.muted)),
                ),
              _JourneyButton(canFinish: canFinish, onComplete: _complete),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('Set Your Cycle', style: AppText.h2), const SizedBox(height: 5), Text('Your dates stay on this device. You can change them later.', style: AppText.sub)],
    );
  }
}

/// Single-select intent (track / conceive / avoid); tunes the fertility copy.
class _GoalCard extends StatelessWidget {
  const _GoalCard();

  static Object _icon(CycleGoal goal) => switch (goal) {
    CycleGoal.track => AppIcons.spark,
    CycleGoal.conceive => AppIcons.heart,
  };

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<SettingsProvider>().goal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your goal', style: AppText.secIn),
          const SizedBox(height: 10),
          // One row of equal-width chips, matching the tracking-mode picker
          // below so both single-choice blocks read the same way.
          Row(
            children: [
              for (var i = 0; i < CycleGoal.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AppChip(
                    label: CycleGoal.values[i].label,
                    icon: _icon(CycleGoal.values[i]),
                    selected: CycleGoal.values[i] == goal,
                    singleLine: true,
                    onTap: () => context.read<SettingsProvider>().setGoal(CycleGoal.values[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(goal.blurb, style: AppText.sans(10.5, c: AppColors.muted, h: 1.45)),
        ],
      ),
    );
  }
}

/// Multi-toggle tracking mode picker; defaults to Cycle (always at least one active).
class _TrackingModeCard extends StatelessWidget {
  const _TrackingModeCard();
  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What to track', style: AppText.secIn),
          const SizedBox(height: 10),
          TrackingModeChips(selected: ob.trackingModes, onToggle: (mode) => context.read<OnboardingProvider>().toggleTrackingMode(mode)),
        ],
      ),
    );
  }
}

/// Year-of-birth row; the dropdown shows the only year value (no duplicate label text).
class _YearOfBirthCard extends StatelessWidget {
  const _YearOfBirthCard();
  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final year = ob.yearOfBirth;
    final nowYear = DateTime.now().year;
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Year of Birth', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: year,
              isDense: true,
              hint: Text('Select year', style: AppText.sans(12, c: AppColors.placeholder)),
              items: [for (var y = nowYear; y >= nowYear - 100; y--) DropdownMenuItem(value: y, child: Text('$y', style: AppText.sans(13, w: FontWeight.w600, c: AppColors.ink)))],
              onChanged: (v) {
                if (v != null) context.read<OnboardingProvider>().setYear(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Optional history of earlier period starts; seeding these makes predictions
/// reflect the user's real cycle lengths instead of a guessed slider value.
class _PastPeriodsCard extends StatefulWidget {
  final VoidCallback onPickLast;
  const _PastPeriodsCard({required this.onPickLast});

  @override
  State<_PastPeriodsCard> createState() => _PastPeriodsCardState();
}

class _PastPeriodsCardState extends State<_PastPeriodsCard> {
  /// Reason the last add/edit failed. Kept on screen instead of in a SnackBar
  /// so the user can read it while fixing the date.
  String? _error;

  /// Moves the slider onto the length the entered dates imply; leaves a manual
  /// value alone until 2+ starts exist.
  void _applyDerivedLength(OnboardingProvider ob) {
    final derived = ob.deriveCycleLengthFromHistory();
    if (derived != null) ob.setCycle(derived, fromHistory: true);
  }

  Future<void> _add() async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(DateTime.now().year - 2), lastDate: DateTime.now());
    if (picked == null || !mounted) return;
    if (!ob.addPreviousPeriod(picked)) {
      setState(() => _error = ob.lastValidationError ?? 'Could not add that date.');
      return;
    }
    setState(() => _error = null);
    _applyDerivedLength(ob);
  }

  Future<void> _editDate(DateTime existing) async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showDatePicker(context: context, initialDate: existing, firstDate: DateTime(DateTime.now().year - 2), lastDate: DateTime.now());
    if (picked == null || !mounted) return;
    if (!ob.replacePreviousPeriod(existing, picked)) {
      setState(() => _error = ob.lastValidationError ?? 'Could not update that date.');
      return;
    }
    setState(() => _error = null);
    _applyDerivedLength(ob);
  }


  /// Removes a row and offers an undo.
  void _remove(DateTime start) {
    final ob = context.read<OnboardingProvider>();
    ob.removePreviousPeriod(start);
    setState(() => _error = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${AppDate.long(start)}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ob.restorePreviousPeriod(start);
            _applyDerivedLength(ob);
          },
        ),
      ),
    );
  }

  Widget _buildTapTarget({required VoidCallback onTap, required String tooltip, required Widget child}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Align(alignment: Alignment.centerLeft, child: child)),
      ),
    );
  }

  Widget _buildLastRow(OnboardingProvider ob) {
    final date = ob.pickedDate;
    return InkWell(
      onTap: widget.onPickLast,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last period', style: AppText.sans(10.5, c: AppColors.muted)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          date == null ? 'Pick a date' : AppDate.long(date),
                          style: AppText.serif(13, c: date == null ? AppColors.placeholder : AppColors.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (date != null) ...[const SizedBox(width: 8), AppTag.gold('Estimated')],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(AppIcons.cal, size: AppIconSize.head, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(DateTime d) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: _buildTapTarget(
              onTap: () => _editDate(d),
              tooltip: 'Edit date',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(AppDate.long(d), style: AppText.sans(11.5, w: FontWeight.w600, c: AppColors.ink), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  FaIcon(FontAwesomeIcons.pen, size: 10, color: AppColors.muted),
                ],
              ),
            ),
          ),
          AppTag.gold('Estimated'),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: FaIcon(FontAwesomeIcons.xmark, size: 12, color: AppColors.muted),
            tooltip: 'Remove',
            onPressed: () => _remove(d),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.danger.withValues(alpha: 0.4))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.circleExclamation, size: 11, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: AppText.sans(10.5, c: AppColors.danger, h: 1.35))),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _add,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pur,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(48, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: FaIcon(FontAwesomeIcons.plus, size: 11, color: AppColors.pur),
        label: Text('Add an earlier period', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.pur, decoration: TextDecoration.underline)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final entries = ob.previousPeriodStarts;
    final error = _error;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Past periods', style: AppText.secIn),
              Flexible(child: Text('${entries.length} of ${OnboardingProvider.maxPreviousPeriods} earlier periods', style: AppText.sans(10, c: AppColors.muted), textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            entries.length < 2
                ? 'Your last period is required. Add at least two earlier periods (three starts total) to calculate your cycle length. Keep at least ${OnboardingProvider.minGapDays} days between starts.'
                : 'Cycle length is calculated from your starts. Tap a date to change it.',
            style: AppText.sans(10.5, c: AppColors.muted, h: 1.45),
          ),
          const SizedBox(height: 8),
          _buildLastRow(ob),
          if (error != null) ...[const SizedBox(height: 8), _buildError(error)],
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Earlier periods', style: AppText.sans(10, w: FontWeight.w700, c: AppColors.muted).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 2),
            for (final d in entries) _buildRow(d),
          ],
          const SizedBox(height: 4),
          _buildAddButton(),
        ],
      ),
    );
  }
}

class _CycleLengthCard extends StatelessWidget {
  const _CycleLengthCard();
  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    return AppCard(
      child: AppSliderRow(
        label: 'Cycle length',
        value: '${ob.cycleLength} Days',
        min: OnboardingProvider.minCycleLength.toDouble(),
        max: OnboardingProvider.maxCycleLength.toDouble(),
        current: ob.cycleLength.toDouble(),
        onChanged: (v) => context.read<OnboardingProvider>().setCycle(v.round()),
        hint: ob.cycleLengthFromHistory ? 'Calculated from your dates - adjust freely' : null,
      ),
    );
  }
}

class _BleedLengthCard extends StatelessWidget {
  const _BleedLengthCard();
  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    return AppCard(
      child: AppSliderRow(
        label: 'Bleeding phase length',
        value: '${ob.bleedLength} Days',
        min: 2,
        max: 10,
        current: ob.bleedLength.toDouble(),
        onChanged: (v) => context.read<OnboardingProvider>().setBleed(v.round()),
      ),
    );
  }
}

class _JourneyButton extends StatelessWidget {
  final bool canFinish;
  final VoidCallback onComplete;
  const _JourneyButton({required this.canFinish, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: canFinish ? 1 : 0.45, child: AppButton(label: 'Get Started', onTap: canFinish ? onComplete : null));
  }
}
