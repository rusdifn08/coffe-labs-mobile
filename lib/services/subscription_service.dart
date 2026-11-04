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
    return SubscriptionPlan.fromString(planString);
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
    final tier = await getCurrentTier();
    return tier == SubscriptionTier.pro || tier == SubscriptionTier.business;
  }

  /// Cek apakah pengguna memiliki lisensi Business
  static Future<bool> isBusiness() async {
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
