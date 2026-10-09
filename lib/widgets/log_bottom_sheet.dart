import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../common/log_data.dart';
import '../models/day_log.dart';
import '../providers/logging_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import 'app_chip.dart';
import 'app_slider_row.dart';

const kMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/// Opens the log sheet for [date]; when [scrollTo] is given the sheet scrolls
/// (only if needed) to that category's section.
Future<void> showLogSheet(BuildContext context, DateTime date, {LogCategory? scrollTo}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder:
        (_) =>
            DraggableScrollableSheet(expand: false, initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, builder: (_, ctrl) => LogBottomSheet(date: date, scroll: ctrl, scrollTo: scrollTo)),
  );
}

class LogBottomSheet extends StatefulWidget {
  final DateTime date;
  final ScrollController scroll;
  final LogCategory? scrollTo;
  const LogBottomSheet({super.key, required this.date, required this.scroll, this.scrollTo});

  @override
  State<LogBottomSheet> createState() => _LogBottomSheetState();
}

class _LogBottomSheetState extends State<LogBottomSheet> {
  /// Snapshot taken before any edit, so cancel can discard changes.
  late final DayLog? _original;

  /// Key attached to the [widget.scrollTo] section so it can be revealed.
  GlobalKey? _targetKey;
  int _scrollRetries = 0;

