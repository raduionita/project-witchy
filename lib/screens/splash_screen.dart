import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../widgets/app_icon.dart';

/// Loading screen shown while [AppBootstrap] initializes storage.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(
              Icons.water_drop,
              size: AppIconSize.huge,
              color: Colors.white,
            ),
            const SizedBox(height: AppSpacing.kSm),
            Text(
              'Witchy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kXl),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}