import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/app_theme.dart';
import '../symptom_categories.dart';

/// Multi-select symptom picker grouped by category.
///
/// Renders each [SymptomCategory] from [kSymptomCategories] as a labelled row
/// of [FilterChip]s, so users can browse symptoms by the area they affect.
class SymptomChipGroup extends StatelessWidget {
  const SymptomChipGroup({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  /// Currently selected symptom names.
  final Set<String> selected;

  /// Callback invoked when a chip is toggled with its label.
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final SymptomCategory category in kSymptomCategories(l10n))
          _category(context, category),
      ],
    );
  }

  Widget _category(BuildContext context, SymptomCategory category) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.kSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.kXs),
          Wrap(
            spacing: AppSpacing.kSm,
            runSpacing: AppSpacing.kSm,
            children: category.symptoms
                .map(
                  (String item) => FilterChip(
                    label: Text(item),
                    selected: selected.contains(item),
                    onSelected: (_) => onToggle(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}