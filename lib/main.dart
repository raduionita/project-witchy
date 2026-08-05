// Main entry point for Witchy app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WitchyApp extends StatelessWidget {
  const WitchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Witchy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
        useAdaptiveTheme: false,
      ),
      home: const HomeScreen(),
    );
  }

}

void main() async {
  // Initialize persistence service
  final prefs = await SharedPreferences.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CycleTrackerService(prefs)),
        ChangeNotifierProvider(