  @override
  void initState() {
    super.initState();
    _original = context.read<LoggingProvider>().peekDay(widget.date)?.copy();
    if (widget.scrollTo != null) {
      _targetKey = GlobalKey();
      // Wait out the sheet's entrance animation, then position the content.
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _scheduleScroll();
      });
    }
  }

  void _scheduleScroll() => WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTarget());

  /// Scrolls the target category into view when it isn't fully visible already.
  void _scrollToTarget() {
    final targetCtx = _targetKey?.currentContext;
    final targetBox = targetCtx?.findRenderObject() as RenderBox?;
    final viewportBox = context.findRenderObject() as RenderBox?;
    if (!mounted || targetCtx == null || targetBox == null || viewportBox == null || !targetBox.attached || !viewportBox.attached) {
      if (_scrollRetries++ < 3) _scheduleScroll();
      return;
    }
    final top = targetBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
    final bottom = top + targetBox.size.height;
    if (top >= 0 && bottom <= viewportBox.size.height) return; // already fully visible
    final delta = top < 0 ? top - 12 : bottom - viewportBox.size.height + 12;
    final position = widget.scroll.position;
    final target = (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent).toDouble();
    if ((target - position.pixels).abs() < 1) return;
    position.animateTo(target, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
  }

  GlobalKey? _keyFor(LogCategory category) => widget.scrollTo?.title == category.title ? _targetKey : null;

  void _cancel() {
    context.read<LoggingProvider>().restoreDay(widget.date, _original);
    Navigator.of(context).pop();
  }

  void _approve() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final log = context.watch<LoggingProvider>();
    final date = widget.date;
    final entry = log.peekDay(date) ?? DayLog();
    return ListView(
      controller: widget.scroll,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 12),
        _SheetHeader(date: date, original: _original, onCancel: _cancel, onApprove: _approve),
        const SizedBox(height: 4),
        Text('Select physical and mental essences flowing within you.', style: AppText.sub, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        _LogCycleSection(
          category: LogData.flows,
          sectionKey: _keyFor(LogData.flows),
          selected: (o) => entry.flow.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleFlow(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.collectionMethods,
          sectionKey: _keyFor(LogData.collectionMethods),
          selected: (o) => entry.collection.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleCollection(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.painSymptoms,
          sectionKey: _keyFor(LogData.painSymptoms),
          selected: (o) => entry.symptoms.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleSymptom(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.digestion,
          sectionKey: _keyFor(LogData.digestion),
          selected: (o) => entry.digestion.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleDigestion(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.skinHair,
          sectionKey: _keyFor(LogData.skinHair),
          selected: (o) => entry.skinHair.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleSkinHair(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.moods,
          sectionKey: _keyFor(LogData.moods),
          selected: (o) => entry.moods.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleMood(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.cravings,
          sectionKey: _keyFor(LogData.cravings),
          selected: (o) => entry.cravings.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleCravings(date, o.name),
        ),
        _LogCycleSection(
          category: LogData.discharge,
          sectionKey: _keyFor(LogData.discharge),
          selected: (o) => entry.discharge.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleDischarge(date, o.name),
        ),
        _LogCycleSection(category: LogData.sex, sectionKey: _keyFor(LogData.sex), selected: (o) => entry.sex.contains(o.name), onTap: (o) => context.read<LoggingProvider>().toggleSex(date, o.name)),
        _LogCycleSection(
          category: LogData.sleep,
          sectionKey: _keyFor(LogData.sleep),
          selected: (o) => entry.sleep.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleSleep(date, o.name),
        ),
        _LogCycleSlider(date: date, pain: entry.pain),
        _TemperatureRow(date: date, temperature: entry.temperature),
        const SizedBox(height: 8),
        Text('Notes', style: AppText.sec),
        const SizedBox(height: 8),
        _NotesField(date: date, initialNotes: entry.notes),
      ],
    );
  }
}

/// One log-sheet category: sec title + 2-col multi-toggle chip grid.
class _LogCycleSection extends StatelessWidget {
  final LogCategory category;
  final GlobalKey? sectionKey;
  final bool Function(LogOption) selected;
  final void Function(LogOption) onTap;
  const _LogCycleSection({required this.category, this.sectionKey, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.readableOn(category.color ?? AppColors.pur, AppColors.bg);
    return Padding(
      key: sectionKey,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.title, style: AppText.sec.copyWith(color: color)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 4.8,
            children: [
              for (final o in category.options)
                AppChip(label: o.name, icon: o.icon, iconColor: color, iconCount: o.iconCount, selected: selected(o), selectedColor: category.color ?? AppColors.pur, onTap: () => onTap(o)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Uterine contraction pain slider bound to the day's log entry.
class _LogCycleSlider extends StatelessWidget {
  final DateTime date;
  final double pain;
  const _LogCycleSlider({required this.date, required this.pain});

  @override
  Widget build(BuildContext context) {
    return AppSliderRow(label: 'Uterine Contraction Pain', value: 'Level ${pain.round()}', min: 0, max: 10, current: pain, onChanged: (v) => context.read<LoggingProvider>().setPain(date, v));
  }
}

/// Basal body temperature entry: null = unlogged, otherwise 35.0-38.0 °C.
class _TemperatureRow extends StatelessWidget {
  final DateTime date;
  final double? temperature;
  const _TemperatureRow({required this.date, required this.temperature});

  static const double _min = 35.0;
  static const double _max = 38.0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LoggingProvider>();
    final label = 'Basal Body Temperature';
    if (temperature == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppText.sec), Text('Not logged', style: AppText.serif(13.5, c: AppColors.muted))]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: AppChip(label: 'Add reading', icon: AppIcons.thermometer, selected: false, onTap: () => provider.setTemperature(date, 36.5)),
          ),
        ],
      );
    }
    final t = temperature!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.sec),
            Row(
              children: [
                Text('${t.toStringAsFixed(1)} °C', style: AppText.serif(13.5, c: AppColors.pur)),
                const SizedBox(width: 4),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24, maxWidth: 24, maxHeight: 24),
                  padding: EdgeInsets.zero,
                  iconSize: 14,
                  tooltip: 'Clear reading',
                  onPressed: () => provider.setTemperature(date, null),
                  icon: FaIcon(AppIcons.cancel, size: 14, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(
            context,
          ).copyWith(activeTrackColor: AppColors.pur, inactiveTrackColor: AppColors.sliderTrack, thumbColor: Colors.white, overlayShape: SliderComponentShape.noOverlay, trackHeight: 4),
          child: Slider(
            min: _min,
            max: _max,
            divisions: 30,
            value: t.clamp(_min, _max),
            onChanged: (v) => provider.setTemperature(date, double.parse(v.toStringAsFixed(1))),
          ),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final DateTime date;
  final DayLog? original;
  final VoidCallback onCancel;
  final VoidCallback onApprove;
  const _SheetHeader({required this.date, required this.original, required this.onCancel, required this.onApprove});

  static const _box = BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34);

  Widget _circleButton({required FaIconData icon, required Color color, required VoidCallback onPressed}) {
    return IconButton(
      constraints: _box,
      style: IconButton.styleFrom(backgroundColor: Colors.white, shape: const CircleBorder()),
      onPressed: onPressed,
      icon: FaIcon(icon, size: AppIconSize.base, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circleButton(icon: AppIcons.cancel, color: AppColors.red, onPressed: onCancel),
        Expanded(child: Text('${kMonths[date.month - 1]} ${date.day}, ${date.year}', textAlign: TextAlign.center, style: AppText.serif(17))),
        _circleButton(icon: AppIcons.approve, color: AppColors.green, onPressed: onApprove),
      ],
    );
  }
}

class _NotesField extends StatefulWidget {
  final DateTime date;
  final String initialNotes;
  const _NotesField({required this.date, required this.initialNotes});

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<_NotesField> {
  late final TextEditingController controller = TextEditingController(text: widget.initialNotes);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: AppText.sans(12.5, c: AppColors.ink),
      onChanged: (v) => context.read<LoggingProvider>().setNotes(widget.date, v),
      decoration: InputDecoration(
        hintText: 'Whisper your thoughts, rituals, and reflections…',
        hintStyle: AppText.sans(12.5, c: AppColors.placeholder),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pur)),
      ),
    );
  }
}
