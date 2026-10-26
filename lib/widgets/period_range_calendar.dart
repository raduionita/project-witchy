import 'package:flutter/material.dart';

import '../common/date_format.dart';
import '../models/period_range.dart';
import '../services/period_range_rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Booking-style month calendar for picking a period range.
///
/// The user taps the first day, then the last day, like an airplane or hotel
/// booker. Days that cannot start (or end) a period are disabled up front, so
/// the rules are visible before the user commits to a date.
class PeriodRangeCalendar extends StatefulWidget {
  const PeriodRangeCalendar({
    super.key,
    this.existing = const [],
    this.initial,
    this.initialStart,
    this.onChanged,
    this.today,
  });

  /// Periods already stored. Their days cannot be picked again.
  final List<PeriodRange> existing;

  /// The range being edited. It is excluded from the gap and overlap checks.
  final PeriodRange? initial;

  /// The day the calendar opens on when a new period is added.
  final DateTime? initialStart;

  /// Called on every selection change; null while the range is incomplete.
  final ValueChanged<PeriodRange?>? onChanged;

  /// Overrides "today" so tests can pick fixed dates.
  final DateTime? today;

  @override
  State<PeriodRangeCalendar> createState() => _PeriodRangeCalendarState();
}

class _PeriodRangeCalendarState extends State<PeriodRangeCalendar> {
  late DateTime _month;
  DateTime? _start;
  DateTime? _end;

  DateTime get _today {
    final t = widget.today ?? DateTime.now();
    return DateTime(t.year, t.month, t.day);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _start = initial.start;
      _end = initial.end;
      _month = DateTime(initial.start.year, initial.start.month);
    } else if (widget.initialStart != null) {
      final start = widget.initialStart!;
      _start = DateTime(start.year, start.month, start.day);
      _month = DateTime(start.year, start.month);
    } else {
      final today = _today;
      _month = DateTime(today.year, today.month);
    }
  }

  @override
  void didUpdateWidget(covariant PeriodRangeCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final initial = widget.initial;
    if (initial != null && oldWidget.initial != initial) {
      setState(() {
        _start = initial.start;
        _end = initial.end;
        _month = DateTime(initial.start.year, initial.start.month);
      });
    }
  }

  /// The picked range, or null while only the first day is known.
  PeriodRange? get _range {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return null;
    return PeriodRange(start: start, end: end);
  }

  /// True while the next tap picks the last day of the period.
  bool get _pickingEnd => _start != null && _end == null;

  void _onDayTap(DateTime day) {
    final start = _start;
    if (start != null && _end == null) {
      setState(() {
        if (day.isBefore(start)) {
          // An earlier day starts a new selection instead.
          _start = day;
        } else {
          _end = day;
        }
      });
    } else {
      setState(() {
        _start = day;
        _end = null;
      });
    }
    widget.onChanged?.call(_range);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  bool get _canGoBack {
    final earliest = _today.subtract(const Duration(days: PeriodRangeRules.maxHistoryDays));
    final limit = DateTime(earliest.year, earliest.month);
    return _month.isAfter(limit);
  }

  bool get _canGoForward {
    final today = _today;
    return _month.isBefore(DateTime(today.year, today.month));
  }

  Future<void> _jumpToMonth() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _month = DateTime(picked.year, picked.month);
    });
  }

  bool _isEnabled(DateTime day) {
    if (_pickingEnd) {
      return PeriodRangeRules.canEndOn(
        day,
        start: _start!,
        existing: widget.existing,
        editing: widget.initial,
        today: _today,
      );
    }
    return PeriodRangeRules.canStartOn(
      day,
      existing: widget.existing,
      editing: widget.initial,
      today: _today,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// The 42 cells of the month, Monday first, including the days that spill
  /// in from the neighbouring months.
  List<DateTime> _cells() {
    final first = DateTime(_month.year, _month.month, 1);
    final leading = first.weekday - 1;
    final origin = DateTime(first.year, first.month, 1 - leading);
    return [
      for (var i = 0; i < 42; i++)
        DateTime(origin.year, origin.month, origin.day + i),
    ];
  }

  String get _summary {
    final range = _range;
    if (range != null) {
      return '${AppDate.longRange(range.start, range.end)} · ${range.length} days';
    }
    final start = _start;
    if (start == null) return 'Tap a day to choose the first day.';
    return '${AppDate.long(start)} - now tap the last day.';
  }

  Widget _buildDayCell(DateTime day) {
    final inMonth = day.month == _month.month && day.year == _month.year;
    final enabled = _isEnabled(day);
    final start = _start;
    final end = _end;
    final isStart = start != null && _sameDay(day, start);
    final isEnd = end != null && _sameDay(day, end);
    final inSelection = start != null &&
        end != null &&
        !day.isBefore(start) &&
        !day.isAfter(end);
    final isSelected = isStart || isEnd || inSelection;
    final inExisting = widget.existing.any((range) => range.contains(day));
    final isToday = _sameDay(day, _today);

    Color background = Colors.transparent;
    Color text = inMonth ? AppColors.ink : AppColors.placeholder;
    FontWeight weight = FontWeight.w500;
    if (!inMonth || !enabled) {
      text = AppColors.placeholder;
    }
    if (isSelected) {
      background = AppColors.pur;
      text = Colors.white;
      weight = FontWeight.w700;
    } else if (isToday) {
      background = AppColors.lav;
    }

    return Semantics(
      key: Key('period-day-${day.year}-${day.month}-${day.day}'),
      label: '${AppDate.weekdayLong(day)}, ${AppDate.long(day)}',
      button: enabled,
      selected: isSelected,
      child: GestureDetector(
        onTap: enabled ? () => _onDayTap(day) : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: background,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.pur, width: 1.5)
                        : null,
                  ),
                ),
                Text('${day.day}', style: AppText.sans(13, w: weight, c: text)),
                if (inExisting && !isSelected)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Center(
              child: Text(label, style: AppText.sans(10, w: FontWeight.w700, c: AppColors.muted)),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          key: const Key('period-prev-month'),
          onPressed: _canGoBack ? () => _shiftMonth(-1) : null,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.ink,
          visualDensity: VisualDensity.compact,
          tooltip: 'Previous month',
        ),
        Expanded(
          child: InkWell(
            onTap: _jumpToMonth,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Text(
                  AppDate.monthYear(_month),
                  key: const Key('period-month-label'),
                  style: AppText.sans(12.5, w: FontWeight.w600, c: AppColors.ink),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          key: const Key('period-next-month'),
          onPressed: _canGoForward ? () => _shiftMonth(1) : null,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.ink,
          visualDensity: VisualDensity.compact,
          tooltip: 'Next month',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 4),
        _buildWeekDays(),
        const SizedBox(height: 4),
        for (var week = 0; week < 6; week++)
          Row(
            children: [
              for (var day = 0; day < 7; day++)
                Expanded(child: _buildDayCell(cells[week * 7 + day])),
            ],
          ),
        const SizedBox(height: 10),
        Text(
          _summary,
          key: const Key('period-range-summary'),
          textAlign: TextAlign.center,
          style: AppText.sans(11, w: FontWeight.w600, c: AppColors.ink),
        ),
        if (_range != null) ...[
          const SizedBox(height: 2),
          Text(
            'Tap a day to pick a new range.',
            textAlign: TextAlign.center,
            style: AppText.sans(10, c: AppColors.muted),
          ),
        ],
      ],
    );
  }
}
