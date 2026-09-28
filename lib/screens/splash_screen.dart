import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/app_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<OnboardingProvider>().onboarded) Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Emblem(),
                  SizedBox(height: 14),
                  Text('Witchy', style: AppText.brand),
                  SizedBox(height: 4),
                  Text('Track your cycle with magic', style: AppText.sans(12, c: AppColors.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                children: [
                  AppButton(label: 'Awaken Your Power', busy: auth.busy, onTap: () => Navigator.pushNamed(context, '/onboarding')),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already a witch? ', style: AppText.sans(11, c: AppColors.muted)),
                      GestureDetector(onTap: () => Navigator.pushNamed(context, '/auth'), child: Text('Sign In', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFE2F8)),
      alignment: Alignment.center,
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [AppColors.orbLight, AppColors.orbDark])),
        child: const FaIcon(AppIcons.moon, size: AppIconSize.xl, color: AppColors.gold),
      ),
    );
  }
}
