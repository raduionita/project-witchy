import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/router/app_route_path.dart';
import '../../app/router/app_router_delegate.dart';
import '../../l10n/app_localizations.dart';
import '../../models/calendar_day.dart';
import '../../models/cycle_phase.dart';
import '../../models/cycle_prediction.dart';
import '../../models/ovulation_test_result.dart';
import '../../models/tracking_mode.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/calendar_fetcher.dart';
import '../../utils/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import '../../widgets/day_markers.dart';
import '../calendar/cycle_calendar.dart';
import '../logging/log_biometrics_sheet.dart';
import '../logging/log_period_sheet.dart';
import '../logging/log_symptom_sheet.dart';
import '../perimenopause/perimenopause_screen.dart';
import '../pregnancy/pregnancy_screen.dart';

/// The Home tab: today's status and cycle predictions.
///
/// Content adapts to the user's [TrackingMode]: cycle mode shows the classic
/// prediction cards, while pregnancy/perimenopause modes hand off to their
/// stage-specific screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure predictions are fresh after onboarding/navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CycleProvider>().recompute();
    });
  }

  Widget _dayStrip(Color background, Color foreground) {
    final CycleProvider provider = context.watch<CycleProvider>();
    final BiometricProvider biometrics = context.watch<BiometricProvider>();
    final DateTime today = dateOnly(DateTime.now());
    final CyclePrediction? prediction = provider.prediction;
    final List<CalendarDay> grid = CalendarFetcher().fetchMonth(today, prediction: prediction, loggedPeriodDays: provider.periodDays, profile: provider.profile ?? kDefaultCalendarProfile);
    final Map<DateTime, CalendarDay> byDate = <DateTime, CalendarDay>{for (final CalendarDay d in grid) dateOnly(d.date): d};

    final Set<DateTime> wanted = <DateTime>{for (int i = -_DayStripGrid.kDaysBefore; i <= _DayStripGrid.kDaysAfter; i++) addDays(today, i)};
    final List<CalendarDay> days = <CalendarDay>[
      for (final DateTime date in wanted.toList()..sort())
        _withMarkers(
          byDate[date] ?? CalendarDay(date: date, state: CalendarDayState.none, isToday: date == today),
          biometrics,
        ),
    ];

    return _DayStripGrid(days: days, today: today, background: background, foreground: foreground, onDayTap: _onDayTap, onDayLongPress: _onDayLongPress);
  }

  CalendarDay _withMarkers(CalendarDay day, BiometricProvider biometrics) {
    return CalendarDay(
      date: day.date,
      state: day.state,
      isToday: day.isToday,
      markers: biometrics.markersFor(day.date),
    );
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

  Widget _onboardingCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      onTap: () {
        final AppRouterDelegate delegate = Router.of(context).routerDelegate as AppRouterDelegate;
        delegate.go(const AppOnboardingRoute());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary), const Spacer(), const Icon(Icons.chevron_right)]),
          const SizedBox(height: AppSpacing.kSm),
          Text(l10n.homeSetupTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.kXs),
          Text(l10n.homeSetupBody, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  /// White card holding the calendar day-strip and today's biometric badges.
  Widget _stripCard(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardBg = isDark ? theme.colorScheme.surfaceContainerLow : AppColors.kSurfaceBase;
    final Color fg = theme.colorScheme.onSurface;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.homeToday, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
              IconButton(
                tooltip: l10n.biometricsTitle,
                onPressed: () => LogBiometricsSheet.show(context: context, date: DateTime.now()),
                icon: const Icon(Icons.thermostat),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.kSm),
          _dayStrip(cardBg, fg),
          _todayBiometrics(context, fg),
        ],
      ),
    );
  }

  /// 180px progress dial: lavender track, primary arc by cycle progress.
  Widget _cycleDial(BuildContext context, CyclePrediction prediction) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final int cycleDay = daysBetween(prediction.currentCycleStart, DateTime.now()) + 1;
    final int cycleLength = daysBetween(prediction.currentCycleStart, prediction.nextPeriodStart);
    final double progress = cycleLength <= 0 ? 0 : (cycleDay / cycleLength).clamp(0.0, 1.0);
    final CyclePhase phase = prediction.currentCyclePhase;

    return Center(
      child: Container(
        width: AppSizing.kCycleCircle,
        height: AppSizing.kCycleCircle,
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerLow : AppColors.kSurfaceBase,
          shape: BoxShape.circle,
          boxShadow: AppShadows.kHero,
        ),
        child: CustomPaint(
          painter: _CycleProgressPainter(
            progress: progress,
            track: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.kPrimaryLightest,
            arc: isDark ? theme.colorScheme.primary : AppColors.kPrimary,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.homeCycleDayLabel, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text('$cycleDay', style: theme.textTheme.displayMedium?.copyWith(color: isDark ? theme.colorScheme.onSurface : AppColors.kPrimary)),
                const SizedBox(height: AppSpacing.kSm),
                Text(cyclePhaseLabel(l10n, phase), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Period in" and "Fertility window" status cards side by side.
  Widget _statusCards(BuildContext context, CyclePrediction prediction) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final int days = daysBetween(DateTime.now(), prediction.nextPeriodStart);
    final bool fertileNow = prediction.fertileWindow.contains(DateTime.now());

    Widget card({required String title, required String value, bool highlighted = false}) {
      return Expanded(
        child: AppCard(
          highlighted: highlighted,
          child: Column(
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.kXs),
              Text(value, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card(title: l10n.homePeriodIn, value: l10n.homeInDays(days)),
        const SizedBox(width: AppSpacing.kMd),
        card(
          title: l10n.homeFertileWindow,
          value: fertileNow ? l10n.homePeakToday : '${DateFormat('MMM d').format(prediction.fertileWindow.start)} – ${DateFormat('MMM d').format(prediction.fertileWindow.end)}',
          highlighted: fertileNow,
        ),
      ],
    );
  }

  /// Phase-aware tip banner below the status cards.
  Widget _tipBanner(BuildContext context, CyclePrediction prediction) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String tip = switch (prediction.currentCyclePhase) {
      CyclePhase.menstruation => l10n.homeTipMenstrual,
      CyclePhase.follicular => l10n.homeTipFollicular,
      CyclePhase.ovulatory => l10n.homeTipOvulatory,
      CyclePhase.luteal => l10n.homeTipLuteal,
    };
    return AppInfoBanner(
      icon: Icons.lightbulb_outline,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${l10n.homeTipTitle} ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: tip),
          ],
        ),
      ),
    );
  }

  Widget _todayBiometrics(BuildContext context, Color onFill) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BiometricProvider biometrics = context.watch<BiometricProvider>();
    final DateTime today = dateOnly(DateTime.now());
    final double? bbt = biometrics.bbtOn(today);
    final OvulationTestResult? lh = biometrics.ovulationTestOn(today);
    if (bbt == null && lh == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.kMd),
      child: Wrap(
        spacing: AppSpacing.kSm,
        runSpacing: AppSpacing.kSm,
        children: <Widget>[
          if (bbt != null)
            _todayBadge(l10n.todayBbt(bbt.toStringAsFixed(2)), onFill),
          if (lh != null)
            _todayBadge(l10n.todayLh(ovulationTestLabel(l10n, lh)), onFill),
        ],
      ),
    );
  }

  Widget _todayBadge(String label, Color onFill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kSm, vertical: AppSpacing.kXs),
      decoration: BoxDecoration(
        color: onFill.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.kRadiusPill),
        border: Border.all(color: onFill.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onFill, fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CycleProvider provider = context.watch<CycleProvider>();
    final CyclePrediction? prediction = provider.prediction;
    final bool onboarded = provider.profile?.onboarded ?? false;

    final TrackingMode mode = provider.profile?.mode ?? TrackingMode.cycle;
    if (mode == TrackingMode.pregnancy) return const PregnancyScreen();
    if (mode == TrackingMode.perimenopause) return const PerimenopauseScreen();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          _stripCard(context),
          const SizedBox(height: AppSpacing.kMd),
          if (!onboarded || prediction == null)
            _onboardingCard(context)
          else ...[
            const SizedBox(height: AppSpacing.kSm),
            _cycleDial(context, prediction),
            const SizedBox(height: AppSpacing.kLg),
            _statusCards(context, prediction),
            const SizedBox(height: AppSpacing.kMd),
            _tipBanner(context, prediction),
          ],
        ],
      ),
    );
  }
}

