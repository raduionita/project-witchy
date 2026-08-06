import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import 'legal_content.dart';

/// Renders a locally supplied legal document (privacy policy or terms).
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.kMd),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.kMd),
          itemBuilder: (BuildContext context, int index) {
            final LegalSection section = sections[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.kSm),
                Text(
                  section.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
