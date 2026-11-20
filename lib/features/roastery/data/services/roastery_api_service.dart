import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/roastery.dart';

class RoasteryApiService {
  static const String _publicCacheKey = 'coffeehub_business_roasteries_v1';
  static const String _myRoasteryCacheKey = 'coffeehub_my_business_roastery_v1';

  final Dio _dio;

  const RoasteryApiService(this._dio);

  Future<List<Roastery>> fetchPublicBusinessRoasteries({
    String? cluster,
    String? query,
  }) async {
    try {
      final params = <String, dynamic>{'limit': 60, 'offset': 0};
      if (cluster != null && cluster.trim().isNotEmpty && cluster != 'Semua') {
        params['cluster'] = cluster.trim();
      }
      if (query != null && query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }

      final resp = await _dio.get<Map<String, dynamic>>(
        '/api/v1/roasteries',
        queryParameters: params,
      );
      final rawList = resp.data?['data'] as List<dynamic>? ?? const [];
      final parsed = rawList
          .whereType<Map>()
          .map((e) => Roastery.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (cluster == null && (query == null || query.isEmpty)) {
        await _savePublicCache(parsed);
      }
      return parsed;
    } catch (_) {
      return loadCachedPublicRoasteries();
    }
  }

  Future<Roastery?> fetchRoasteryDetail(String idOrSlug) async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/v1/roasteries/$idOrSlug');
    final data = resp.data?['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return Roastery.fromJson(data);
  }

  Future<Roastery?> fetchMyRoastery() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('/api/v1/roasteries/me');
      final data = resp.data?['data'];
      if (data == null) {
        await _saveMyRoasteryCache(null);
        return null;
      }
      final parsed = Roastery.fromJson(Map<String, dynamic>.from(data as Map));
      await _saveMyRoasteryCache(parsed);
      return parsed;
    } catch (_) {
      return loadCachedMyRoastery();
    }
  }

  Future<Roastery> createMyRoastery({
    required String name,
    required String city,
    required String address,
    required String description,
    required String specialties,
    required String cluster,
    required String salesHighlight,
    required String logoUrl,
    String? logoPublicId,
    String? bannerUrl,
    String? bannerPublicId,
    String? whatsappNumber,
    String? instagramHandle,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'city': city.trim(),
      'address': address.trim(),
      'description': description.trim(),
      'specialties': specialties.trim(),
      'cluster': cluster.trim(),
      'sales_highlight': salesHighlight.trim(),
      'logo_url': logoUrl.trim(),
      if (logoPublicId != null && logoPublicId.isNotEmpty)
        'logo_public_id': logoPublicId,
      if (bannerUrl != null && bannerUrl.isNotEmpty) 'banner_url': bannerUrl,
      if (bannerPublicId != null && bannerPublicId.isNotEmpty)
        'banner_public_id': bannerPublicId,
      if (whatsappNumber != null && whatsappNumber.trim().isNotEmpty)
        'whatsapp_number': whatsappNumber.trim(),
      if (instagramHandle != null && instagramHandle.trim().isNotEmpty)
        'instagram_handle': instagramHandle.trim(),
    };

    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/v1/roasteries',
      data: payload,
    );
    final data = Map<String, dynamic>.from(resp.data!['data'] as Map);
    final created = Roastery.fromJson(data);
    await _saveMyRoasteryCache(created);
    return created;
  }

  Future<Roastery> updateMyRoastery(Map<String, dynamic> fields) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/api/v1/roasteries/me',
      data: fields,
    );
    final data = Map<String, dynamic>.from(resp.data!['data'] as Map);
    final updated = Roastery.fromJson(data);
    await _saveMyRoasteryCache(updated);
    return updated;
  }

  Future<CoffeeLineupItem> addLineup(CoffeeLineupItem item) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/v1/roasteries/me/lineups',
      data: item.toUpsertPayload(),
    );
    final data = Map<String, dynamic>.from(resp.data!['data'] as Map);
    return CoffeeLineupItem.fromJson(data);
  }

  Future<CoffeeLineupItem> updateLineup(String lineupId, CoffeeLineupItem item) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/api/v1/roasteries/me/lineups/$lineupId',
      data: item.toUpsertPayload(),
    );
    final data = Map<String, dynamic>.from(resp.data!['data'] as Map);
    return CoffeeLineupItem.fromJson(data);
  }

  Future<void> deleteLineup(String lineupId) async {
    await _dio.delete<Map<String, dynamic>>(
      '/api/v1/roasteries/me/lineups/$lineupId',
    );
  }

  static Future<List<Roastery>> loadCachedPublicRoasteries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_publicCacheKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => Roastery.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> _savePublicCache(List<Roastery> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _publicCacheKey,
        json.encode(items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  static Future<Roastery?> loadCachedMyRoastery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_myRoasteryCacheKey);
      if (raw == null || raw.isEmpty) return null;
      return Roastery.fromJson(Map<String, dynamic>.from(json.decode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveMyRoasteryCache(Roastery? item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (item == null) {
        await prefs.remove(_myRoasteryCacheKey);
      } else {
        await prefs.setString(_myRoasteryCacheKey, json.encode(item.toJson()));
      }
    } catch (_) {}
  }
}
