import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Pengelola sesi pemutar video LMS yang aman terhadap bug crash ANGLE Windows
/// (`egl::Surface::releaseTexImage` di `media_kit_video` 2.0.1) sekaligus
/// mencegah stall UI thread saat pengguna menekan tombol Back atau berpindah sub-bab.
class LmsVideoSessionManager {
  LmsVideoSessionManager._();

  static final LmsVideoSessionManager instance = LmsVideoSessionManager._();

  /// Lebar maksimum target render S/W pada Windows agar blit pixel buffer ringan & 60fps.
  static const int windowsSwMaxWidth = 960;
  static const int windowsSwMaxHeight = 540;

  Player? _player;
  VideoController? _controller;
  StreamSubscription<VideoParams>? _windowsResizeSub;

  int _activeToken = 0;
  Future<void> _opChain = Future<void>.value();

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

  bool isTokenActive(int token) => token != 0 && token == _activeToken;

  /// Mengambil kepemilikan sesi video baru (menggantikan pemilik sebelumnya secara aman,
  /// termasuk saat transisi `Navigator.pushReplacement`).
  int acquireSession() {
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
    final completer = Completer<(Player, VideoController)?>();

    _opChain = _opChain.then((_) async {
      if (!isTokenActive(token)) {
        completer.complete(null);
        return;
      }
      try {
        _ensureInitialized();
        final player = _player!;
        final controller = _controller!;

        await player.pause();
        await player.setRate(1.0);
        if (!isTokenActive(token)) {
          await player.stop();
          completer.complete(null);
          return;
        }

        await player.open(Media(playableSource), play: false);
        if (!isTokenActive(token)) {
          await player.pause();
          await player.stop();
          completer.complete(null);
          return;
        }

        completer.complete((player, controller));
      } catch (err) {
        debugPrint('LmsVideoSessionManager.openMedia error: $err');
        completer.complete(null);
      }
    });

    return completer.future;
  }

  /// Menjeda pemutaran apabila [token] masih memegang sesi aktif.
  void pauseIfActive(int token) {
    if (!isTokenActive(token) || _player == null) return;
    _opChain = _opChain.then((_) async {
      if (!isTokenActive(token) || _player == null) return;
      try {
        await _player!.pause();
      } catch (_) {}
    });
  }

  /// Melepas sesi saat layar ditutup (`dispose`).
  ///
  /// Tidak menghancurkan `VideoOutput` native secara sinkron di UI thread (yang
  /// memicu stall `promise.get_future().wait()` maupun crash `ANGLESurfaceManager`),
  /// melainkan menghentikan media (`pause` + `stop`) sehingga audio dan buffer frame
  /// segera dibebaskan tanpa lag saat navigasi Back.
  void releaseSession(int token) {
    if (!isTokenActive(token)) return;
    _activeToken++; // Invalidasi token lama segera agar openMedia yang sedang berjalan batal
    final int releasedEpoch = _activeToken;
    final player = _player;
    if (player == null) return;

    // Hentikan audio seketika (0ms latency) tanpa memblokir UI thread
    unawaited(player.pause().catchError((_) {}));

    _opChain = _opChain.then((_) async {
      // Skip bila layar baru sudah mengambil alih sesi untuk sub-bab lain
      if (_activeToken != releasedEpoch || _player != player) return;
      try {
        await player.pause();
        await player.stop();
      } catch (_) {}
    });
  }
}
