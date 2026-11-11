import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi sqflite FFI untuk platform desktop (Windows / Linux / macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Mencegah crash akibat bug assertion bawaan engine Flutter Windows RawKeyboard saat menekan tombol Alt / Alt+Tab
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final stack = details.stack?.toString() ?? '';
    final message = exception is AssertionError ? (exception.message?.toString() ?? '') : '';

    if (message.contains('raw_keyboard.dart') ||
        message.contains('_keysPressed.isNotEmpty') ||
        stack.contains('raw_keyboard.dart:863') ||
        stack.contains('handleRawKeyMessage')) {
      // Abaikan bug internal engine Windows RawKeyboard saat transisi fokus/Alt
      return;
    }

    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    final errStr = error.toString();
    final stackStr = stack.toString();
    if (errStr.contains('raw_keyboard.dart') ||
        errStr.contains('_keysPressed.isNotEmpty') ||
        stackStr.contains('raw_keyboard.dart:863') ||
        stackStr.contains('handleRawKeyMessage')) {
      return true; // Ditangani, jangan sebarkan crash
    }
    return false;
  };

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
