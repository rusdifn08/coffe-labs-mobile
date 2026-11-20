import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'lms_media_kit_hot_restart_guard_stub.dart'
    if (dart.library.ffi) 'lms_media_kit_hot_restart_guard_io.dart';

/// Pengelola sesi pemutar video LMS yang aman terhadap:
/// 1. Bug crash ANGLE Windows (`egl::Surface::releaseTexImage` di `media_kit_video` 2.0.1),
/// 2. Fatal Dart VM crash saat Debug Hot Restart (`Callback invoked after it has been deleted`),
/// 3. Stall UI thread saat pengguna menekan tombol Back atau berpindah sub-bab.
class LmsVideoSessionManager {
  LmsVideoSessionManager._();

  static final LmsVideoSessionManager instance = LmsVideoSessionManager._();

  /// Lebar maksimum target render S/W pada Windows agar blit pixel buffer ringan & 60fps.
  static const int windowsSwMaxWidth = 960;
  static const int windowsSwMaxHeight = 540;

  /// Jeda singkat sebelum `Player.dispose()` dijalankan setelah layar video ditutup:
  /// - Cukup lama agar perpindahan Sub-Bab Sebelumnya/Berikutnya memakai ulang player hangat (0ms),
  /// - Cukup singkat agar setelah tombol Back seluruh `mpv_handle` & `NativeCallable` dilepas bersih.
  static const Duration idleDisposeDelay = Duration(milliseconds: 350);

  Player? _player;
  VideoController? _controller;
  StreamSubscription<VideoParams>? _windowsResizeSub;
  Timer? _idleDisposeTimer;

