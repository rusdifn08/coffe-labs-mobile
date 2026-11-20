import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';

typedef _MpvSetWakeupCallbackC = Void Function(
  Pointer<Void> ctx,
  Pointer<Void> cb,
  Pointer<Void> d,
);
typedef _MpvSetWakeupCallbackDart = void Function(
  Pointer<Void> ctx,
  Pointer<Void> cb,
  Pointer<Void> d,
);

/// Mencegah fatal Dart VM crash (`Callback invoked after it has been deleted`)
/// pada Windows/Desktop Debug saat Hot Restart:
///
/// Pada `media_kit` 1.2.6, `NativeReferenceHolder` mengirim `"quit"` ke `mpv_handle*`
/// milik isolate lama tanpa lebih dulu mengosongkan `mpv_set_wakeup_callback`.
/// Saat libmpv memproses `"quit"`, thread native memanggil `NativeCallable.listener`
/// yang sudah dihapus bersama isolate sebelumnya.
///
/// Guard ini mengosongkan `mpv_set_wakeup_callback(ref, nullptr, nullptr)` secara
/// sinkron tepat sebelum `MediaKit.ensureInitialized()` berjalan.
void sanitizeMediaKitHotRestartCallbacksImpl() {
  if (!kDebugMode) return;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return;
  if (Platform.environment.containsKey('FLUTTER_TEST')) return;

  try {
    final sep = Platform.pathSeparator;
    final refFile = File(
      '${Directory.systemTemp.path}${sep}com.alexmercerind.media_kit.NativeReferenceHolder.$pid',
    );
    if (!refFile.existsSync()) return;

    final rawAddress = refFile.readAsStringSync().trim();
    final bufferAddress = int.tryParse(rawAddress);
    if (bufferAddress == null || bufferAddress == 0) return;

    final lib = _openLoadedLibMpv();
    if (lib == null) return;

    final setWakeup = lib.lookupFunction<_MpvSetWakeupCallbackC, _MpvSetWakeupCallbackDart>(
      'mpv_set_wakeup_callback',
    );

    const kReferenceBufferSize = 512;
    final buffer = Pointer<IntPtr>.fromAddress(bufferAddress);
    for (int i = 0; i < kReferenceBufferSize; i++) {
      final refAddress = (buffer + i).value;
      if (refAddress != 0) {
        setWakeup(Pointer<Void>.fromAddress(refAddress), nullptr, nullptr);
      }
    }
  } catch (err) {
    debugPrint('LmsMediaKitHotRestartGuard skipped: $err');
  }
}

DynamicLibrary? _openLoadedLibMpv() {
  final candidates = Platform.isWindows
      ? const ['libmpv-2.dll', 'mpv-2.dll', 'mpv-1.dll']
      : (Platform.isMacOS
          ? const ['Mpv.framework/Mpv']
          : const ['libmpv.so', 'libmpv.so.2', 'libmpv.so.1']);
  for (final name in candidates) {
    try {
      return DynamicLibrary.open(name);
    } catch (_) {}
  }
  return null;
}
