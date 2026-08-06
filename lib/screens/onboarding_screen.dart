import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../widgets/app_button.dart';

/// First-run collection of baseline cycle data.
///
/// Full onboarding flow is implemented in Phase 3; this scaffold provides the
/// route target and a placeholder CTA.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.kLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Welcome to Witchy',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.kSm),
              Text(
                'Let\'s set up your cycle so we can give you accurate predictions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              AppButton(
                label: 'Get Started',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}