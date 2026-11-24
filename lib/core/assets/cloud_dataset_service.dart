import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../network/backend_endpoint_manager.dart';
import 'cloud_asset_manager.dart';

/// Layanan pemuat dataset JSON terkompresi (Database NeonDB + Object Storage Gzip CDN)
/// dengan disk-cache offline permanen sehingga 2.7+ MB JSON statis tidak membebani APK.
///
/// Urutan resolusi cepat:
/// 1. RAM cache (instan < 0.1 ms)
/// 2. Bundel/lokal dev gzip (`cloud_assets/data/<key>.json.gz` saat unit test/dev)
/// 3. Disk cache perangkat (`ApplicationSupportDirectory/cloud_datasets/<key>.json`)
/// 4. Backend Database API (`/api/v1/assets/datasets/<key>`, Brotli/Gzip)
/// 5. Multi-CDN Object Storage Gzip (`cloud_assets/data/<key>.json.gz`) -> `gzip.decode`
class CloudDatasetService {
  CloudDatasetService._();

  static final Map<String, String> _memoryCache = {};
  static final Map<String, Future<String?>> _inflight = {};
  static final http.Client _http = http.Client();

  /// Normalisasi path `assets/data/coffee.json` atau key `coffee` menjadi key bersih.
  static String normalizeKey(String keyOrAssetPath) {
    var clean = keyOrAssetPath.trim().replaceAll('\\', '/');
    if (clean.contains('/')) {
      clean = clean.split('/').last;
    }
    if (clean.endsWith('.json.gz')) {
      clean = clean.substring(0, clean.length - '.json.gz'.length);
    } else if (clean.endsWith('.json')) {
      clean = clean.substring(0, clean.length - '.json'.length);
    }
    return clean.toLowerCase();
  }

  /// Helper sinkron untuk unit test & VM desktop: membaca gzip/json lokal tanpa network.
  static String? loadDatasetSyncForTest(String keyOrAssetPath) {
    final key = normalizeKey(keyOrAssetPath);
    final cached = _memoryCache[key];
    if (cached != null && cached.isNotEmpty) return cached;
    if (kIsWeb) return null;

    final gzCandidates = [
      'cloud_assets/data/$key.json.gz',
      'assets/data/$key.json',
    ];
    for (final candidate in gzCandidates) {
      try {
        final f = File(candidate);
        if (!f.existsSync()) continue;
        final raw = candidate.endsWith('.gz')
            ? utf8.decode(gzip.decode(f.readAsBytesSync()))
            : f.readAsStringSync();
        if (raw.isNotEmpty) {
          _memoryCache[key] = raw;
          return raw;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Memuat string JSON dataset dari cache lokal, Database API, atau Gzip Object Storage CDN.
  static Future<String?> loadDatasetString(
    String keyOrAssetPath, {
    bool forceRefresh = false,
  }) async {
    final key = normalizeKey(keyOrAssetPath);
    if (!forceRefresh && _memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    if (_inflight.containsKey(key)) {
      return _inflight[key];
    }

    final future = _resolveDataset(key, forceRefresh: forceRefresh);
    _inflight[key] = future;
    try {
      return await future;
    } finally {
      _inflight.remove(key);
    }
  }

  static Future<String?> _resolveDataset(
    String key, {
    required bool forceRefresh,
  }) async {
    // 1. Jika masih ada di bundel lokal atau repo lokal (unit test / dev desktop)
    if (!forceRefresh) {
      final localSync = loadDatasetSyncForTest(key);
      if (localSync != null) return localSync;

      try {
        final bundled = await rootBundle.loadString('assets/data/$key.json');
        if (bundled.isNotEmpty) {
          _memoryCache[key] = bundled;
          return bundled;
        }
      } catch (_) {}
    }

    // 2. Cek disk cache perangkat (instant offline load)
    final cacheFile = await _getCacheFile(key);
    if (!forceRefresh && cacheFile != null && await cacheFile.exists()) {
      try {
        final cached = await cacheFile.readAsString();
        if (cached.isNotEmpty) {
          _memoryCache[key] = cached;
          // Refresh senyap di background jika umur cache > 24 jam
          unawaited(_refreshInBackgroundIfStale(key, cacheFile));
          return cached;
        }
      } catch (_) {}
    }

    // 3. Ambil dari Backend Database (NeonDB) atau Object Storage Gzip Multi-CDN
    final fetched = await _fetchFromCloud(key);
    if (fetched != null && fetched.isNotEmpty) {
      _memoryCache[key] = fetched;
      if (cacheFile != null) {
        try {
          await cacheFile.parent.create(recursive: true);
          await cacheFile.writeAsString(fetched, flush: true);
        } catch (_) {}
      }
      return fetched;
    }

    return null;
  }

  static Future<File?> _getCacheFile(String key) async {
    if (kIsWeb) return null;
    try {
      final dir = await getApplicationSupportDirectory();
      return File('${dir.path}${Platform.pathSeparator}cloud_datasets${Platform.pathSeparator}$key.json');
    } catch (_) {
      return null;
    }
  }

  static Future<void> _refreshInBackgroundIfStale(String key, File file) async {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return;
      final stat = await file.stat();
      if (DateTime.now().difference(stat.modified) < const Duration(hours: 24)) {
        return;
      }
      final fresh = await _fetchFromCloud(key);
      if (fresh != null && fresh.isNotEmpty) {
        _memoryCache[key] = fresh;
        await file.writeAsString(fresh, flush: true);
      }
    } catch (_) {}
  }

  static Future<String?> _fetchFromCloud(String key) async {
    // 3a. Coba Backend Database API (`/api/v1/assets/datasets/<key>`)
    try {
      final baseUrl = await BackendEndpointManager.instance.getActiveBaseUrl();
      final apiUri = Uri.parse('$baseUrl/api/v1/assets/datasets/$key');
      final res = await _http
          .get(apiUri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return jsonEncode(decoded['data']);
        }
        return res.body;
      }
    } catch (e) {
      debugPrint('CloudDatasetService DB API fallback ($key): $e');
    }

    // 3b. Fallback Multi-CDN Object Storage Gzip (`cloud_assets/data/<key>.json.gz`)
    final cdnUrls = CloudAssetManager.resolveCandidateUrls('data/$key.json.gz');
    for (final url in cdnUrls) {
      try {
        final res = await _http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 12));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          final bytes = res.bodyBytes;
          // Cek magic bytes Gzip (0x1f 0x8b); beberapa CDN otomatis men-decompress
          final rawJson = (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b)
              ? utf8.decode(gzip.decode(bytes))
              : utf8.decode(bytes);
          if (rawJson.isNotEmpty) {
            return rawJson;
          }
        }
      } catch (e) {
        debugPrint('CloudDatasetService CDN mirror skip ($url): $e');
      }
    }
    return null;
  }

  @visibleForTesting
  static void clearMemoryCache() {
    _memoryCache.clear();
  }
}
