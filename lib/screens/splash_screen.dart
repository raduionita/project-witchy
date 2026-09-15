import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.kPrimaryLightest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.kScreenMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: AppSizing.kLogoCircle,
                  height: AppSizing.kLogoCircle,
                  decoration: const BoxDecoration(color: AppColors.kPrimary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('W', style: text.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: AppSpacing.kMd),
                Text('Witchy', style: text.displayLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.kSm),
                Text(
                  'Your holistic cycle, fertility, and reproductive health companion',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: AppColors.kTextSecondary),
                ),
                const SizedBox(height: AppSpacing.kMd),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd, vertical: AppSpacing.kSm),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.kRadiusPill)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 14, color: AppColors.kPrimary),
                      const SizedBox(width: 6),
                      Flexible(child: Text('End-to-End Encrypted • Your Health Data Stays Yours', style: text.bodySmall?.copyWith(color: AppColors.kTextSecondary))),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.kXl),
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.kPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
