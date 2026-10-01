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
    final date = ob.pickedDate;
    final nowYear = DateTime.now().year;
    final canFinish = ob.yearOfBirth != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Your Rhythms', style: AppText.h2),
              const SizedBox(height: 5),
              Text('Calibrate your lunar engine. When did your last bleeding phase commence?', style: AppText.sub),
              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Year of Birth', style: AppText.sans(11, c: AppColors.muted)),
                        const SizedBox(height: 3),
                        Text(ob.yearOfBirth?.toString() ?? 'Select year', style: AppText.serif(14, c: canFinish ? AppColors.ink : AppColors.placeholder)),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: ob.yearOfBirth,
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
              ),
              const SizedBox(height: 12),
              AppCard(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _pickDate,
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
              ),
              const SizedBox(height: 12),
              AppCard(
                child: AppSliderRow(
                  label: 'Cycle duration (stardust tides)',
                  value: '${ob.cycleLength} Days',
                  min: 20,
                  max: 40,
                  current: ob.cycleLength.toDouble(),
                  onChanged: (v) => context.read<OnboardingProvider>().setCycle(v.round()),
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: AppSliderRow(
                  label: 'Bleeding phase length',
                  value: '${ob.bleedLength} Days',
                  min: 2,
                  max: 10,
                  current: ob.bleedLength.toDouble(),
                  onChanged: (v) => context.read<OnboardingProvider>().setBleed(v.round()),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: canFinish ? 1 : 0.45,
                child: AppButton(label: 'Begin the Journey', onTap: canFinish ? _complete : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
