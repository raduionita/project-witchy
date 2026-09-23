import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/witchy_icons.dart';
import 'witchy_widgets.dart';

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

Future<void> showLogSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(expand: false, initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, builder: (_, ctrl) => LogBottomSheet(date: date, scroll: ctrl)),
  );
}

class LogBottomSheet extends StatelessWidget {
  final DateTime date;
  final ScrollController scroll;
  const LogBottomSheet({super.key, required this.date, required this.scroll});

  static const flows = ['None', 'Light', 'Medium', 'Heavy'];
  static const moods = [
    ('Enchanted', WitchyIcons.spark, AppColors.pur),
    ('Grounded', WitchyIcons.leaf, Color(0xFF4C8C4A)),
    ('Shadowy', WitchyIcons.moon, Color(0xFF5B4A8C)),
    ('Restless', WitchyIcons.zap, Color(0xFFC2703B)),
  ];
  static const symptoms = [
    ('Uterine Cramps', WitchyIcons.alert, AppColors.pur),
    ('Headache', WitchyIcons.zap, Color(0xFFC2703B)),
    ('Bloating', WitchyIcons.drop, Color(0xFF3E7BC0)),
    ('Fatigue', WitchyIcons.moon, Color(0xFF5B4A8C)),
  ];

  @override
  Widget build(BuildContext context) {
    final log = context.watch<LoggingProvider>();
    final entry = log.day(date);
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 12),
        Text('${_months[date.month - 1]} ${date.day}, ${date.year}', style: AppText.serif(17)),
        const SizedBox(height: 4),
        Text('Select physical and mental essences flowing within you.', style: AppText.sub),
        const SizedBox(height: 12),
        Text('Bleed Intensity', style: AppText.sec),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final f in flows) WitchyChip(label: f, selected: entry.flow == f, onTap: () => context.read<LoggingProvider>().setFlow(date, f))]),
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
          children: [for (final m in moods) WitchyChip(label: m.$1, icon: m.$2, iconColor: m.$3, selected: entry.moods.contains(m.$1), onTap: () => context.read<LoggingProvider>().toggleMood(date, m.$1))],
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
            for (final s in symptoms) WitchyChip(label: s.$1, icon: s.$2, iconColor: s.$3, selected: entry.symptoms.contains(s.$1), onTap: () => context.read<LoggingProvider>().toggleSymptom(date, s.$1)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Notes', style: AppText.sec),
        const SizedBox(height: 8),
        _NotesField(date: date, initialNotes: entry.notes),
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
