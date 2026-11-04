import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: CoffeeHubApp()));
}

/// Root widget aplikasi Coffee Labs berbasis Riverpod ConsumerWidget & GoRouter deklaratif.
class CoffeeHubApp extends ConsumerWidget {
  const CoffeeHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Coffee Labs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Mencegah bug sinkronisasi engine Chromium accessibility_bridge (AXTree) di Windows Desktop
        if (!kIsWeb && Platform.isWindows) {
          return ExcludeSemantics(child: child ?? const SizedBox());
        }
        return child ?? const SizedBox();
      },
    );
  }
}
