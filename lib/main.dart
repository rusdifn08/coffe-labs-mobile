import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/communities/presentation/services/community_deep_link_listener.dart';
import 'features/notifications/data/services/device_token_lifecycle_service.dart';
import 'features/notifications/data/services/local_push_orchestrator.dart';
import 'features/notifications/presentation/controllers/notification_center_controller.dart';
import 'features/notifications/presentation/controllers/notification_deep_link_controller.dart';
import 'features/scanner/data/local/prototype_database.dart';
import 'features/social_chat/presentation/controllers/chat_controllers.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi sqflite FFI untuk platform desktop (Windows / Linux / macOS)
  PrototypeDatabase.ensureFfiInitialized();

  // Daftarkan background FCM handler secara aman pada platform mobile tanpa crash bila config Firebase belum ada.
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {}
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

    ref.listen(authControllerProvider, (prev, next) {
      final wasAuthed = prev?.value != null;
      final isAuthedNow = next.value != null;
      if (!wasAuthed && isAuthedNow) {
        unawaited(
          ref
              .read(deviceTokenLifecycleServiceProvider)
              .initializeAndSyncToken(requestPermission: true),
        );
        unawaited(ref.read(chatWsServiceProvider).connectIfAuthenticated());
        unawaited(
          ref.read(unreadNotificationsCountProvider.notifier).refresh(),
        );
      }
    });

    Future.microtask(() {
      ref.read(notificationDeepLinkControllerProvider).initialize(router);
      ref.read(chatWsServiceProvider).connectIfAuthenticated();
    });

    return MaterialApp.router(
      title: 'Coffee Labs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        final content = (!kIsWeb && Platform.isWindows)
            ? ExcludeSemantics(child: child ?? const SizedBox())
            : (child ?? const SizedBox());
        return CommunityDeepLinkListener(child: content);
      },
    );
  }
}
