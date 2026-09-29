import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../utils/app_icons.dart';

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
        child: FaIcon(AppIcons.moon, size: size * 0.32, color: AppColors.gold),
      ),
    );
  }
}
