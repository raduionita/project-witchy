import 'dart:convert';

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

  /// Key on the scrolling body so visibility math uses the scroll viewport,
  /// not the whole sheet (the header sits outside the list now).
  final GlobalKey _listKey = GlobalKey();
  int _scrollRetries = 0;

  /// Flashes the requested category for a moment when the sheet opens at it.
  bool _highlight = false;

  @override
  void initState() {
    super.initState();
    _original = context.read<LoggingProvider>().peekDay(widget.date)?.copy();
    if (widget.scrollTo != null) {
      _targetKey = GlobalKey();
      // Wait out the sheet's entrance animation, then position the content and
      // flash the category so the jump is explained rather than jarring.
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() => _highlight = true);
        _scheduleScroll();
        Future<void>.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) setState(() => _highlight = false);
        });
      });
    }
  }

  void _scheduleScroll() => WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTarget());

  /// Scrolls the target category into view when it isn't fully visible already.
  void _scrollToTarget() {
    final targetCtx = _targetKey?.currentContext;
    final targetBox = targetCtx?.findRenderObject() as RenderBox?;
    final viewportBox = _listKey.currentContext?.findRenderObject() as RenderBox?;
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

  /// True when the day's entry differs from the snapshot taken on open, so the
  /// close button knows it has edits to warn about.
  bool get _isDirty =>
      jsonEncode((context.read<LoggingProvider>().peekDay(widget.date) ?? DayLog()).toJson()) != jsonEncode((_original ?? DayLog()).toJson());

  void _cancel() {
    context.read<LoggingProvider>().restoreDay(widget.date, _original);
    Navigator.of(context).pop();
  }

  /// Cancel, confirming first when the day has unsaved edits.
  Future<void> _confirmCancel() async {
    if (!_isDirty) return _cancel();
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text('Discard changes?', style: AppText.serif(17)),
            content: Text('Your edits for this day will not be saved.', style: AppText.sans(12.5, c: AppColors.body)),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Keep editing', style: AppText.sans(12.5, w: FontWeight.w600, c: AppColors.muted))),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Discard', style: AppText.sans(12.5, w: FontWeight.w600, c: AppColors.red))),
            ],
          ),
    );
    if (discard == true && mounted) _cancel();
  }

  void _approve() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final log = context.watch<LoggingProvider>();
    final date = widget.date;
    final entry = log.peekDay(date) ?? DayLog();
    final sections = <Widget>[
      _LogCycleSection(
        category: LogData.flows,
        sectionKey: _keyFor(LogData.flows),
        highlight: _highlight,
        selected: (o) => entry.flow.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().selectFlow(date, o.name),
      ),
      // Collection method only makes sense while a flow level is logged, so it
      // stays hidden (and is cleared) until bleeding is recorded.
      if (entry.flow.isNotEmpty)
        _LogCycleSection(
          category: LogData.collectionMethods,
          sectionKey: _keyFor(LogData.collectionMethods),
          highlight: _highlight,
          selected: (o) => entry.collection.contains(o.name),
          onTap: (o) => context.read<LoggingProvider>().toggleCollection(date, o.name),
        ),
      _LogCycleSection(
        category: LogData.painSymptoms,
        sectionKey: _keyFor(LogData.painSymptoms),
        highlight: _highlight,
        selected: (o) => entry.symptoms.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleSymptom(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.digestion,
        sectionKey: _keyFor(LogData.digestion),
        highlight: _highlight,
        selected: (o) => entry.digestion.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleDigestion(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.skinHair,
        sectionKey: _keyFor(LogData.skinHair),
        highlight: _highlight,
        selected: (o) => entry.skinHair.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleSkinHair(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.moods,
        sectionKey: _keyFor(LogData.moods),
        highlight: _highlight,
        selected: (o) => entry.moods.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleMood(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.cravings,
        sectionKey: _keyFor(LogData.cravings),
        highlight: _highlight,
        selected: (o) => entry.cravings.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleCravings(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.discharge,
        sectionKey: _keyFor(LogData.discharge),
        highlight: _highlight,
        selected: (o) => entry.discharge.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleDischarge(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.sex,
        sectionKey: _keyFor(LogData.sex),
        highlight: _highlight,
        selected: (o) => entry.sex.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleSex(date, o.name),
      ),
      _LogCycleSection(
        category: LogData.sleep,
        sectionKey: _keyFor(LogData.sleep),
        highlight: _highlight,
        selected: (o) => entry.sleep.contains(o.name),
        onTap: (o) => context.read<LoggingProvider>().toggleSleep(date, o.name),
      ),
    ];
    return Column(
      children: [
        // Pinned head: drag handle, date title with cancel/approve, subtitle.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              _SheetHeader(date: date, dirty: _isDirty, onCancel: _confirmCancel, onApprove: _approve),
              const SizedBox(height: 4),
              Text('Select what you are experiencing today.', style: AppText.sub, textAlign: TextAlign.center),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          // Eager build: the sheet is short enough that keeping every section
          // in the tree costs little, and it lets the open-at-category jump
          // find its target even when it starts far off screen.
          child: SingleChildScrollView(
            key: _listKey,
            controller: widget.scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  sections[i],
                  if (i < sections.length - 1) Divider(color: AppColors.line, thickness: 1, height: 16),
                ],
                _LogCycleSlider(date: date, pain: entry.pain),
                _TemperatureRow(date: date, temperature: entry.temperature),
                _OvulationTestRow(date: date, ovulationTest: entry.ovulationTest),
                const SizedBox(height: 8),
                Text('Notes', style: AppText.sec),
                const SizedBox(height: 8),
                _NotesField(date: date, initialNotes: entry.notes),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One log-sheet category: sec title + 2-col chip grid. Flow is the exception -
/// its provider call is single-select (see [LoggingProvider.selectFlow]).
class _LogCycleSection extends StatelessWidget {
  final LogCategory category;
  final GlobalKey? sectionKey;

  /// True while this section is the one the sheet was opened at, so it can
  /// flash a tinted outline instead of silently scrolling into view.
  final bool highlight;
  final bool Function(LogOption) selected;
  final void Function(LogOption) onTap;
  const _LogCycleSection({required this.category, this.sectionKey, this.highlight = false, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = category.color ?? AppColors.pur;
    // Option icons carry the category hue; the title uses the neutral
    // section-title token so vivid accents never fight the heading.
    final iconColor = AppColors.readableOn(accent, AppColors.bg);
    // Only the section the sheet was opened at owns a key, so this is that one.
    final active = highlight && sectionKey != null;
    return AnimatedContainer(
      key: sectionKey,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? accent.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.title, style: AppText.sec),
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
                AppChip(label: o.name, icon: o.icon, iconColor: iconColor, iconCount: o.iconCount, selected: selected(o), selectedColor: accent, onTap: () => onTap(o)),
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

/// Ovulation test result: null = unlogged, otherwise positive/negative.
/// Tapping the active result clears it back to unlogged.
class _OvulationTestRow extends StatelessWidget {
  final DateTime date;
  final String? ovulationTest;
  const _OvulationTestRow({required this.date, required this.ovulationTest});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LoggingProvider>();
    const label = 'Ovulation Test';
    final status = switch (ovulationTest) {
      'positive' => 'Positive',
      'negative' => 'Negative',
      _ => 'Not logged',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.sec),
            Row(
              children: [
                Text(status, style: AppText.serif(13.5, c: ovulationTest == 'positive' ? AppColors.pink : AppColors.muted)),
                if (ovulationTest != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24, maxWidth: 24, maxHeight: 24),
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    tooltip: 'Clear result',
                    onPressed: () => provider.setOvulationTest(date, null),
                    icon: FaIcon(AppIcons.cancel, size: 14, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AppChip(
              label: 'Positive',
              selected: ovulationTest == 'positive',
              onTap: () => provider.setOvulationTest(date, ovulationTest == 'positive' ? null : 'positive'),
            ),
            const SizedBox(width: 8),
            AppChip(
              label: 'Negative',
              selected: ovulationTest == 'negative',
              onTap: () => provider.setOvulationTest(date, ovulationTest == 'negative' ? null : 'negative'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final DateTime date;

  /// True when the day has unsaved edits, so Save is emphasised and Cancel
  /// knows to confirm before discarding.
  final bool dirty;
  final VoidCallback onCancel;
  final VoidCallback onApprove;
  const _SheetHeader({required this.date, required this.dirty, required this.onCancel, required this.onApprove});

  static const _box = BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34);

  /// Round icon button with its action label underneath, so Cancel and Save
  /// read as actions rather than bare glyphs.
  Widget _circleButton({required FaIconData icon, required Color color, required String label, required VoidCallback onPressed, bool emphasis = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: _box,
          style: IconButton.styleFrom(backgroundColor: emphasis ? color : AppColors.card, shape: const CircleBorder()),
          tooltip: label,
          onPressed: onPressed,
          icon: FaIcon(icon, size: AppIconSize.base, color: emphasis ? Colors.white : color),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppText.sans(9.5, w: FontWeight.w600, c: emphasis ? color : AppColors.muted)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _circleButton(icon: AppIcons.cancel, color: AppColors.red, label: 'Cancel', onPressed: onCancel),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${kMonths[date.month - 1]} ${date.day}, ${date.year}', textAlign: TextAlign.center, style: AppText.serif(17)),
          ),
        ),
        _circleButton(icon: AppIcons.approve, color: AppColors.green, label: 'Save', onPressed: onApprove, emphasis: dirty),
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
        hintText: 'Add any notes for this day…',
        hintStyle: AppText.sans(12.5, c: AppColors.placeholder),
        filled: true,
        fillColor: AppColors.fieldBg,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pur)),
      ),
    );
  }
}
