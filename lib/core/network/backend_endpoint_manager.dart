import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Manifest endpoint dinamis yang di-host di multi-CDN gratis (Vercel, jsDelivr, GitHub Raw)
/// secara independen dari Railway agar migrasi ke VPS pribadi berjalan otomatis tanpa download APK baru.
class RuntimeEndpointManifest {
  final int schemaVersion;
  final int manifestRevision;
  final String primaryApiUrl;
  final List<String> fallbackApiUrls;
  final String? assetCdnBaseUrl;
  final List<String> assetCdnFallbackUrls;
  final String healthPath;
  final String? updatedAt;
  final bool forceSwitch;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final String? sourceMirror;

  const RuntimeEndpointManifest({
    this.schemaVersion = 1,
    required this.manifestRevision,
    required this.primaryApiUrl,
    this.fallbackApiUrls = const [],
    this.assetCdnBaseUrl,
    this.assetCdnFallbackUrls = const [],
    this.healthPath = '/api/health',
    this.updatedAt,
    this.forceSwitch = false,
    this.maintenanceMode = false,
    this.maintenanceMessage,
    this.sourceMirror,
  });

  factory RuntimeEndpointManifest.fromJson(
    Map<String, dynamic> json, {
    String? sourceMirror,
  }) {
    final primary = BackendEndpointManager.normalizeAndValidateUrl(
      json['primary_api_url']?.toString(),
    );
    if (primary == null) {
      throw const FormatException('primary_api_url tidak valid atau bukan HTTPS');
    }

    final rawFallbacks = json['fallback_api_urls'];
    final fallbacks = <String>[];
    if (rawFallbacks is List) {
      for (final item in rawFallbacks) {
        final validated = BackendEndpointManager.normalizeAndValidateUrl(
          item?.toString(),
        );
        if (validated != null && validated != primary && !fallbacks.contains(validated)) {
          fallbacks.add(validated);
        }
      }
    }

    final assetCdnPrimary = BackendEndpointManager.normalizeAndValidateUrl(
      json['asset_cdn_base_url']?.toString(),
    );
    final rawAssetFallbacks = json['asset_cdn_fallback_urls'];
    final assetFallbacks = <String>[];
    if (rawAssetFallbacks is List) {
      for (final item in rawAssetFallbacks) {
        final validated = BackendEndpointManager.normalizeAndValidateUrl(
          item?.toString(),
        );
        if (validated != null &&
            validated != assetCdnPrimary &&
            !assetFallbacks.contains(validated)) {
          assetFallbacks.add(validated);
        }
      }
    }

    final rawHealthPath = json['health_path']?.toString().trim();
    final healthPath = (rawHealthPath != null && rawHealthPath.startsWith('/'))
        ? rawHealthPath
        : '/api/health';

    return RuntimeEndpointManifest(
      schemaVersion: int.tryParse('${json['schema_version'] ?? 1}') ?? 1,
      manifestRevision: int.tryParse('${json['manifest_revision'] ?? 1}') ?? 1,
      primaryApiUrl: primary,
      fallbackApiUrls: fallbacks,
      assetCdnBaseUrl: assetCdnPrimary,
      assetCdnFallbackUrls: assetFallbacks,
      healthPath: healthPath,
      updatedAt: json['updated_at']?.toString(),
      forceSwitch: json['force_switch'] == true,
      maintenanceMode: json['maintenance_mode'] == true,
      maintenanceMessage: json['maintenance_message']?.toString(),
      sourceMirror: sourceMirror ?? json['source_mirror']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'manifest_revision': manifestRevision,
        'primary_api_url': primaryApiUrl,
        'fallback_api_urls': fallbackApiUrls,
        'asset_cdn_base_url': assetCdnBaseUrl,
        'asset_cdn_fallback_urls': assetCdnFallbackUrls,
        'health_path': healthPath,
        'updated_at': updatedAt,
        'force_switch': forceSwitch,
        'maintenance_mode': maintenanceMode,
        'maintenance_message': maintenanceMessage,
        'source_mirror': sourceMirror,
      };

  List<String> get orderedCandidates {
    final seen = <String>{};
    final result = <String>[];
    for (final url in [primaryApiUrl, ...fallbackApiUrls]) {
      if (seen.add(url)) result.add(url);
    }
    return result;
  }
}

class EndpointSyncReport {
  final bool switched;
  final String activeBaseUrl;
  final int manifestRevision;
  final String source;
  final String message;

