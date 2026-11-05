import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_service.dart';

/// Model konfigurasi kustomisasi struk kasir & slow bar
class ReceiptSettings {
  final String storeName;
  final String tagline;
  final String icon;
  final String baristaName;
  final String footerNote;
  final String subFooter;
  final String socialHandle;
  final int paperWidthMm;

  const ReceiptSettings({
    required this.storeName,
    required this.tagline,
    required this.icon,
    required this.baristaName,
    required this.footerNote,
    required this.subFooter,
    required this.socialHandle,
    this.paperWidthMm = 58,
  });

  ReceiptSettings copyWith({
    String? storeName,
    String? tagline,
    String? icon,
    String? baristaName,
    String? footerNote,
    String? subFooter,
    String? socialHandle,
    int? paperWidthMm,
  }) {
    return ReceiptSettings(
      storeName: storeName ?? this.storeName,
      tagline: tagline ?? this.tagline,
      icon: icon ?? this.icon,
      baristaName: baristaName ?? this.baristaName,
      footerNote: footerNote ?? this.footerNote,
      subFooter: subFooter ?? this.subFooter,
      socialHandle: socialHandle ?? this.socialHandle,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
    );
  }

  static const ReceiptSettings defaultSettings = ReceiptSettings(
    storeName: 'COFFEE LABS',
    tagline: 'SPECIALTY COFFEE HUB',
    icon: '☕',
    baristaName: 'Coffee Labs Barista',
    footerNote: 'SELAMAT MENIKMATI KOPI ANDA!',
    subFooter: 'Diseduh Presisi & Penuh Rasa',
    socialHandle: '@coffeelabs.specialty',
    paperWidthMm: 58,
  );
}

/// Service untuk memuat dan menyimpan preferensi struk secara persisten
class ReceiptSettingsService {
  ReceiptSettingsService._();

  static const String _keyStoreName = 'receipt_custom_store_name';
  static const String _keyTagline = 'receipt_custom_tagline';
  static const String _keyIcon = 'receipt_custom_icon';
  static const String _keyBarista = 'receipt_custom_barista';
  static const String _keyFooter = 'receipt_custom_footer';
  static const String _keySubFooter = 'receipt_custom_sub_footer';
  static const String _keySocial = 'receipt_custom_social';
  static const String _keyPaperWidth = 'receipt_custom_paper_width';

  static final ValueNotifier<ReceiptSettings> settingsNotifier =
      ValueNotifier<ReceiptSettings>(ReceiptSettings.defaultSettings);

  static const List<String> iconPresets = [
    '☕',
    '🌿',
    '👑',
    '⚡',
    '🌟',
    '🔥',
    '🤎',
    '🎯',
    '🧪',
    '💎',
    '🚀',
    '✨',
  ];

  /// Memuat pengaturan struk dari SharedPreferences
  static Future<ReceiptSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cek jika nama toko belum disetel manual, coba gunakan nama profil pengguna
    String defaultStore = 'COFFEE LABS';
    String defaultBarista = 'Coffee Labs Barista';
    try {
      final userName = await ProfileService.getUserName();
      if (userName.isNotEmpty && userName.toLowerCase() != 'novice brewer') {
        defaultBarista = userName;
      }
    } catch (_) {}

    final storeName = prefs.getString(_keyStoreName) ?? defaultStore;
    final tagline = prefs.getString(_keyTagline) ?? 'SPECIALTY COFFEE HUB';
    final icon = prefs.getString(_keyIcon) ?? '☕';
    final baristaName = prefs.getString(_keyBarista) ?? defaultBarista;
    final footerNote = prefs.getString(_keyFooter) ?? 'SELAMAT MENIKMATI KOPI ANDA!';
    final subFooter = prefs.getString(_keySubFooter) ?? 'Diseduh Presisi & Penuh Rasa';
    final socialHandle = prefs.getString(_keySocial) ?? '@coffeelabs.specialty';
    final paperWidth = prefs.getInt(_keyPaperWidth) ?? 58;

    final settings = ReceiptSettings(
      storeName: storeName,
      tagline: tagline,
      icon: icon,
      baristaName: baristaName,
      footerNote: footerNote,
      subFooter: subFooter,
      socialHandle: socialHandle,
      paperWidthMm: paperWidth,
    );

    settingsNotifier.value = settings;
    return settings;
  }

  /// Menyimpan pengaturan struk
  static Future<void> saveSettings(ReceiptSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreName, settings.storeName.trim());
    await prefs.setString(_keyTagline, settings.tagline.trim());
    await prefs.setString(_keyIcon, settings.icon.trim());
    await prefs.setString(_keyBarista, settings.baristaName.trim());
    await prefs.setString(_keyFooter, settings.footerNote.trim());
    await prefs.setString(_keySubFooter, settings.subFooter.trim());
    await prefs.setString(_keySocial, settings.socialHandle.trim());
    await prefs.setInt(_keyPaperWidth, settings.paperWidthMm);

    settingsNotifier.value = settings;
  }

  /// Reset ke konfigurasi default atau sinkron dari profil
  static Future<ReceiptSettings> resetToProfile() async {
    String userName = 'COFFEE LABS';
    try {
      final name = await ProfileService.getUserName();
      if (name.isNotEmpty && name.toLowerCase() != 'novice brewer') {
        userName = name;
      }
    } catch (_) {}

    final resetSettings = ReceiptSettings(
      storeName: userName.toUpperCase(),
      tagline: 'SPECIALTY COFFEE HUB',
      icon: '☕',
      baristaName: userName,
      footerNote: 'SELAMAT MENIKMATI KOPI ANDA!',
      subFooter: 'Diseduh Presisi & Penuh Rasa',
      socialHandle: '@${userName.toLowerCase().replaceAll(' ', '')}.specialty',
      paperWidthMm: 58,
    );

    await saveSettings(resetSettings);
    return resetSettings;
  }
}
