import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _userNameKey = 'coffeehub_user_name';
  static const String _userImageKey = 'coffeehub_user_image';

  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userNameKey);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Barista';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userImageKey);
  }

  static Future<void> setUserImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userImageKey, path);
  }
}