  const EndpointSyncReport({
    required this.switched,
    required this.activeBaseUrl,
    required this.manifestRevision,
    required this.source,
    required this.message,
  });
}

typedef EndpointHttpGet = Future<http.Response> Function(
  Uri uri, {
  Map<String, String>? headers,
});

/// Zero-Downtime Dynamic Backend Endpoint Discovery & Automatic Failover Manager.
///
/// Arsitektur 3 lapis agar perpindahan Railway -> VPS Pribadi / Custom Domain
/// berlangsung otomatis tanpa user perlu download APK baru:
/// 1. Multi-CDN Static Edge Manifest (Vercel Edge -> jsDelivr CDN -> GitHub Raw)
/// 2. Zero-Trust `/api/health` verification (anti captive-portal / anti hijack)
/// 3. Automatic single-flight failover saat transport error / 502 / 503 / 504
class BackendEndpointManager {
  BackendEndpointManager._internal()
      : _httpGetOverride = null,
        _manifestMirrorsOverride = null;

  static final BackendEndpointManager instance = BackendEndpointManager._internal();

  /// Constructor khusus unit test untuk injeksi HTTP client & custom mirrors.
  @visibleForTesting
  BackendEndpointManager.forTest({
    EndpointHttpGet? httpGet,
    List<String>? manifestMirrors,
  })  : _httpGetOverride = httpGet,
        _manifestMirrorsOverride = manifestMirrors;

  static const String defaultProductionUrl =
      'https://coffe-labs-backend-production.up.railway.app';

  static const String _manualOverrideKey = 'coffeehub_backend_server_url';
  static const String _discoveredUrlKey = 'coffeehub_discovered_api_url_v1';
  static const String _cachedManifestKey = 'coffeehub_endpoint_manifest_cache_v1';
  static const String _lastSyncAtKey = 'coffeehub_endpoint_last_sync_ms_v1';

  static const Duration _syncTtl = Duration(minutes: 10);
  static const Duration _failoverCooldown = Duration(seconds: 20);
  static const Duration _probeTimeout = Duration(seconds: 4);

  /// 3 mirror gratis independen dari Railway. Jika Railway mati total, aplikasi
  /// tetap bisa menemukan alamat VPS pribadi baru melalui salah satu CDN ini.
  static const List<String> defaultManifestMirrors = [
    'https://brewingcoffee.vercel.app/runtime-endpoints.json',
    'https://cdn.jsdelivr.net/gh/rusdifn08/coffe-labs-mobile@main/config/runtime-endpoints.json',
    'https://raw.githubusercontent.com/rusdifn08/coffe-labs-mobile/main/config/runtime-endpoints.json',
  ];

  final EndpointHttpGet? _httpGetOverride;
  final List<String>? _manifestMirrorsOverride;

  final ValueNotifier<String> activeBaseUrlNotifier =
      ValueNotifier<String>(defaultProductionUrl);

  String _activeBaseUrl = defaultProductionUrl;
  String? _manualOverrideUrl;
  RuntimeEndpointManifest? _cachedManifest;
  bool _hydrated = false;
  Future<EndpointSyncReport>? _inflightSync;
  Future<String?>? _inflightFailover;
  DateTime? _lastFailoverAt;

  List<String> get manifestMirrors =>
      _manifestMirrorsOverride ?? defaultManifestMirrors;

