import 'dart:io';

/// Kandidat sumber streaming video LMS beserta pasangan MP4 fallback untuk failover runtime.
class LmsVideoCandidate {
  final String url;
  final String badge;
  final String? fallbackMp4Url;

  const LmsVideoCandidate({
    required this.url,
    required this.badge,
    this.fallbackMp4Url,
  });
}

/// Resolver URL streaming video Akademi Barista (HLS `.m3u8` + Faststart `.mp4` + Poster HD).
///
/// Menjamin video tetap bisa diputar di perangkat mobile walaupun backend mengembalikan
/// URL Cloudinary yang belum diunggah (404) atau jaringan seluler membutuhkan timeout lebih panjang.
class LmsVideoStreamResolver {
  LmsVideoStreamResolver._();

  static const Map<String, String> knownSubchapterStems = {
    '1.1': 'coffeelabs/lms/bab1/sub_1_1_bcc',
    '1.2': 'coffeelabs/lms/bab1/sub_1_2_water',
    '1.3': 'coffeelabs/lms/bab1/sub_1_3_degassing',
    '1.4': 'coffeelabs/lms/bab1/sub_1_4_paragon',
  };

  /// Mengekstrak object key stem (`coffeelabs/lms/...` tanpa ekstensi) dari kode sub-bab
  /// atau dari URL server (`res.cloudinary.com`, `/api/v1/toolkit/object-storage/...`, dll.).
  static String? extractObjectStem({
    required String subchapterCode,
    String? serverUrl,
  }) {
    final mapped = knownSubchapterStems[subchapterCode.trim()];
    if (mapped != null) return mapped;

    final raw = (serverUrl ?? '').trim();
    if (raw.isEmpty) return null;
    final cleanPath = raw.split('?').first.split('#').first;
    final idx = cleanPath.indexOf('coffeelabs/lms/');
    if (idx < 0) return null;

    var stem = cleanPath.substring(idx);
    if (stem.endsWith('.m3u8')) {
      stem = stem.substring(0, stem.length - 5);
    } else if (stem.endsWith('.mp4')) {
      stem = stem.substring(0, stem.length - 4);
    }
    return stem.isEmpty ? null : stem;
  }

  /// Menghasilkan URL poster HD (`_poster.png`) dari Object Storage backend bila tersedia.
  static String? posterUrlFor({
    required String subchapterCode,
    required String apiBaseUrl,
    String? serverUrl,
  }) {
    final stem = extractObjectStem(
      subchapterCode: subchapterCode,
      serverUrl: serverUrl,
    );
    if (stem == null) return null;
    final base = _normalizeBase(apiBaseUrl);
    if (base.isEmpty) return null;
    return '$base/api/v1/toolkit/object-storage/${stem}_poster.png';
  }

