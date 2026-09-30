import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const kPickerMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Opens a month/year picker sheet; resolves to the picked month (day 1) or null.
Future<DateTime?> showMonthPicker(BuildContext context, DateTime current) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => MonthPickerSheet(current: current),
  );
}

class MonthPickerSheet extends StatefulWidget {
  final DateTime current;
  const MonthPickerSheet({super.key, required this.current});

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  late int _year = widget.current.year;

  void _stepYear(int delta) {
    setState(() => _year = (_year + delta).clamp(1900, 2200));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chevron(Icons.chevron_left, () => _stepYear(-1)),
              Text('$_year', style: AppText.serif(17)),
              _chevron(Icons.chevron_right, () => _stepYear(1)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.3,
            children: [
              for (var m = 0; m < 12; m++) _monthCell(m + 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chevron(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
          child: Icon(icon, size: 18, color: AppColors.pur),
        ),
      ),
    );
  }

  Widget _monthCell(int month) {
    final selected = _year == widget.current.year && month == widget.current.month;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(DateTime(_year, month, 1)),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.pur : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.pur : AppColors.line),
          ),
          child: Text(kPickerMonths[month - 1], style: AppText.sans(11.5, w: FontWeight.w600, c: selected ? Colors.white : AppColors.chipText)),
        ),
      ),
    );
  }
}
