import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class AppContentColumn extends StatelessWidget {
  const AppContentColumn({super.key, required this.child, this.maxWidth = AppBreakpoints.kMaxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
  }
}