  String get activeBaseUrlSync => _activeBaseUrl;
  String? get manualOverrideUrl => _manualOverrideUrl;
  RuntimeEndpointManifest? get cachedManifest => _cachedManifest;
  int get currentManifestRevision => _cachedManifest?.manifestRevision ?? 0;
  String get currentSourceLabel {
    if (_manualOverrideUrl != null && _manualOverrideUrl!.isNotEmpty) {
      return 'Manual Override (Admin)';
    }
    return _cachedManifest?.sourceMirror ?? 'Default Embedded';
  }

  /// Menormalisasi & memvalidasi URL backend agar selalu aman (HTTPS, bebas
  /// localhost/emulator/Render lama yang sudah pensiun).
  static String? normalizeAndValidateUrl(
    String? rawUrl, {
    bool allowInsecureLocal = false,
  }) {
    final trimmed = rawUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    if (host.contains('onrender.com')) return null;

    final isLocalHost = host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host == '0.0.0.0';
    if (isLocalHost && !allowInsecureLocal) return null;

    if (scheme != 'https' && !(allowInsecureLocal && scheme == 'http')) {
      return null;
    }

    final clean = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    return clean;
  }

  /// Backward-compatible normalizer yang selalu mengembalikan URL valid.
  static String normalizeBaseUrl(String? savedUrl) {
    return normalizeAndValidateUrl(savedUrl) ?? defaultProductionUrl;
  }

  /// Konversi URL HTTP/HTTPS aktif menjadi URI WebSocket (`wss://` / `ws://`) secara dinamis.
  Uri buildWebSocketUri(String path, {String? overrideBaseUrl}) {
    final base = normalizeBaseUrl(overrideBaseUrl ?? _activeBaseUrl);
    final parsed = Uri.parse(base);
    final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return parsed.replace(
      scheme: wsScheme,
      path: normalizedPath,
      query: null,
    );
  }

  Future<void> _ensureHydrated() async {
    if (_hydrated) return;
    _hydrated = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Muat manifest cache jika ada
      final rawManifest = prefs.getString(_cachedManifestKey);
      if (rawManifest != null && rawManifest.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawManifest);
          if (decoded is Map<String, dynamic>) {
            _cachedManifest = RuntimeEndpointManifest.fromJson(decoded);
          }
        } catch (_) {}
      }

      // 2. Cek apakah ada override manual dari pengguna/admin
      final rawManual = prefs.getString(_manualOverrideKey)?.trim();
      if (rawManual != null && rawManual.isNotEmpty) {
        final validatedManual = normalizeAndValidateUrl(rawManual);
        if (validatedManual == null) {
          // Bersihkan URL Render/localhost lama
          await prefs.remove(_manualOverrideKey);
        } else if (validatedManual != defaultProductionUrl) {
          // Hormati URL VPS/custom manual yang disetel admin
          _manualOverrideUrl = validatedManual;
          _setActiveInMemory(validatedManual);
          return;
        } else {
          // Jika tersimpan URL Railway default lama sebagai "manual", lepaskan agar
          // perangkat bisa mengikuti auto-migrasi VPS dari manifest CDN!
          await prefs.remove(_manualOverrideKey);
        }
      }

      // 3. Muat URL hasil discovery otomatis terakhir
      final discovered = normalizeAndValidateUrl(
        prefs.getString(_discoveredUrlKey),
      );
      if (discovered != null) {
        _setActiveInMemory(discovered);
        return;
      }

