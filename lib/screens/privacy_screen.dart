import 'package:flutter/material.dart';

import '../navigation/app_nav.dart';
import '../services/prefs_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/legal_links.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final PrefsService _prefs = PrefsService();
  bool _terms = false;
  bool _privacy = false;
  bool _child = false;

  bool get _allAgreed => _terms && _privacy && _child;

  Future<void> _accept() async {
    await _prefs.setPrivacyAccepted();
    if (!mounted) return;
    context.reset('/auth');
  }

  void _decline() => context.backOr('/');

  void _open(String title, String url) => context.go(LegalLinks.route(title, url));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Your Privacy Promise', style: AppText.h2, textAlign: TextAlign.center),
                        const SizedBox(height: 5),
                        Text(
                          'Witchy keeps your body\u2019s stories where they belong \u2014 on this device. Nothing you log is uploaded, sold, or shared with third parties, and Witchy never replaces professional medical care.',
                          style: AppText.sub,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        AppCard(
                          child: Column(
                            children: [
                              _ConsentRow(
                                first: true,
                                title: 'I agree to the Terms of Service',
                                link: 'Read the Terms',
                                value: _terms,
                                onChanged: (v) => setState(() => _terms = v ?? false),
                                onLink: () => _open('Terms of Service', LegalLinks.terms),
                              ),
                              _ConsentRow(
                                title: 'I agree to the Privacy Policy',
                                link: 'Read the Privacy Policy',
                                value: _privacy,
                                onChanged: (v) => setState(() => _privacy = v ?? false),
                                onLink: () => _open('Privacy Policy', LegalLinks.privacy),
                              ),
                              _ConsentRow(
                                title: 'I confirm I am of the required age and accept the Child Protection notice',
                                link: 'Read the Child Protection Policy',
                                value: _child,
                                onChanged: (v) => setState(() => _child = v ?? false),
                                onLink: () => _open('Child Protection', LegalLinks.childProtection),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: _OutlineButton(label: 'Refuse', onTap: _decline)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: _allAgreed ? 1 : 0.45,
                      child: AppButton(label: 'Accept', onTap: _allAgreed ? _accept : null),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String title;
  final String link;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onLink;
  final bool first;
  const _ConsentRow({required this.title, required this.link, required this.value, required this.onChanged, required this.onLink, this.first = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: first ? Colors.transparent : AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.pur,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onChanged,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink), textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onLink,
                      child: Text(link, style: AppText.sans(10.5, c: AppColors.pur).copyWith(decoration: TextDecoration.underline), textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
        child: Text(label, textAlign: TextAlign.center, style: AppText.sans(13.5, w: FontWeight.w600, c: AppColors.ink)),
      ),
    );
  }
}
