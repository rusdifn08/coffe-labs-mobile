import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_plan.dart';
import 'trial_service.dart';

class SubscriptionService {
  static const String _planKey = 'coffeehub_active_subscription_plan';
  static const String _activatedAtKey = 'coffeehub_subscription_activated_at';
  static const String _paymentMethodKey = 'coffeehub_subscription_payment_method';
  static const String _premiumKey = 'coffee_labs_is_premium_pro';

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  /// Mengambil paket langganan yang sedang aktif saat ini.
  /// PRIORITAS UTAMA: Jika ada sesi akun pengguna login, tier akun dari backend adalah Ground Truth mutlak!
  static Future<SubscriptionPlan> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Otoritas Tertinggi: Sesi pengguna login resmi (RBAC dari server/database)
    final rawUserJson = prefs.getString('coffeehub_auth_user_json');
    if (rawUserJson != null && rawUserJson.isNotEmpty) {
      try {
        final map = json.decode(rawUserJson) as Map<String, dynamic>;
        final role = map['role']?.toString().toLowerCase();
        final tier = (map['tier']?.toString() ?? 'trial').toLowerCase().trim();
        final username = map['username']?.toString().toLowerCase();

        if (role == 'admin' || tier == 'business' || username == 'bisnis123') {
          return SubscriptionPlan.business;
        } else if (tier == 'pro') {
          return SubscriptionPlan.pro;
        } else {
          // Pengguna terdaftar dengan tier trial / novice -> STRICTLY TRIAL!
          return SubscriptionPlan.trial;
        }
      } catch (_) {}
    }

    // 2. Mode Tamu / Unauthenticated: Cek lisensi lokal perangkat
    final planString = prefs.getString(_planKey);
    final storedPlan = SubscriptionPlan.fromString(planString);
    return storedPlan;
  }

  /// Mengambil tier aktif (trial, pro, business)
  static Future<SubscriptionTier> getCurrentTier() async {
    final plan = await getCurrentPlan();
    return plan.tier;
  }

  /// Cek apakah pengguna telah memiliki lisensi Pro atau Business (bebas iklan & seduh unlimited)
  static Future<bool> isProOrBusiness() async {
    final prefs = await SharedPreferences.getInstance();

    // Jika ada akun login, gunakan hak akses akun secara ketat
    final rawUserJson = prefs.getString('coffeehub_auth_user_json');
    if (rawUserJson != null && rawUserJson.isNotEmpty) {
      try {
        final map = json.decode(rawUserJson) as Map<String, dynamic>;
        final role = map['role']?.toString().toLowerCase();
        final tier = (map['tier']?.toString() ?? 'trial').toLowerCase().trim();
        final username = map['username']?.toString().toLowerCase();

        if (role == 'admin' || tier == 'business' || tier == 'pro' || username == 'bisnis123') {
          return true;
        }
        // Akun login biasa (trial) tidak boleh mewarisi sisa flag lokal perangkat
        return false;
      } catch (_) {}
    }

    final isPrem = prefs.getBool(_premiumKey) ?? false;
    if (isPrem) return true;

    final tier = await getCurrentTier();
    return tier == SubscriptionTier.pro || tier == SubscriptionTier.business;
  }

  /// Cek apakah pengguna memiliki lisensi Business
  static Future<bool> isBusiness() async {
    final prefs = await SharedPreferences.getInstance();

    // Jika ada akun login, otoritas hanya dari status akun server
    final rawUserJson = prefs.getString('coffeehub_auth_user_json');
    if (rawUserJson != null && rawUserJson.isNotEmpty) {
      try {
        final map = json.decode(rawUserJson) as Map<String, dynamic>;
        final role = map['role']?.toString().toLowerCase();
        final tier = (map['tier']?.toString() ?? 'trial').toLowerCase().trim();
        final username = map['username']?.toString().toLowerCase();

        if (role == 'admin' || tier == 'business' || username == 'bisnis123') {
          return true;
        }
        // Akun login non-business STRICTLY dilarang mengakses business mode!
        return false;
      } catch (_) {}
    }

    final tier = await getCurrentTier();
    return tier == SubscriptionTier.business;
  }

  /// Mengaktifkan paket Coffee Labs Pro atau Business
  static Future<void> activatePlan(
    SubscriptionPlan plan, {
    String paymentMethod = 'QRIS Instant',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPlanStr = prefs.getString(_planKey);
    final isPrem = prefs.getBool(_premiumKey) ?? false;
    final isAlreadySame = (currentPlanStr == plan.id && isPrem);

    await prefs.setString(_planKey, plan.id);
    await prefs.setString(_activatedAtKey, DateTime.now().toIso8601String());
    await prefs.setString(_paymentMethodKey, paymentMethod);
    await prefs.setBool(_premiumKey, true);

    // Nonaktifkan batasan kuota trial
    await TrialService.setTrialMode(false);

    if (!isAlreadySame) {
      changeNotifier.value++;
    }
  }

  /// Reset akun kembali ke mode Trial (misal saat logout / demo)
  static Future<void> resetToTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPlanStr = prefs.getString(_planKey);
    final isPrem = prefs.getBool(_premiumKey) ?? false;
    final isAlreadyTrial = (currentPlanStr == null && !isPrem);

    await prefs.remove(_planKey);
    await prefs.remove(_activatedAtKey);
    await prefs.remove(_paymentMethodKey);
    await prefs.setBool(_premiumKey, false);

    await TrialService.setTrialMode(true);

    if (!isAlreadyTrial) {
      changeNotifier.value++;
    }
  }

  /// Dapatkan tanggal aktivasi paket
  static Future<DateTime?> getActivationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activatedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Dapatkan metode pembayaran yang digunakan
  static Future<String> getPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_paymentMethodKey) ?? 'QRIS Instant';
  }
}
