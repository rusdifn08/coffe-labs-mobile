import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class LanguageService {
  static const String _keyLanguage = 'app_selected_language';
  static final LanguageNotifier changeNotifier = LanguageNotifier();

  // Bahasa bawaan (Default): English ('en')
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  static bool get isEnglish => _currentLanguage == 'en';

  static Future<String> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_keyLanguage) ?? 'en';
      return _currentLanguage;
    } catch (_) {
      return 'en';
    }
  }

  static Future<void> setLanguage(String langCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = langCode;
      await prefs.setString(_keyLanguage, langCode);
      changeNotifier.notify();
    } catch (e) {
      debugPrint('⚠️ Error saving language: $e');
    }
  }

  static String getLanguageLabel(String code) {
    switch (code) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
      default:
        return 'English (Default)';
    }
  }
}
