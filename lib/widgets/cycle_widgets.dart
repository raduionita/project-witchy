import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'witchy_widgets.dart';

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
          gradient: SweepGradient(startAngle: -1.57, endAngle: 4.71, stops: const [0.0, 0.46, 0.46, 1.0], colors: const [AppColors.pur, AppColors.pur, Color(0xFFE9DBF5), Color(0xFFE9DBF5)]),
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
                  const Icon(Icons.nightlight_round, size: 12, color: AppColors.gold),
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

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;
  const StatCard({super.key, required this.label, required this.value, required this.sub, this.valueColor = AppColors.pur});

  @override
  Widget build(BuildContext context) {
    return WitchyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.sans(8.5, w: FontWeight.w700, c: AppColors.muted).copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 3),
          Text(value, style: AppText.serif(19, c: valueColor)),
          const SizedBox(height: 1),
          Text(sub, style: AppText.sans(10, c: AppColors.muted)),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const QuickAction({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
        child: Column(children: [IconBadge(icon: icon), const SizedBox(height: 8), Text(label, style: AppText.sans(10, w: FontWeight.w500, c: AppColors.chipText))]),
      ),
    );
  }
}

class CycleCalendar extends StatelessWidget {
  const CycleCalendar({super.key});
  @override
  Widget build(BuildContext context) {
    const fertile = {10, 11, 12, 13};
    const period = {14, 15, 16, 17, 18};
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Center(child: Text(d, style: AppText.sans(9, w: FontWeight.w600, c: AppColors.muted))),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        for (var day = 1; day <= 31; day++)
          Center(
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: period.contains(day) ? AppColors.pur : (fertile.contains(day) ? AppColors.fertileBg : null)),
              child: Text(
                '$day',
                style: AppText.sans(
                  11,
                  c: period.contains(day) ? Colors.white : (fertile.contains(day) ? AppColors.fertileText : AppColors.body),
                  w: (period.contains(day) || fertile.contains(day)) ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        const SizedBox.shrink(),
      ],
    );
  }
}

class TrendBars extends StatelessWidget {
  final List<double> heights = const [0.58, 0.72, 0.62, 0.78, 0.94, 0.68, 0.74];
  const TrendBars({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: heights[i],
                        widthFactor: 1,
                        child: Container(margin: const EdgeInsets.symmetric(horizontal: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: AppColors.barGradient)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text('M${i + 1}', style: AppText.sans(8.5, c: AppColors.muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
