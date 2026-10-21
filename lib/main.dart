import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CoffeeHubApp());
}

class CoffeeHubApp extends StatelessWidget {
  const CoffeeHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Labs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        // Mencegah bug sinkronisasi engine Chromium accessibility_bridge (AXTree) di Windows Desktop
        if (!kIsWeb && Platform.isWindows) {
          return ExcludeSemantics(child: child ?? const SizedBox());
        }
        return child ?? const SizedBox();
      },
      home: const SplashScreen(),
    );
  }
}
