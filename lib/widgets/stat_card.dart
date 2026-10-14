import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  /// When set the card gets a pointer cursor and reports taps; without it the
  /// card is a plain read-only tile.
  final VoidCallback? onTap;
  StatCard({super.key, required this.label, required this.value, required this.sub, Color? valueColor, this.onTap})
    : valueColor = valueColor ?? AppColors.pur;

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label.toUpperCase(), style: AppText.sans(8.5, w: FontWeight.w700, c: AppColors.muted).copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 3),
        ],
        Text(value, style: AppText.serif(19, c: valueColor)),
        const SizedBox(height: 1),
        Text(sub, style: AppText.sans(10, c: AppColors.muted)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = AppCard(child: _buildContent());
    if (onTap == null) return card;
    return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: card));
  }
}
