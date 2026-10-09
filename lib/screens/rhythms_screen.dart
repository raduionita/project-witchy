import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../navigation/app_nav.dart';
import '../providers/logging_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_slider_row.dart';

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
    context.read<LoggingProvider>().setFlow(onboarding.lastPeriodStart, 'Medium');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 12),
              const _YearOfBirthCard(),
              const SizedBox(height: 12),
              _LastBleedDateCard(onTap: _pickDate),
              const SizedBox(height: 12),
              const _CycleLengthCard(),
              const SizedBox(height: 12),
              const _BleedLengthCard(),
              const Spacer(),
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
        Text('Set Your Rhythms', style: AppText.h2),
        const SizedBox(height: 5),
        Text('Calibrate your lunar engine. When did your last bleeding phase commence?', style: AppText.sub),
      ],
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
              const FaIcon(AppIcons.cal, size: AppIconSize.head, color: AppColors.muted),
            ],
          ),
        ),
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
        label: 'Cycle duration (stardust tides)',
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
      child: AppButton(label: 'Begin the Journey', onTap: canFinish ? onComplete : null),
    );
  }
}
