import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/calendar_day.dart';
import '../../models/cycle_prediction.dart';
import '../../models/user_profile.dart';
import '../../providers/cycle_provider.dart';
import '../../services/calendar_fetcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../logging/log_period_sheet.dart';
import '../logging/log_symptom_sheet.dart';

/// Default profile used to render the calendar before onboarding completes.
const UserProfile kDefaultCalendarProfile = UserProfile(id: 'default');

/// Interactive month calendar with per-day cycle states.
///
/// Reads [CycleProvider] for logged days + predictions, renders a fixed
/// 42-cell grid (Monday-first) and supports both arrow buttons and horizontal
/// swipe to change months. Tapping a day toggles the period log for it.
class CycleCalendar extends StatefulWidget {
  const CycleCalendar({super.key});

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  DateTime _visibleMonth = dateOnly(DateTime.now());

  static final DateFormat _monthTitle = DateFormat('MMMM yyyy');

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  Future<void> _onDayTap(CalendarDay day) async {
    final CycleProvider provider = context.read<CycleProvider>();
    if (provider.isPeriodDay(day.date)) {
      await provider.removePeriodDay(day.date);
    } else {
      await LogPeriodSheet.show(context: context, date: day.date);
    }
  }

  Future<void> _onDayLongPress(CalendarDay day) async {
    await LogSymptomSheet.show(context: context, date: day.date);
  }

  @override
  Widget build(BuildContext context) {
    final CycleProvider provider = context.watch<CycleProvider>();
    final CyclePrediction? prediction = provider.prediction;
    final List<CalendarDay> grid = CalendarFetcher().fetchMonth(
      _visibleMonth,
      prediction: prediction,
      loggedPeriodDays: provider.periodDays,
      profile: provider.profile ?? kDefaultCalendarProfile,
    );

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.kSm),
        _buildWeekdayRow(),
        const SizedBox(height: AppSpacing.kXs),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              final double velocity = details.primaryVelocity ?? 0;
              if (velocity > 300) _changeMonth(-1);
              if (velocity < -300) _changeMonth(1);
            },
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: grid.length,
              itemBuilder: (BuildContext context, int index) => _DayCell(
                day: grid[index],
                onTap: _onDayTap,
                onLongPress: _onDayLongPress,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          _monthTitle.format(_visibleMonth),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> weekdays = <String>[
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    return Row(
      children: weekdays
          .map(
            (String label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.onTap,
    required this.onLongPress,
  });

  final CalendarDay day;
  final Future<void> Function(CalendarDay day) onTap;
  final Future<void> Function(CalendarDay day) onLongPress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? stateColor = _stateColor(day.state, scheme);
    final bool inMonth = day.state != CalendarDayState.none;
    final bool isPeriodOrFertile =
        day.state == CalendarDayState.period || day.state == CalendarDayState.ovulation;

    final Color textColor = day.isToday
        ? scheme.primary
        : stateColor != null && isPeriodOrFertile
            ? Colors.white
            : scheme.onSurface.withValues(alpha: inMonth ? 1.0 : 0.3);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.kRadiusLg),
      onTap: () => onTap(day),
      onLongPress: () => onLongPress(day),
      child: Container(
        alignment: Alignment.center,
        decoration: stateColor == null
            ? (day.isToday
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.primary, width: 2),
                  )
                : null)
            : BoxDecoration(
                shape: BoxShape.circle,
                color: stateColor.withValues(alpha: isPeriodOrFertile ? 1.0 : 0.25),
                border: day.isToday
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
        child: Text(
          '${day.date.day}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Color? _stateColor(CalendarDayState state, ColorScheme scheme) {
    return switch (state) {
      CalendarDayState.period => scheme.primary,
      CalendarDayState.predictedPeriod => scheme.primary,
      CalendarDayState.fertile => const Color(0xFF66BB6A),
      CalendarDayState.ovulation => const Color(0xFF2E7D32),
      CalendarDayState.none => null,
    };
  }
}
