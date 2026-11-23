import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/user_scoped_storage.dart';
import '../features/gamification/services/gamification_service.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'profile_service.dart';

class ProfileSyncResult {
  final bool syncedToCloud;
  final String? avatarUrl;
  final String? fullName;
  final String? email;
  final String message;

  const ProfileSyncResult({
    required this.syncedToCloud,
    this.avatarUrl,
    this.fullName,
    this.email,
    required this.message,
  });
}

/// Mesin sinkronisasi lintas perangkat (Cross-Device Cloud Sync) Coffee Labs.
///
/// Menjamin data Gamification (Level, EXP, Seduhan, Toolkit, Evaluasi, Streak),
/// Riwayat Seduh, Jurnal Rasa, Favorit, Resep Custom, Nama, dan Foto Profil
/// terisolasi per-user dan selalu identik di perangkat mana pun pengguna login.
class UserCloudSyncService {
  UserCloudSyncService._();

  static const String _dirtyFlagBaseKey = 'coffeehub_cloud_state_dirty_v1';
  static final http.Client _httpClient = http.Client();

  static Timer? _pushDebounce;
  static bool _hooksRegistered = false;
  static bool _isHydrating = false;
  static bool _isPushing = false;
  static String? _lastHydratedUserId;
  static DateTime? _lastHydratedAt;

  static bool _isCloudEligibleUser(AuthUser? user) {
    if (user == null) return false;
    final id = user.id.trim().toLowerCase();
    if (id.isEmpty || id == UserScopedStorage.guestScope) return false;
    if (id.startsWith('admin_preset_') || id == 'business_demo_user') return false;
    return true;
  }

  /// Mendaftarkan hook mutasi otomatis sehingga setiap perubahan data lokal
  /// milik user terautentikasi langsung dijadwalkan untuk push ke cloud NeonDB.
  static void ensureHooksRegistered() {
    if (_hooksRegistered) return;
    _hooksRegistered = true;
    UserScopedStorage.onUserDataMutated = () {
      unawaited(_markCurrentUserDirty());
      schedulePushToCloud();
    };
  }

  static Future<void> _markCurrentUserDirty({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await UserScopedStorage.scopedKeyAsync(
        _dirtyFlagBaseKey,
        userId: userId,
        prefs: prefs,
      );
      await prefs.setBool(key, true);
    } catch (_) {}
  }

  static Future<bool> _isUserDirty(SharedPreferences prefs, String userId) async {
    final key = UserScopedStorage.scopedKey(_dirtyFlagBaseKey, userId: userId);
    return prefs.getBool(key) ?? false;
  }

  static Future<void> _clearUserDirty(SharedPreferences prefs, String userId) async {
    final key = UserScopedStorage.scopedKey(_dirtyFlagBaseKey, userId: userId);
    await prefs.setBool(key, false);
  }

  /// Menjadwalkan sinkronisasi latar belakang (debounced) setelah mutasi lokal.
  static void schedulePushToCloud({Duration delay = const Duration(milliseconds: 900)}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _pushDebounce?.cancel();
    _pushDebounce = Timer(delay, () {
      unawaited(pushCurrentUserStateToCloud());
    });
  }

