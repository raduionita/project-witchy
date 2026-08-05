import 'package:flutter/material.dart';
import '../utils/theme_colors.dart';

class FertilityIndicator extends StatelessWidget {
  final bool isFertile;
  final int daysUntilOvulation;

  const FertilityIndicator({
    super.key,
    required this.isFertile,
    required this.daysUntilOvulation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: isFertile ? WitchyColors.ovulationColor : WitchyColors.lightText,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Fertility Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFertile ? WitchyColors.ovulationColor : WitchyColors.lightText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isFertile
                      ? 'Fertile Window Open'
                      : daysUntilOvulation > 0
                          ? 'Next ovulation in $daysUntilOvulation days'
                          : 'Low fertility phase',
                  style: TextStyle(
                    fontSize: 14,
                    color: isFertile ? WitchyColors.ovulationColor : WitchyColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
