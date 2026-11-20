import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/rust_api_client.dart';
import '../models/beans_radar_models.dart';

class DetectedNetworkLocation {
  final double latitude;
  final double longitude;
  final String cityLabel;
  final String region;

  const DetectedNetworkLocation({
    required this.latitude,
    required this.longitude,
    required this.cityLabel,
    required this.region,
  });
}

/// Mesin Routing Jalan In-App (Polyline + Jarak + ETA + Turn-by-Turn) & Deteksi Lokasi IP Nyata.
/// 1. Utamakan Backend Rust Axum (`GET /api/v1/radar/route` — Redis Grid Cache 6 Jam + Geoapify/OSRM).
/// 2. Cadangan langsung OSRM Public Road Engine (`router.project-osrm.org`, 0 API key) agar
///    garis rute jalan langsung tergambar di dalam peta aplikasi tanpa membuka browser web!
class RadarRoutingService {
  final RustApiClient? _api;
  final Dio _publicDio;

  RadarRoutingService({RustApiClient? api, Dio? publicDio})
      : _api = api,
        _publicDio = publicDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
                headers: const {'User-Agent': 'CoffeeLabsRadar/3.0'},
              ),
            );

  /// Deteksi lokasi jaringan (IP/Wi-Fi) NYATA saat GPS perangkat mati (terutama di Windows Desktop).
  /// Tidak pernah memalsukan Jakarta jika pengguna berada di Bandung, Surabaya, Medan, Bali, dll.
  Future<DetectedNetworkLocation?> detectRealNetworkLocation() async {
    // Provider 1: ipwho.is (Gratis, HTTPS, tanpa API key, akurat untuk ISP Indonesia)
    try {
      final resp = await _publicDio
          .get<dynamic>('https://ipwho.is/')
          .timeout(const Duration(seconds: 4));
      final data = resp.data;
      if (data is Map && data['success'] == true) {
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null && _isValidCoord(lat, lng)) {
          final city = (data['city'] ?? '').toString().trim();
          final region = (data['region'] ?? '').toString().trim();
          final label = [city, region].where((s) => s.isNotEmpty).join(', ');
          return DetectedNetworkLocation(
            latitude: lat,
            longitude: lng,
            cityLabel: label.isNotEmpty ? label : 'Lokasi Jaringan Anda',
            region: region,
          );
        }
      }
    } catch (_) {}

    // Provider 2: get.geojs.io (Cadangan bebas kuota)
    try {
      final resp = await _publicDio
          .get<dynamic>('https://get.geojs.io/v1/ip/geo.json')
          .timeout(const Duration(seconds: 4));
      final data = resp.data;
      if (data is Map) {
        final lat = double.tryParse((data['latitude'] ?? '').toString());
        final lng = double.tryParse((data['longitude'] ?? '').toString());
        if (lat != null && lng != null && _isValidCoord(lat, lng)) {
          final city = (data['city'] ?? '').toString().trim();
          final region = (data['region'] ?? '').toString().trim();
          final label = [city, region].where((s) => s.isNotEmpty).join(', ');
          return DetectedNetworkLocation(
            latitude: lat,
            longitude: lng,
            cityLabel: label.isNotEmpty ? label : 'Lokasi Jaringan Anda',
            region: region,
          );
        }
      }
    } catch (_) {}

    return null;
  }

  /// Hitung garis rute jalan (polyline) dari lokasi user ke tujuan kafe/roastery langsung di dalam aplikasi.
  Future<RadarRouteResult> fetchInAppRoadRoute({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    required RadarTravelMode mode,
  }) async {
    final origin = LatLng(originLat, originLng);

    // 1. Coba Backend Rust Axum (Redis 6h Cache + Geoapify/OSRM)
    if (_api != null) {
      try {
        final raw = await _api.get(
          '/api/v1/radar/route',
          queryParameters: {
            'origin_lat': originLat,
            'origin_lng': originLng,
            'dest_lat': destination.latitude,
            'dest_lng': destination.longitude,
            'mode': mode.apiValue,
          },
        );
        if (raw is Map<String, dynamic> && raw['data'] is Map) {
          final d = (raw['data'] as Map).cast<String, dynamic>();
          final pts = _parseLatLngPairs(d['coordinates']);
          if (pts.length >= 2) {
            final steps = (d['steps'] as List? ?? const [])
                .whereType<Map>()
                .map((s) => RadarRouteStep.fromJson(s.cast<String, dynamic>()))
                .toList();
            return RadarRouteResult(
              destination: destination,
              mode: mode,
              provider: (d['provider'] ?? 'backend').toString(),
              cacheHit: d['cache_hit'] == true,
              distanceMeters: ((d['distance_meters'] as num?) ?? 0).toDouble(),
              durationSeconds: ((d['duration_seconds'] as num?) ?? 0).toDouble(),
              origin: origin,
              points: pts,
              steps: steps,
            );
          }
        }
      } catch (_) {}
    }

    // 2. Fallback langsung OSRM Public Road Routing Engine (real road geometry, 0 API key)
    try {
      final profile = mode.osrmProfile;
      final url =
          'https://router.project-osrm.org/route/v1/$profile/'
          '${originLng.toStringAsFixed(6)},${originLat.toStringAsFixed(6)};'
          '${destination.longitude.toStringAsFixed(6)},${destination.latitude.toStringAsFixed(6)}'
          '?overview=full&geometries=geojson&steps=true';
      final resp = await _publicDio
          .get<dynamic>(url)
          .timeout(const Duration(seconds: 8));
      final data = resp.data;
      if (data is Map && data['routes'] is List && (data['routes'] as List).isNotEmpty) {
        final route0 = (data['routes'] as List).first as Map;
        final distM = ((route0['distance'] as num?) ?? 0).toDouble();
        final rawDur = ((route0['duration'] as num?) ?? 0).toDouble();
        final durS = mode == RadarTravelMode.motorcycle
            ? (rawDur * 0.82).clamp(60.0, 86400.0)
            : rawDur;
        final geom = route0['geometry'] as Map?;
        final rawCoords = geom?['coordinates'] as List? ?? const [];
        final pts = <LatLng>[];
        for (final c in rawCoords) {
          if (c is List && c.length >= 2) {
            final lng = (c[0] as num).toDouble();
            final lat = (c[1] as num).toDouble();
            pts.add(LatLng(lat, lng));
          }
        }
        final steps = <RadarRouteStep>[];
        final legs = route0['legs'] as List? ?? const [];
        for (final leg in legs.whereType<Map>()) {
          for (final st in (leg['steps'] as List? ?? const []).whereType<Map>().take(20)) {
            final street = (st['name'] ?? '').toString().trim();
            final m = st['maneuver'] as Map?;
            final mType = (m?['type'] ?? 'continue').toString();
            final mod = (m?['modifier'] ?? '').toString();
            final instr = _formatIndonesianStep(mType, mod, street);
            steps.add(
              RadarRouteStep(
                instruction: instr,
                distanceMeters: ((st['distance'] as num?) ?? 0).toDouble(),
                durationSeconds: ((st['duration'] as num?) ?? 0).toDouble(),
              ),
            );
          }
        }
        if (pts.length >= 2) {
          return RadarRouteResult(
            destination: destination,
            mode: mode,
            provider: 'osrm_direct',
            cacheHit: false,
            distanceMeters: distM,
            durationSeconds: durS,
            origin: origin,
            points: pts,
            steps: steps,
          );
        }
      }
    } catch (_) {}

    // 3. Offline fallback: garis estimasi langsung jika internet mati total
    final straightM = RadarPlaceCard.haversineMeters(
      originLat,
      originLng,
      destination.latitude,
      destination.longitude,
    );
    final roadM = straightM * 1.32;
    final speedMps = mode == RadarTravelMode.walk
        ? 1.35
        : (mode == RadarTravelMode.drive ? 7.5 : 8.8);
    return RadarRouteResult(
      destination: destination,
      mode: mode,
      provider: 'offline_estimate',
      cacheHit: false,
      distanceMeters: roadM,
      durationSeconds: (roadM / speedMps).clamp(60.0, 86400.0),
      origin: origin,
      points: [origin, LatLng(destination.latitude, destination.longitude)],
      steps: [
        RadarRouteStep(
          instruction: 'Menuju ${destination.name} (${destination.cityKabupaten})',
          distanceMeters: roadM,
          durationSeconds: roadM / speedMps,
        ),
      ],
    );
  }

  static List<LatLng> _parseLatLngPairs(dynamic raw) {
    if (raw is! List) return const [];
    final out = <LatLng>[];
    for (final p in raw) {
      if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
        out.add(LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()));
      }
    }
    return out;
  }

  static String _formatIndonesianStep(String type, String mod, String street) {
    final road = street.isNotEmpty ? ' ke $street' : '';
    switch (type) {
      case 'depart':
        return street.isNotEmpty ? 'Mulai perjalanan dari $street' : 'Mulai perjalanan';
      case 'arrive':
        return 'Tiba di lokasi tujuan';
      case 'roundabout':
      case 'rotary':
        return 'Masuk bundaran$road';
      case 'turn':
      case 'new name':
      case 'fork':
      case 'end of road':
        if (mod.contains('left')) return 'Belok kiri$road';
        if (mod.contains('right')) return 'Belok kanan$road';
        if (mod.contains('uturn')) return 'Putar balik$road';
        return 'Lurus ikuti jalur$road';
      default:
        return street.isNotEmpty ? 'Ikuti $street' : 'Lanjutkan perjalanan';
    }
  }

  static bool _isValidCoord(double lat, double lng) {
    return lat.isFinite &&
        lng.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180 &&
        !(lat.abs() < 0.01 && lng.abs() < 0.01);
  }
}

final radarRoutingServiceProvider = Provider<RadarRoutingService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return RadarRoutingService(api: RustApiClient(dio: dio));
});