      if (_cachedManifest != null) {
        _setActiveInMemory(_cachedManifest!.primaryApiUrl);
        return;
      }
    } catch (_) {}
    _setActiveInMemory(defaultProductionUrl);
  }

  void _setActiveInMemory(String url) {
    _activeBaseUrl = url;
    if (activeBaseUrlNotifier.value != url) {
      activeBaseUrlNotifier.value = url;
    }
  }

  /// Mengembalikan Base URL aktif secepat mungkin (<1ms setelah hidrasi pertama).
  Future<String> getActiveBaseUrl() async {
    await _ensureHydrated();
    return _activeBaseUrl;
  }

  /// Dipanggil saat startup aplikasi (non-blocking) untuk sinkronisasi manifest di background.
  Future<void> initializeInBackground() async {
    await _ensureHydrated();
    await syncManifestFromMirrors(force: false);
  }

  /// Menyetel override manual (misal admin menguji VPS baru sebelum flip global).
  /// Kirim string kosong untuk kembali ke mode Auto-Discovery Multi-CDN.
  Future<void> setManualOverrideUrl(String url) async {
    await _ensureHydrated();
    final prefs = await SharedPreferences.getInstance();
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      _manualOverrideUrl = null;
      await prefs.remove(_manualOverrideKey);
      final fallback = normalizeAndValidateUrl(prefs.getString(_discoveredUrlKey)) ??
          _cachedManifest?.primaryApiUrl ??
          defaultProductionUrl;
      _setActiveInMemory(fallback);
      return;
    }

    final validated = normalizeAndValidateUrl(trimmed, allowInsecureLocal: kDebugMode);
    if (validated == null) {
      throw ArgumentError('URL server harus berformat https://domain-anda.com yang valid.');
    }

    _manualOverrideUrl = validated;
    await prefs.setString(_manualOverrideKey, validated);
    _setActiveInMemory(validated);
  }

  /// Sinkronisasi manifest endpoint dari 3 CDN gratis (Vercel -> jsDelivr -> GitHub Raw).
  /// Hanya berpindah ke endpoint baru jika `/api/health` terverifikasi milik Coffee Labs!
  Future<EndpointSyncReport> syncManifestFromMirrors({bool force = false}) {
    final existing = _inflightSync;
    if (existing != null) return existing;

    final task = _doSyncManifestFromMirrors(force: force);
    _inflightSync = task;
    task.whenComplete(() {
      if (identical(_inflightSync, task)) {
        _inflightSync = null;
      }
    });
    return task;
  }

  Future<EndpointSyncReport> _doSyncManifestFromMirrors({
    required bool force,
  }) async {
    await _ensureHydrated();
    final prefs = await SharedPreferences.getInstance();

    if (!force) {
      final lastMs = prefs.getInt(_lastSyncAtKey) ?? 0;
      if (lastMs > 0) {
        final age = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(lastMs),
        );
        if (age < _syncTtl) {
          return EndpointSyncReport(
            switched: false,
            activeBaseUrl: _activeBaseUrl,
            manifestRevision: currentManifestRevision,
            source: currentSourceLabel,
            message: 'Endpoint cache masih segar.',
          );
        }
      }
    }

    final fetched = await _fetchFreshestManifest();
    await prefs.setInt(_lastSyncAtKey, DateTime.now().millisecondsSinceEpoch);

    if (fetched == null) {
      return EndpointSyncReport(
        switched: false,
        activeBaseUrl: _activeBaseUrl,
        manifestRevision: currentManifestRevision,
        source: currentSourceLabel,
        message: 'Semua mirror CDN sedang tidak terjangkau; tetap memakai endpoint aktif.',
      );
    }

    // Lindungi terhadap rollback cache CDN yang lebih tua (monotonic revision)
    final prevRevision = _cachedManifest?.manifestRevision ?? 0;
    if (!force && fetched.manifestRevision < prevRevision) {
      return EndpointSyncReport(
        switched: false,
        activeBaseUrl: _activeBaseUrl,
        manifestRevision: prevRevision,
        source: currentSourceLabel,
        message: 'Mirror mengembalikan revisi lama (v${fetched.manifestRevision} < v$prevRevision); diabaikan.',
      );
    }

    _cachedManifest = fetched;
    await prefs.setString(_cachedManifestKey, jsonEncode(fetched.toJson()));

    // Hormati override manual admin kecuali force_switch dipicu & user menghapus override
    if (_manualOverrideUrl != null && _manualOverrideUrl!.isNotEmpty) {
      return EndpointSyncReport(
        switched: false,
        activeBaseUrl: _activeBaseUrl,
        manifestRevision: fetched.manifestRevision,
        source: currentSourceLabel,
        message: 'Manifest v${fetched.manifestRevision} tersimpan, tetapi override manual aktif.',
      );
    }

    final shouldEvaluateSwitch = fetched.primaryApiUrl != _activeBaseUrl ||
        fetched.forceSwitch ||
        force;

    if (!shouldEvaluateSwitch) {
      return EndpointSyncReport(
        switched: false,
        activeBaseUrl: _activeBaseUrl,
        manifestRevision: fetched.manifestRevision,
        source: fetched.sourceMirror ?? 'CDN Manifest',
        message: 'Endpoint aktif sudah sinkron dengan manifest v${fetched.manifestRevision}.',
      );
    }

    // Pilih kandidat sehat pertama dari manifest (primary terlebih dahulu, lalu fallback)
    for (final candidate in fetched.orderedCandidates) {
      final healthy = await verifyCoffeeLabsHealth(
        candidate,
        healthPath: fetched.healthPath,
      );
      if (healthy) {
        final didSwitch = candidate != _activeBaseUrl;
        _setActiveInMemory(candidate);
        await prefs.setString(_discoveredUrlKey, candidate);
        if (didSwitch) {
          debugPrint(
            '🌐 Dynamic Endpoint Migrated -> $candidate (manifest v${fetched.manifestRevision} via ${fetched.sourceMirror})',
          );
        }
        return EndpointSyncReport(
          switched: didSwitch,
          activeBaseUrl: candidate,
          manifestRevision: fetched.manifestRevision,
          source: fetched.sourceMirror ?? 'CDN Manifest',
          message: didSwitch
              ? 'Berhasil berpindah ke server baru: $candidate'
              : 'Endpoint sehat terverifikasi: $candidate',
        );
      }
    }

    return EndpointSyncReport(
      switched: false,
      activeBaseUrl: _activeBaseUrl,
      manifestRevision: fetched.manifestRevision,
      source: fetched.sourceMirror ?? 'CDN Manifest',
      message: 'Kandidat manifest v${fetched.manifestRevision} belum lulus health-check; mempertahankan endpoint saat ini.',
    );
  }

  /// Dipicu otomatis oleh Dio interceptor ketika server saat ini mengalami
  /// timeout / DNS error / connection refused / HTTP 502-504.
  /// Mengembalikan URL baru yang sehat jika berhasil failover, atau `null` bila belum ada.
  Future<String?> failoverOnTransportError({required String failedUrl}) {
    final existing = _inflightFailover;
    if (existing != null) return existing;

    final now = DateTime.now();
    if (_lastFailoverAt != null && now.difference(_lastFailoverAt!) < _failoverCooldown) {
      return Future.value(null);
    }

    final task = _doFailover(failedUrl: normalizeBaseUrl(failedUrl));
    _inflightFailover = task;
    task.whenComplete(() {
      if (identical(_inflightFailover, task)) {
        _inflightFailover = null;
      }
    });
    return task;
  }

  Future<String?> _doFailover({required String failedUrl}) async {
    await _ensureHydrated();
    _lastFailoverAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    final freshManifest = await _fetchFreshestManifest();
    if (freshManifest != null) {
      final prevRevision = _cachedManifest?.manifestRevision ?? 0;
      if (freshManifest.manifestRevision >= prevRevision) {
        _cachedManifest = freshManifest;
        await prefs.setString(_cachedManifestKey, jsonEncode(freshManifest.toJson()));
        await prefs.setInt(_lastSyncAtKey, DateTime.now().millisecondsSinceEpoch);
      }
    }

    final healthPath = _cachedManifest?.healthPath ?? '/api/health';
    final candidates = <String>[
      ...?_cachedManifest?.orderedCandidates,
      defaultProductionUrl,
    ];

    final seen = <String>{failedUrl};
    for (final candidate in candidates) {
      final normalized = normalizeAndValidateUrl(candidate);
      if (normalized == null || !seen.add(normalized)) continue;

      final healthy = await verifyCoffeeLabsHealth(
        normalized,
        healthPath: healthPath,
      );
      if (healthy) {
        _manualOverrideUrl = null;
        await prefs.remove(_manualOverrideKey);
        await prefs.setString(_discoveredUrlKey, normalized);
        _setActiveInMemory(normalized);
        debugPrint('🛡️ Auto-Failover sukses: $failedUrl -> $normalized');
        return normalized;
      }
    }
    return null;
  }

  /// Menerima petunjuk migrasi langsung dari server aktif (misal header `X-CoffeeLabs-Api-Base`),
  /// lalu memverifikasi `/api/health` sebelum berpindah.
  Future<bool> applyServerMigrationHint(String? suggestedBaseUrl) async {
    final candidate = normalizeAndValidateUrl(suggestedBaseUrl);
    if (candidate == null || candidate == _activeBaseUrl) return false;
    if (_manualOverrideUrl != null && _manualOverrideUrl!.isNotEmpty) return false;

    final healthy = await verifyCoffeeLabsHealth(candidate);
    if (!healthy) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_discoveredUrlKey, candidate);
    _setActiveInMemory(candidate);
    debugPrint('🚀 Server Migration Hint applied -> $candidate');
    return true;
  }

  Future<RuntimeEndpointManifest?> _fetchFreshestManifest() async {
    RuntimeEndpointManifest? best;

    for (final mirrorUrl in manifestMirrors) {
      try {
        final uri = Uri.parse(mirrorUrl);
        final response = await _performGet(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
          },
        ).timeout(_probeTimeout);

        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) continue;

        final mirrorName = _labelForMirror(uri.host);
        final parsed = RuntimeEndpointManifest.fromJson(
          decoded,
          sourceMirror: mirrorName,
        );

        if (best == null || parsed.manifestRevision > best.manifestRevision) {
          best = parsed;
        }
        // Jika mirror utama (Vercel Edge) berhasil dan responsif, langsung pakai
        // kecuali kita sedang failover; untuk kecepatan & efisiensi cukup lanjut
        // hanya bila mirror gagal atau revisi lebih kecil.
        if (best.manifestRevision >= (_cachedManifest?.manifestRevision ?? 0)) {
          break;
        }
      } catch (_) {
        // Coba mirror berikutnya secara diam-diam
      }
    }

    return best;
  }

  /// Zero-Trust Health Probe: memastikan endpoint baru mengembalikan HTTP 200
  /// DAN JSON resmi Coffee Labs (`status == "ok"` dan `app` memuat "Coffee Labs").
  /// Kebal terhadap captive portal Wi-Fi kafe/hotel yang membalas HTML 200 OK.
  Future<bool> verifyCoffeeLabsHealth(
    String baseUrl, {
    String healthPath = '/api/health',
  }) async {
    final clean = normalizeAndValidateUrl(
      baseUrl,
      allowInsecureLocal: kDebugMode,
    );
    if (clean == null) return false;

    try {
      final path = healthPath.startsWith('/') ? healthPath : '/$healthPath';
      final response = await _performGet(
        Uri.parse('$clean$path'),
        headers: const {'Accept': 'application/json'},
      ).timeout(_probeTimeout);

      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return false;

      final status = decoded['status']?.toString().toLowerCase() ?? '';
      final appName = decoded['app']?.toString().toLowerCase() ?? '';
      return status == 'ok' && appName.contains('coffee labs');
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _performGet(
    Uri uri, {
    Map<String, String>? headers,
  }) {
    final override = _httpGetOverride;
    if (override != null) {
      return override(uri, headers: headers);
    }
    return http.get(uri, headers: headers);
  }

  static String _labelForMirror(String host) {
    final lower = host.toLowerCase();
    if (lower.contains('vercel.app') || lower.contains('coffeelabs')) {
      return 'Vercel Edge CDN';
    }
    if (lower.contains('jsdelivr.net')) return 'jsDelivr Global CDN';
    if (lower.contains('githubusercontent.com')) return 'GitHub Raw Mirror';
    return host;
  }
}
