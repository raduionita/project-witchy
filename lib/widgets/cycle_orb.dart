import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class CycleOrb extends StatelessWidget {
  final String day;
  final String phase;

  /// Fraction of the cycle elapsed (0..1); places the "today" marker and drives
  /// the sweep fill drawn behind it.
  final double progress;

  /// Cycle length used to convert cycle days into ring positions.
  final int cycleLength;

  /// Days 1..[bleedLength] render as the period segment.
  final int bleedLength;

  /// Inclusive cycle-day bounds of the fertile window.
  final int fertileStartDay;
  final int fertileEndDay;

  /// Swatch row under the orb explaining the ring colours.
  final bool showLegend;
  const CycleOrb({
    super.key,
    this.day = '14',
    this.phase = 'Ovulation',
    this.progress = 0,
    this.cycleLength = 28,
    this.bleedLength = 5,
    this.fertileStartDay = 10,
    this.fertileEndDay = 16,
    this.showLegend = true,
  });

  /// Ring gradient split into hard-edged slices: period, fertile window, and the
  /// rest of the cycle. Both SweepGradient stop lists must be strictly
  /// non-decreasing and cover 0..1, so each slice contributes its own start and
  /// end stop (zero-width slices are dropped rather than duplicated).
  SweepGradient _buildRingGradient() {
    final length = cycleLength <= 0 ? 28.0 : cycleLength.toDouble();
    final periodEnd = (bleedLength / length).clamp(0.0, 1.0);
    final fertileFrom = ((fertileStartDay - 1) / length).clamp(0.0, 1.0);
    final fertileTo = (fertileEndDay / length).clamp(0.0, 1.0);
    final marks = <double>[0.0, periodEnd, fertileFrom, fertileTo, 1.0]..sort();
    final stops = <double>[];
    final colors = <Color>[];
    for (var i = 0; i < marks.length - 1; i++) {
      final from = marks[i];
      final to = marks[i + 1];
      if (to - from < 0.0001) continue;
      final mid = (from + to) / 2;
      final Color color;
      if (mid < periodEnd) {
        color = AppColors.pink;
      } else if (mid > fertileFrom - 0.0001 && mid < fertileTo + 0.0001) {
        color = AppColors.pur;
      } else {
        color = AppColors.lav2;
      }
      stops..add(from)..add(to);
      colors..add(color)..add(color);
    }
    return SweepGradient(startAngle: -1.57, endAngle: 4.71, stops: stops, colors: colors);
  }

  Widget _buildOrb(double fill) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: _buildRingGradient()),
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
            const SizedBox(height: 4),
            Text('${(fill * 100).round()}% through', style: AppText.sans(9, c: AppColors.orbSub.withValues(alpha: .8))),
          ],
        ),
      ),
    );
  }

  /// Gold dot riding the ring at [fill], rotated from 12 o'clock.
  Widget _buildMarker(double fill) {
    return Transform.rotate(
      angle: fill * 2 * math.pi,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 2.5),
          decoration: BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: .6), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendEntry(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppText.sans(9.5, c: AppColors.muted)),
      ],
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendEntry(AppColors.pink, 'Period'),
          const SizedBox(width: 14),
          _buildLegendEntry(AppColors.pur, 'Fertile'),
          const SizedBox(width: 14),
          _buildLegendEntry(AppColors.gold, 'Today'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fill = progress.clamp(0.0, 1.0);
    return Center(
      child: Column(
        children: [
          Semantics(
            label: 'Cycle day $day, $phase. Period days 1-$bleedLength, fertile window days $fertileStartDay-$fertileEndDay, ${(fill * 100).round()} percent complete',
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildOrb(fill),
                Positioned.fill(child: _buildMarker(fill)),
              ],
            ),
          ),
          if (showLegend) _buildLegend(),
        ],
      ),
    );
  }
}
