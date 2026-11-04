import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee_level.dart';

class GamificationStats {
  final int totalExp;
  final CoffeeLevel level;
  final int brewsCount;
  final int cuppingCount;
  final int toolkitCount;
  final int streakDays;
  final double progress;
  final int expToNext;

  const GamificationStats({
    required this.totalExp,
    required this.level,
    required this.brewsCount,
    required this.cuppingCount,
    required this.toolkitCount,
    required this.streakDays,
    required this.progress,
    required this.expToNext,
  });
}

/// Service gamifikasi untuk mencatat EXP, Level, dan Aktivitas Barista.
class GamificationService extends ChangeNotifier {
  GamificationService._();
  static final GamificationService instance = GamificationService._();

  static ChangeNotifier get changeNotifier => instance;

  static const String _keyExp = 'gamification_total_exp_v2';
  static const String _keyBrews = 'gamification_brews_count';
  static const String _keyCupping = 'gamification_cupping_count';
  static const String _keyToolkit = 'gamification_toolkit_count';
  static const String _keyStreak = 'gamification_streak_days';
  static const String _keyLastDate = 'gamification_last_date';

  /// Mendapatkan statistik gamifikasi pengguna saat ini
  Future<GamificationStats> getStats() async {
    final sp = await SharedPreferences.getInstance();
    int exp = sp.getInt(_keyExp) ?? 0;
    final brews = sp.getInt(_keyBrews) ?? 0;
    final cupping = sp.getInt(_keyCupping) ?? 0;
    final toolkit = sp.getInt(_keyToolkit) ?? 0;
    final streak = sp.getInt(_keyStreak) ?? 1;

    // Minimum EXP dari aktivitas yang tercatat
    final activityExp = (brews * 50) + (cupping * 35) + (toolkit * 20) + (streak * 25);
    if (exp < activityExp) {
      exp = activityExp;
      await sp.setInt(_keyExp, exp);
    }

    final lvl = CoffeeLevel.fromExp(exp);
    return GamificationStats(
      totalExp: exp,
      level: lvl,
      brewsCount: brews,
      cuppingCount: cupping,
      toolkitCount: toolkit,
      streakDays: streak,
      progress: lvl.getProgress(exp),
      expToNext: lvl.expNeededToNext(exp),
    );
  }

  /// Set level dan statistik gamifikasi secara eksplisit (e.g. untuk preset akun admin1-10)
  Future<void> setLevelStats({
    required int exp,
    int brews = 0,
    int cupping = 0,
    int toolkit = 0,
    int streak = 1,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_keyExp, exp);
    await sp.setInt(_keyBrews, brews);
    await sp.setInt(_keyCupping, cupping);
    await sp.setInt(_keyToolkit, toolkit);
    await sp.setInt(_keyStreak, streak);
    notifyListeners();
  }

  /// Catat seduhan selesai (+50 EXP dasar, bonus rating & catatan)
  Future<void> recordBrewCompleted({bool hasRating = false, bool hasNotes = false}) async {
    final sp = await SharedPreferences.getInstance();
    int earned = 50;
    if (hasRating) earned += 15;
    if (hasNotes) earned += 25;

    final currentExp = sp.getInt(_keyExp) ?? 0;
    final currentBrews = sp.getInt(_keyBrews) ?? 0;

    await sp.setInt(_keyExp, currentExp + earned);
    await sp.setInt(_keyBrews, currentBrews + 1);

    await _checkStreakInternal(sp);
    notifyListeners();
  }

  /// Catat penggunaan toolkit presisi (Matriks Grinder, TDS, Kimia Air, 4:6) (+20 EXP)
  Future<void> recordToolkitUsed(String toolName) async {
    final sp = await SharedPreferences.getInstance();
    final currentExp = sp.getInt(_keyExp) ?? 0;
    final currentTools = sp.getInt(_keyToolkit) ?? 0;

    await sp.setInt(_keyExp, currentExp + 20);
    await sp.setInt(_keyToolkit, currentTools + 1);

    notifyListeners();
  }

  /// Catat cupping/evaluasi sensorik flavor wheel (+35 EXP)
  Future<void> recordCuppingCompleted() async {
    final sp = await SharedPreferences.getInstance();
    final currentExp = sp.getInt(_keyExp) ?? 0;
    final currentCupping = sp.getInt(_keyCupping) ?? 0;

    await sp.setInt(_keyExp, currentExp + 35);
    await sp.setInt(_keyCupping, currentCupping + 1);

    notifyListeners();
  }

  /// Sinkronisasi awal dengan riwayat seduhan riil user
  Future<void> syncWithBrewHistoryCount(int actualHistoryCount) async {
    final sp = await SharedPreferences.getInstance();
    final currentBrews = sp.getInt(_keyBrews) ?? 0;
    if (actualHistoryCount > currentBrews) {
      final diff = actualHistoryCount - currentBrews;
      final currentExp = sp.getInt(_keyExp) ?? 0;
      await sp.setInt(_keyBrews, actualHistoryCount);
      await sp.setInt(_keyExp, currentExp + (diff * 50));
      notifyListeners();
    }
  }

  /// Cek streak harian
  Future<void> checkDailyStreak() async {
    final sp = await SharedPreferences.getInstance();
    await _checkStreakInternal(sp);
  }

  Future<void> _checkStreakInternal(SharedPreferences sp) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDateStr = sp.getString(_keyLastDate);

    if (lastDateStr == todayStr) return; // Sudah tercatat hari ini

    int streak = sp.getInt(_keyStreak) ?? 0;
    if (lastDateStr != null) {
      try {
        final lastDate = DateTime.parse(lastDateStr);
        final diffDays = now.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
        if (diffDays == 1) {
          streak += 1;
        } else if (diffDays > 1) {
          streak = 1; // reset streak jika bolong
        }
      } catch (_) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    final currentExp = sp.getInt(_keyExp) ?? 0;
    await sp.setString(_keyLastDate, todayStr);
    await sp.setInt(_keyStreak, streak);
    await sp.setInt(_keyExp, currentExp + 25); // Bonus harian
  }
}
