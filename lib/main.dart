import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:bulka_frontend/dev/dev_launcher_screen.dart';
import 'package:bulka_frontend/screens/splash_screen/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the system bars on every Android version (Android 15+ forces
  // this anyway), so layouts look the same on all devices. Screens and the
  // bottom nav bar pad themselves with the system insets.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  runApp(const BulkaApp());
}

class BulkaApp extends StatelessWidget {
  const BulkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Debug builds boot straight into the dev screen launcher so any
      // screen can be opened directly, without ever touching this file.
      // kDebugMode is false in release/profile builds, where the app
      // always starts at SplashScreen exactly as before — the production
      // flow is untouched.
      home: kDebugMode ? const DevLauncherScreen() : const SplashScreen(),
    );
  }
}
