import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../common/date_format.dart';
import '../models/period_range.dart';
import '../models/period_record.dart';
import '../navigation/app_nav.dart';
import '../providers/auth_provider.dart';
import '../providers/logging_provider.dart';
import '../providers/onboarding_provider.dart';
import '../services/period_range_rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_slider_row.dart';
import '../widgets/period_range_calendar_sheet.dart';
import '../widgets/tracking_mode_chip.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _complete() async {
    final onboarding = context.read<OnboardingProvider>();
    await onboarding.finish();
    if (!mounted) return;
    await context.read<AuthProvider>().markLocalSession();
    if (!mounted) return;
    // Save the ranges the user picked. No flow days are invented: the start
    // and the last day are the user's own dates, so the records are real and
    // no longer carry the Estimated label.
    final logging = context.read<LoggingProvider>();
    logging.wipeAssumed();
    final records = <PeriodRecord>[
      for (final range in onboarding.pastPeriods)
        PeriodRecord(
          start: range.start,
          end: range.end,
          source: PeriodSource.onboarding,
          estimated: false,
        ),
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
    // At least one period is required because predictions need a real anchor.
    final canFinish = ob.yearOfBirth != null && ob.pastPeriods.isNotEmpty;
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
                    const _TrackingModeCard(),
                    const SizedBox(height: 12),
                    const _YearOfBirthCard(),
                    const SizedBox(height: 12),
                    _PastPeriodsCard(),
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
                  child: Text('Add at least one past period to continue.', style: AppText.sans(10.5, c: AppColors.muted)),
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

/// The periods the user remembers. Every row is a range; the most recent start
/// sets the cycle day and the starts feed the cycle length.
class _PastPeriodsCard extends StatefulWidget {
  const _PastPeriodsCard();

  @override
  State<_PastPeriodsCard> createState() => _PastPeriodsCardState();
}

class _PastPeriodsCardState extends State<_PastPeriodsCard> {
  /// Reason the last add/edit failed. Kept on screen instead of in a SnackBar
  /// so the user can read it while fixing the dates.
  String? _error;

  /// Moves the slider onto the length the entered dates imply; leaves a manual
  /// value alone until 2+ starts exist.
  void _applyDerivedLength(OnboardingProvider ob) {
    final derived = ob.deriveCycleLengthFromHistory();
    if (derived != null) ob.setCycle(derived, fromHistory: true);
  }

  Future<void> _add() async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showPeriodRangeCalendarSheet(
      context,
      existing: ob.pastPeriods,
    );
    if (picked == null || !mounted) return;
    if (!ob.addPeriodRange(picked)) {
      setState(() => _error = ob.lastValidationError ?? 'Could not add that period.');
      return;
    }
    setState(() => _error = null);
    _applyDerivedLength(ob);
  }

  Future<void> _editRange(PeriodRange range) async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showPeriodRangeCalendarSheet(
      context,
      existing: ob.pastPeriods,
      editing: range,
    );
    if (picked == null || !mounted) return;
    if (!ob.replacePeriodRange(range.start, picked)) {
      setState(() => _error = ob.lastValidationError ?? 'Could not update that period.');
      return;
    }
    setState(() => _error = null);
    _applyDerivedLength(ob);
  }

  /// Removes a row and offers an undo.
  void _remove(PeriodRange range) {
    final ob = context.read<OnboardingProvider>();
    ob.removePeriodRange(range.start);
    setState(() => _error = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${AppDate.longRange(range.start, range.end)}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ob.restorePeriodRange(range);
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

  Widget _buildRow(PeriodRange range) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: _buildTapTarget(
              onTap: () => _editRange(range),
              tooltip: 'Edit period',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(AppDate.longRange(range.start, range.end), style: AppText.sans(11.5, w: FontWeight.w600, c: AppColors.ink), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  FaIcon(FontAwesomeIcons.pen, size: 10, color: AppColors.muted),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: FaIcon(FontAwesomeIcons.xmark, size: 12, color: AppColors.muted),
            tooltip: 'Remove',
            onPressed: () => _remove(range),
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
        icon: FaIcon(AppIcons.calendarAdd, size: 11, color: AppColors.pur),
        label: Text('Add past period', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.pur, decoration: TextDecoration.underline)),
      ),
    );
  }

  /// The hint under the title depends on how much history is in the list.
  String _copy(int count) {
    if (count == 0) {
      return 'Add the period you remember best. The most recent start sets your cycle day. Keep at least ${PeriodRangeRules.minGapDays} days between starts.';
    }
    if (count == 1) {
      return 'Your most recent start sets your cycle day. Add an earlier period to calculate your cycle length.';
    }
    return 'Cycle length is calculated from your starts. Tap a period to change it.';
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final entries = ob.pastPeriods;
    final error = _error;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Past periods', style: AppText.secIn),
              Flexible(child: Text('${entries.length} of ${OnboardingProvider.maxPeriods} periods', style: AppText.sans(10, c: AppColors.muted), textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 4),
          Text(_copy(entries.length), style: AppText.sans(10.5, c: AppColors.muted, h: 1.45)),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final range in entries) _buildRow(range),
          ],
          if (error != null) ...[const SizedBox(height: 8), _buildError(error)],
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
