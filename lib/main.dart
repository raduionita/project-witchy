import 'package:flutter/material.dart';

void main() {
  runApp(const WitchyApp());
}

class WitchyApp extends StatelessWidget {
  const WitchyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Witchy', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)), home: const WitchyHomePage(title: 'Witchy Home Page'));
  }
}

class WitchyHomePage extends StatefulWidget {
  const WitchyHomePage({super.key, required this.title});

  final String title;

  @override
  State<WitchyHomePage> createState() => _WitchyHomePageState();
}

class _WitchyHomePageState extends State<WitchyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Witchy is a comprehensive health tracking application designed to help you understand and monitor your menstrual cycle, fertility window, pregnancy, and overall reproductive health',
            ),
          ],
        ),
      ),
    );
  }
}
