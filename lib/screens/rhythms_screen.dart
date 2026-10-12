import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../navigation/app_nav.dart';
import '../providers/auth_provider.dart';
import '../providers/logging_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_slider_row.dart';
import '../widgets/tracking_mode_chip.dart';

class RhythmsScreen extends StatefulWidget {
  const RhythmsScreen({super.key});

  @override
  State<RhythmsScreen> createState() => _RhythmsScreenState();
}

class _RhythmsScreenState extends State<RhythmsScreen> {
  Future<void> _pickDate() async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: ob.pickedDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) ob.setDate(picked);
  }

  Future<void> _complete() async {
    final onboarding = context.read<OnboardingProvider>();
    await onboarding.finish();
    if (!mounted) return;
    await context.read<AuthProvider>().markLocalSession();
    if (!mounted) return;
    // Seed the picked start date and any earlier periods as real bleed spans so
    // PeriodHistory derives true cycle lengths from day one.
    final logging = context.read<LoggingProvider>();
    final bleedLength = onboarding.bleedLength;
    final today = DateTime.now();
    void seed(DateTime start) {
      if (start.isAfter(today)) return;
      for (var i = 0; i < bleedLength; i++) {
        logging.setFlow(DateTime(start.year, start.month, start.day + i), 'Medium');
      }
    }

    final picked = onboarding.pickedDate;
    if (picked != null) seed(picked);
    for (final previous in List<DateTime>.of(onboarding.previousPeriodStarts)) {
      seed(previous);
    }
    // Pregnancy tracker stays decoupled: its LMP is set on the pregnancy screen
    // itself, never auto-seeded from the cycle anchor.
    context.reset('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    // Default year (now − 25) is preselected, so this is true from the first frame.
    final canFinish = ob.yearOfBirth != null;
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
                    _LastBleedDateCard(onTap: _pickDate),
                    const SizedBox(height: 12),
                    const _PastPeriodsCard(),
                    const SizedBox(height: 12),
                    const _CycleLengthCard(),
                    const SizedBox(height: 12),
                    const _BleedLengthCard(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
      children: [
        Text('Set Your Cycle', style: AppText.h2),
        const SizedBox(height: 5),
        Text('Set up your cycle. When did your last period start?', style: AppText.sub),
      ],
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
          Text('What shall we track?', style: AppText.secIn),
          const SizedBox(height: 10),
          TrackingModeChips(selected: ob.trackingModes, onToggle: (mode) => context.read<OnboardingProvider>().toggleTrackingMode(mode)),
        ],
      ),
    );
  }
}

/// Year-of-birth dropdown; preselected with the provider default (now − 25).
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Year of Birth', style: AppText.sans(11, c: AppColors.muted)),
              const SizedBox(height: 3),
              Text(year?.toString() ?? 'Select year', style: AppText.serif(14, c: year == null ? AppColors.placeholder : AppColors.ink)),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: year,
              isDense: true,
              hint: Text('Year', style: AppText.sans(11, c: AppColors.placeholder)),
              items: [
                for (var y = nowYear; y >= nowYear - 100; y--)
                  DropdownMenuItem(value: y, child: Text('$y', style: AppText.sans(13, w: FontWeight.w600, c: AppColors.ink))),
              ],
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

class _LastBleedDateCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LastBleedDateCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final date = context.watch<OnboardingProvider>().pickedDate;
    return AppCard(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last bleeding phase', style: AppText.sans(11, c: AppColors.muted)),
                  const SizedBox(height: 3),
                  Text(date == null ? 'Pick a date' : DateFormat('MMMM d, yyyy').format(date), style: AppText.serif(14, c: date == null ? AppColors.placeholder : AppColors.ink)),
                ],
              ),
              FaIcon(AppIcons.cal, size: AppIconSize.head, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optional history of earlier period starts; seeding these makes predictions
/// reflect the user's real cycle lengths instead of a guessed slider value.
class _PastPeriodsCard extends StatelessWidget {
  const _PastPeriodsCard();

  Future<void> _add(BuildContext context) async {
    final ob = context.read<OnboardingProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
    );
    if (picked == null || !context.mounted) return;
    ob.addPreviousPeriod(picked);
    final derived = ob.deriveCycleLengthFromHistory();
    if (derived != null) ob.setCycle(derived);
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    final entries = ob.previousPeriodStarts;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent periods', style: AppText.secIn),
          const SizedBox(height: 4),
          Text(
            'Add the start date of each earlier period. Two or more dates let us match your real cycle length.',
            style: AppText.sans(10.5, c: AppColors.muted, h: 1.45),
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final d in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMMM d, yyyy').format(d), style: AppText.sans(11.5, w: FontWeight.w600, c: AppColors.ink)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: FaIcon(FontAwesomeIcons.xmark, size: 12, color: AppColors.muted),
                      tooltip: 'Remove',
                      onPressed: () => context.read<OnboardingProvider>().removePreviousPeriod(d),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _add(context),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.plus, size: 11, color: AppColors.pur),
                  const SizedBox(width: 6),
                  Text('+ Add another period', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.pur, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
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
        min: 20,
        max: 40,
        current: ob.cycleLength.toDouble(),
        onChanged: (v) => context.read<OnboardingProvider>().setCycle(v.round()),
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
    return Opacity(
      opacity: canFinish ? 1 : 0.45,
      child: AppButton(label: 'Get Started', onTap: canFinish ? onComplete : null),
    );
  }
}
