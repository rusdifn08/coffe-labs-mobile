import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/gamification/models/coffee_level.dart';
import '../features/gamification/services/gamification_service.dart';
import '../models/subscription_plan.dart';
import 'auth_service.dart';
import 'profile_service.dart';
import 'subscription_service.dart';
import 'trial_service.dart';

/// Service untuk menyediakan preset akun demo admin1 s/d admin10
/// serta akun pengujian bisnis123 untuk mencoba Mode Kasir & Always-On Display.
class PresetAdminService {
  PresetAdminService._();

  static const String _tokenKey = 'coffeehub_auth_jwt_token';
  static const String _userKey = 'coffeehub_auth_user_json';

  /// Cek dan proses login instan jika username & password adalah admin1..admin10 atau bisnis123
  static Future<AuthResult?> tryLogin(String username, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Dukungan akun bisnis123 untuk mencoba Mode Kasir & Display
    if (cleanUsername == 'bisnis123') {
      if (cleanPassword != 'bisnis123') {
        return const AuthResult(
          success: false,
          message: 'Password untuk akun demo bisnis123 adalah bisnis123.',
          status: 'error',
        );
      }

      final user = AuthUser(
        id: 'business_demo_user',
        username: 'bisnis123',
        fullName: 'Coffee Labs Barista Business',
        role: 'user',
        status: 'approved',
        avatarUrl: 'assets/images/characters/avatar_2.png',
        createdAt: DateTime.now().toIso8601String(),
      );

      final token = 'demo_business_jwt_token_2026';
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.setString(_tokenKey, token),
        prefs.setString(_userKey, json.encode(user.toJson())),
        ProfileService.setUserName(user.fullName),
        ProfileService.setUserImagePath('assets/images/characters/avatar_2.png'),
        TrialService.setTrialMode(false),
        SubscriptionService.activatePlan(SubscriptionPlan.business, paymentMethod: 'Business Demo License'),
      ]);

      AuthService.changeNotifier.value++;

      return AuthResult.success(
        token,
        user,
        'Selamat datang! Akun Business aktif. Mode Kasir (POS) & AMOLED AOD siap digunakan.',
      );
    }

    final match = RegExp(r'^admin([1-9]|10)$').firstMatch(cleanUsername);
    if (match == null) return null;

    // Password harus sama persis dengan username (misal admin1 / admin1)
    if (cleanPassword != cleanUsername) {
      return AuthResult(
        success: false,
        message: 'Password untuk akun preset $cleanUsername harus sama dengan username-nya.',
        status: 'error',
      );
    }

    final levelNum = int.parse(match.group(1)!);
    final targetLevel = CoffeeLevel.allLevels[levelNum - 1];

    // Data statistik dan EXP presisi yang mewakili level 1 s.d. 10
    final stats = _getPresetStatsForLevel(levelNum);

    // Update EXP dan metrik aktivitas di GamificationService
    await GamificationService.instance.setLevelStats(
      exp: stats.exp,
      brews: stats.brews,
      cupping: stats.cupping,
      toolkit: stats.toolkit,
      streak: stats.streak,
    );

    final avatarIndex = ((levelNum - 1) % 4) + 1;
    final avatarUrl = 'assets/images/characters/avatar_$avatarIndex.png';

    final user = AuthUser(
      id: 'admin_preset_$levelNum',
      username: cleanUsername,
      fullName: 'Admin Lv.$levelNum - ${targetLevel.title}',
      role: 'admin',
      status: 'approved',
      avatarUrl: avatarUrl,
      createdAt: DateTime.now().toIso8601String(),
    );

    final token = 'preset_admin_jwt_token_level_$levelNum';
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_userKey, json.encode(user.toJson())),
      ProfileService.setUserName(user.fullName),
      ProfileService.setUserImagePath(avatarUrl),
      TrialService.setTrialMode(false),
    ]);

    AuthService.changeNotifier.value++;

    return AuthResult.success(
      token,
      user,
      'Login preset berhasil! Anda masuk sebagai Admin Level $levelNum (${targetLevel.title}).',
    );
  }

  static ({int exp, int brews, int cupping, int toolkit, int streak}) _getPresetStatsForLevel(int level) {
    switch (level) {
      case 1:
        return (exp: 50, brews: 1, cupping: 0, toolkit: 0, streak: 1);
      case 2:
        return (exp: 300, brews: 4, cupping: 2, toolkit: 1, streak: 2);
      case 3:
        return (exp: 700, brews: 8, cupping: 5, toolkit: 3, streak: 3);
      case 4:
        return (exp: 1350, brews: 15, cupping: 10, toolkit: 8, streak: 5);
      case 5:
        return (exp: 2300, brews: 25, cupping: 18, toolkit: 15, streak: 7);
      case 6:
        return (exp: 3600, brews: 40, cupping: 28, toolkit: 25, streak: 10);
      case 7:
        return (exp: 5400, brews: 60, cupping: 42, toolkit: 38, streak: 14);
      case 8:
        return (exp: 7600, brews: 85, cupping: 60, toolkit: 55, streak: 21);
      case 9:
        return (exp: 10500, brews: 120, cupping: 85, toolkit: 75, streak: 30);
      case 10:
      default:
        return (exp: 15000, brews: 180, cupping: 120, toolkit: 110, streak: 45);
    }
  }
}
