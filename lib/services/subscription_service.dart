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

  /// Mengambil paket langganan yang sedang aktif saat ini
  static Future<SubscriptionPlan> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planString = prefs.getString(_planKey);
    final storedPlan = SubscriptionPlan.fromString(planString);

    if (storedPlan.tier != SubscriptionTier.trial) {
      return storedPlan;
    }

    // Failsafe auto-detection dari sesi pengguna login tersimpan
    final rawUserJson = prefs.getString('coffeehub_auth_user_json');
    if (rawUserJson != null && rawUserJson.isNotEmpty) {
      try {
        final map = json.decode(rawUserJson) as Map<String, dynamic>;
        final role = map['role']?.toString().toLowerCase();
        final tier = map['tier']?.toString().toLowerCase();
        final username = map['username']?.toString().toLowerCase();

        if (role == 'admin' || tier == 'business' || username == 'bisnis123') {
          await activatePlan(
            SubscriptionPlan.business,
            paymentMethod: 'Business Commercial License',
          );
          return SubscriptionPlan.business;
        } else if (tier == 'pro') {
          await activatePlan(
            SubscriptionPlan.pro,
            paymentMethod: 'Pro Lifetime License',
          );
          return SubscriptionPlan.pro;
        }
      } catch (_) {}
    }

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
    final isPrem = prefs.getBool(_premiumKey) ?? false;
    if (isPrem) return true;

    final rawUserJson = prefs.getString('coffeehub_auth_user_json');
    if (rawUserJson != null && rawUserJson.isNotEmpty) {
      try {
        final map = json.decode(rawUserJson) as Map<String, dynamic>;
        final role = map['role']?.toString().toLowerCase();
        final tier = map['tier']?.toString().toLowerCase();
        final username = map['username']?.toString().toLowerCase();

        if (role == 'admin' || tier == 'business' || tier == 'pro' || username == 'bisnis123') {
          return true;
        }
      } catch (_) {}
    }

    final tier = await getCurrentTier();
    return tier == SubscriptionTier.pro || tier == SubscriptionTier.business;
  }

  /// Cek apakah pengguna memiliki lisensi Business
  static Future<bool> isBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUserJson = prefs.getString('coffeehub_auth_user_json');
    if (rawUserJson != null && rawUserJson.isNotEmpty) {
      try {
        final map = json.decode(rawUserJson) as Map<String, dynamic>;
        final role = map['role']?.toString().toLowerCase();
        final tier = map['tier']?.toString().toLowerCase();
        final username = map['username']?.toString().toLowerCase();

        if (role == 'admin' || tier == 'business' || username == 'bisnis123') {
          return true;
        }
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
    await prefs.setString(_planKey, plan.id);
    await prefs.setString(_activatedAtKey, DateTime.now().toIso8601String());
    await prefs.setString(_paymentMethodKey, paymentMethod);
    await prefs.setBool(_premiumKey, true);

    // Nonaktifkan batasan kuota trial
    await TrialService.setTrialMode(false);

    changeNotifier.value++;
  }

  /// Reset akun kembali ke mode Trial (misal saat logout / demo)
  static Future<void> resetToTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
    await prefs.remove(_activatedAtKey);
    await prefs.remove(_paymentMethodKey);
    await prefs.setBool(_premiumKey, false);

    await TrialService.setTrialMode(true);

    changeNotifier.value++;
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
