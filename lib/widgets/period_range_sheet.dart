import 'package:flutter/material.dart';

import '../models/period_record.dart';
import '../models/period_range.dart';
import '../providers/logging_provider.dart';
import '../widgets/period_range_calendar_sheet.dart';

/// Shared add/edit sheet for a past period.
///
/// A null [record] adds a manual period; an existing record can be changed or
/// deleted. The dates are picked with the same booking-style calendar and the
/// same rules the onboarding card uses, and they are written through
/// [LoggingProvider] so every screen sees the same list immediately.
Future<void> showPeriodRangeSheet(
  BuildContext context, {
  required LoggingProvider logging,
  PeriodRecord? record,
  DateTime? initialStart,
}) async {
  final existing = <PeriodRange>[
    for (final saved in logging.periodRecords)
      PeriodRange(start: saved.start, end: saved.end ?? saved.start),
  ];
  final editing = record == null
      ? null
      : PeriodRange(start: record.start, end: record.end ?? record.start);
  final picked = await showPeriodRangeCalendarSheet(
    context,
    existing: existing,
    editing: editing,
    initialStart: initialStart,
    onDelete: record == null ? null : (sheetContext) => _delete(sheetContext, logging, record),
  );
  if (picked == null) return;
  if (record == null) {
    logging.addPeriodRecord(picked.start, end: picked.end);
  } else {
    logging.updatePeriodRecord(
      record.start,
      start: picked.start,
      end: picked.end,
      source: record.source,
      estimated: record.estimated,
    );
  }
}

/// Confirms the deletion, then removes the saved dates. Flow logged day by day
/// is not touched.
Future<void> _delete(
  BuildContext sheetContext,
  LoggingProvider logging,
  PeriodRecord record,
) async {
  final confirmed = await showDialog<bool>(
    context: sheetContext,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete this period?'),
      content: const Text(
        'This removes the saved dates. Flow logged day by day is not changed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  logging.deletePeriodRecord(record.start);
  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
}
