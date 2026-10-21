import 'package:flutter/material.dart';

import '../models/period_range.dart';
import '../services/period_range_rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/danger_button.dart';
import '../widgets/period_range_calendar.dart';

/// Bottom sheet that picks a period range with the booking-style calendar.
///
/// Returns the picked range, or null when the user cancels. The sheet only
/// offers the save button when the selection satisfies
/// [PeriodRangeRules.validate].
Future<PeriodRange?> showPeriodRangeCalendarSheet(
  BuildContext context, {
  List<PeriodRange> existing = const [],
  PeriodRange? editing,
  DateTime? initialStart,
  DateTime? today,
  void Function(BuildContext sheetContext)? onDelete,
}) {
  return showModalBottomSheet<PeriodRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PeriodRangeCalendarSheet(
      existing: existing,
      editing: editing,
      initialStart: initialStart,
      today: today,
      onDelete: onDelete,
    ),
  );
}

class _PeriodRangeCalendarSheet extends StatefulWidget {
  const _PeriodRangeCalendarSheet({
    required this.existing,
    this.editing,
    this.initialStart,
    this.today,
    this.onDelete,
  });

  final List<PeriodRange> existing;
  final PeriodRange? editing;
  final DateTime? initialStart;
  final DateTime? today;
  final void Function(BuildContext sheetContext)? onDelete;

  @override
  State<_PeriodRangeCalendarSheet> createState() =>
      _PeriodRangeCalendarSheetState();
}

class _PeriodRangeCalendarSheetState extends State<_PeriodRangeCalendarSheet> {
  PeriodRange? _range;
  String? _error;

  /// Reason the current selection cannot be saved, or null when it can.
  String? _validationError() {
    final range = _range;
    if (range == null) return null;
    return PeriodRangeRules.validate(
      range: range,
      existing: widget.existing,
      editing: widget.editing,
      today: widget.today,
    );
  }

  void _onChanged(PeriodRange? range) {
    setState(() {
      _range = range;
      _error = null;
    });
  }

  void _save() {
    final range = _range;
    if (range == null) return;
    final error = _validationError();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(range);
  }

  Widget _buildHeader() {
    final editing = widget.editing != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          editing ? 'Edit past period' : 'Add past period',
          style: AppText.secIn,
        ),
        const SizedBox(height: 4),
        Text(
          'Tap the first day, then the last day of the period.',
          style: AppText.sans(11, c: AppColors.muted, h: 1.45),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = _error ?? _validationError();
    final canSave = _range != null && error == null;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              PeriodRangeCalendar(
                existing: widget.existing,
                initial: widget.editing,
                initialStart: widget.initialStart,
                today: widget.today,
                onChanged: _onChanged,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error,
                  key: const Key('period-range-error'),
                  style: AppText.sans(11, w: FontWeight.w600, c: AppColors.red),
                ),
              ],
              const SizedBox(height: 14),
              Opacity(
                opacity: canSave ? 1 : 0.45,
                child: AppButton(
                  label: 'Save period',
                  onTap: canSave ? _save : null,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 4),
                DangerButton(
                  label: 'Delete period',
                  onTap: () => widget.onDelete!(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
