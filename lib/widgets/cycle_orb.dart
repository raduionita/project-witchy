import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class CycleOrb extends StatelessWidget {
  final String day;
  final String phase;
  const CycleOrb({super.key, this.day = '14', this.phase = 'Full Moon Peak'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(startAngle: -1.57, endAngle: 4.71, stops: const [0.0, 0.46, 0.46, 1.0], colors: [AppColors.pur, AppColors.pur, const Color(0xFFE9DBF5), const Color(0xFFE9DBF5)]),
        ),
        child: Container(
          width: 172,
          height: 172,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [AppColors.orbLight, AppColors.orbDark])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(AppIcons.moon, size: AppIconSize.xs, color: AppColors.gold),
                  const SizedBox(width: 5),
                  Text('CYCLE DAY', style: AppText.sans(8, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.3)),
                ],
              ),
              Text(day, style: AppText.serif(46, c: Colors.white, h: 1.0)),
              const SizedBox(height: 12),
              Text(phase, style: AppText.sans(10.5, c: AppColors.orbSub)),
            ],
          ),
        ),
      ),
    );
  }
}