  int _activeToken = 0;
  Future<void>? _pendingOp;

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final prev = _pendingOp;
    final next = (prev == null ? Future<void>.value() : prev.catchError((_) {}))
        .then((_) => action());
    late final Future<void> tracked;
    tracked = next.then((_) {}, onError: (_) {}).whenComplete(() {
      if (identical(_pendingOp, tracked)) {
        _pendingOp = null;
      }
    });
    _pendingOp = tracked;
    return next;
  }

  /// Membersihkan wakeup callback libmpv dari isolate sebelumnya tepat sebelum
  /// `MediaKit.ensureInitialized()` dipanggil pada Hot Restart debug desktop.
  static void sanitizeDebugHotRestartCallbacks() {
    sanitizeMediaKitHotRestartCallbacksImpl();
  }

  /// Mengembalikan konfigurasi [VideoControllerConfiguration] yang aman per platform.
  ///
  /// Pada Windows, `media_kit_video` 2.0.1 memanggil `eglReleaseTexImage` tanpa
  /// konteks EGL aktif di `ANGLESurfaceManager::CleanUp(true)`, yang memicu
  /// native fatal assert `Surface.cpp:528` (force close). Mode software pixel buffer
  /// (`enableHardwareAcceleration: false`, `hwdec: 'no'`) menghindari `ANGLESurfaceManager`
  /// sepenuhnya dan berjalan mulus pada resolusi terukur 960x540.
  static VideoControllerConfiguration buildVideoControllerConfig({
    required bool isWindows,
  }) {
    if (isWindows) {
      return const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
        hwdec: 'no',
        width: windowsSwMaxWidth,
        height: windowsSwMaxHeight,
      );
    }
    return const VideoControllerConfiguration(
      enableHardwareAcceleration: true,
    );
  }

  /// Menghitung ukuran target S/W yang menjaga rasio aspek video <= 960x540.
  static (int width, int height) computeWindowsSwSize(int rawWidth, int rawHeight) {
    if (rawWidth <= 0 || rawHeight <= 0) {
      return (windowsSwMaxWidth, windowsSwMaxHeight);
    }
    if (rawWidth <= windowsSwMaxWidth && rawHeight <= windowsSwMaxHeight) {
      return (rawWidth, rawHeight);
    }
    final widthScale = windowsSwMaxWidth / rawWidth;
    final heightScale = windowsSwMaxHeight / rawHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;
    final w = (rawWidth * scale).round().clamp(16, windowsSwMaxWidth);
    final h = (rawHeight * scale).round().clamp(16, windowsSwMaxHeight);
    return (w, h);
  }

  int get activeToken => _activeToken;

  bool get hasPendingIdleDispose => _idleDisposeTimer?.isActive ?? false;

  bool isTokenActive(int token) => token != 0 && token == _activeToken;

  /// Mengambil kepemilikan sesi video baru (menggantikan pemilik sebelumnya secara aman,
  /// termasuk saat transisi `Navigator.pushReplacement`).
  int acquireSession() {
    _idleDisposeTimer?.cancel();
    _idleDisposeTimer = null;
    _activeToken++;
    return _activeToken;
  }

  void _ensureInitialized() {
    if (_player != null && _controller != null) return;
    final isWindows = !kIsWeb && Platform.isWindows;
    final player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 16 * 1024 * 1024,
      ),
    );
    final controller = VideoController(
      player,
      configuration: buildVideoControllerConfig(isWindows: isWindows),
    );

    if (isWindows) {
      _windowsResizeSub?.cancel();
      _windowsResizeSub = player.stream.videoParams.listen((params) {
        final dw = params.dw ?? 0;
        final dh = params.dh ?? 0;
        if (dw <= 0 || dh <= 0) return;
        final (targetW, targetH) = computeWindowsSwSize(dw, dh);
        unawaited(
          controller.setSize(width: targetW, height: targetH).catchError((_) {}),
        );
      });
    }

    _player = player;
    _controller = controller;
  }

  /// Membuka media baru secara terurut (serialized) untuk [token].
  /// Mengembalikan `(player, controller)` bila [token] masih aktif, atau `null` bila batal.
  Future<(Player, VideoController)?> openMedia({
    required int token,
    required String playableSource,
  }) {
    return _enqueue<(Player, VideoController)?>(() async {
      if (!isTokenActive(token)) {
        return null;
      }
      try {
        _ensureInitialized();
        final player = _player!;
        final controller = _controller!;

        await player.pause();
        await player.setRate(1.0);
        if (!isTokenActive(token)) {
          await player.stop();
          return null;
        }

        await player.open(Media(playableSource), play: false);
        if (!isTokenActive(token)) {
          await player.pause();
          await player.stop();
          return null;
        }

        return (player, controller);
      } catch (err) {
        debugPrint('LmsVideoSessionManager.openMedia error: $err');
        return null;
      }
    });
  }

  /// Menjeda pemutaran apabila [token] masih memegang sesi aktif.
  void pauseIfActive(int token) {
    if (!isTokenActive(token) || _player == null) return;
    unawaited(
      _enqueue<void>(() async {
        if (!isTokenActive(token) || _player == null) return;
        try {
          await _player!.pause();
        } catch (_) {}
      }),
    );
  }

  /// Melepas sesi saat layar ditutup (`dispose`).
  ///
  /// 1. Menghentikan audio seketika (0ms latency) tanpa memblokir transisi Back.
  /// 2. Setelah jeda singkat [idleDisposeDelay], bila tidak ada sub-bab baru yang
  ///    mengambil alih sesi, memanggil `player.dispose()` secara terurut agar
  ///    `mpv_set_wakeup_callback`, `NativeCallable`, dan `NativeReferenceHolder`
  ///    dilepas tuntas (mencegah leak & crash Dart VM saat Hot Restart).
  void releaseSession(int token) {
    if (!isTokenActive(token)) return;
    _activeToken++; // Invalidasi token lama segera agar openMedia yang sedang berjalan batal
    final int releasedEpoch = _activeToken;
    final player = _player;
    if (player == null) return;

    // Hentikan audio seketika (0ms latency) tanpa memblokir UI thread
    unawaited(player.pause().catchError((_) {}));

    _idleDisposeTimer?.cancel();
    _idleDisposeTimer = Timer(idleDisposeDelay, () {
      _idleDisposeTimer = null;
      if (_activeToken != releasedEpoch) return;
      _enqueueDisposeIfIdle(releasedEpoch);
    });
  }

  void _enqueueDisposeIfIdle(int expectedEpoch) {
    unawaited(
      _enqueue<void>(() async {
        if (_activeToken != expectedEpoch) return;
        await _disposeActivePlayerLocked();
      }),
    );
  }

  /// Melepas seluruh instance `Player` secara eksplisit (mis. saat shutdown/detached).
  Future<void> disposeImmediately() {
    _idleDisposeTimer?.cancel();
    _idleDisposeTimer = null;
    _activeToken++;
    if (_player == null && _windowsResizeSub == null && _pendingOp == null) {
      return Future<void>.value();
    }
    return _enqueue<void>(_disposeActivePlayerLocked);
  }

  Future<void> _disposeActivePlayerLocked() async {
    final player = _player;
    _player = null;
    _controller = null;

    final sub = _windowsResizeSub;
    _windowsResizeSub = null;
    if (sub != null) {
      try {
        await sub.cancel();
      } catch (_) {}
    }

    if (player == null) return;
    try {
      await player.pause();
    } catch (_) {}
    try {
      await player.stop();
    } catch (_) {}
    try {
      await player.dispose();
    } catch (err) {
      debugPrint('LmsVideoSessionManager.dispose error: $err');
    }
  }
}