/// Progress ring for the home cycle dial: lavender track with primary arc.
class _CycleProgressPainter extends CustomPainter {
  const _CycleProgressPainter({required this.progress, required this.track, required this.arc});

  final double progress;
  final Color track;
  final Color arc;

  static const double _stroke = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - _stroke) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      Paint()
        ..color = arc
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CycleProgressPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.track != track || oldDelegate.arc != arc;
}

/// Horizontally scrollable strip of day cells with edge-arrow buttons.
///
/// Shows [kDaysBefore] days before today and [kDaysAfter] after, scrolling by
/// [kScrollDays] per arrow press. Exactly [_kVisibleDays] columns fit the
/// viewport at once; the arrow buttons overlay the strip's edges so all seven
/// days stay visible. Every column reserves equal top/bottom slots so that all
/// circles sit on a common, vertically centered axis; only today's column
/// fills those slots with the month (above) and weekday (below) labels.
class _DayStripGrid extends StatefulWidget {
  const _DayStripGrid({required this.days, required this.today, required this.background, required this.foreground, required this.onDayTap, required this.onDayLongPress});

  static const int kDaysBefore = 40;
  static const int kDaysAfter = 40;
  static const int kScrollDays = 5;
  static const int _kVisibleDays = 7;
  static const double _kLabelHeight = 22;
  static const double _kMinDayWidth = 40;
  static const double _kMaxDayWidth = 64;
  static const double _kCellSize = 40;
  static const double _kFadeWidth = 28;
  static const double _kArrowSize = 32;

