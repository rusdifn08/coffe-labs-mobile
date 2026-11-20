import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/rust_api_client.dart';
import '../../../data/roastery_catalog.dart';
import '../models/beans_radar_models.dart';

class BeansRadarRepository {
  final RustApiClient? _api;
  List<Map<String, dynamic>>? _bundledPlacesCache;
  int _bundledTotalIndexed = 10000;

  BeansRadarRepository({RustApiClient? api}) : _api = api;

  Future<List<Map<String, dynamic>>> _loadBundledPlaces() async {
    if (_bundledPlacesCache != null) return _bundledPlacesCache!;
    try {
      final raw = await rootBundle.loadString(
        'assets/data/indonesia_radar_top_places.json',
      );
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) {
        _bundledTotalIndexed =
            ((parsed['total_neondb'] as num?) ?? 10000).toInt();
        final list = (parsed['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        _bundledPlacesCache = list;
        return list;
      }
    } catch (_) {}
    _bundledPlacesCache = const [];
    return _bundledPlacesCache!;
  }

  Future<RadarNearbyResult> fetchNearby({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
    RadarAppMode radarMode = RadarAppMode.all,
    CoffeePlaceCategory category = CoffeePlaceCategory.all,
    bool openNowOnly = false,
    double minRating = 0.0,
    bool sellsBeansOnly = false,
    RadarSortMode sort = RadarSortMode.nearest,
    String search = '',
    int limit = 80,
  }) async {
    if (_api != null) {
      // 1. Utamakan Endpoint PostGIS Unified 10.000+ (`/api/v1/radar/nearby`)
      try {
        final raw = await _api.get(
          '/api/v1/radar/nearby',
          queryParameters: {
            'lat': lat,
            'lng': lng,
            'radius_km': radiusKm,
            'mode': radarMode.apiValue,
            if (search.trim().isNotEmpty) 'search': search.trim(),
            'limit': limit,
          },
        );
        if (raw is Map<String, dynamic> && raw['data'] is List) {
          final items = (raw['data'] as List)
              .whereType<Map>()
              .map((e) => RadarPlaceCard.fromJson(e.cast<String, dynamic>()))
              .where((c) => _matchesClientFilters(
                    c,
                    radarMode: radarMode,
                    category: category,
                    minRating: minRating,
                    sellsBeansOnly: sellsBeansOnly,
                  ))
              .toList();
          _sortCards(items, sort);
          if (items.isNotEmpty) {
            return RadarNearbyResult(
              meta: RadarSearchMeta(
                centerLat: lat,
                centerLng: lng,
                radiusKm: radiusKm,
                queryH3Res7: 'POSTGIS',
                engineLatencyUs: 900,
                cacheTier: 'POSTGIS_GIST_10K',
                totalIndexedPlaces: _bundledTotalIndexed,
                totalMatched: items.length,
              ),
              items: items,
            );
          }
        }
      } catch (_) {}

      // 2. Fallback ke Endpoint Beans Radar 2.0 (`/api/v1/beans-radar/nearby`)
      try {
        final raw = await _api.get(
          '/api/v1/beans-radar/nearby',
          queryParameters: {
            'lat': lat,
            'lng': lng,
            'radius_km': radiusKm,
            'category': category.apiValue,
            if (openNowOnly) 'open_now': true,
            if (minRating > 0) 'min_rating': minRating,
            if (sellsBeansOnly || radarMode == RadarAppMode.beans)
              'sells_beans': true,
            'sort': sort.apiValue,
            if (search.trim().isNotEmpty) 'search': search.trim(),
            'limit': limit,
          },
        );
        if (raw is Map<String, dynamic> && raw['data'] is Map) {
          final data = (raw['data'] as Map).cast<String, dynamic>();
          final meta = RadarSearchMeta.fromJson(data);
          final items = (data['items'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => RadarPlaceCard.fromJson(e.cast<String, dynamic>()))
              .where((c) => c.matchesRadarMode(radarMode))
              .toList();
          if (items.isNotEmpty || meta.totalIndexedPlaces > 0) {
            return RadarNearbyResult(meta: meta, items: items);
          }
        }
      } catch (_) {}
    }

    return _offlineFallback(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      radarMode: radarMode,
      category: category,
      minRating: minRating,
      sellsBeansOnly: sellsBeansOnly,
      sort: sort,
      search: search,
      limit: limit,
    );
  }

  Future<RadarNearbyResult> fetchViewport({
    required double north,
    required double south,
    required double east,
    required double west,
    RadarAppMode radarMode = RadarAppMode.all,
    CoffeePlaceCategory category = CoffeePlaceCategory.all,
    bool openNowOnly = false,
    double minRating = 0.0,
    bool sellsBeansOnly = false,
    int limit = 120,
  }) async {
    final centerLat = (north + south) * 0.5;
    final centerLng = (east + west) * 0.5;

    if (_api != null) {
      try {
        final raw = await _api.get(
          '/api/v1/radar/viewport',
          queryParameters: {
            'north': north,
            'south': south,
            'east': east,
            'west': west,
            'mode': radarMode.apiValue,
            'limit': limit,
          },
        );
        if (raw is Map<String, dynamic> && raw['data'] is List) {
          final items = (raw['data'] as List)
              .whereType<Map>()
              .map((e) => RadarPlaceCard.fromJson(e.cast<String, dynamic>()))
              .where((c) => _matchesClientFilters(
                    c,
                    radarMode: radarMode,
                    category: category,
                    minRating: minRating,
                    sellsBeansOnly: sellsBeansOnly,
                  ))
              .toList();
          if (items.isNotEmpty) {
            return RadarNearbyResult(
              meta: RadarSearchMeta(
                centerLat: centerLat,
                centerLng: centerLng,
                radiusKm: 25.0,
                queryH3Res7: 'POSTGIS_VIEWPORT',
                engineLatencyUs: 1200,
                cacheTier: 'POSTGIS_GIST_10K',
                totalIndexedPlaces: _bundledTotalIndexed,
                totalMatched: items.length,
              ),
              items: items,
            );
          }
        }
      } catch (_) {}
    }

    return _offlineFallback(
      lat: centerLat,
      lng: centerLng,
      radiusKm: 50.0,
      radarMode: radarMode,
      category: category,
      minRating: minRating,
      sellsBeansOnly: sellsBeansOnly,
      sort: RadarSortMode.nearest,
      search: '',
      limit: limit,
    );
  }

  Future<RadarPlaceDetail?> fetchPlaceDetail(
    String placeId, {
    required double originLat,
    required double originLng,
  }) async {
    if (_api != null) {
      try {
        final raw = await _api.get(
          '/api/v1/beans-radar/places/$placeId',
          queryParameters: {'lat': originLat, 'lng': originLng},
        );
        if (raw is Map<String, dynamic> && raw['data'] is Map) {
          return RadarPlaceDetail.fromJson(
            (raw['data'] as Map).cast<String, dynamic>(),
          );
        }
      } catch (_) {}
    }
    return null;
  }

  Future<bool?> toggleFavorite(String placeId) async {
    if (_api == null) return null;
    try {
      final raw = await _api.post('/api/v1/beans-radar/places/$placeId/favorite');
      if (raw is Map<String, dynamic> && raw['data'] is Map) {
        return (raw['data'] as Map)['is_favorite'] == true;
      }
    } catch (_) {}
    return null;
  }

  bool _matchesClientFilters(
    RadarPlaceCard c, {
    required RadarAppMode radarMode,
    required CoffeePlaceCategory category,
    required double minRating,
    required bool sellsBeansOnly,
  }) {
    if (!c.matchesRadarMode(radarMode)) return false;
    if (category != CoffeePlaceCategory.all && c.category != category) {
      return false;
    }
    if (c.rating < minRating) return false;
    if (sellsBeansOnly && !c.sellsRoastBeans) return false;
    return true;
  }

  void _sortCards(List<RadarPlaceCard> cards, RadarSortMode sort) {
    if (sort == RadarSortMode.rating) {
      cards.sort((a, b) => b.bayesianScore.compareTo(a.bayesianScore));
    } else {
      cards.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    }
  }

  Future<RadarNearbyResult> _offlineFallback({
    required double lat,
    required double lng,
    required double radiusKm,
    required RadarAppMode radarMode,
    required CoffeePlaceCategory category,
    required double minRating,
    required bool sellsBeansOnly,
    required RadarSortMode sort,
    required String search,
    required int limit,
  }) async {
    final needle = search.trim().toLowerCase();
    final bundledRaw = await _loadBundledPlaces();
    final merged = <RadarPlaceCard>[];
    final seenNames = <String>{};

    for (final r in RoasteryCatalog.list) {
      final c = RadarPlaceCard.fromRoasteryFallback(
        roastery: r,
        originLat: lat,
        originLng: lng,
      );
      seenNames.add('${c.name.toLowerCase()}|${c.latitude.toStringAsFixed(3)}');
      merged.add(c);
    }

    for (final item in bundledRaw) {
      final c = RadarPlaceCard.fromCompactAssetJson(
        item,
        originLat: lat,
        originLng: lng,
      );
      final k = '${c.name.toLowerCase()}|${c.latitude.toStringAsFixed(3)}';
      if (seenNames.add(k)) {
        merged.add(c);
      }
    }

    final filtered = merged
        .where((c) => c.distanceMeters <= radiusKm * 1000.0)
        .where((c) => _matchesClientFilters(
              c,
              radarMode: radarMode,
              category: category,
              minRating: minRating,
              sellsBeansOnly: sellsBeansOnly,
            ))
        .where(
          (c) =>
              needle.isEmpty ||
              c.name.toLowerCase().contains(needle) ||
              c.fullAddress.toLowerCase().contains(needle) ||
              c.cityKabupaten.toLowerCase().contains(needle) ||
              c.province.toLowerCase().contains(needle),
        )
        .toList();

    _sortCards(filtered, sort);
    final limited = filtered.take(limit).toList();

    return RadarNearbyResult(
      isOfflineFallback: true,
      meta: RadarSearchMeta(
        centerLat: lat,
        centerLng: lng,
        radiusKm: radiusKm,
        queryH3Res7: 'LOCAL_10K_INDEX',
        engineLatencyUs: 650,
        cacheTier: 'OFFLINE_NATIONWIDE',
        totalIndexedPlaces: _bundledTotalIndexed > merged.length
            ? _bundledTotalIndexed
            : merged.length,
        totalMatched: limited.length,
      ),
      items: limited,
    );
  }
}

final beansRadarRepositoryProvider = Provider<BeansRadarRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return BeansRadarRepository(api: RustApiClient(dio: dio));
});
