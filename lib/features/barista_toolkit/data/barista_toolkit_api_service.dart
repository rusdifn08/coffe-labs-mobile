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

  Future<List<EbookChapterAstModel>> fetchEbookChaptersAst(
    String ebookId, {
    String? bookCode,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/toolkit/ebooks/$ebookId/chapters',
      );
      final data = res.data?['data'] as Map?;
      final list = data?['chapters'] as List? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((e) => EbookChapterAstModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}

    // Fallback langsung ke Object Storage publik (`{code}_chapters.json`) agar bebas error 401
    if (bookCode != null && bookCode.isNotEmpty) {
      try {
        final directUrl = await resolveMediaUrlAsync(
          '/api/v1/toolkit/object-storage/coffeelabs/ebooks/$bookCode/${bookCode}_chapters.json',
        );
        final res = await _createCleanDownloadDio().get<dynamic>(directUrl);
        final raw = res.data;
        final List<dynamic> list = raw is List
            ? raw
            : (raw is String
                ? (jsonDecode(raw) as List<dynamic>)
                : (raw is Map && raw['chapters'] is List
                    ? raw['chapters'] as List<dynamic>
                    : const []));
        if (list.isNotEmpty) {
          return list
              .map((e) => EbookChapterAstModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } catch (_) {}
    }
    return const [];
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

  static Dio _createCleanDownloadDio() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 20),
          followRedirects: true,
        ),
      );

  static String _formatDownloadProgressMb(int received, int total) {
    final recMb = (received / (1024 * 1024)).toStringAsFixed(1);
    if (total > 0) {
      final totMb = (total / (1024 * 1024)).toStringAsFixed(1);
      return '$recMb / $totMb MB';
    }
    return '$recMb MB';
  }

  /// Mengubah error jaringan / Dio teknis menjadi pesan bahasa Indonesia yang jelas dan ramah.
  static String formatFriendlyDownloadError(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 401) {
        return 'Sesi akun perlu diperbarui. Silakan login ulang atau coba unduh kembali.';
      }
      if (code == 403) {
        return 'E-Book ini memerlukan akses paket Pro/Business.';
      }
      if (code == 404) {
        return 'Berkas E-Book belum tersedia di server Cloud Storage. Silakan tarik untuk menyegarkan katalog.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Koneksi melambat (timeout) saat mengunduh E-Book. Pastikan jaringan stabil lalu coba lagi.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server Cloud Storage. Periksa koneksi internet Anda.';
      }
      return 'Gagal mengunduh E-Book dari Cloud Storage (HTTP ${code ?? '-'}). Silakan coba lagi.';
    }
    final raw = error.toString().replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '');
    if (raw.length > 160) {
      return '${raw.substring(0, 157)}...';
    }
    return raw;
  }

  /// Mengunduh paket E-Book lengkap (PDF Asli + EPUB3 Reflowable + Bab AST) dari Cloud Object Storage
  /// ke penyimpanan permanen perangkat pengguna dengan multi-source failover & validasi integritas.
  Future<void> downloadBookPackageFromObjectStorage({
    required EbookCatalogItem book,
    required void Function(double progress, String statusLabel) onProgress,
  }) async {
    final vault = EncryptedEbookVaultService.instance;
    final code = book.bookCode;
    final (deviceId, deviceSecret) = await vault.ensureDeviceCredentials();

    onProgress(0.05, 'Menghubungkan Cloud Object Storage...');
    String? signedPdfUrl;
    String? signedEpubUrl;
    String? signedClbkUrl;

    // 1. Coba minta lisensi (opsional — jika 401/offline pada buku Trial, langsung lanjut Object Storage)
    try {
      final license = await requestEbookLicense(
        ebookId: book.id,
        deviceInstallationId: deviceId,
        deviceWrappingSecretB64: base64Encode(deviceSecret),
      );
      final sPdf = license['signed_pdf_url']?.toString() ?? '';
      final sEpub = license['signed_epub_url']?.toString() ?? '';
      final sAsset = license['signed_asset_url']?.toString() ?? '';
      if (sPdf.isNotEmpty) signedPdfUrl = sPdf;
      if (sEpub.isNotEmpty) signedEpubUrl = sEpub;
      if (sAsset.isNotEmpty) signedClbkUrl = sAsset;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 && !_isTestEnv) {
        await AuthService.syncProfile(force: true);
      }
    } catch (_) {}

    final isTrialOrOpen = book.requiredTier.trim().toLowerCase() == 'trial' ||
        book.requiredTier.trim().toLowerCase() == 'free';

    // 2. Unduh PDF Asli (prioritas utama) dengan failover otomatis:
    //    Public Object Storage (anti-401) <-> Endpoint Backend Terotentikasi <-> Signed URL
    final pdfCandidates = <String>[
      if (signedPdfUrl != null && signedPdfUrl.startsWith('https://')) signedPdfUrl,
      if (isTrialOrOpen || book.isUnlocked)
        '/api/v1/toolkit/object-storage/coffeelabs/ebooks/$code/${code}_id.pdf',
      '/api/v1/toolkit/ebooks/${book.id}/asset?format=pdf',
    ];

    Uint8List? pdfBytes;
    Uint8List? clbookBytes;
    Object? lastErr;

    onProgress(0.12, 'Mengunduh E-Book PDF Asli...');
    for (final candidate in pdfCandidates) {
      try {
        final bytes = await _downloadBinaryWithRetry(
          candidate,
          useCleanClient: candidate.contains('/object-storage/') ||
              candidate.startsWith('https://'),
          onChunk: (p, rec, tot) => onProgress(
            0.12 + p * 0.48,
            'Mengunduh PDF (${_formatDownloadProgressMb(rec, tot)})...',
          ),
        );
        if (EncryptedEbookVaultService.isValidPdfBytes(bytes)) {
          pdfBytes = bytes;
          break;
        }
      } catch (e) {
        lastErr = e;
      }
    }

    // Cadangan: bila PDF langsung gagal, unduh `.clbook` terenkripsi
    if (pdfBytes == null) {
      final clbkCandidates = <String>[
        if (signedClbkUrl != null && signedClbkUrl.startsWith('https://')) signedClbkUrl,
        if (isTrialOrOpen || book.isUnlocked)
          '/api/v1/toolkit/object-storage/coffeelabs/ebooks/$code/${code}_ast.clbook',
        '/api/v1/toolkit/ebooks/${book.id}/asset?format=clbook',
      ];
      for (final candidate in clbkCandidates) {
        try {
          final bytes = await _downloadBinaryWithRetry(
            candidate,
            useCleanClient: candidate.contains('/object-storage/') ||
                candidate.startsWith('https://'),
            onChunk: (p, rec, tot) => onProgress(
              0.18 + p * 0.42,
              'Mengunduh Paket Terenkripsi (${_formatDownloadProgressMb(rec, tot)})...',
            ),
          );
          if (EncryptedEbookVaultService.isValidClbookBytes(bytes)) {
            clbookBytes = bytes;
            break;
          }
        } catch (e) {
          lastErr = e;
        }
      }
    }

    // 3. Unduh EPUB3 Reflowable untuk pengalaman baca layaknya Kindle / Apple Books
    onProgress(0.64, 'Mengunduh EPUB3 Reflowable...');
    final epubCandidates = <String>[
      if (signedEpubUrl != null && signedEpubUrl.startsWith('https://')) signedEpubUrl,
      if (isTrialOrOpen || book.isUnlocked)
        '/api/v1/toolkit/object-storage/coffeelabs/ebooks/$code/${code}_id.epub',
      '/api/v1/toolkit/ebooks/${book.id}/asset?format=epub',
    ];
    Uint8List? epubBytes;
    for (final candidate in epubCandidates) {
      try {
        final bytes = await _downloadBinaryWithRetry(
          candidate,
          useCleanClient: candidate.contains('/object-storage/') ||
              candidate.startsWith('https://'),
          onChunk: (p, rec, tot) => onProgress(
            0.64 + p * 0.22,
            'Mengunduh EPUB3 (${_formatDownloadProgressMb(rec, tot)})...',
          ),
        );
        if (EncryptedEbookVaultService.isValidEpubBytes(bytes)) {
          epubBytes = bytes;
          break;
        }
      } catch (e) {
        lastErr ??= e;
      }
    }

    // 4. Ambil ringkasan Bab & Lab Interaktif (Editorial AST)
    onProgress(0.88, 'Menyiapkan Daftar Isi & Catatan Bab...');
    final chapters = await fetchEbookChaptersAst(book.id, bookCode: code);

    if (pdfBytes == null && clbookBytes == null && epubBytes == null) {
      throw lastErr ??
          StateError('Gagal mengunduh berkas E-Book dari Cloud Storage.');
    }

    onProgress(0.95, 'Menyimpan ke Penyimpanan Offline Perangkat...');
    await vault.saveDownloadedBookPackage(
      bookCode: code,
      pdfBytes: pdfBytes,
      clbookBytes: clbookBytes,
      epubBytes: epubBytes,
      chaptersAst: chapters,
    );
    onProgress(1.0, 'Tersimpan di perangkat & siap dibaca offline!');
  }

  Future<Uint8List> _downloadBinaryWithRetry(
    String rawUrl, {
    required bool useCleanClient,
    required void Function(double fraction, int received, int total) onChunk,
    int maxAttempts = 2,
  }) async {
    Object? lastErr;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _downloadBinaryUrl(
          rawUrl,
          useCleanClient: useCleanClient,
          onChunk: onChunk,
        );
      } catch (e) {
        lastErr = e;
        if (e is DioException) {
          final code = e.response?.statusCode;
          // Jangan retry bila 401/403/404 agar failover langsung pindah ke kandidat berikutnya
          if (code == 401 || code == 403 || code == 404) {
            rethrow;
          }
        }
        if (attempt < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
        }
      }
    }
    throw lastErr ?? StateError('Unduhan gagal setelah $maxAttempts percobaan.');
  }

  Future<Uint8List> _downloadBinaryUrl(
    String rawUrl, {
    bool useCleanClient = false,
    required void Function(double fraction, int received, int total) onChunk,
  }) async {
    final isExternal =
        rawUrl.startsWith('http://') || rawUrl.startsWith('https://');
    final targetUrl =
        useCleanClient && !isExternal ? await resolveMediaUrlAsync(rawUrl) : rawUrl;
    final client = (isExternal || useCleanClient) ? _createCleanDownloadDio() : _dio;
    final res = await client.get<List<int>>(
      targetUrl,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
      ),
      onReceiveProgress: (received, total) {
        final fraction = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.35;
        onChunk(fraction, received, total);
      },
    );
    final data = res.data;
    if (data == null || data.isEmpty) {
      throw StateError('Payload unduhan Cloud Storage kosong.');
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