  final List<CalendarDay> days;
  final DateTime today;
  final Color background;
  final Color foreground;
  final Future<void> Function(CalendarDay day) onDayTap;
  final Future<void> Function(CalendarDay day) onDayLongPress;

  @override
  State<_DayStripGrid> createState() => _DayStripGridState();
}

class _DayStripGridState extends State<_DayStripGrid> {
  final ScrollController _controller = ScrollController();

  static final DateFormat _monthFormat = DateFormat('MMMM');
  static final DateFormat _weekdayFormat = DateFormat('EEEE');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnToday());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _todayIndex => widget.days.indexWhere((CalendarDay d) => dateOnly(d.date) == dateOnly(widget.today));

  double get _dayWidth {
    if (!_controller.hasClients) return _DayStripGrid._kCellSize;
    final double raw = _controller.position.viewportDimension / _DayStripGrid._kVisibleDays;
    return raw.clamp(_DayStripGrid._kMinDayWidth, _DayStripGrid._kMaxDayWidth);
  }

  void _centerOnToday() {
    if (!_controller.hasClients) return;
    final double viewport = _controller.position.viewportDimension;
    final double target = _todayIndex * _dayWidth - (viewport - _dayWidth) / 2;
    _controller.jumpTo(target.clamp(0.0, _controller.position.maxScrollExtent));
  }

  void _scrollByDays(int days) {
    if (!_controller.hasClients) return;
    final double target = _controller.offset + days * _dayWidth;
    _controller.animateTo(target.clamp(0.0, _controller.position.maxScrollExtent), duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Widget _buildColumn(BuildContext context, CalendarDay day, {required double dayWidth, required bool isMiddle}) {
    final String month = isMiddle ? _monthFormat.format(day.date) : '';
    final String weekday = isMiddle ? _weekdayFormat.format(day.date) : '';
    return SizedBox(
      width: dayWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _DayStripGrid._kLabelHeight, child: month.isEmpty ? null : Center(child: _monthWeekdayLabel(context, month))),
          const SizedBox(height: AppSpacing.kXs),
          _DayCell(day: day, background: widget.background, foreground: widget.foreground, onTap: widget.onDayTap, onLongPress: widget.onDayLongPress),
          const SizedBox(height: AppSpacing.kXs),
          SizedBox(height: _DayStripGrid._kLabelHeight, child: weekday.isEmpty ? null : Center(child: _monthWeekdayLabel(context, weekday))),
        ],
      ),
    );
  }

  Widget _monthWeekdayLabel(BuildContext context, String text) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: widget.foreground.withValues(alpha: 0.7)));
  }

  Widget _edgeFade(Color toTransparent, {required bool fadeLeft}) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: fadeLeft ? [widget.background, toTransparent] : [toTransparent, widget.background]),
        ),
      ),
    );
  }

  Widget _arrow(IconData icon, VoidCallback onPressed) {
    return SizedBox(width: _DayStripGrid._kArrowSize, child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, color: widget.foreground), onPressed: onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final int todayIndex = _todayIndex;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double dayWidth = (constraints.maxWidth / _DayStripGrid._kVisibleDays).clamp(_DayStripGrid._kMinDayWidth, _DayStripGrid._kMaxDayWidth);
        final Color transparent = widget.background.withValues(alpha: 0);
        return SizedBox(
          height: _DayStripGrid._kLabelHeight * 2 + AppSpacing.kXs * 2 + _DayStripGrid._kCellSize,
          child: Stack(
            children: [
              Positioned.fill(
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemExtent: dayWidth,
                  itemCount: widget.days.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CalendarDay day = widget.days[index];
                    return _buildColumn(context, day, dayWidth: dayWidth, isMiddle: index == todayIndex);
                  },
                ),
              ),
              Positioned(left: 0, top: 0, bottom: 0, width: _DayStripGrid._kFadeWidth, child: _edgeFade(transparent, fadeLeft: true)),
              Positioned(right: 0, top: 0, bottom: 0, width: _DayStripGrid._kFadeWidth, child: _edgeFade(transparent, fadeLeft: false)),
              Positioned(left: 0, top: 0, bottom: 0, child: Center(child: _arrow(Icons.chevron_left, () => _scrollByDays(-_DayStripGrid.kScrollDays)))),
              Positioned(right: 0, top: 0, bottom: 0, child: Center(child: _arrow(Icons.chevron_right, () => _scrollByDays(_DayStripGrid.kScrollDays)))),
            ],
          ),
        );
      },
    );
  }
}

