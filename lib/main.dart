import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:bulka_frontend/screens/splash_screen/splash_screen.dart';

void main() {
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
      home:  SplashScreen(),
    );
  }
}