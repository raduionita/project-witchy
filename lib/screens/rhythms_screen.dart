import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_slider_row.dart';

class RhythmsScreen extends StatelessWidget {
  const RhythmsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const FaIcon(AppIcons.back, size: AppIconSize.head, color: AppColors.muted),
                        Text('Harvest Moon (Oct)', style: AppText.serif(13)),
                        const FaIcon(AppIcons.right, size: AppIconSize.head, color: AppColors.muted),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (var d = 14; d <= 20; d++)
                          GestureDetector(
                            onTap: () => context.read<OnboardingProvider>().setDay(d),
                            child: Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: ob.selectedDay == d ? AppColors.pur : null),
                                  child: Text('$d', style: AppText.sans(11.5, c: ob.selectedDay == d ? Colors.white : AppColors.body, w: ob.selectedDay == d ? FontWeight.w600 : FontWeight.w400)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
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
              AppButton(
                label: 'Bind Magic Link',
                onTap: () async {
                  await context.read<OnboardingProvider>().finish();
                  if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
