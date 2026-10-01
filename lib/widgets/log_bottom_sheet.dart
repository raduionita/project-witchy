import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/day_log.dart';
import '../providers/logging_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import 'app_chip.dart';
import 'app_slider_row.dart';

const kMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

Future<void> showLogSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(expand: false, initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, builder: (_, ctrl) => LogBottomSheet(date: date, scroll: ctrl)),
  );
}

class LogBottomSheet extends StatefulWidget {
  final DateTime date;
  final ScrollController scroll;
  const LogBottomSheet({super.key, required this.date, required this.scroll});

  static const flows = ['None', 'Light', 'Medium', 'Heavy'];
  static const moods = [
    ('Enchanted', AppIcons.spark, AppColors.pur),
    ('Grounded', AppIcons.leaf, AppColors.green),
    ('Shadowy', AppIcons.moon, Color(0xFF5B4A8C)),
    ('Restless', AppIcons.zap, Color(0xFFC2703B)),
  ];
  static const symptoms = [
    ('Uterine Cramps', AppIcons.alert, AppColors.pur),
    ('Headache', AppIcons.zap, Color(0xFFC2703B)),
    ('Bloating', AppIcons.drop, Color(0xFF3E7BC0)),
    ('Fatigue', AppIcons.moon, Color(0xFF5B4A8C)),
  ];

  @override
  State<LogBottomSheet> createState() => _LogBottomSheetState();
}

class _LogBottomSheetState extends State<LogBottomSheet> {
  /// Snapshot taken before any edit, so cancel can discard changes.
  late final DayLog? _original;

  @override
  void initState() {
    super.initState();
    _original = context.read<LoggingProvider>().peekDay(widget.date)?.copy();
  }

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
        Text('Bleed Intensity', style: AppText.sec),
        const SizedBox(height: 8),
        Row(spacing: 8, children: [for (final f in LogBottomSheet.flows) Expanded(child: AppChip(label: f, selected: entry.flow == f, onTap: () => context.read<LoggingProvider>().setFlow(date, f)))]),
        const SizedBox(height: 12),
        Text('Emotional Currents', style: AppText.sec),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.4,
          children: [
            for (final m in LogBottomSheet.moods)
              AppChip(label: m.$1, icon: m.$2, iconColor: m.$3, selected: entry.moods.contains(m.$1), onTap: () => context.read<LoggingProvider>().toggleMood(date, m.$1)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Somatic Echoes', style: AppText.sec),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.4,
          children: [
            for (final s in LogBottomSheet.symptoms)
              AppChip(label: s.$1, icon: s.$2, iconColor: s.$3, selected: entry.symptoms.contains(s.$1), onTap: () => context.read<LoggingProvider>().toggleSymptom(date, s.$1)),
          ],
        ),
        const SizedBox(height: 12),
        AppSliderRow(label: 'Uterine Contraction Pain', value: 'Level ${entry.pain.round()}', min: 0, max: 10, current: entry.pain, onChanged: (v) => context.read<LoggingProvider>().setPain(date, v)),
        const SizedBox(height: 8),
        Text('Notes', style: AppText.sec),
        const SizedBox(height: 8),
        _NotesField(date: date, initialNotes: entry.notes),
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.pur)),
      ),
    );
  }
}
