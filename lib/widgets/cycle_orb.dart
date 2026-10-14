import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class CycleOrb extends StatelessWidget {
  final String day;
  final String phase;

  /// Fraction of the cycle elapsed (0..1); drives the sweep fill from 12 o'clock.
  final double progress;
  const CycleOrb({super.key, this.day = '14', this.phase = 'Ovulation', this.progress = 0});

  @override
  Widget build(BuildContext context) {
    final fill = progress.clamp(0.0, 1.0);
    // SweepGradient stops must be strictly non-decreasing; keep a hairline of
    // track visible when the cycle has barely started.
    final stops = fill <= 0.001 ? const [0.0, 0.001, 0.001, 1.0] : <double>[0.0, fill, fill, 1.0];
    return Center(
      child: Semantics(
        label: 'Cycle day $day, $phase, ${(fill * 100).round()} percent complete',
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(startAngle: -1.57, endAngle: 4.71, stops: stops, colors: [AppColors.pur, AppColors.pur, AppColors.lav2, AppColors.lav2]),
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
      ),
    );
  }
}
