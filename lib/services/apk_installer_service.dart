import 'app_update_service.dart';

/// Kompatibilitas mundur: self-install APK langsung (`REQUEST_INSTALL_PACKAGES`)
/// sudah dinonaktifkan permanen pada flavor `store` demi kepatuhan Google Play Protect.
/// Seluruh pembaruan kini memakai Shorebird Delta OTA Patch atau OS Browser Handoff.
class ApkInstallerService {
  static Future<bool> canRequestPackageInstalls() async => false;

  static Future<bool> openInstallPermissionSettings() async => false;

  static Future<bool> openOfficialDownload(String downloadUrl) {
    return AppUpdateService.openDownloadUrl(downloadUrl);
  }
}
