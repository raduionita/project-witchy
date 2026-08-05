import 'package:flutter/material.dart';
import '../utils/theme_colors.dart';

class CycleInfoCard extends StatelessWidget {
  final String phase;
  final int dayNumber;
  final int totalDays;
  final bool isActive;
  final double? flowIntensity;
  final int? daysUntilNextPeriod;

  const CycleInfoCard({
    super.key,
    required this.phase,
    required this.dayNumber,
    required this.totalDays,
    required this.isActive,
    this.flowIntensity,
    this.daysUntilNextPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [WitchyColors.periodColor, WitchyColors.periodColor.withValues(alpha: 0.8)]
              : [WitchyColors.primary, WitchyColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phase,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isActive && flowIntensity != null) ...[
                _buildFlowIndicator(flowIntensity!),
                const SizedBox(width: 16),
              ],
              Text(
                isActive
                    ? 'Day $dayNumber of $totalDays'
                    : 'Day $dayNumber of $totalDays',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isActive && daysUntilNextPeriod != null)
            Text(
              '$daysUntilNextPeriod days until next period',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          if (!isActive && daysUntilNextPeriod != null) const SizedBox(height: 12),
          _buildProgressBar(isActive ? dayNumber : totalDays - (daysUntilNextPeriod ?? 0)),
        ],
      ),
    );
  }

  Widget _buildFlowIndicator(double intensity) {
    final bars = intensity.round().clamp(1, 5);
    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: 6,
          height: 12 + (index * 3),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index < bars ? Colors.white : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar(int currentDay) {
    final progress = (currentDay / totalDays).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        valueColor: const AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }
}