/// Single circle in the strip, mirroring the calendar day-cell visuals and
/// interactions.
class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.background, required this.foreground, required this.onTap, required this.onLongPress});

  final CalendarDay day;
  final Color background;
  final Color foreground;
  final Future<void> Function(CalendarDay day) onTap;
  final Future<void> Function(CalendarDay day) onLongPress;

  static const double _size = 40;
  static const double _kMinTextContrast = 3.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? stateColor = _stateColor(day.state, scheme);
    final bool isSolid = day.state == CalendarDayState.period || day.state == CalendarDayState.ovulation;

    final Color cellBackground =
        stateColor == null
            ? background
            : isSolid
            ? stateColor
            : Color.alphaBlend(stateColor.withValues(alpha: 0.25), background);

    final Color textColor;
    if (day.isToday) {
      textColor = ColorUtils.contrast(foreground, cellBackground) >= _kMinTextContrast ? foreground : _readableTextColor(cellBackground);
    } else if (isSolid) {
      textColor = _readableTextColor(cellBackground);
    } else {
      textColor = foreground;
    }

    final Color ring = foreground.withValues(alpha: 0.25);

    final BoxDecoration decoration =
        stateColor == null
            ? BoxDecoration(shape: BoxShape.circle, border: Border.all(color: day.isToday ? foreground : ring, width: day.isToday ? 2 : 1))
            : BoxDecoration(shape: BoxShape.circle, color: stateColor.withValues(alpha: isSolid ? 1.0 : 0.25), border: day.isToday ? Border.all(color: foreground, width: 2) : null);

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => onTap(day),
      onLongPress: () => onLongPress(day),
      child: Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: decoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${day.date.day}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor, fontSize: day.isToday ? 16 : 12, fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal),
            ),
            if (day.markers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DayMarkersRow(markers: day.markers, size: 7, color: textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _readableTextColor(Color cellBackground) {
    return ColorUtils.readableText(cellBackground, lightText: Colors.white, darkText: foreground);
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
}
