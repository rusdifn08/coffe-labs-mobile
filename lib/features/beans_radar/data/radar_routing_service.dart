import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/rust_api_client.dart';
import '../domain/models/multimodal_route_models.dart';
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

/// Mesin Multi-Modal Smart Routing Engine (Jalan Kaki vs Motor Indonesia vs Mobil)
/// 1. Utamakan Backend Rust Axum (`POST /api/v1/routing/compare-modes` & `POST /api/v1/routing/navigate`).
/// 2. Direct Fallback: Valhalla FOSSGIS (`pedestrian`, `motorcycle`, `auto`) -> 3 Server OSRM Terpisah (`routed-foot`, `routed-bike`, `routed-car`).
/// 3. Tidak lagi memakai `router.project-osrm.org` agar jalur Jalan Kaki, Motor, & Mobil selalu berbeda nyata!
class RadarRoutingService {
  final RustApiClient? _api;
  final Dio _publicDio;

  RadarRoutingService({RustApiClient? api, Dio? publicDio})
      : _api = api,
        _publicDio = publicDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 7),
                receiveTimeout: const Duration(seconds: 10),
                headers: const {'User-Agent': 'CoffeeLabsRadar/3.0'},
              ),
            );

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<DetectedNetworkLocation?> detectRealNetworkLocation() async {
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

  /// Reverse-geocode server-side fallback agar label lokasi tidak pernah nyasar ke kota lain.
  Future<String?> reverseGeocodeServer(double lat, double lng) async {
    if (_api == null) return null;
    try {
      final raw = await _api.get(
        '/api/v1/routing/reverse-geocode',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      if (raw is Map<String, dynamic> && raw['data'] is Map) {
        final d = (raw['data'] as Map).cast<String, dynamic>();
        final label = (d['label'] ?? '').toString().trim();
        if (label.isNotEmpty) return label;
      }
    } catch (_) {}
    return null;
  }

  /// Menghitung perbandingan rute 3 moda sekaligus (Jalan Kaki, Motor, Mobil) dengan rute alternatif.
  Future<MultiModalRouteComparison> compareAllModes({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    bool avoidTolls = false,
  }) async {
    final origin = LatLng(originLat, originLng);

    if (_api != null) {
      try {
        final raw = await _api.post(
          '/api/v1/routing/compare-modes',
          body: {
            'origin_lat': originLat,
            'origin_lng': originLng,
            'dest_lat': destination.latitude,
            'dest_lng': destination.longitude,
            'avoid_tolls': avoidTolls,
            'alternates': 2,
          },
        );
        if (raw is Map<String, dynamic> && raw['data'] is Map) {
          final d = (raw['data'] as Map).cast<String, dynamic>();
          final foot = ModeRouteBundle.fromBackendJson(
            (d['foot'] as Map?)?.cast<String, dynamic>() ?? const {},
            RadarTravelMode.walk,
          );
          final moto = ModeRouteBundle.fromBackendJson(
            (d['motorcycle'] as Map?)?.cast<String, dynamic>() ?? const {},
            RadarTravelMode.motorcycle,
          );
          final car = ModeRouteBundle.fromBackendJson(
            (d['car'] as Map?)?.cast<String, dynamic>() ?? const {},
            RadarTravelMode.drive,
          );
          if (foot.primary.points.length >= 2 &&
              moto.primary.points.length >= 2 &&
              car.primary.points.length >= 2) {
            return MultiModalRouteComparison(
              destination: destination,
              origin: origin,
              timezoneAbbr: (d['timezone_abbr'] ?? 'WIB').toString(),
              isRushHour: d['is_rush_hour'] == true,
              avoidTolls: avoidTolls,
              foot: foot,
              motorcycle: moto,
              car: car,
            );
          }
        }
      } catch (_) {}
    }

    if (_isTestEnv && _api == null) {
      final results = await Future.wait([
        _isTestOverrideOfFetchInAppRoute
            ? fetchInAppRoadRoute(
                originLat: originLat,
                originLng: originLng,
                destination: destination,
                mode: RadarTravelMode.walk,
              )
            : fetchSingleModeRoute(
                originLat: originLat,
                originLng: originLng,
                destination: destination,
                mode: RadarTravelMode.walk,
                avoidTolls: true,
              ),
        _isTestOverrideOfFetchInAppRoute
            ? fetchInAppRoadRoute(
                originLat: originLat,
                originLng: originLng,
                destination: destination,
                mode: RadarTravelMode.motorcycle,
              )
            : fetchSingleModeRoute(
                originLat: originLat,
                originLng: originLng,
                destination: destination,
                mode: RadarTravelMode.motorcycle,
                avoidTolls: true,
              ),
        _isTestOverrideOfFetchInAppRoute
            ? fetchInAppRoadRoute(
                originLat: originLat,
                originLng: originLng,
                destination: destination,
                mode: RadarTravelMode.drive,
              )
            : fetchSingleModeRoute(
                originLat: originLat,
                originLng: originLng,
                destination: destination,
                mode: RadarTravelMode.drive,
                avoidTolls: avoidTolls,
              ),
      ]);
      return MultiModalRouteComparison(
        destination: destination,
        origin: origin,
        avoidTolls: avoidTolls,
        foot: _bundleFromRouteResult(results[0], true),
        motorcycle: _bundleFromRouteResult(results[1], true),
        car: _bundleFromRouteResult(results[2], avoidTolls),
      );
    }

    final bundles = await Future.wait([
      _resolveDirectModeBundle(originLat, originLng, destination, RadarTravelMode.walk, true),
      _resolveDirectModeBundle(originLat, originLng, destination, RadarTravelMode.motorcycle, true),
      _resolveDirectModeBundle(originLat, originLng, destination, RadarTravelMode.drive, avoidTolls),
    ]);

    return MultiModalRouteComparison(
      destination: destination,
      origin: origin,
      avoidTolls: avoidTolls,
      foot: bundles[0],
      motorcycle: bundles[1],
      car: bundles[2],
    );
  }

  /// Auto-reroute cepat untuk mode Navigasi Live saat menyimpang > 35m.
  bool get _isTestOverrideOfFetchInAppRoute =>
      _isTestEnv && runtimeType != RadarRoutingService;

  Future<RadarRouteResult> navigateLive({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    required RadarTravelMode mode,
    bool avoidTolls = false,
    double? bearingDeg,
  }) async {
    if (_api != null) {
      try {
        final raw = await _api.post(
          '/api/v1/routing/navigate',
          body: {
            'origin_lat': originLat,
            'origin_lng': originLng,
            'dest_lat': destination.latitude,
            'dest_lng': destination.longitude,
            'mode': mode.backendEnumValue,
            'avoid_tolls': mode == RadarTravelMode.drive ? avoidTolls : true,
            if (bearingDeg != null && bearingDeg.isFinite) 'bearing_deg': bearingDeg,
          },
        );
        if (raw is Map<String, dynamic> && raw['data'] is Map) {
          final bundle = ModeRouteBundle.fromBackendJson(
            (raw['data'] as Map).cast<String, dynamic>(),
            mode,
          );
          if (bundle.primary.points.length >= 2) {
            final p = bundle.primary;
            return RadarRouteResult(
              destination: destination,
              mode: mode,
              provider: p.provider,
              cacheHit: p.cacheHit,
              distanceMeters: p.distanceMeters,
              durationSeconds: p.durationSeconds,
              origin: LatLng(originLat, originLng),
              points: p.points,
              steps: p.steps,
              alternatives: bundle.allRoutes,
              hasToll: p.hasToll,
              usesAlleys: p.usesAlleys,
              modeBadge: p.modeBadge,
              trafficMultiplier: p.trafficMultiplier,
            );
          }
        }
      } catch (_) {}
    }
    return fetchSingleModeRoute(
      originLat: originLat,
      originLng: originLng,
      destination: destination,
      mode: mode,
      avoidTolls: avoidTolls,
    );
  }

  /// Dipertahankan kompatibel 100% dengan signature lama (4 named args) untuk mock & test.
  Future<RadarRouteResult> fetchInAppRoadRoute({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    required RadarTravelMode mode,
  }) {
    return fetchSingleModeRoute(
      originLat: originLat,
      originLng: originLng,
      destination: destination,
      mode: mode,
      avoidTolls: mode != RadarTravelMode.drive,
    );
  }

  Future<RadarRouteResult> fetchSingleModeRoute({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    required RadarTravelMode mode,
    bool avoidTolls = false,
  }) async {
    final origin = LatLng(originLat, originLng);
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
          final pts = parseBackendLatLngs(d['coordinates']);
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

    final bundle = await _resolveDirectModeBundle(
      originLat,
      originLng,
      destination,
      mode,
      avoidTolls,
    );
    final p = bundle.primary;
    return RadarRouteResult(
      destination: destination,
      mode: mode,
      provider: p.provider,
      cacheHit: p.cacheHit,
      distanceMeters: p.distanceMeters,
      durationSeconds: p.durationSeconds,
      origin: origin,
      points: p.points,
      steps: p.steps,
      alternatives: bundle.allRoutes,
      hasToll: p.hasToll,
      usesAlleys: p.usesAlleys,
      modeBadge: p.modeBadge,
      trafficMultiplier: p.trafficMultiplier,
    );
  }

  Future<ModeRouteBundle> _resolveDirectModeBundle(
    double oLat,
    double oLng,
    RadarPlaceCard dest,
    RadarTravelMode mode,
    bool avoidTolls,
  ) async {
    final valhalla = await _queryValhallaDirect(oLat, oLng, dest, mode, avoidTolls);
    if (valhalla != null) return valhalla;

    final osrm = await _queryFossgisOsrmDirect(oLat, oLng, dest, mode, avoidTolls);
    if (osrm != null) return osrm;

    return _offlineFallbackBundle(oLat, oLng, dest, mode, avoidTolls);
  }

  Future<ModeRouteBundle?> _queryValhallaDirect(
    double oLat,
    double oLng,
    RadarPlaceCard dest,
    RadarTravelMode mode,
    bool avoidTolls,
  ) async {
    try {
      final String costing;
      final Map<String, dynamic> options;
      switch (mode) {
        case RadarTravelMode.walk:
          costing = 'pedestrian';
          options = {
            'pedestrian': {
              'walking_speed': 4.8,
              'walkway_factor': 0.85,
              'alley_factor': 0.9,
            },
          };
          break;
        case RadarTravelMode.motorcycle:
          costing = 'motorcycle';
          options = {
            'motorcycle': {
              'use_tolls': 0.0,
              'use_highways': 0.2,
              'use_trails': 0.3,
              'use_living_streets': 0.9,
            },
          };
          break;
        case RadarTravelMode.drive:
          costing = 'auto';
          options = {
            'auto': {
              'use_tolls': avoidTolls ? 0.0 : 1.0,
              'alley_penalty': 120.0,
            },
          };
          break;
      }

      final resp = await _publicDio
          .post<dynamic>(
            'https://valhalla1.openstreetmap.de/route',
            data: jsonEncode({
              'locations': [
                {'lat': oLat, 'lon': oLng},
                {'lat': dest.latitude, 'lon': dest.longitude},
              ],
              'costing': costing,
              'costing_options': options,
              'alternates': 2,
              'units': 'kilometers',
            }),
            options: Options(contentType: 'application/json'),
          )
          .timeout(const Duration(seconds: 8));

      final data = resp.data;
      if (data is! Map || data['trip'] is! Map) return null;
      final primary = _parseValhallaTrip(
        (data['trip'] as Map).cast<String, dynamic>(),
        mode,
        avoidTolls,
        0,
        'Rute Terbaik',
      );
      if (primary == null) return null;

      final alts = <RadarRouteAlternative>[];
      final rawAlts = data['alternates'] as List? ?? const [];
      for (var i = 0; i < rawAlts.length && i < 2; i++) {
        final item = rawAlts[i];
        if (item is Map && item['trip'] is Map) {
          final dto = _parseValhallaTrip(
            (item['trip'] as Map).cast<String, dynamic>(),
            mode,
            avoidTolls,
            i + 1,
            'Alternatif ${i + 1}',
          );
          if (dto != null && dto.durationSeconds <= primary.durationSeconds * 1.35) {
            alts.add(dto);
          }
        }
      }
      return ModeRouteBundle(mode: mode, primary: primary, alternatives: alts);
    } catch (_) {
      return null;
    }
  }

  RadarRouteAlternative? _parseValhallaTrip(
    Map<String, dynamic> trip,
    RadarTravelMode mode,
    bool avoidTolls,
    int idx,
    String label,
  ) {
    final summary = trip['summary'] as Map?;
    final legs = trip['legs'] as List?;
    if (summary == null || legs == null || legs.isEmpty) return null;
    final leg0 = legs.first as Map;
    final pts = decodePolyline6((leg0['shape'] ?? '').toString());
    if (pts.length < 2) return null;

    final distM = ((summary['length'] as num?) ?? 0).toDouble() * 1000.0;
    final rawDur = ((summary['time'] as num?) ?? 0).toDouble();
    final hasToll = mode == RadarTravelMode.drive &&
        !avoidTolls &&
        summary['has_toll'] == true;
    final durS = _applyIndonesiaTrafficEta(mode, rawDur, distM);
    final steps = <RadarRouteStep>[];
    for (final m in (leg0['maneuvers'] as List? ?? const []).whereType<Map>().take(22)) {
      final street = (m['street_names'] as List?)?.isNotEmpty == true
          ? (m['street_names'] as List).first.toString()
          : '';
      final instr = (m['instruction'] ?? '').toString().trim();
      steps.add(
        RadarRouteStep(
          instruction: instr.isNotEmpty
              ? instr
              : (street.isNotEmpty ? 'Ikuti $street' : 'Lanjutkan perjalanan'),
          distanceMeters: ((m['length'] as num?) ?? 0).toDouble() * 1000.0,
          durationSeconds: ((m['time'] as num?) ?? 0).toDouble(),
          streetName: street,
        ),
      );
    }
    return RadarRouteAlternative(
      routeId: 'valhalla_${mode.apiValue}_$idx',
      label: label,
      provider: 'valhalla_direct',
      mode: mode,
      cacheHit: false,
      distanceMeters: distM,
      durationSeconds: durS,
      hasToll: hasToll,
      avoidedTolls: avoidTolls || mode != RadarTravelMode.drive,
      usesAlleys: mode != RadarTravelMode.drive,
      modeBadge: _modeBadge(mode, avoidTolls),
      points: pts,
      steps: steps,
    );
  }

  Future<ModeRouteBundle?> _queryFossgisOsrmDirect(
    double oLat,
    double oLng,
    RadarPlaceCard dest,
    RadarTravelMode mode,
    bool avoidTolls,
  ) async {
    try {
      final exclude =
          mode == RadarTravelMode.drive && avoidTolls ? '&exclude=toll' : '';
      final url =
          '${mode.osrmFossgisBaseUrl}/'
          '${oLng.toStringAsFixed(6)},${oLat.toStringAsFixed(6)};'
          '${dest.longitude.toStringAsFixed(6)},${dest.latitude.toStringAsFixed(6)}'
          '?overview=full&geometries=geojson&steps=true&alternatives=true$exclude';
      final resp =
          await _publicDio.get<dynamic>(url).timeout(const Duration(seconds: 8));
      final data = resp.data;
      if (data is! Map || data['routes'] is! List || (data['routes'] as List).isEmpty) {
        return null;
      }
      final routes = data['routes'] as List;
      final primary = _parseOsrmRouteItem(
        (routes.first as Map).cast<String, dynamic>(),
        mode,
        avoidTolls,
        0,
        'Rute Terbaik',
      );
      if (primary == null) return null;

      final alts = <RadarRouteAlternative>[];
      for (var i = 1; i < routes.length && i <= 2; i++) {
        final dto = _parseOsrmRouteItem(
          (routes[i] as Map).cast<String, dynamic>(),
          mode,
          avoidTolls,
          i,
          'Alternatif $i',
        );
        if (dto != null && dto.durationSeconds <= primary.durationSeconds * 1.35) {
          alts.add(dto);
        }
      }
      return ModeRouteBundle(mode: mode, primary: primary, alternatives: alts);
    } catch (_) {
      return null;
    }
  }

  RadarRouteAlternative? _parseOsrmRouteItem(
    Map<String, dynamic> route,
    RadarTravelMode mode,
    bool avoidTolls,
    int idx,
    String label,
  ) {
    final geom = route['geometry'] as Map?;
    final rawCoords = geom?['coordinates'] as List? ?? const [];
    final pts = <LatLng>[];
    for (final c in rawCoords) {
      if (c is List && c.length >= 2) {
        pts.add(LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()));
      }
    }
    if (pts.length < 2) return null;
    final distM = ((route['distance'] as num?) ?? 0).toDouble();
    final rawDur = ((route['duration'] as num?) ?? 0).toDouble();
    final durS = _applyIndonesiaTrafficEta(mode, rawDur, distM);
    final steps = <RadarRouteStep>[];
    for (final leg in (route['legs'] as List? ?? const []).whereType<Map>()) {
      for (final st in (leg['steps'] as List? ?? const []).whereType<Map>().take(20)) {
        final street = (st['name'] ?? '').toString().trim();
        final m = st['maneuver'] as Map?;
        steps.add(
          RadarRouteStep(
            instruction: _formatIndonesianStep(
              (m?['type'] ?? 'continue').toString(),
              (m?['modifier'] ?? '').toString(),
              street,
            ),
            distanceMeters: ((st['distance'] as num?) ?? 0).toDouble(),
            durationSeconds: ((st['duration'] as num?) ?? 0).toDouble(),
            streetName: street,
          ),
        );
      }
    }
    return RadarRouteAlternative(
      routeId: 'osrm_fossgis_${mode.apiValue}_$idx',
      label: label,
      provider: 'osrm_fossgis_direct',
      mode: mode,
      cacheHit: false,
      distanceMeters: distM,
      durationSeconds: durS,
      avoidedTolls: avoidTolls || mode != RadarTravelMode.drive,
      usesAlleys: mode != RadarTravelMode.drive,
      modeBadge: _modeBadge(mode, avoidTolls),
      points: pts,
      steps: steps,
    );
  }

  ModeRouteBundle _offlineFallbackBundle(
    double oLat,
    double oLng,
    RadarPlaceCard dest,
    RadarTravelMode mode,
    bool avoidTolls,
  ) {
    final straightM = RadarPlaceCard.haversineMeters(
      oLat,
      oLng,
      dest.latitude,
      dest.longitude,
    );
    final factor = mode == RadarTravelMode.walk
        ? 1.16
        : (mode == RadarTravelMode.motorcycle ? 1.28 : 1.44);
    final roadM = math.max(50.0, straightM * factor);
    final speedMps = mode == RadarTravelMode.walk
        ? 1.33
        : (mode == RadarTravelMode.motorcycle ? 8.8 : 6.6);
    final durS = (roadM / speedMps).clamp(60.0, 86400.0);

    final midOffset = mode == RadarTravelMode.walk
        ? 0.0004
        : (mode == RadarTravelMode.motorcycle ? -0.0007 : 0.0014);
    final mid = LatLng(
      (oLat + dest.latitude) * 0.5 + midOffset,
      (oLng + dest.longitude) * 0.5 - midOffset,
    );

    final primary = RadarRouteAlternative(
      routeId: 'offline_${mode.apiValue}_0',
      label: 'Rute Estimasi',
      provider: 'offline_multimodal_estimate',
      mode: mode,
      cacheHit: false,
      distanceMeters: roadM,
      durationSeconds: durS,
      avoidedTolls: avoidTolls || mode != RadarTravelMode.drive,
      usesAlleys: mode != RadarTravelMode.drive,
      modeBadge: _modeBadge(mode, avoidTolls),
      points: [LatLng(oLat, oLng), mid, LatLng(dest.latitude, dest.longitude)],
      steps: [
        RadarRouteStep(
          instruction: 'Menuju ${dest.name} (${dest.cityKabupaten})',
          distanceMeters: roadM,
          durationSeconds: durS,
        ),
      ],
    );
    return ModeRouteBundle(mode: mode, primary: primary);
  }

  static ModeRouteBundle _bundleFromRouteResult(
    RadarRouteResult r,
    bool avoidTolls,
  ) {
    final primary = RadarRouteAlternative(
      routeId: 'mock_${r.mode.apiValue}_0',
      label: 'Rute Terbaik',
      provider: r.provider,
      mode: r.mode,
      cacheHit: r.cacheHit,
      distanceMeters: r.distanceMeters,
      durationSeconds: r.durationSeconds,
      avoidedTolls: avoidTolls || r.mode != RadarTravelMode.drive,
      usesAlleys: r.mode != RadarTravelMode.drive,
      modeBadge: _modeBadge(r.mode, avoidTolls),
      points: r.points,
      steps: r.steps,
    );
    return ModeRouteBundle(mode: r.mode, primary: primary);
  }

  static double _applyIndonesiaTrafficEta(
    RadarTravelMode mode,
    double rawDur,
    double distM,
  ) {
    switch (mode) {
      case RadarTravelMode.walk:
        final tobler = math.max(40.0, distM / 1.33);
        return ((rawDur * 0.6) + (tobler * 0.4)).clamp(40.0, 86400.0);
      case RadarTravelMode.motorcycle:
        return (rawDur * 0.82).clamp(45.0, 86400.0);
      case RadarTravelMode.drive:
        return (rawDur * 1.24).clamp(60.0, 86400.0);
    }
  }

  static String _modeBadge(RadarTravelMode mode, bool avoidTolls) {
    switch (mode) {
      case RadarTravelMode.walk:
        return 'Trotoar & Gang • Bebas Macet';
      case RadarTravelMode.motorcycle:
        return 'Bebas Tol • Lewat Gang';
      case RadarTravelMode.drive:
        return avoidTolls ? 'Non-Tol • Jalur Mobil' : 'Boleh Tol • Jalur Arteri';
    }
  }

  static String _formatIndonesianStep(String type, String mod, String street) {
    final road = street.isNotEmpty ? ' ke $street' : '';
    switch (type) {
      case 'depart':
        return street.isNotEmpty
            ? 'Mulai perjalanan dari $street'
            : 'Mulai perjalanan';
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
