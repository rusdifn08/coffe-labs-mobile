import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../models/subscription_plan.dart';
import '../../../services/auth_service.dart';
import '../../../services/subscription_service.dart';
import '../../../services/trial_service.dart';
import '../domain/barista_toolkit_models.dart';
import 'barista_toolkit_seed_data.dart';
import 'ebook_drm_vault_service.dart';

final baristaToolkitApiProvider = Provider<BaristaToolkitApiService>((ref) {
  return BaristaToolkitApiService(ref.watch(dioClientProvider));
});

class BaristaToolkitApiService {
  final Dio _dio;
  BaristaToolkitApiService(this._dio);

  static Future<List<LmsCourseModel>>? _inFlightCoursesFetch;
  static List<LmsCourseModel>? _cachedRemoteCourses;
  static DateTime? _lastCoursesFetchAt;

  static void invalidateLmsCoursesCache() {
    _cachedRemoteCourses = null;
    _lastCoursesFetchAt = null;
  }

  /// Mengonversi path relatif Object Storage backend (`/api/v1/...`) menjadi URL absolut lengkap.
  String resolveMediaUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final cleanBase =
        AuthAndRefreshInterceptor.normalizeBaseUrl(_dio.options.baseUrl);
    return trimmed.startsWith('/') ? '$cleanBase$trimmed' : '$cleanBase/$trimmed';
  }

  /// Mengonversi path relatif Object Storage memakai Base URL live aktif dari [BackendEndpointManager].
  Future<String> resolveMediaUrlAsync(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final activeBase = await AuthAndRefreshInterceptor.resolveActiveBaseUrl();
    final cleanBase = AuthAndRefreshInterceptor.normalizeBaseUrl(activeBase);
    return trimmed.startsWith('/') ? '$cleanBase$trimmed' : '$cleanBase/$trimmed';
  }

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<(AuthUser?, SubscriptionPlan)> _resolveCurrentSessionTier() async {
    await TrialService.getPolicy();
    AuthUser? user = await AuthService.getCurrentUser();
    if (user != null && !_isTestEnv) {
      final synced = await AuthService.syncProfile();
      if (synced != null) {
        user = synced;
      }
    }
    final plan = await SubscriptionService.getCurrentPlan();
    return (user, plan);
  }

  /// Menyelaraskan status kunci setiap E-Book terhadap tier akun live (Pro/Business/Admin/Trial7H)
  /// agar akun Pro tidak pernah terkunci akibat cache seed atau JWT lama sebelum rotasi.
  Future<List<EbookCatalogItem>> reconcileEbooksAccess(
    List<EbookCatalogItem> books, {
    bool syncRemoteProfile = false,
  }) async {
    await TrialService.getPolicy();
    AuthUser? user = await AuthService.getCurrentUser();
    if (syncRemoteProfile && user != null && !_isTestEnv) {
      final synced = await AuthService.syncProfile();
      if (synced != null) user = synced;
    }
    final plan = await SubscriptionService.getCurrentPlan();
    final fullTrial = TrialService.isFullNonBusinessTrialActiveSync(user: user);
    return books
        .map(
          (b) => b.copyWith(
            isUnlocked: ToolkitTierAccess.isUnlockedFor(
              requiredTier: b.requiredTier,
              user: user,
              localPlan: plan,
              hasFullNonBusinessTrial: fullTrial,
            ),
          ),
        )
        .toList();
  }

  /// Menyelaraskan status kunci setiap Bab LMS terhadap tier akun live.
  Future<List<LmsCourseModel>> reconcileCoursesAccess(
    List<LmsCourseModel> courses, {
    bool syncRemoteProfile = false,
  }) async {
    await TrialService.getPolicy();
    AuthUser? user = await AuthService.getCurrentUser();
    if (syncRemoteProfile && user != null && !_isTestEnv) {
      final synced = await AuthService.syncProfile();
      if (synced != null) user = synced;
    }
    final plan = await SubscriptionService.getCurrentPlan();
    final fullTrial = TrialService.isFullNonBusinessTrialActiveSync(user: user);
    return courses
        .map(
          (c) => c.copyWith(
            isUnlocked: ToolkitTierAccess.isUnlockedFor(
              requiredTier: c.requiredTier,
              user: user,
              localPlan: plan,
              hasFullNonBusinessTrial: fullTrial,
            ),
          ),
        )
        .toList();
  }

  Future<List<LmsCourseModel>> fetchLmsCourses({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedRemoteCourses != null &&
        _lastCoursesFetchAt != null &&
        now.difference(_lastCoursesFetchAt!) < const Duration(seconds: 15)) {
      return reconcileCoursesAccess(_cachedRemoteCourses!);
    }
    if (!forceRefresh && _inFlightCoursesFetch != null) {
      return _inFlightCoursesFetch!;
    }
    final future = _fetchLmsCoursesInternal();
    _inFlightCoursesFetch = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightCoursesFetch, future)) {
        _inFlightCoursesFetch = null;
      }
    }
  }

  Future<List<LmsCourseModel>> _fetchLmsCoursesInternal() async {
    final (user, plan) = await _resolveCurrentSessionTier();
    final fullTrial = TrialService.isFullNonBusinessTrialActiveSync(user: user);
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/toolkit/lms/courses');
      final list = res.data?['data'] as List? ?? [];
      if (list.isNotEmpty) {
        final mapped = list.map((e) {
          final model = LmsCourseModel.fromJson(Map<String, dynamic>.from(e as Map));
          final localAllowed = ToolkitTierAccess.isUnlockedFor(
            requiredTier: model.requiredTier,
            user: user,
            localPlan: plan,
            hasFullNonBusinessTrial: fullTrial,
          );
          return model.copyWith(isUnlocked: model.isUnlocked || localAllowed);
        }).toList();
        _cachedRemoteCourses = mapped;
        _lastCoursesFetchAt = DateTime.now();
        return mapped;
      }
    } catch (_) {}
    final offline = await BaristaToolkitFallbackSeed.loadOfflineCoursesAsync();
    return offline
        .map(
          (c) => c.copyWith(
            isUnlocked: ToolkitTierAccess.isUnlockedFor(
              requiredTier: c.requiredTier,
              user: user,
              localPlan: plan,
              hasFullNonBusinessTrial: fullTrial,
            ),
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> fetchLessonStream(String lessonId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/toolkit/lms/lessons/$lessonId/stream',
    );
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  Future<Map<String, dynamic>> syncLmsProgress({
    required String lessonId,
    required String watchedBitmapB64,
    required int lastPositionSec,
    List<int>? quizAnswers,
  }) async {
    invalidateLmsCoursesCache();
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/toolkit/lms/lessons/$lessonId/progress',
      data: {
        'watched_bitmap_b64': watchedBitmapB64,
        'last_position_sec': lastPositionSec,
        'quiz_answers': ?quizAnswers,
      },
    );
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  Future<List<EbookCatalogItem>> fetchEbooks() async {
    final (user, plan) = await _resolveCurrentSessionTier();
    final fullTrial = TrialService.isFullNonBusinessTrialActiveSync(user: user);
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/toolkit/ebooks');
      final list = res.data?['data'] as List? ?? [];
      if (list.isNotEmpty) {
        return list.map((e) {
          final model = EbookCatalogItem.fromJson(Map<String, dynamic>.from(e as Map));
          final localAllowed = ToolkitTierAccess.isUnlockedFor(
            requiredTier: model.requiredTier,
            user: user,
            localPlan: plan,
            hasFullNonBusinessTrial: fullTrial,
          );
          return model.copyWith(isUnlocked: model.isUnlocked || localAllowed);
        }).toList();
      }
    } catch (_) {}
    final offline = await BaristaToolkitFallbackSeed.offlineEbooks();
    return offline
        .map(
          (b) => b.copyWith(
            isUnlocked: ToolkitTierAccess.isUnlockedFor(
              requiredTier: b.requiredTier,
              user: user,
              localPlan: plan,
              hasFullNonBusinessTrial: fullTrial,
            ),
          ),
        )
        .toList();
  }

  Future<List<EbookChapterAstModel>> fetchEbookChaptersAst(String ebookId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/toolkit/ebooks/$ebookId/chapters',
      );
      final data = res.data?['data'] as Map?;
      final list = data?['chapters'] as List? ?? [];
      return list
          .map((e) => EbookChapterAstModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CoffeeDictionaryEntryModel>> fetchCoffeeDictionary({
    String? letter,
    String? query,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/toolkit/dictionary',
        queryParameters: {
          if (letter != null && letter.isNotEmpty) 'letter': letter,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );
      final list = res.data?['data'] as List? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((e) => CoffeeDictionaryEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    final all = await BaristaToolkitFallbackSeed.offlineDictionary();
    return all.where((e) {
      final okLetter = letter == null || letter.isEmpty || e.alphabetLetter.toUpperCase() == letter.toUpperCase();
      final q = (query ?? '').trim().toLowerCase();
      final okQuery = q.isEmpty ||
          e.termTitle.toLowerCase().contains(q) ||
          e.shortDefinitionId.toLowerCase().contains(q);
      return okLetter && okQuery;
    }).toList();
  }

  Future<Map<String, dynamic>> requestEbookLicense({
    required String ebookId,
    required String deviceInstallationId,
    required String deviceWrappingSecretB64,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/toolkit/ebooks/$ebookId/license',
      data: {
        'device_installation_id': deviceInstallationId,
        'device_wrapping_secret_b64': deviceWrappingSecretB64,
      },
    );
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  /// Mengunduh paket E-Book lengkap (.clbook + .epub + Bab AST) dari Object Storage ke vault privat offline.
  Future<void> downloadBookPackageFromObjectStorage({
    required EbookCatalogItem book,
    required void Function(double progress, String statusLabel) onProgress,
  }) async {
    final vault = EncryptedEbookVaultService.instance;
    final (deviceId, deviceSecret) = await vault.ensureDeviceCredentials();

    onProgress(0.08, 'Meminta lisensi Object Storage...');
    String clbkUrl = '/api/v1/toolkit/ebooks/${book.id}/asset?format=clbook';
    String epubUrl = '/api/v1/toolkit/ebooks/${book.id}/asset?format=epub';

    try {
      final license = await requestEbookLicense(
        ebookId: book.id,
        deviceInstallationId: deviceId,
        deviceWrappingSecretB64: base64Encode(deviceSecret),
      );
      final sAsset = license['signed_asset_url']?.toString() ?? '';
      final sEpub = license['signed_epub_url']?.toString() ?? '';
      if (sAsset.isNotEmpty) clbkUrl = sAsset;
      if (sEpub.isNotEmpty) epubUrl = sEpub;
    } catch (_) {
      // Fallback ke endpoint asset terotentikasi saat tanpa wrap secret
    }

    onProgress(0.20, 'Mengunduh PDF Terenkripsi (.clbook)...');
    Uint8List clbookBytes;
    try {
      clbookBytes = await _downloadBinaryUrl(
        clbkUrl,
        onChunk: (p) => onProgress(0.20 + p * 0.38, 'Mengunduh PDF Terenkripsi...'),
      );
    } on DioException catch (e) {
      // Jika JWT masih memuat tier lama (403), paksa sinkronisasi profil/rotasi JWT lalu coba ulang sekali
      if (e.response?.statusCode == 403 && !_isTestEnv) {
        await AuthService.syncProfile(force: true);
        clbookBytes = await _downloadBinaryUrl(
          clbkUrl,
          onChunk: (p) => onProgress(0.20 + p * 0.38, 'Menyelaraskan lisensi Pro & mengunduh...'),
        );
      } else {
        rethrow;
      }
    }

    onProgress(0.60, 'Mengunduh EPUB3 Reflowable...');
    Uint8List? epubBytes;
    try {
      epubBytes = await _downloadBinaryUrl(
        epubUrl,
        onChunk: (p) => onProgress(0.60 + p * 0.25, 'Mengunduh EPUB3...'),
      );
    } catch (_) {}

    onProgress(0.88, 'Menyimpan Editorial AST untuk baca offline...');
    final chapters = await fetchEbookChaptersAst(book.id);

    await vault.saveDownloadedBookPackage(
      bookCode: book.bookCode,
      clbookBytes: clbookBytes,
      epubBytes: epubBytes,
      chaptersAst: chapters,
    );
    onProgress(1.0, 'Tersedia untuk baca offline!');
  }

  Future<Uint8List> _downloadBinaryUrl(
    String rawUrl, {
    required void Function(double fraction) onChunk,
  }) async {
    final isExternalSigned = rawUrl.startsWith('https://res.cloudinary.com/');
    final client = isExternalSigned ? Dio() : _dio;
    final res = await client.get<List<int>>(
      rawUrl,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onChunk((received / total).clamp(0.0, 1.0));
        }
      },
    );
    final data = res.data;
    if (data == null || data.isEmpty) {
      throw StateError('Payload unduhan Object Storage kosong.');
    }
    return Uint8List.fromList(data);
  }

  Future<void> syncEbookProgress({
    required String ebookId,
    required int currentPage,
    int? currentChapterNumber,
    List<Map<String, dynamic>>? bookmarks,
    List<Map<String, dynamic>>? highlights,
    String? preferredReaderMode,
  }) async {
    try {
      await _dio.put<dynamic>(
        '/api/v1/toolkit/ebooks/$ebookId/progress',
        data: {
          'current_page': currentPage,
          'current_chapter_number': ?currentChapterNumber,
          'highest_page_reached': currentPage,
          'read_pages': [currentPage],
          'bookmarks_json': ?bookmarks,
          'highlights_notes_json': ?highlights,
          'preferred_reader_mode': ?preferredReaderMode,
        },
      );
    } catch (_) {}
  }

  Future<List<GameBrewChapterModel>> fetchGameChapters() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/toolkit/game-brew/chapters');
      final list = res.data?['data'] as List? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((e) => GameBrewChapterModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    return BaristaToolkitFallbackSeed.offlineChapters();
  }

  Future<Map<String, dynamic>> submitGameScore({
    required int chapterNumber,
    required double pourAccuracyPct,
    required double extractionYieldEst,
    required double thermalStabilityScore,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/toolkit/game-brew/chapters/$chapterNumber/submit',
      data: {
        'pour_accuracy_pct': pourAccuracyPct,
        'extraction_yield_est': extractionYieldEst,
        'thermal_stability_score': thermalStabilityScore,
      },
    );
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  Future<Map<String, dynamic>> submitGame3DScore({
    required int chapterNumber,
    required double durationSec,
    required double pouredTotalMl,
    required double laminarFlowRatio,
    required double flatBedScorePct,
    required double spiralEvennessPct,
    required bool swirlPerformed,
    required int bypassEventsCount,
    required double extractionYieldEst,
    required double thermalStabilityScore,
    required List<Map<String, dynamic>> sampleCurve2Hz,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/toolkit/game-brew/chapters/$chapterNumber/submit-3d',
      data: {
        'duration_sec': durationSec,
        'poured_total_ml': pouredTotalMl,
        'laminar_flow_ratio': laminarFlowRatio.clamp(0.0, 1.0),
        'flat_bed_score_pct': flatBedScorePct.clamp(0.0, 100.0),
        'spiral_evenness_pct': spiralEvennessPct.clamp(0.0, 100.0),
        'swirl_performed': swirlPerformed,
        'bypass_events_count': bypassEventsCount,
        'extraction_yield_est': extractionYieldEst.clamp(10.0, 30.0),
        'thermal_stability_score': thermalStabilityScore.clamp(0.0, 100.0),
        'sample_curve_2hz': sampleCurve2Hz,
      },
    );
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  Future<BrewDoctorDiagnosisModel> diagnoseBrew({
    required List<String> symptomTags,
    required double doseG,
    required double waterMl,
    required double tempC,
    required int targetSec,
    required int actualSec,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/toolkit/brew-doctor/diagnose',
        data: {
          'symptom_tags': symptomTags,
          'dose_g': doseG,
          'water_ml': waterMl,
          'temp_c': tempC,
          'target_sec': targetSec,
          'actual_sec': actualSec,
        },
      );
      final data = res.data?['data'] as Map<String, dynamic>?;
      if (data != null) return BrewDoctorDiagnosisModel.fromJson(data);
    } catch (_) {}
    return diagnoseOfflineFallback(
      symptomTags: symptomTags,
      doseG: doseG,
      waterMl: waterMl,
      tempC: tempC,
      targetSec: targetSec,
      actualSec: actualSec,
    );
  }

  static BrewDoctorDiagnosisModel diagnoseOfflineFallback({
    required List<String> symptomTags,
    required double doseG,
    required double waterMl,
    required double tempC,
    required int targetSec,
    required int actualSec,
  }) {
    double x = 0.0;
    double y = 0.0;
    int sourHits = 0;
    int bitterHits = 0;
    bool channeling = false;

    for (final raw in symptomTags) {
      switch (raw.trim().toLowerCase()) {
        case 'sour':
        case 'salty':
        case 'grassy':
        case 'acidic':
        case 'quick_finish':
          x -= 0.55;
          sourHits++;
        case 'bitter':
        case 'astringent':
        case 'dry':
        case 'ashy':
          x += 0.55;
          bitterHits++;
        case 'channeling':
        case 'uneven':
          channeling = true;
        case 'weak':
        case 'watery':
        case 'thin':
          y -= 0.5;
        case 'heavy':
        case 'muddy':
          y += 0.5;
      }
    }

    x += ((actualSec - targetSec) / 60.0).clamp(-0.4, 0.4);
    final ratio = (waterMl / (doseG <= 0 ? 15.0 : doseG)).clamp(1.0, 30.0);
    if (ratio >= 16.5) y -= 0.3;
    if (ratio <= 14.2) y += 0.3;
    x = x.clamp(-1.0, 1.0);
    y = y.clamp(-1.0, 1.0);

    final ey = (20.0 + x * 3.2).clamp(15.0, 25.0);
    final tds = (1.38 + y * 0.25 + (15.5 - ratio) * 0.04).clamp(0.95, 1.85);

    if (channeling || (sourHits > 0 && bitterHits > 0)) {
      return BrewDoctorDiagnosisModel(
        diagnosisCode: 'UNEVEN_CHANNELING',
        diagnosisTitle: 'Channeling & Ekstraksi Tidak Merata',
        xExtraction: x,
        yStrength: y,
        estimatedEyPct: double.parse(ey.toStringAsFixed(1)),
        estimatedTdsPct: double.parse(tds.toStringAsFixed(2)),
        grindClicksDelta: -1,
        tempCDelta: 0,
        recommendedRatio: '1:15.5',
        explanation: 'Rasa asam dan pahit sepat muncul bersamaan karena air menerobos celah bed kopi.',
        pourTechniqueAdvice: 'Lakukan Rao Spin lembut saat blooming 35 detik dan tuang melingkar tenang di tengah.',
      );
    }
    if (x < -0.25) {
      return BrewDoctorDiagnosisModel(
        diagnosisCode: 'UNDER_EXTRACTED',
        diagnosisTitle: 'Under-Extracted (Kurang Terekstrak)',
        xExtraction: x,
        yStrength: y,
        estimatedEyPct: double.parse(ey.toStringAsFixed(1)),
        estimatedTdsPct: double.parse(tds.toStringAsFixed(2)),
        grindClicksDelta: -2,
        tempCDelta: 2,
        recommendedRatio: '1:15',
        explanation: 'Gula manis kopi belum larut sempurna sehingga asam tajam mendominasi cangkir.',
        pourTechniqueAdvice: 'Haluskan gilingan -2 klik dan naikkan suhu seduh +2°C.',
      );
    }
    if (x > 0.25) {
      return BrewDoctorDiagnosisModel(
        diagnosisCode: 'OVER_EXTRACTED',
        diagnosisTitle: 'Over-Extracted (Terlalu Terekstrak)',
        xExtraction: x,
        yStrength: y,
        estimatedEyPct: double.parse(ey.toStringAsFixed(1)),
        estimatedTdsPct: double.parse(tds.toStringAsFixed(2)),
        grindClicksDelta: 2,
        tempCDelta: -2,
        recommendedRatio: '1:15.5',
        explanation: 'Kontak air berlebih menarik tanin pahit & sepat kering di akhir drawdown.',
        pourTechniqueAdvice: 'Kasarkan gilingan +2 klik, turunkan suhu -2°C, atau pakai Thermal Drop 70°C di tuangan akhir.',
      );
    }
    if (y < -0.25) {
      return BrewDoctorDiagnosisModel(
        diagnosisCode: 'WEAK_RATIO',
        diagnosisTitle: 'Body Terlalu Ringan (Weak / Watery)',
        xExtraction: x,
        yStrength: y,
        estimatedEyPct: double.parse(ey.toStringAsFixed(1)),
        estimatedTdsPct: double.parse(tds.toStringAsFixed(2)),
        grindClicksDelta: -1,
        tempCDelta: 0,
        recommendedRatio: '1:14.5',
        explanation: 'Kadar TDS berada di bawah rentang manis Golden Cup.',
        pourTechniqueAdvice: 'Padatkan rasio ke 1:14.5 atau bagi 60% tuangan akhir menjadi 3x tuangan.',
      );
    }
    return BrewDoctorDiagnosisModel(
      diagnosisCode: 'BALANCED_GOLDEN_CUP',
      diagnosisTitle: 'Golden Cup Seimbang (Sweet & Clean)',
      xExtraction: x,
      yStrength: y,
      estimatedEyPct: double.parse(ey.toStringAsFixed(1)),
      estimatedTdsPct: double.parse(tds.toStringAsFixed(2)),
      grindClicksDelta: 0,
      tempCDelta: 0,
      recommendedRatio: '1:${ratio.toStringAsFixed(1)}',
      explanation: 'Ekstraksi & kekuatan cangkir berada di zona manis ideal SCA Golden Cup!',
      pourTechniqueAdvice: 'Pertahankan parameter gilingan, suhu, dan ritme tuang saat ini.',
    );
  }
}
