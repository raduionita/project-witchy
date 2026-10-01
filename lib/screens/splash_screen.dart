import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.plum,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.min(constraints.maxWidth, constraints.maxHeight) * 0.25;
          return Center(child: Image.asset('assets/images/cat-moon-mask-512.png', width: side, height: side, fit: BoxFit.contain, color: AppColors.gold, colorBlendMode: BlendMode.srcIn));
        },
      ),
    );
  }
}
