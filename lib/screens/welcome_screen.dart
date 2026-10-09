import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_nav.dart';
import '../providers/onboarding_provider.dart';
import '../services/prefs_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_emblem.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<OnboardingProvider>().onboarded) context.go('/dashboard');
    });
  }

  Future<void> _awaken() async {
    final accepted = await context.read<PrefsService>().isPrivacyAccepted();
    if (!mounted) return;
    context.go(accepted ? '/onboarding' : '/privacy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppEmblem(),
                  const SizedBox(height: 14),
                  Text('Witchy', style: AppText.brand),
                  const SizedBox(height: 4),
                  Text('Track your cycle with magic', style: AppText.sans(12, c: AppColors.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: AppButton(label: 'Awaken Your Power', onTap: _awaken),
            ),
          ],
        ),
      ),
    );
  }
}
