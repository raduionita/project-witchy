import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../utils/app_icons.dart';

class MoonRow extends StatelessWidget {
  const MoonRow({super.key});
  @override
  Widget build(BuildContext context) {
    const moons = [(-40.0, AppColors.pur), (-18.0, AppColors.pur), (0.0, AppColors.gold), (18.0, AppColors.pur), (40.0, AppColors.pur)];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (rot, color) in moons) ...[
          Transform.rotate(angle: rot * math.pi / 180, child: FaIcon(AppIcons.moon, color: color, size: AppIconSize.base)),
          if (rot != 40.0) const SizedBox(width: 16),
        ],
      ],
    );
  }
}
