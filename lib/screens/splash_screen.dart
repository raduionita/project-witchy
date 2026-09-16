import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.kCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: const BoxDecoration(color: Color(0xFFEFE2F8), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(gradient: AppGradients.kOrb, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(Icons.nights_stay_outlined, size: 42, color: AppColors.kGold),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Witchy', style: text.displayLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      'Track your cycle with magic',
                      style: text.bodyMedium?.copyWith(color: AppColors.kMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.star, size: 14, color: AppColors.kGold),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.kPurple)),
            ),
          ],
        ),
      ),
    );
  }
}