  /// Menyusun urutan kandidat URL streaming terdeduplikasi:
  /// - Jika `serverUrl` adalah URL backend Object Storage atau Cloudinary, selalu prioritaskan
  ///   Object Storage backend (`/api/v1/toolkit/object-storage/<stem>.m3u8` lalu `.mp4`) agar
  ///   tidak terblokir 404 Cloudinary (yang hanya dikonfigurasi untuk avatar), namun tetap
  ///   menyertakan `serverUrl` sebagai cadangan sekunder.
  /// - Jika `serverUrl` adalah CDN eksternal khusus (mis. R2/CloudFront), coba `serverUrl` dulu
  ///   lalu fallback otomatis ke Object Storage backend.
  static List<LmsVideoCandidate> buildRemoteCandidates({
    required String subchapterCode,
    required String apiBaseUrl,
    String? serverUrl,
  }) {
    final base = _normalizeBase(apiBaseUrl);
    final stem = extractObjectStem(
      subchapterCode: subchapterCode,
      serverUrl: serverUrl,
    );
    final cleanServer = (serverUrl ?? '').trim();
    final isPlaceholder =
        cleanServer.isEmpty || cleanServer.contains('cdn.coffeelabs.app');
    final isCloudinary = cleanServer.contains('res.cloudinary.com');

    final resolvedServer = isPlaceholder ? '' : _resolveAgainstBase(cleanServer, base);
    final objM3u8 = (stem != null && base.isNotEmpty)
        ? '$base/api/v1/toolkit/object-storage/$stem.m3u8'
        : null;
    final objMp4 = (stem != null && base.isNotEmpty)
        ? '$base/api/v1/toolkit/object-storage/$stem.mp4'
        : null;

    final out = <LmsVideoCandidate>[];
    final seen = <String>{};

    void addCandidate(String? url, String badge, {String? fallbackMp4}) {
      if (url == null || url.isEmpty) return;
      if (!seen.add(url)) return;
      out.add(
        LmsVideoCandidate(
          url: url,
          badge: badge,
          fallbackMp4Url: fallbackMp4 == url ? null : fallbackMp4,
        ),
      );
    }

    if (resolvedServer.isNotEmpty && !isCloudinary) {
      final serverMp4 = resolvedServer.endsWith('.m3u8')
          ? resolvedServer.replaceAll('.m3u8', '.mp4')
          : null;
      addCandidate(
        resolvedServer,
        resolvedServer.endsWith('.m3u8') ? 'HLS Cloud Stream' : 'HD MP4 Cloud',
        fallbackMp4: objMp4 ?? serverMp4,
      );
      if (serverMp4 != null) {
        addCandidate(serverMp4, 'HD MP4 Cloud');
      }
    }

    // Object Storage Backend (Railway / VPS): HTTP 200 + HTTP 206 Range Seeking
    addCandidate(objM3u8, 'HLS Object Storage', fallbackMp4: objMp4);
    addCandidate(objMp4, 'HD MP4 Cloud');

    // Cadangan sekunder: URL Cloudinary bila suatu saat video juga diunggah ke Cloudinary
    if (resolvedServer.isNotEmpty && isCloudinary) {
      final cloudMp4 = resolvedServer.endsWith('.m3u8')
          ? resolvedServer.replaceAll('.m3u8', '.mp4')
          : null;
      addCandidate(
        resolvedServer,
        resolvedServer.endsWith('.m3u8') ? 'HLS Cloudinary' : 'HD MP4 Cloudinary',
        fallbackMp4: objMp4 ?? cloudMp4,
      );
      if (cloudMp4 != null) {
        addCandidate(cloudMp4, 'HD MP4 Cloudinary');
      }
    }

    return out;
  }

  /// Memverifikasi keterjangkauan URL media secara tahan jaringan seluler (timeout 5 detik,
  /// mendukung redirect, serta fallback `GET Range: bytes=0-1023` bila `HEAD` ditolak).
  static Future<bool> probeHttpReachable(
    String url, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return false;
    }
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final headReq = await client.headUrl(uri).timeout(timeout);
      headReq.followRedirects = true;
      final headRes = await headReq.close().timeout(timeout);
      await headRes.drain<void>();
      if (headRes.statusCode >= 200 && headRes.statusCode < 300) {
        return true;
      }
      if (headRes.statusCode == 405 || headRes.statusCode == 403) {
        final getReq = await client.getUrl(uri).timeout(timeout);
        getReq.followRedirects = true;
        getReq.headers.set(HttpHeaders.rangeHeader, 'bytes=0-1023');
        final getRes = await getReq.close().timeout(timeout);
        await getRes.drain<void>();
        return getRes.statusCode >= 200 && getRes.statusCode < 300;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  static String _normalizeBase(String raw) {
    var s = raw.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static String _resolveAgainstBase(String rawUrl, String cleanBase) {
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    if (cleanBase.isEmpty) return rawUrl;
    return rawUrl.startsWith('/') ? '$cleanBase$rawUrl' : '$cleanBase/$rawUrl';
  }
}
