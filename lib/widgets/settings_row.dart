import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SettingsRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final bool first;
  const SettingsRow({super.key, required this.label, required this.trailing, this.first = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: AppColors.line))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppText.sans(12, w: FontWeight.w500, c: AppColors.ink)), trailing]),
    );
  }
}
