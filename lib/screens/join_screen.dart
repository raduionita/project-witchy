import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../navigation/app_nav.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/app_emblem.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  Future<void> _signIn(Future<void> Function() action) async {
    await action();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final error = auth.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (!auth.signedIn) return;
    if (!context.mounted) return;
    context.reset('/onboarding');
  }

  void _skip() => context.reset('/onboarding');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppEmblem(size: 112),
                    const SizedBox(height: 14),
                    Text('Join Witchy', style: AppText.h2),
                    const SizedBox(height: 6),
                    Text(
                      'Your rhythms stay on this device. Sign up to keep your magic in sync, or slip in incognito and begin straight away.',
                      style: AppText.sub,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _Soc(label: 'Continue with Google', icon: AppIcons.google, onTap: () => _signIn(() => context.read<AuthProvider>().signInWithGoogle())),
              const SizedBox(height: 10),
              _Soc(label: 'Continue with Apple', icon: AppIcons.apple, onTap: () => _signIn(() => context.read<AuthProvider>().signInWithApple())),
              const SizedBox(height: 10),
              _Ghost(label: 'Skip for now', onTap: _skip),
            ],
          ),
        ),
      ),
    );
  }
}

class _Soc extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final VoidCallback onTap;
  const _Soc({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: AppColors.plumGradient, boxShadow: const [AppColors.primaryShadow]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [FaIcon(icon, size: AppIconSize.head, color: Colors.white), const SizedBox(width: 8), Text(label, style: AppText.btn)],
        ),
      ),
    );
  }
}

class _Ghost extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Ghost({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.plum2, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(AppIcons.moon, size: AppIconSize.sm, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: AppText.btn),
          ],
        ),
      ),
    );
  }
}
