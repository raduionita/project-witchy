import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/calendar_day.dart';
import '../../models/cycle_prediction.dart';
import '../../models/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/calendar_fetcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../widgets/day_markers.dart';
import '../logging/log_biometrics_sheet.dart';
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
  static const int _kInitialPage = 10000;
  static final DateFormat _monthTitle = DateFormat('MMMM yyyy');

  final PageController _pageController = PageController(initialPage: _kInitialPage);
  final DateTime _anchorMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int _page = _kInitialPage;

  DateTime _monthForPage(int page) {
    return DateTime(_anchorMonth.year, _anchorMonth.month + (page - _kInitialPage), 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    _pageController.animateToPage(_page + delta, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
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

  Widget _buildHeader() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Text(_monthTitle.format(_monthForPage(_page)), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
              IconButton(tooltip: l10n.biometricsTitle, onPressed: () => LogBiometricsSheet.show(context: context, date: DateTime.now()), icon: const Icon(Icons.thermostat)),
            ],
          ),
        ),
        IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  Widget _buildWeekdayRow(MaterialLocalizations localizations, int firstDayOfWeek) {
    final int offset = firstDayOfWeek % 7;
    final List<String> weekdays = <String>[for (int i = 0; i < 7; i++) localizations.narrowWeekdays[(offset + i) % 7]];
    return Row(
      key: const ValueKey<String>('calendar-weekday-row'),
      children:
          weekdays
              .map(
                (String label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CycleProvider provider = context.watch<CycleProvider>();
    final BiometricProvider biometrics = context.watch<BiometricProvider>();
    final int firstDayOfWeek = provider.profile?.firstDayOfWeek ?? DateTime.monday;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.kSm),
        _buildWeekdayRow(localizations, firstDayOfWeek),
        const SizedBox(height: AppSpacing.kXs),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _page = page),
            itemBuilder: (BuildContext context, int index) {
              final CyclePrediction? prediction = provider.prediction;
              final List<CalendarDay> grid = CalendarFetcher().fetchMonth(
                _monthForPage(index),
                prediction: prediction,
                loggedPeriodDays: provider.periodDays,
                profile: provider.profile ?? kDefaultCalendarProfile,
                firstDayOfWeek: firstDayOfWeek,
              );
              final List<CalendarDay> marked = <CalendarDay>[
                for (final CalendarDay day in grid) CalendarDay(date: day.date, state: day.state, isToday: day.isToday, markers: biometrics.markersFor(day.date)),
              ];
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                itemCount: marked.length,
                itemBuilder: (BuildContext context, int gridIndex) => _DayCell(day: marked[gridIndex], onTap: _onDayTap, onLongPress: _onDayLongPress),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.onTap, required this.onLongPress});

  final CalendarDay day;
  final Future<void> Function(CalendarDay day) onTap;
  final Future<void> Function(CalendarDay day) onLongPress;
  static const double _kMinTextContrast = 3.0;

  Color _readableTextColor(ColorScheme scheme, Color background) {
    return ColorUtils.readableText(background, lightText: Colors.white, darkText: scheme.onSurface);
  }

  Color? _stateColor(CalendarDayState state, ColorScheme scheme) {
    return switch (state) {
      CalendarDayState.period => AppColors.kCyclePeriod,
      CalendarDayState.predictedPeriod => AppColors.kCyclePeriod,
      CalendarDayState.fertile => AppColors.kCycleFertile,
      CalendarDayState.ovulation => AppColors.kCycleOvulation,
      CalendarDayState.none => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? stateColor = _stateColor(day.state, scheme);
    final bool inMonth = day.state != CalendarDayState.none;
    final bool isPeriodOrFertile = day.state == CalendarDayState.period || day.state == CalendarDayState.ovulation;

    final Color background =
        stateColor == null
            ? scheme.surface
            : isPeriodOrFertile
            ? stateColor
            : Color.alphaBlend(stateColor.withValues(alpha: 0.25), scheme.surface);

    final Color textColor;
    if (day.isToday) {
      textColor = ColorUtils.contrast(scheme.primary, background) >= _kMinTextContrast ? scheme.primary : _readableTextColor(scheme, background);
    } else if (isPeriodOrFertile) {
      textColor = _readableTextColor(scheme, background);
    } else if (inMonth) {
      textColor = scheme.onSurface;
    } else {
      textColor = scheme.onSurface.withValues(alpha: 0.45);
    }

    final Color ring = scheme.surfaceContainerHighest.withValues(alpha: 0.4);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.kRadiusM),
      onTap: () => onTap(day),
      onLongPress: () => onLongPress(day),
      child: Container(
        alignment: Alignment.center,
        decoration:
            stateColor == null
                ? BoxDecoration(shape: BoxShape.circle, border: Border.all(color: day.isToday ? scheme.primary : ring, width: day.isToday ? 2 : 1))
                : BoxDecoration(shape: BoxShape.circle, color: stateColor.withValues(alpha: isPeriodOrFertile ? 1.0 : 0.25), border: day.isToday ? Border.all(color: scheme.primary, width: 2) : null),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${day.date.day}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor, fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal)),
            if (day.markers.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 1), child: FittedBox(fit: BoxFit.scaleDown, child: DayMarkersRow(markers: day.markers, color: textColor))),
          ],
        ),
      ),
    );
  }
}