  /// Memaksa pengiriman mutasi yang belum tersinkron sebelum pengguna logout.
  static Future<void> flushPendingSync() async {
    _pushDebounce?.cancel();
    _pushDebounce = null;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      await pushCurrentUserStateToCloud().timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  /// Mengunduh dan menghidrasi seluruh data personal pengguna dari cloud NeonDB
  /// ke partisi lokal `u_<userId>_*`. Dipanggil saat login, boot app, dan pull-to-refresh.
  static Future<bool> hydrateFromCloud({
    required AuthUser user,
    bool force = false,
  }) async {
    ensureHooksRegistered();
    if (!_isCloudEligibleUser(user)) return false;

    final uid = user.id.trim();
    UserScopedStorage.setActiveUserId(uid);

    if (!force &&
        _lastHydratedUserId == uid &&
        _lastHydratedAt != null &&
        DateTime.now().difference(_lastHydratedAt!) < const Duration(seconds: 15)) {
      return true;
    }

    if (_isHydrating) return false;
    _isHydrating = true;

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) return false;

      final baseUrl = await AuthService.getBaseUrl();
      final res = await _httpClient
          .get(
            Uri.parse('$baseUrl/api/v1/users/me/cloud-state'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return false;

      final decoded = json.decode(res.body);
      if (decoded is! Map<String, dynamic>) return false;
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return false;

      final prefs = await SharedPreferences.getInstance();
      final isDirty = await _isUserDirty(prefs, uid);

      final hasCloudRecord = data['has_cloud_record'] == true;
      final cloudExp = (data['total_exp'] as num?)?.toInt() ?? 0;
      final cloudBrews = (data['brews_count'] as num?)?.toInt() ?? 0;
      final cloudToolkit = (data['toolkit_count'] as num?)?.toInt() ?? 0;
      final cloudCupping = (data['cupping_count'] as num?)?.toInt() ?? 0;
      final cloudStreak = math.max(1, (data['streak_days'] as num?)?.toInt() ?? 1);
      final cloudLastDate = data['last_activity_date']?.toString();

      final cloudHistory = (data['brew_history'] as List<dynamic>?) ?? const [];
      final cloudJournal = (data['brew_journal'] as List<dynamic>?) ?? const [];
      final cloudCustom = (data['custom_recipes'] as List<dynamic>?) ?? const [];
      final cloudFavs = ((data['favorite_recipe_ids'] as List<dynamic>?) ?? const [])
          .map((e) => (e as num?)?.toInt() ?? -1)
          .where((e) => e > 0)
          .toList();
      final cloudDeleted = ((data['deleted_default_ids'] as List<dynamic>?) ?? const [])
          .map((e) => (e as num?)?.toInt() ?? -1)
          .where((e) => e > 0)
          .toList();

      final localRawG = await GamificationService.instance.exportRawState(userId: uid);
      final localExp = (localRawG['total_exp'] as num?)?.toInt() ?? 0;
      final localBrews = (localRawG['brews_count'] as num?)?.toInt() ?? 0;
      final localToolkit = (localRawG['toolkit_count'] as num?)?.toInt() ?? 0;
      final localCupping = (localRawG['cupping_count'] as num?)?.toInt() ?? 0;
      final localStreak = math.max(1, (localRawG['streak_days'] as num?)?.toInt() ?? 1);
      final localLastDate = localRawG['last_activity_date']?.toString();

      final mergedExp = math.max(cloudExp, localExp);
      final mergedBrews = math.max(cloudBrews, localBrews);
      final mergedToolkit = math.max(cloudToolkit, localToolkit);
      final mergedCupping = math.max(cloudCupping, localCupping);
      final mergedStreak = math.max(cloudStreak, localStreak);
      final mergedLastDate = _pickLatestDate(cloudLastDate, localLastDate);

      final localCols = await ApiService.exportCloudCollections(userId: uid);
      final localHistory = (localCols['brew_history'] as List<dynamic>?) ?? const [];
      final localJournal = (localCols['brew_journal'] as List<dynamic>?) ?? const [];
      final localCustom = (localCols['custom_recipes'] as List<dynamic>?) ?? const [];
      final localFavs = (localCols['favorite_recipe_ids'] as List<int>?) ?? const <int>[];
      final localDeleted = (localCols['deleted_default_ids'] as List<int>?) ?? const <int>[];

      final List<dynamic> finalHistory;
      final List<dynamic> finalJournal;
      final List<dynamic> finalCustom;
      final List<int> finalFavs;
      final List<int> finalDeleted;

      if (hasCloudRecord && !isDirty) {
        finalHistory = cloudHistory;
        finalJournal = cloudJournal;
        finalCustom = cloudCustom;
        finalFavs = cloudFavs;
        finalDeleted = cloudDeleted;
      } else {
        finalHistory = _mergeMapLists(
          cloudHistory,
          localHistory,
          keyOf: (m) => '${m['id'] ?? ''}_${m['brewedAt'] ?? ''}',
          maxItems: 50,
        );
        finalJournal = _mergeMapLists(
          cloudJournal,
          localJournal,
          keyOf: (m) => '${m['id'] ?? m['createdAt'] ?? ''}',
          maxItems: 100,
        );
        finalCustom = _mergeMapLists(
          cloudCustom,
          localCustom,
          keyOf: (m) => '${m['id'] ?? ''}',
          maxItems: 100,
        );
        finalFavs = <int>{...cloudFavs, ...localFavs}.toList();
        finalDeleted = <int>{...cloudDeleted, ...localDeleted}.toList();
      }

      await GamificationService.instance.applyCloudSnapshot(
        userId: uid,
        totalExp: mergedExp,
        brewsCount: mergedBrews,
        toolkitCount: mergedToolkit,
        cuppingCount: mergedCupping,
        streakDays: mergedStreak,
        lastActivityDate: mergedLastDate,
      );

      await ApiService.applyCloudCollections(
        userId: uid,
        brewHistory: finalHistory,
        brewJournal: finalJournal,
        favoriteRecipeIds: finalFavs,
        customRecipes: finalCustom,
        deletedDefaultIds: finalDeleted,
      );

      final cloudFullName = data['full_name']?.toString().trim();
      final cloudAvatar = data['avatar_url']?.toString().trim();
      await ProfileService.applyCloudProfile(
        userId: uid,
        fullName: cloudFullName,
        avatarUrl: cloudAvatar,
      );

      if ((cloudFullName != null && cloudFullName.isNotEmpty && cloudFullName != user.fullName) ||
          (cloudAvatar != null && cloudAvatar.isNotEmpty && cloudAvatar != user.avatarUrl)) {
        final refreshed = AuthUser(
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: (cloudFullName != null && cloudFullName.isNotEmpty)
              ? cloudFullName
              : user.fullName,
          role: user.role,
          status: user.status,
          tier: user.tier,
          subscriptionPlanId: user.subscriptionPlanId,
          avatarUrl: (cloudAvatar != null && cloudAvatar.isNotEmpty)
              ? cloudAvatar
              : user.avatarUrl,
          createdAt: user.createdAt,
          trialFullUntil: user.trialFullUntil,
          trialPolicyOverride: user.trialPolicyOverride,
        );
        await AuthService.persistSessionMirrors(prefs, user: refreshed);
      }

      _lastHydratedUserId = uid;
      _lastHydratedAt = DateTime.now();

      final localAhead = mergedExp > cloudExp ||
          mergedBrews > cloudBrews ||
          mergedToolkit > cloudToolkit ||
          mergedCupping > cloudCupping ||
          isDirty ||
          (!hasCloudRecord &&
              (mergedExp > 0 ||
                  finalHistory.isNotEmpty ||
                  finalJournal.isNotEmpty ||
                  finalFavs.isNotEmpty ||
                  finalCustom.isNotEmpty));

      if (localAhead) {
        schedulePushToCloud(delay: const Duration(milliseconds: 300));
      } else {
        await _clearUserDirty(prefs, uid);
      }
      return true;
    } catch (e) {
      debugPrint('⚠️ UserCloudSyncService.hydrateFromCloud error: $e');
      return false;
    } finally {
      _isHydrating = false;
    }
  }

  /// Mengirimkan snapshot state lokal milik pengguna aktif ke NeonDB Cloud.
  static Future<bool> pushCurrentUserStateToCloud() async {
    if (_isPushing) return false;
    final user = await AuthService.getCurrentUser();
    if (!_isCloudEligibleUser(user)) return false;

    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return false;

    final uid = user!.id.trim();
    _isPushing = true;

    try {
      final gState = await GamificationService.instance.exportRawState(userId: uid);
      final cols = await ApiService.exportCloudCollections(userId: uid);
      final baseUrl = await AuthService.getBaseUrl();

      final payload = {
        'total_exp': gState['total_exp'] ?? 0,
        'brews_count': gState['brews_count'] ?? 0,
        'toolkit_count': gState['toolkit_count'] ?? 0,
        'cupping_count': gState['cupping_count'] ?? 0,
        'streak_days': math.max(1, (gState['streak_days'] as num?)?.toInt() ?? 1),
        if (gState['last_activity_date'] != null)
          'last_activity_date': gState['last_activity_date'],
        'brew_history': cols['brew_history'] ?? const [],
        'brew_journal': cols['brew_journal'] ?? const [],
        'favorite_recipe_ids': cols['favorite_recipe_ids'] ?? const [],
        'custom_recipes': cols['custom_recipes'] ?? const [],
        'deleted_default_ids': cols['deleted_default_ids'] ?? const [],
      };

      final res = await _httpClient
          .put(
            Uri.parse('$baseUrl/api/v1/users/me/cloud-state'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await _clearUserDirty(prefs, uid);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ UserCloudSyncService.pushCurrentUserStateToCloud error: $e');
      return false;
    } finally {
      _isPushing = false;
    }
  }

  /// Memperbarui nama dan/atau foto profil ke partisi lokal, mengunggah foto galeri ke Cloudinary
  /// (jika berupa file lokal), dan menyinkronkannya ke `PUT /api/v1/users/profile` sehingga langsung
  /// tampil di Social Chat, daftar barista, dan semua perangkat user.
  static Future<ProfileSyncResult> updateProfileAndSync({
    String? fullName,
    String? email,
    String? avatarPathOrUrl,
  }) async {
    final cleanName = fullName?.trim();
    final cleanEmail = email?.trim().toLowerCase();
    final cleanAvatar = avatarPathOrUrl?.trim();

    if (cleanName != null && cleanName.isNotEmpty) {
      await ProfileService.setUserName(cleanName);
    }
    if (cleanAvatar != null && cleanAvatar.isNotEmpty) {
      await ProfileService.setUserImagePath(cleanAvatar);
    }

    final user = await AuthService.getCurrentUser();
    final token = await AuthService.getToken();
    if (!_isCloudEligibleUser(user) || token == null || token.isEmpty) {
      return ProfileSyncResult(
        syncedToCloud: false,
        avatarUrl: cleanAvatar,
        fullName: cleanName,
        email: cleanEmail,
        message: 'Profil disimpan secara lokal.',
      );
    }

    String? resolvedAvatarForCloud = cleanAvatar;
    if (cleanAvatar != null &&
        cleanAvatar.isNotEmpty &&
        !cleanAvatar.startsWith('assets/') &&
        !cleanAvatar.startsWith('http://') &&
        !cleanAvatar.startsWith('https://')) {
      final uploadedUrl = await _uploadAvatarToCloudinary(
        localFilePath: cleanAvatar,
        userId: user!.id,
        token: token,
      );
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        resolvedAvatarForCloud = uploadedUrl;
      } else {
        // Jangan kirim path file lokal (/data/user/0/...) ke NeonDB agar perangkat lain tidak rusak.
        resolvedAvatarForCloud = null;
      }
    }

    final body = <String, dynamic>{};
    if (cleanName != null && cleanName.isNotEmpty) {
      body['full_name'] = cleanName;
    }
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      body['email'] = cleanEmail;
    }
    if (resolvedAvatarForCloud != null && resolvedAvatarForCloud.isNotEmpty) {
      body['avatar_url'] = resolvedAvatarForCloud;
    }

    if (body.isEmpty) {
      return ProfileSyncResult(
        syncedToCloud: false,
        avatarUrl: cleanAvatar,
        fullName: cleanName,
        email: cleanEmail,
        message: 'Foto profil disimpan lokal. Unggah foto galeri ke cloud membutuhkan koneksi internet.',
      );
    }

    try {
      final baseUrl = await AuthService.getBaseUrl();
      final res = await _httpClient
          .put(
            Uri.parse('$baseUrl/api/v1/users/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final data = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
            ? decoded['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        final finalName = (data['full_name']?.toString().trim().isNotEmpty == true)
            ? data['full_name'].toString().trim()
            : (cleanName ?? user!.fullName);
        final finalEmail = (data['email']?.toString().trim().isNotEmpty == true)
            ? data['email'].toString().trim()
            : ((cleanEmail != null && cleanEmail.isNotEmpty) ? cleanEmail : user!.email);
        final finalAvatar = (data['avatar_url']?.toString().trim().isNotEmpty == true)
            ? data['avatar_url'].toString().trim()
            : (resolvedAvatarForCloud ?? user!.avatarUrl);

        final updatedUser = AuthUser(
          id: user!.id,
          username: user.username,
          email: finalEmail,
          fullName: finalName,
          role: user.role,
          status: user.status,
          tier: user.tier,
          subscriptionPlanId: user.subscriptionPlanId,
          avatarUrl: finalAvatar,
          createdAt: user.createdAt,
          trialFullUntil: user.trialFullUntil,
          trialPolicyOverride: user.trialPolicyOverride,
        );

        final prefs = await SharedPreferences.getInstance();
        await AuthService.persistSessionMirrors(prefs, user: updatedUser);
        await ProfileService.applyCloudProfile(
          userId: user.id,
          fullName: finalName,
          avatarUrl: finalAvatar,
        );
        AuthService.changeNotifier.value++;

        return ProfileSyncResult(
          syncedToCloud: true,
          avatarUrl: finalAvatar,
          fullName: finalName,
          email: finalEmail,
          message: 'Profil berhasil disimpan & disinkronkan ke cloud!',
        );
      }

      try {
        final errJson = json.decode(res.body);
        if (errJson is Map<String, dynamic> &&
            errJson['message']?.toString().trim().isNotEmpty == true) {
          return ProfileSyncResult(
            syncedToCloud: false,
            avatarUrl: cleanAvatar,
            fullName: cleanName,
            email: cleanEmail,
            message: errJson['message'].toString().trim(),
          );
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('⚠️ UserCloudSyncService.updateProfileAndSync error: $e');
    }

    return ProfileSyncResult(
      syncedToCloud: false,
      avatarUrl: cleanAvatar,
      fullName: cleanName,
      email: cleanEmail,
      message: 'Profil tersimpan di perangkat (gagal menyinkronkan ke server saat ini).',
    );
  }

  /// Unggah gambar profil dari galeri langsung ke Cloudinary memakai Signed Upload endpoint backend.
  static Future<String?> _uploadAvatarToCloudinary({
    required String localFilePath,
    required String userId,
    required String token,
  }) async {
    try {
      final file = File(localFilePath);
      if (!file.existsSync()) return null;

      final baseUrl = await AuthService.getBaseUrl();
      final safeUid = UserScopedStorage.normalizeUserId(userId);
      final publicId = 'avatar_${safeUid}_${DateTime.now().millisecondsSinceEpoch}';

      final sigRes = await _httpClient
          .post(
            Uri.parse('$baseUrl/api/v1/media/upload-signature'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'folder': 'coffe_labs/avatars',
              'public_id': publicId,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (sigRes.statusCode != 200) return null;
      final sigDecoded = json.decode(sigRes.body);
      final sigData = (sigDecoded is Map<String, dynamic> &&
              sigDecoded['data'] is Map<String, dynamic>)
          ? sigDecoded['data'] as Map<String, dynamic>
          : null;
      if (sigData == null) return null;

      final uploadUrl = sigData['upload_url']?.toString() ?? '';
      final apiKey = sigData['api_key']?.toString() ?? '';
      final signature = sigData['signature']?.toString() ?? '';
      final timestamp = sigData['timestamp']?.toString() ?? '';
      final folder = sigData['folder']?.toString() ?? 'coffe_labs/avatars';
      final signedPublicId = sigData['public_id']?.toString();

      if (uploadUrl.isEmpty || apiKey.isEmpty || signature.isEmpty || timestamp.isEmpty) {
        return null;
      }

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..fields['folder'] = folder;
      if (signedPublicId != null && signedPublicId.isNotEmpty) {
        request.fields['public_id'] = signedPublicId;
      }
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        debugPrint('⚠️ Cloudinary upload gagal (HTTP ${streamed.statusCode}): $body');
        return null;
      }

      final uploaded = json.decode(body);
      if (uploaded is Map<String, dynamic>) {
        final secureUrl = uploaded['secure_url']?.toString().trim() ??
            uploaded['url']?.toString().trim();
        if (secureUrl != null && secureUrl.startsWith('http')) {
          return secureUrl;
        }
      }
    } catch (e) {
      debugPrint('⚠️ _uploadAvatarToCloudinary error: $e');
    }
    return null;
  }

  static String? _pickLatestDate(String? a, String? b) {
    final ca = a?.trim();
    final cb = b?.trim();
    if (ca == null || ca.isEmpty) return cb;
    if (cb == null || cb.isEmpty) return ca;
    return ca.compareTo(cb) >= 0 ? ca : cb;
  }

  static List<dynamic> _mergeMapLists(
    List<dynamic> primary,
    List<dynamic> secondary, {
    required String Function(Map<dynamic, dynamic>) keyOf,
    required int maxItems,
  }) {
    final seen = <String>{};
    final merged = <dynamic>[];
    for (final item in [...primary, ...secondary]) {
      if (item is! Map) continue;
      final k = keyOf(item);
      if (k.isNotEmpty && !seen.add(k)) continue;
      merged.add(item);
      if (merged.length >= maxItems) break;
    }
    return merged;
  }
}
