import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Sanctuary cycle-day orb: conic progress ring + radial plum orb.
class CycleOrb extends StatelessWidget {
  const CycleOrb({super.key, required this.cycleDay, required this.subtitle, required this.progress});

  final int cycleDay;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            startAngle: -1.5708,
            endAngle: 4.7124,
            stops: <double>[progress.clamp(0.0, 1.0), progress.clamp(0.0, 1.0)],
            colors: const <Color>[AppColors.kPurple, Color(0xFFE9DBF5)],
          ),
        ),
        child: Container(
          width: 172,
          height: 172,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.kOrb),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.nights_stay_outlined, size: 12, color: AppColors.kGold),
                  SizedBox(width: 5),
                  Text('CYCLE DAY', style: TextStyle(fontSize: 8, letterSpacing: 1.28, fontWeight: FontWeight.w700, color: AppColors.kGold)),
                ],
              ),
              Text('$cycleDay', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 46, height: 1.0)),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(subtitle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Color(0xFFD9C2EC))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
