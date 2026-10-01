import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppEmblem extends StatelessWidget {
  final double size;
  const AppEmblem({super.key, this.size = 132});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFE2F8)),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.727,
        height: size * 0.727,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [AppColors.orbLight, AppColors.orbDark])),
        child: Image.asset('assets/images/cat-moon-mask-512.png', width: size * 0.36, height: size * 0.36, cacheWidth: 256, fit: BoxFit.contain, color: AppColors.gold, colorBlendMode: BlendMode.srcIn),
      ),
    );
  }
}
