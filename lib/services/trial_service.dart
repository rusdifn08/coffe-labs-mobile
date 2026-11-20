import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trial_access_policy.dart';
import '../theme/app_theme.dart';
import 'auth_service.dart';
import 'profile_service.dart';
import 'seed_data.dart';

class TrialService {
  static const String _trialModeKey = 'coffeehub_is_trial_mode';
  static const String _trialBrewsCountKey = 'coffeehub_trial_brews_count';
  static const String _trialLockTimeKey = 'coffeehub_trial_lock_timestamp';
  static const String _trialPolicyJsonKey = 'coffeehub_trial_policy_json';

  static const int maxTrialBrews = 10;
  static const int maxTrialRecipes = 10;
  static const Duration lockDuration = Duration(days: 7); // 1 Minggu

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);
  static final http.Client _httpClient = http.Client();

  static TrialAccessPolicy _cachedPolicy = TrialAccessPolicy.strictLimited;
  static bool _policyLoadedFromDisk = false;
  static bool? _cachedIsTrialMode;
  static Set<int> _cachedCanonicalFreeIds = <int>{};
  static int _cachedCanonicalLimit = -1;

  static DateTime? _lastPolicySyncTime;

  static TrialAccessPolicy get currentPolicySync => _cachedPolicy;
  static bool? get cachedIsTrialMode => _cachedIsTrialMode;

  static void resetPolicyMemoryCache() {
    _cachedPolicy = TrialAccessPolicy.strictLimited;
    _policyLoadedFromDisk = false;
    _cachedIsTrialMode = null;
    _cachedCanonicalFreeIds = <int>{};
    _cachedCanonicalLimit = -1;
    _lastPolicySyncTime = null;
  }

  /// Muat kebijakan Trial dari cache lokal atau backend NeonDB (/api/v1/app/trial-policy).
  static Future<TrialAccessPolicy> getPolicy({bool refreshFromBackend = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_trialPolicyJsonKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cachedPolicy = TrialAccessPolicy.fromJson(
          json.decode(raw) as Map<String, dynamic>,
        );
        _policyLoadedFromDisk = true;
      } catch (_) {}
    } else if (!_policyLoadedFromDisk) {
      _cachedPolicy = TrialAccessPolicy.strictLimited;
      _policyLoadedFromDisk = true;
    }

    if (refreshFromBackend) {
      await syncPolicyFromBackend(force: true);
    }
    return _cachedPolicy;
  }

  /// Sinkronisasi kebijakan Trial terbaru dari backend Rust Axum.
  static Future<TrialAccessPolicy> syncPolicyFromBackend({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastPolicySyncTime != null &&
        now.difference(_lastPolicySyncTime!) < const Duration(seconds: 30)) {
      return _cachedPolicy;
    }
    _lastPolicySyncTime = now;
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/app/trial-policy');
      final response =
          await _httpClient.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final payload = decoded['data'] as Map<String, dynamic>?;
        if (payload != null) {
          final fresh = TrialAccessPolicy.fromJson(payload);
          await setLocalPolicy(fresh, notify: true);
        }
      }
    } catch (_) {}
    return _cachedPolicy;
  }

  /// Simpan kebijakan Trial lokal secara langsung (digunakan Admin & pengujian unit).
  static Future<void> setLocalPolicy(
    TrialAccessPolicy policy, {
    bool notify = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final oldEncoded = prefs.getString(_trialPolicyJsonKey);
    final newEncoded = policy.encodeJson();
    _cachedPolicy = policy;
    _policyLoadedFromDisk = true;
    _cachedCanonicalFreeIds = <int>{};
    _cachedCanonicalLimit = -1;
    await prefs.setString(_trialPolicyJsonKey, newEncoded);
    if (notify && oldEncoded != newEncoded) {
      changeNotifier.value++;
    }
  }

  /// Admin: perbarui kebijakan Trial ke backend NeonDB (/api/admin/trial-policy) + cache lokal.
  static Future<bool> adminSavePolicy(
    TrialAccessPolicy policy, {
    bool resetActivatedAt = false,
  }) async {
    await setLocalPolicy(policy);
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) return false;
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/trial-policy');
      final res = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(policy.toJson(resetActivatedAt: resetActivatedAt)),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body) as Map<String, dynamic>;
        final payload = decoded['data'] as Map<String, dynamic>?;
        if (payload != null) {
          await setLocalPolicy(TrialAccessPolicy.fromJson(payload));
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Cek apakah pengguna sedang berada di Mode Trial / Tamu
  static Future<bool> isTrialMode() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(_trialModeKey) ?? false;
    _cachedIsTrialMode = val;
    return val;
  }

  /// Aktifkan / nonaktifkan mode trial
  static Future<void> setTrialMode(bool isTrial) async {
    _cachedIsTrialMode = isTrial;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool(_trialModeKey);
    if (current == isTrial) return;

    await prefs.setBool(_trialModeKey, isTrial);
    if (isTrial) {
      // Hanya set nama default "Pengunjung" jika belum ada user login resmi
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        final currentName = await ProfileService.getUserName();
        if (currentName.isEmpty || currentName == 'Barista') {
          await ProfileService.setUserName('Pengunjung');
        }
      }
    }
    changeNotifier.value++;
  }

  /// Evaluasi sinkron apakah sebuah fitur terbuka berdasarkan akun, role,
  /// override user (trial_full_until), dan TrialAccessPolicy dari Admin.
  static bool isFeatureUnlockedSync(
    TrialFeature feature, {
    AuthUser? user,
    TrialAccessPolicy? policy,
    DateTime? now,
  }) {
    if (user != null && (user.isAdmin || user.isBusiness)) {
      return true;
    }
    if (user != null && user.isPro) {
      return feature != TrialFeature.businessSuite;
    }

    final p = policy ?? _cachedPolicy;

    // Business Suite STRICTLY terkunci untuk non-Business kecuali Custom Admin eksplisit
    if (feature == TrialFeature.businessSuite) {
      final applicable = user != null ? p.applyToRegisteredTrial : p.applyToGuests;
      return p.isCustom &&
          p.allowBusinessSuite &&
          applicable &&
          p.isWithinActiveWindow(userTrialFullUntil: user?.trialFullUntil, now: now);
    }

    // Per-user Trial 7 Hari Full Non-Bisnis override oleh Admin
    if (user != null &&
        user.trialPolicyOverride == TrialAccessPolicy.modeFull7dNonBusiness &&
        user.trialFullUntil != null &&
        (now ?? DateTime.now()).isBefore(user.trialFullUntil!)) {
      return true;
    }
    if (user != null &&
        user.trialPolicyOverride == TrialAccessPolicy.modeStrictLimited &&
        p.isStrictLimited) {
      return false;
    }

    // Kebijakan Global Admin
    final applies = user != null ? p.applyToRegisteredTrial : p.applyToGuests;
    if (!applies) return false;
    if (!p.isWithinActiveWindow(userTrialFullUntil: user?.trialFullUntil, now: now)) {
      return false;
    }

    switch (feature) {
      case TrialFeature.allRecipes:
        return p.unlockAllRecipes;
      case TrialFeature.unlimitedBrews:
        return p.unlimitedBrews;
      case TrialFeature.smartBrewDialIn:
        return p.unlockSmartBrewDialIn;
      case TrialFeature.aiScanner:
        return p.unlockAiScanner;
      case TrialFeature.toolkitPro:
        return p.unlockToolkitPro;
      case TrialFeature.learningAcademy:
        return p.unlockLearningAcademy;
      case TrialFeature.brewDoctor:
        return p.unlockBrewDoctor;
      case TrialFeature.businessSuite:
        return false;
    }
  }

  static Future<bool> isFeatureUnlocked(TrialFeature feature) async {
    await getPolicy();
    final user = await AuthService.getCurrentUser();
    return isFeatureUnlockedSync(feature, user: user);
  }

  /// Apakah akun saat ini sedang menikmati mode Full Trial 7 Hari Non-Bisnis?
  static bool isFullNonBusinessTrialActiveSync({
    AuthUser? user,
    TrialAccessPolicy? policy,
    DateTime? now,
  }) {
    if (user != null && (user.isAdmin || user.isBusiness || user.isPro)) {
      return false;
    }
    final p = policy ?? _cachedPolicy;
    if (user?.hasActiveFullTrialOverride == true) {
      return true;
    }
    final applies = user != null ? p.applyToRegisteredTrial : p.applyToGuests;
    if (!applies) return false;
    final hasAnyUnlock = p.unlockAllRecipes ||
        p.unlockSmartBrewDialIn ||
        p.unlockToolkitPro ||
        p.unlockLearningAcademy ||
        p.unlockBrewDoctor;
    return hasAnyUnlock &&
        !p.isStrictLimited &&
        p.isWithinActiveWindow(userTrialFullUntil: user?.trialFullUntil, now: now);
  }

  static Duration? remainingTrialPolicyDurationSync({
    AuthUser? user,
    TrialAccessPolicy? policy,
    DateTime? now,
  }) {
    final p = policy ?? _cachedPolicy;
    return p.remainingWindow(userTrialFullUntil: user?.trialFullUntil, now: now);
  }

  /// Ekstrak ID numerik resep secara aman.
  static int extractRecipeId(dynamic rawRecipe) {
    if (rawRecipe is! Map) return -1;
    final rawId = rawRecipe['id'];
    if (rawId is int) return rawId;
    return int.tryParse(rawId?.toString() ?? '') ?? -1;
  }

  /// Menghitung daftar ID resep gratis secara kanonik dari katalog PENUH (sebelum filter/search/sort).
  /// Mencegah bug bypass kunci saat user mengetik pencarian atau memilih filter metode/kategori.
  static Set<int> computeCanonicalFreeIds(
    List<dynamic> unfilteredCatalog, {
    int? maxFree,
  }) {
    final p = _cachedPolicy;
    final limit = (maxFree ??
            (p.unlockAllRecipes ? 999999 : p.maxFreeRecipes))
        .clamp(1, 5000);

    if (unfilteredCatalog.isEmpty) {
      return _seedCanonicalFreeIds(limit);
    }

    final Set<int> ids = <int>{};
    for (final item in unfilteredCatalog) {
      if (item is! Map) continue;
      if (item['isCustom'] == true) continue;
      final id = extractRecipeId(item);
      if (id > 0) {
        ids.add(id);
        if (ids.length >= limit) break;
      }
    }

    if (ids.isNotEmpty) {
      _cachedCanonicalFreeIds = ids;
      _cachedCanonicalLimit = limit;
    }
    return ids;
  }

  static Set<int> _seedCanonicalFreeIds(int limit) {
    if (_cachedCanonicalFreeIds.isNotEmpty && _cachedCanonicalLimit == limit) {
      return _cachedCanonicalFreeIds;
    }
    final defaults = SeedData.getDefaultRecipes();
    // Urutkan sesuai urutan default ApiService (ID 100 paling atas, ID > 100 di atas <= 100)
    final sorted = List<Map<String, dynamic>>.from(defaults)
      ..sort((a, b) {
        final idA = extractRecipeId(a);
        final idB = extractRecipeId(b);
        if (idA == 100) return -1;
        if (idB == 100) return 1;
        if (idA > 100 && idB <= 100) return -1;
        if (idB > 100 && idA <= 100) return 1;
        return idA.compareTo(idB);
      });

    final Set<int> ids = <int>{};
    for (final item in sorted) {
      final id = extractRecipeId(item);
      if (id > 0) {
        ids.add(id);
        if (ids.length >= limit) break;
      }
    }
    _cachedCanonicalFreeIds = ids;
    _cachedCanonicalLimit = limit;
    return ids;
  }

  /// Evaluasi kunci resep berbasis IDENTITAS ID KANONIK (bukan indeks hasil filter!).
  /// Aman terhadap Search, Filter Kategori/Metode, Filter Barista, & Sort.
  static bool isRecipeLockedSync(
    dynamic rawRecipe, {
    required bool isTrial,
    Set<int>? canonicalFreeIds,
    List<dynamic>? unfilteredCatalog,
    AuthUser? user,
    TrialAccessPolicy? policy,
  }) {
    if (!isTrial) return false;
    if (isFeatureUnlockedSync(TrialFeature.allRecipes, user: user, policy: policy)) {
      return false;
    }
    if (rawRecipe is Map && rawRecipe['isCustom'] == true) {
      return false;
    }

    final freeIds = canonicalFreeIds ??
        (unfilteredCatalog != null
            ? computeCanonicalFreeIds(unfilteredCatalog)
            : (_cachedCanonicalFreeIds.isNotEmpty
                ? _cachedCanonicalFreeIds
                : _seedCanonicalFreeIds((policy ?? _cachedPolicy).maxFreeRecipes)));

    final id = extractRecipeId(rawRecipe);
    if (id <= 0) return true;
    return !freeIds.contains(id);
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

  /// Cek apakah sebuah resep bisa dibuka
  static Future<bool> isRecipeAccessible(
    int recipeIdOrIndex, {
    dynamic recipe,
  }) async {
    await getPolicy();
    final inTrial = await isTrialMode();
    if (!inTrial) return true;
    final user = await AuthService.getCurrentUser();
    if (isFeatureUnlockedSync(TrialFeature.allRecipes, user: user)) {
      return true;
    }
    if (recipe != null) {
      return !isRecipeLockedSync(recipe, isTrial: true, user: user);
    }
    return recipeIdOrIndex < _cachedPolicy.maxFreeRecipes;
  }

  /// Cek apakah fitur di Barista Toolkit terkunci untuk akun Trial/Pengunjung.
  /// Mempertimbangkan TrialAccessPolicy aktif yang diatur oleh Admin!
  static bool isToolkitItemLocked({
    required bool isTrial,
    required String sectionId,
    AuthUser? user,
    TrialAccessPolicy? policy,
  }) {
    if (!isTrial) return false;
    final lower = sectionId.toLowerCase();
    if (lower == 'ecosystem') return false;
    if (lower == 'smart_brew' || lower == 'dial_in') {
      return !isFeatureUnlockedSync(
        TrialFeature.smartBrewDialIn,
        user: user,
        policy: policy,
      );
    }
    if (lower == 'scanner' || lower == 'ai_scanner') {
      return !isFeatureUnlockedSync(
        TrialFeature.aiScanner,
        user: user,
        policy: policy,
      );
    }
    if (lower == 'learning' || lower == 'academy') {
      return !isFeatureUnlockedSync(
        TrialFeature.learningAcademy,
        user: user,
        policy: policy,
      );
    }
    if (lower == 'brew_doctor') {
      return !isFeatureUnlockedSync(
        TrialFeature.brewDoctor,
        user: user,
        policy: policy,
      );
    }
    return !isFeatureUnlockedSync(
      TrialFeature.toolkitPro,
      user: user,
      policy: policy,
    );
  }

  /// Menampilkan dialog peringatan bahwa fitur Barista Toolkit terkunci untuk pengunjung/trial
  static Future<void> showToolkitLockedDialog({
    required BuildContext context,
    required String featureName,
    required VoidCallback onLoginTap,
  }) async {
    final currentUser = await AuthService.getCurrentUser();
    if (!context.mounted) return;
    final isRegistered = currentUser != null;

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
              'Fitur "$featureName" merupakan peralatan presisi tingkat lanjut untuk pengguna Coffee Labs Pro atau masa Trial Full Access aktif.',
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
                  Row(
                    children: [
                      const Icon(CupertinoIcons.checkmark_seal_fill, size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 6),
                      Text(
                        isRegistered
                            ? 'Akun Terdaftar (Mode Trial):'
                            : 'Akses Mode Pengunjung:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Akses bebas tersedia pada menu Ekosistem & Komunitas serta 10 resep kurasi pembuka.',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isRegistered
                  ? 'Upgrade ke Coffee Labs Pro (99K) di halaman Profil atau minta akses Trial 7 Hari Full Non-Bisnis dari Admin.'
                  : 'Silakan login atau daftar akun Barista untuk membuka akses penuh.',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppTheme.textMuted)),
          ),
          if (!isRegistered)
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
