import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show PointerDeviceKind;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/network/backend_endpoint_manager.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'data/world_indonesia_beans_service.dart';
import 'features/admin_control/widgets/active_feature_lock_kickout_overlay.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/barista_toolkit/data/lms_video_session_manager.dart';
import 'features/bean_scanner/services/coffee_knowledge_graph_service.dart';
import 'features/communities/presentation/services/community_deep_link_listener.dart';
import 'features/gamification/presentation/overlay/global_gamification_overlay_host.dart';
import 'features/monitoring/data/telemetry_batch_outbox_service.dart';
import 'features/notifications/data/services/device_token_lifecycle_service.dart';
import 'features/notifications/data/services/local_push_orchestrator.dart';
import 'features/notifications/presentation/controllers/notification_center_controller.dart';
import 'features/notifications/presentation/controllers/notification_deep_link_controller.dart';
import 'features/scanner/data/local/prototype_database.dart';
import 'features/social_chat/presentation/controllers/chat_controllers.dart';
import 'services/user_cloud_sync_service.dart';
import 'theme/app_theme.dart';

/// ScrollBehavior global Coffee Labs yang dioptimalkan untuk 60–120 FPS:
/// - Mengaktifkan drag menggunakan touch, mouse, trackpad, dan stylus di semua platform.
/// - Menggunakan BouncingScrollPhysics berpadu RangeMaintainingScrollPhysics agar momentum
///   scrolling vertikal maupun horizontal antar kartu terasa sangat halus tanpa patah.
class CoffeeLabsSmoothScrollBehavior extends MaterialScrollBehavior {
  const CoffeeLabsSmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: RangeMaintainingScrollPhysics(),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  UserCloudSyncService.ensureHooksRegistered();

  // Batasi cache tekstur gambar GPU agar perangkat RAM rendah tidak OOM & bebas jank
  PaintingBinding.instance.imageCache.maximumSize = 150;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 64 * 1024 * 1024;

  // Inisialisasi sqflite FFI untuk platform desktop (Windows / Linux / macOS)
  PrototypeDatabase.ensureFfiInitialized();

  // Pra-muat Knowledge Graph Kopi (v3.0), Katalog Biji, & Sinkronisasi Dynamic Backend Endpoint setelah frame pertama tampil
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(BackendEndpointManager.instance.initializeInBackground());
    unawaited(CoffeeKnowledgeGraphService.instance.initialize());
    unawaited(WorldIndonesiaBeansService.instance.ensureLoaded());
  });

  // Inisialisasi native libmpv media_kit secara aman di luar Flutter VM test.
  // Pada Windows Debug Hot Restart, kosongkan wakeup callback libmpv isolate lama
  // sebelum MediaKit.ensureInitialized() mengirim "quit" agar tidak crash Dart VM.
  if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      LmsVideoSessionManager.sanitizeDebugHotRestartCallbacks();
      MediaKit.ensureInitialized();
    } catch (_) {}
  }

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
    TelemetryBatchOutboxService.instance.attachDio(ref.watch(dioClientProvider));

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
      scrollBehavior: const CoffeeLabsSmoothScrollBehavior(),
      routerConfig: router,
      builder: (context, child) {
        final content = (!kIsWeb && Platform.isWindows)
            ? ExcludeSemantics(child: child ?? const SizedBox())
            : (child ?? const SizedBox());
        return ActiveFeatureLockKickoutWatcher(
          router: router,
          child: CommunityDeepLinkListener(
            child: GlobalGamificationOverlayHost(child: content),
          ),
        );
      },
    );
  }
}
