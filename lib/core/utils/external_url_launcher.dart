import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka tautan eksternal (browser, unduhan APK, Google Maps, WhatsApp, dll.)
/// secara tahan Android 11+ (API 30–36) tanpa terblokir `canLaunchUrl()` yang
/// mengembalikan `false` bila package visibility `<queries>` belum dideklarasikan.
Future<bool> launchExternalUri(Uri uri) async {
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched) return true;
  } catch (e) {
    debugPrint('⚠️ launchExternalUri externalApplication failed ($uri): $e');
  }

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (launched) return true;
  } catch (e) {
    debugPrint('⚠️ launchExternalUri platformDefault failed ($uri): $e');
  }

  if (uri.scheme == 'http' || uri.scheme == 'https') {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (launched) return true;
    } catch (e) {
      debugPrint('⚠️ launchExternalUri inAppBrowserView failed ($uri): $e');
    }
  }

  return false;
}
