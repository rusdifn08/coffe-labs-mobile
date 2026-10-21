import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'profile_service.dart';

class TrialService {
  static const String _trialModeKey = 'coffeehub_is_trial_mode';
  static const String _trialBrewsCountKey = 'coffeehub_trial_brews_count';
  static const String _trialLockTimeKey = 'coffeehub_trial_lock_timestamp';

  static const int maxTrialBrews = 10;
  static const int maxTrialRecipes = 10;
  static const Duration lockDuration = Duration(days: 7); // 1 Minggu

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  /// Cek apakah pengguna sedang berada di Mode Trial
  static Future<bool> isTrialMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialModeKey) ?? false;
  }

  /// Aktifkan / nonaktifkan mode trial
  static Future<void> setTrialMode(bool isTrial) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trialModeKey, isTrial);
    if (isTrial) {
      // Jika baru masuk trial, pastikan ada nama tamu
      final currentName = await ProfileService.getUserName();
      if (currentName.isEmpty || currentName == 'Barista') {
        await ProfileService.setUserName('Pengunjung Trial');
      }
    }
    changeNotifier.value++;
  }

  /// Dapatkan jumlah seduhan yang sudah dilakukan selama trial
  static Future<int> getTrialBrewsCount() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkWeeklyReset(prefs);
    return prefs.getInt(_trialBrewsCountKey) ?? 0;
  }

  /// Cek apakah masa lock 1 minggu sudah lewat. Jika sudah, reset otomatis.
  static Future<void> _checkWeeklyReset(SharedPreferences prefs) async {
    final lockMillis = prefs.getInt(_trialLockTimeKey);
    if (lockMillis != null && lockMillis > 0) {
      final lockDate = DateTime.fromMillisecondsSinceEpoch(lockMillis);
      final difference = DateTime.now().difference(lockDate);
      if (difference >= lockDuration) {
        // Sudah 1 minggu, reset trial!
        await prefs.setInt(_trialBrewsCountKey, 0);
        await prefs.remove(_trialLockTimeKey);
        changeNotifier.value++;
      }
    }
  }

  /// Cek apakah fitur seduh sedang terkunci di mode trial
  static Future<bool> isBrewLocked() async {
    final inTrial = await isTrialMode();
    if (!inTrial) return false;

    final prefs = await SharedPreferences.getInstance();
    await _checkWeeklyReset(prefs);

    final count = prefs.getInt(_trialBrewsCountKey) ?? 0;
    return count >= maxTrialBrews;
  }

  /// Hitung sisa waktu tunggu lock 1 minggu
  static Future<Duration?> getRemainingLockDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final lockMillis = prefs.getInt(_trialLockTimeKey);
    if (lockMillis == null || lockMillis <= 0) return null;

    final lockDate = DateTime.fromMillisecondsSinceEpoch(lockMillis);
    final unlockDate = lockDate.add(lockDuration);
    final remaining = unlockDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Cek apakah pengguna diizinkan menyeduh kopi saat ini
  static Future<bool> canBrew() async {
    final inTrial = await isTrialMode();
    if (!inTrial) return true; // Full user bebas seduh

    final locked = await isBrewLocked();
    return !locked;
  }

  /// Rekam seduhan baru untuk trial. Jika mencapai 10, kunci selama 1 minggu.
  static Future<void> recordTrialBrew() async {
    final inTrial = await isTrialMode();
    if (!inTrial) return;

    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_trialBrewsCountKey) ?? 0;
    current++;
    await prefs.setInt(_trialBrewsCountKey, current);

    if (current >= maxTrialBrews) {
      await prefs.setInt(_trialLockTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
    changeNotifier.value++;
  }

  /// Cek apakah sebuah resep bisa dibuka berdasarkan urutan indeksnya (0..9 terbuka)
  static Future<bool> isRecipeAccessible(int recipeIndex) async {
    final inTrial = await isTrialMode();
    if (!inTrial) return true;
    return recipeIndex < maxTrialRecipes;
  }

  /// Menampilkan dialog peringatan fitur trial terkunci
  static Future<void> showLockedDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onLoginTap,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.lock_shield_fill, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.sparkles, size: 20, color: AppTheme.primaryBrown),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Login dengan akun resmi untuk membuka seluruh 96+ resep dan seduh tanpa batas!",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLoginTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Login / Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
