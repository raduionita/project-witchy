import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Qwen `.chip` single/multi-select pill with optional leading icon.
class WitchyChip extends StatelessWidget {
  const WitchyChip({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = selected ? AppColors.kPurple : (isDark ? Theme.of(context).colorScheme.surfaceContainerLow : Colors.white);
    final Color fg = selected ? Colors.white : (isDark ? Theme.of(context).colorScheme.onSurface : const Color(0xFF5D4A70));
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.kPurple : AppColors.kLine),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 12, color: selected ? Colors.white : AppColors.kPurple), const SizedBox(width: 6)],
              Flexible(child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: fg))),
            ],
          ),
        ),
      ),
    );
  }
}
