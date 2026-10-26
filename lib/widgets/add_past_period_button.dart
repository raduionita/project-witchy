import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Compact primary action used wherever a past period is added.
class AddPastPeriodButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddPastPeriodButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add past period',
      child: Semantics(
        button: true,
        label: 'Add past period',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: AppColors.plumGradient, boxShadow: const [AppColors.primaryShadow]),
            child: const Center(child: FaIcon(AppIcons.calendarAdd, size: 14, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
