// Reusable widgets for Witchy app

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A circular button for adding cycle entries (period, ovulation)
class CycleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final IconData actionIcon;

  const CycleActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.primary,
    required this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(actionIcon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

}

/// A calendar day widget for visual cycle tracking
class CalendarDayWidget extends StatelessWidget {
  final int day;
  final DateTime date;
  final bool isPeriod;
  final bool isFertile;

  const CalendarDayWidget({
    super.key,
    required this.day,
    required this.date,
    required this.isPeriod,
    required this.isFertile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPeriod ? AppColors.primary : (isFertile ? AppColors.secondaryLight : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: Text(
        day.toString(),
        style: TextStyle(
          color: isPeriod ? Colors.white : AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }

}

/// A card widget for displaying health insights and predictions
class InsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const InsightCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// A progress bar for tracking cycle stages
class CycleProgressBar extends StatelessWidget {
  final int currentDay;
  final int totalDays;

  const CycleProgressBar({super.key, required this.currentDay, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Day ${currentDay}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            Text('of ${totalDays}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentDay / totalDays).clamp(0.0, 1.0),
          backgroundColor: AppColors.surface,
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
      ],
    );
  }

}
