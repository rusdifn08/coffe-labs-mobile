import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/user_scoped_storage.dart';
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

/// Service gamifikasi terisolasi per-user (`u_<userId>_*`) untuk mencatat EXP,
/// Level, dan Aktivitas Barista serta memicu sinkronisasi cloud lintas perangkat.
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

  Future<String> _k(String base, SharedPreferences sp, {String? userId}) {
    return UserScopedStorage.scopedKeyAsync(base, userId: userId, prefs: sp);
  }

  /// Mendapatkan statistik gamifikasi milik pengguna aktif secara ketat terisolasi.
  Future<GamificationStats> getStats({String? userId}) async {
    final sp = await SharedPreferences.getInstance();
    final uid = userId ?? await UserScopedStorage.resolveActiveUserId(prefs: sp);

    int exp = sp.getInt(UserScopedStorage.scopedKey(_keyExp, userId: uid)) ?? 0;
    final brews = sp.getInt(UserScopedStorage.scopedKey(_keyBrews, userId: uid)) ?? 0;
    final cupping = sp.getInt(UserScopedStorage.scopedKey(_keyCupping, userId: uid)) ?? 0;
    final toolkit = sp.getInt(UserScopedStorage.scopedKey(_keyToolkit, userId: uid)) ?? 0;
    final streak = sp.getInt(UserScopedStorage.scopedKey(_keyStreak, userId: uid)) ?? 1;

    // Minimum EXP konsisten dari aktivitas & streak milik user ini sendiri
    final activityExp = (brews * 50) + (cupping * 35) + (toolkit * 20) + (streak * 25);
    if (exp < activityExp) {
      exp = activityExp;
      await sp.setInt(UserScopedStorage.scopedKey(_keyExp, userId: uid), exp);
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

  /// Mengekspor raw state gamifikasi milik `userId` untuk disinkronkan ke cloud NeonDB.
  Future<Map<String, dynamic>> exportRawState({String? userId}) async {
    final sp = await SharedPreferences.getInstance();
    final uid = userId ?? await UserScopedStorage.resolveActiveUserId(prefs: sp);
    final stats = await getStats(userId: uid);
    final lastDate = sp.getString(UserScopedStorage.scopedKey(_keyLastDate, userId: uid));
    return {
      'total_exp': stats.totalExp,
      'brews_count': stats.brewsCount,
      'toolkit_count': stats.toolkitCount,
      'cupping_count': stats.cuppingCount,
      'streak_days': stats.streakDays,
      'last_activity_date': lastDate,
    };
  }

  /// Menerapkan snapshot dari cloud NeonDB ke partisi milik `userId` tanpa memicu loop push balik.
  Future<void> applyCloudSnapshot({
    required String userId,
    required int totalExp,
    required int brewsCount,
    required int toolkitCount,
    required int cuppingCount,
    required int streakDays,
    String? lastActivityDate,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final uid = UserScopedStorage.normalizeUserId(userId);
    await Future.wait([
      sp.setInt(UserScopedStorage.scopedKey(_keyExp, userId: uid), totalExp < 0 ? 0 : totalExp),
      sp.setInt(UserScopedStorage.scopedKey(_keyBrews, userId: uid), brewsCount < 0 ? 0 : brewsCount),
      sp.setInt(UserScopedStorage.scopedKey(_keyToolkit, userId: uid), toolkitCount < 0 ? 0 : toolkitCount),
      sp.setInt(UserScopedStorage.scopedKey(_keyCupping, userId: uid), cuppingCount < 0 ? 0 : cuppingCount),
      sp.setInt(UserScopedStorage.scopedKey(_keyStreak, userId: uid), streakDays < 1 ? 1 : streakDays),
      if (lastActivityDate != null && lastActivityDate.trim().isNotEmpty)
        sp.setString(UserScopedStorage.scopedKey(_keyLastDate, userId: uid), lastActivityDate.trim()),
    ]);
    notifyListeners();
  }

  /// Memicu pembaruan UI saat sesi berganti akun / logout.
  void notifySessionSwitched() {
    notifyListeners();
  }

  /// Set level dan statistik gamifikasi secara eksplisit (e.g. untuk preset akun admin1-10)
  Future<void> setLevelStats({
    required int exp,
    int brews = 0,
    int cupping = 0,
    int toolkit = 0,
    int streak = 1,
    String? userId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final uid = userId ?? await UserScopedStorage.resolveActiveUserId(prefs: sp);
    await Future.wait([
      sp.setInt(UserScopedStorage.scopedKey(_keyExp, userId: uid), exp),
      sp.setInt(UserScopedStorage.scopedKey(_keyBrews, userId: uid), brews),
      sp.setInt(UserScopedStorage.scopedKey(_keyCupping, userId: uid), cupping),
      sp.setInt(UserScopedStorage.scopedKey(_keyToolkit, userId: uid), toolkit),
      sp.setInt(UserScopedStorage.scopedKey(_keyStreak, userId: uid), streak),
    ]);
    notifyListeners();
  }

  /// Catat seduhan selesai (+50 EXP dasar, bonus rating & catatan)
  Future<void> recordBrewCompleted({bool hasRating = false, bool hasNotes = false}) async {
    final sp = await SharedPreferences.getInstance();
    final expKey = await _k(_keyExp, sp);
    final brewsKey = await _k(_keyBrews, sp);

    int earned = 50;
    if (hasRating) earned += 15;
    if (hasNotes) earned += 25;

    final currentExp = sp.getInt(expKey) ?? 0;
    final currentBrews = sp.getInt(brewsKey) ?? 0;

    await sp.setInt(expKey, currentExp + earned);
    await sp.setInt(brewsKey, currentBrews + 1);

    await _checkStreakInternal(sp);
    notifyListeners();
    UserScopedStorage.notifyDataMutated();
  }

  /// Catat penggunaan toolkit presisi (Matriks Grinder, TDS, Kimia Air, 4:6) (+20 EXP)
  Future<void> recordToolkitUsed(String toolName) async {
    final sp = await SharedPreferences.getInstance();
    final expKey = await _k(_keyExp, sp);
    final toolKey = await _k(_keyToolkit, sp);

    final currentExp = sp.getInt(expKey) ?? 0;
    final currentTools = sp.getInt(toolKey) ?? 0;

    await sp.setInt(expKey, currentExp + 20);
    await sp.setInt(toolKey, currentTools + 1);

    notifyListeners();
    UserScopedStorage.notifyDataMutated();
  }

  /// Catat cupping/evaluasi sensorik flavor wheel (+35 EXP)
  Future<void> recordCuppingCompleted() async {
    final sp = await SharedPreferences.getInstance();
    final expKey = await _k(_keyExp, sp);
    final cupKey = await _k(_keyCupping, sp);

    final currentExp = sp.getInt(expKey) ?? 0;
    final currentCupping = sp.getInt(cupKey) ?? 0;

    await sp.setInt(expKey, currentExp + 35);
    await sp.setInt(cupKey, currentCupping + 1);

    notifyListeners();
    UserScopedStorage.notifyDataMutated();
  }

  /// Sinkronisasi awal dengan riwayat seduhan riil user
  Future<void> syncWithBrewHistoryCount(int actualHistoryCount) async {
    final sp = await SharedPreferences.getInstance();
    final expKey = await _k(_keyExp, sp);
    final brewsKey = await _k(_keyBrews, sp);

    final currentBrews = sp.getInt(brewsKey) ?? 0;
    if (actualHistoryCount > currentBrews) {
      final diff = actualHistoryCount - currentBrews;
      final currentExp = sp.getInt(expKey) ?? 0;
      await sp.setInt(brewsKey, actualHistoryCount);
      await sp.setInt(expKey, currentExp + (diff * 50));
      notifyListeners();
      UserScopedStorage.notifyDataMutated();
    }
  }

  /// Cek streak harian
  Future<void> checkDailyStreak() async {
    final sp = await SharedPreferences.getInstance();
    final updated = await _checkStreakInternal(sp);
    if (updated) {
      notifyListeners();
      UserScopedStorage.notifyDataMutated();
    }
  }

  Future<bool> _checkStreakInternal(SharedPreferences sp) async {
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: sp);
    final expKey = UserScopedStorage.scopedKey(_keyExp, userId: uid);
    final streakKey = UserScopedStorage.scopedKey(_keyStreak, userId: uid);
    final lastDateKey = UserScopedStorage.scopedKey(_keyLastDate, userId: uid);

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDateStr = sp.getString(lastDateKey);

    if (lastDateStr == todayStr) return false; // Sudah tercatat hari ini

    int streak = sp.getInt(streakKey) ?? 0;
    if (lastDateStr != null) {
      try {
        final lastDate = DateTime.parse(lastDateStr);
        final diffDays =
            now.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
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

    final currentExp = sp.getInt(expKey) ?? 0;
    await sp.setString(lastDateKey, todayStr);
    await sp.setInt(streakKey, streak);
    await sp.setInt(expKey, currentExp + 25); // Bonus harian
    return true;
  }
}
