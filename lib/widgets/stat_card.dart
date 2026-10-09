import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;
  StatCard({super.key, required this.label, required this.value, required this.sub, Color? valueColor})
      : valueColor = valueColor ?? AppColors.pur;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
