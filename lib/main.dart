import 'package:flutter/material.dart';

import 'app/app_bootstrap.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppBootstrap bootstrap = AppBootstrap();
  runApp(WitchyApp(bootstrap: bootstrap));

  // Kick off async storage load; the splash screen renders until
  // [AppBootstrap.isBootstrapped] flips, which the router listens to.
  await bootstrap.initialize();
}
