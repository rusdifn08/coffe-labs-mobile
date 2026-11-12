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

  /// Cek apakah pengguna sedang berada di Mode Trial / Tamu
  static Future<bool> isTrialMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialModeKey) ?? false;
  }

  /// Aktifkan / nonaktifkan mode trial
  static Future<void> setTrialMode(bool isTrial) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool(_trialModeKey);
    if (current == isTrial) return;

    await prefs.setBool(_trialModeKey, isTrial);
    if (isTrial) {
      // Jika baru masuk trial, pastikan ada nama tamu
      final currentName = await ProfileService.getUserName();
      if (currentName.isEmpty || currentName == 'Barista') {
        await ProfileService.setUserName('Pengunjung');
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
        await prefs.setInt(_trialBrewsCountKey, 0);
        await prefs.remove(_trialLockTimeKey);
        changeNotifier.value++;
      }
    }
  }

  /// Cek apakah fitur seduh sedang terkunci di mode trial.
  /// Berdasarkan permintaan user: mode pengunjung tidak lagi dibatasi 10x seduhan.
  static Future<bool> isBrewLocked() async {
    return false;
  }

  /// Hitung sisa waktu tunggu lock 1 minggu (null jika tidak terkunci)
  static Future<Duration?> getRemainingLockDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final lockMillis = prefs.getInt(_trialLockTimeKey);
    if (lockMillis == null || lockMillis <= 0) return null;

    final lockDate = DateTime.fromMillisecondsSinceEpoch(lockMillis);
    final unlockDate = lockDate.add(lockDuration);
    final remaining = unlockDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Cek apakah pengguna diizinkan menyeduh kopi saat ini.
  /// Pengunjung bebas menyeduh kopi tanpa batasan 10x.
  static Future<bool> canBrew() async {
    return true;
  }

  /// Rekam seduhan baru untuk trial/pengunjung
  static Future<void> recordTrialBrew() async {
    final inTrial = await isTrialMode();
    if (!inTrial) return;

    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_trialBrewsCountKey) ?? 0;
    current++;
    await prefs.setInt(_trialBrewsCountKey, current);
    changeNotifier.value++;
  }

  /// Cek apakah sebuah resep bisa dibuka berdasarkan urutan indeksnya
  static Future<bool> isRecipeAccessible(int recipeIndex) async {
    return true;
  }

  /// Cek apakah fitur di Barista Toolkit terkunci untuk Pengunjung.
  /// Hanya kategori 'ecosystem' (Marketplace, Roastery, Radar, Jurnal, Social, Favorit) yang terbuka bebas.
  /// Kategori 'lab' (Smart Brew, Dial-In, Grinder, 4:6, TDS) dan 'science' (Water, Freshness, Scale, Cupping) terkunci untuk pengunjung.
  static bool isToolkitItemLocked({required bool isTrial, required String sectionId}) {
    if (!isTrial) return false;
    return sectionId.toLowerCase() != 'ecosystem';
  }

  /// Menampilkan dialog peringatan bahwa fitur Barista Toolkit terkunci untuk pengunjung
  static Future<void> showToolkitLockedDialog({
    required BuildContext context,
    required String featureName,
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
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.lock_fill, color: AppTheme.accentGold, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Fitur Barista Pro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur "$featureName" merupakan peralatan presisi tingkat lanjut yang khusus dirancang untuk Barista profesional.',
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textDark, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2EC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.checkmark_seal_fill, size: 16, color: Color(0xFF2E7D32)),
                      SizedBox(width: 6),
                      Text(
                        'Akses Mode Pengunjung:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sebagai pengunjung, Anda memiliki akses bebas ke seluruh menu Ekosistem & Komunitas (Marketplace Kopi, Coffee Roastery, Beans Radar, Jurnal Brew, Social Coffee & Favorit).',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan login atau daftar akun Barista untuk membuka akses Lab Ekstraksi & Sains Kopi.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Eksplor Komunitas', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLoginTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Daftar / Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Menampilkan dialog peringatan fitur trial terkunci (kompatibilitas lama)
  static Future<void> showLockedDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onLoginTap,
  }) async {
    await showToolkitLockedDialog(
      context: context,
      featureName: title,
      onLoginTap: onLoginTap,
    );
  }
}
