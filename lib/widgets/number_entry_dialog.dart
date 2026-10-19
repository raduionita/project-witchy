import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Compact numeric editor for values that can also be dragged or stepped.
///
/// Sliders use it so a user can type an exact number instead of hunting for a
/// thumb position, and the onboarding period rows use it for their per-period
/// length. Pops the chosen int, or null when dismissed; the field and the
/// -/+ steppers are both held inside [min]..[max], so callers never re-clamp.
class NumberEntryDialog extends StatefulWidget {
  final String title;
  final int initial;
  final int min;
  final int max;

  /// Optional line under the field, e.g. what the number describes.
  final String? hint;
  const NumberEntryDialog({super.key, required this.title, required this.initial, required this.min, required this.max, this.hint});

  @override
  State<NumberEntryDialog> createState() => _NumberEntryDialogState();
}

class _NumberEntryDialogState extends State<NumberEntryDialog> {
  late final TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial.clamp(widget.min, widget.max);
    _controller = TextEditingController(text: '$_value');
    _selectAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAll() => _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);

  /// Steps to [next] and mirrors it into the field so the two never disagree.
  void _setValue(int next) {
    final clamped = next.clamp(widget.min, widget.max);
    setState(() => _value = clamped);
    _controller.text = '$clamped';
    _selectAll();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    Navigator.of(context).pop((parsed ?? _value).clamp(widget.min, widget.max));
  }

  Widget _buildStepButton({required IconData icon, required String tooltip, VoidCallback? onTap}) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: AppColors.pur,
        disabledForegroundColor: AppColors.line,
      ),
      icon: Icon(icon, size: 20),
    );
  }

  Widget _buildField() {
    return SizedBox(
      width: 92,
      child: TextField(
        controller: _controller,
        autofocus: true,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        keyboardType: const TextInputType.numberWithOptions(signed: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        style: AppText.serif(19, c: AppColors.ink),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.fieldBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.line)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: AppText.secIn),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepButton(icon: Icons.remove, tooltip: 'Decrease', onTap: _value > widget.min ? () => _setValue(_value - 1) : null),
              const SizedBox(width: 6),
              _buildField(),
              const SizedBox(width: 6),
              _buildStepButton(icon: Icons.add, tooltip: 'Increase', onTap: _value < widget.max ? () => _setValue(_value + 1) : null),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.hint ?? 'Enter a number between ${widget.min} and ${widget.max}.',
            style: AppText.sans(10.5, c: AppColors.muted, h: 1.4),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('Set')),
      ],
    );
  }
}
