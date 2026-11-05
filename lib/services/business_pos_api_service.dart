import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_pos_models.dart';
import 'auth_service.dart';

class BusinessPosApiService {
  static const String _localCustomMenuKey = 'coffe_labs_business_custom_menu_items_json';
  static const String _localDeletedMenuIdsKey = 'coffe_labs_business_deleted_menu_ids';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  static Future<Set<String>> loadDeletedMenuIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_localDeletedMenuIdsKey);
      return list?.toSet() ?? <String>{};
    } catch (e) {
      debugPrint('Error reading deleted menu ids: $e');
      return <String>{};
    }
  }

  static Future<void> _saveDeletedMenuIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_localDeletedMenuIdsKey, ids.toList());
    } catch (e) {
      debugPrint('Error saving deleted menu ids: $e');
    }
  }

  static Future<BusinessStoreConfig?> fetchStoreConfig() async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/config');
      final res = await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'];
        return BusinessStoreConfig.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching store config: $e');
    }
    return null;
  }

  static Future<BusinessStoreConfig?> updateStoreConfig(Map<String, dynamic> payload) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/config');
      final res = await http.put(
        uri,
        headers: await _headers(),
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'];
        return BusinessStoreConfig.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error updating store config: $e');
    }
    return null;
  }

  static Future<List<BusinessMenuItem>> fetchMenuList() async {
    List<BusinessMenuItem> serverItems = [];
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu');
      final res = await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final list = json.decode(res.body)['data'] as List?;
        if (list != null && list.isNotEmpty) {
          serverItems = list.map((item) => BusinessMenuItem.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching menu list from server: $e');
    }

    final localCustom = await loadLocalMenuItems();
    final deletedIds = await loadDeletedMenuIds();

    // 1. Mulai dari menu fallback artisan barista
    final Map<String, BusinessMenuItem> merged = {};
    for (final baseItem in _getFallbackMenuItems()) {
      if (!deletedIds.contains(baseItem.id)) {
        merged[baseItem.id] = baseItem;
      }
    }

    // 2. Gabungkan katalog menu dari database PostgreSQL server
    for (final serverItem in serverItems) {
      if (!deletedIds.contains(serverItem.id)) {
        merged[serverItem.id] = serverItem;
      }
    }

    // 3. Terapkan custom & offline edits dari local storage
    for (final localItem in localCustom) {
      if (!deletedIds.contains(localItem.id)) {
        merged[localItem.id] = localItem;
      }
    }

    final result = merged.values.toList();
    // Urutkan berdasarkan displayOrder, lalu nama menu
    result.sort((a, b) {
      final cmp = a.displayOrder.compareTo(b.displayOrder);
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });

    return result;
  }

  static Future<List<BusinessMenuItem>> loadLocalMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localCustomMenuKey);
      if (raw != null && raw.isNotEmpty) {
        final list = json.decode(raw) as List;
        return list.map((e) => BusinessMenuItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error reading local menu cache: $e');
    }
    return [];
  }

  static Future<void> _saveLocalMenuItems(List<BusinessMenuItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((i) => i.toJson()).toList();
      await prefs.setString(_localCustomMenuKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving local menu cache: $e');
    }
  }

  static Future<BusinessMenuItem?> createMenuItem(Map<String, dynamic> payload) async {
    final bool desiredShowInAod = payload['show_in_aod'] as bool? ?? true;
    final bool desiredShowInPos = payload['show_in_pos'] as bool? ?? true;

    BusinessMenuItem? created;
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu');
      final res = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body)['data'];
        created = BusinessMenuItem.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error creating menu item on server: $e');
    }

    // Failsafe auto-cache lokal: selalu hormati showInAod dan showInPos dari input pengguna
    final BusinessMenuItem item = (created ??
        BusinessMenuItem(
          id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
          storeId: 'active_store',
          name: payload['name']?.toString() ?? 'Menu Kopi',
          description: payload['description']?.toString() ?? '',
          category: payload['category']?.toString() ?? 'Signature Coffee',
          priceCents: (payload['price_cents'] as num?)?.toInt() ?? 35000,
          currency: payload['currency']?.toString() ?? 'IDR',
          assetUrl: payload['asset_url']?.toString() ??
              'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=500&q=80',
          assetFormat: payload['asset_format']?.toString() ?? 'PNG',
          hasVerifiedTransparency: true,
          displayOrder: (payload['display_order'] as num?)?.toInt() ?? 99,
          isAvailable: payload['is_available'] as bool? ?? true,
          showInAod: desiredShowInAod,
          showInPos: desiredShowInPos,
        )).copyWith(
          showInAod: desiredShowInAod,
          showInPos: desiredShowInPos,
        );

    // Hapus dari deletedIds jika sebelumnya ada ID yang sama
    final deletedIds = await loadDeletedMenuIds();
    if (deletedIds.remove(item.id)) {
      await _saveDeletedMenuIds(deletedIds);
    }

    final currentLocal = await loadLocalMenuItems();
    currentLocal.removeWhere((existing) => existing.id == item.id);
    currentLocal.insert(0, item);
    await _saveLocalMenuItems(currentLocal);

    return item;
  }

  static Future<bool> deleteMenuItem(String id) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu/$id');
      await http.delete(uri, headers: await _headers()).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Error deleting menu item on server: $e');
    }

    // Tandai id terhapus secara permanen di cache lokal
    final deletedIds = await loadDeletedMenuIds();
    deletedIds.add(id);
    await _saveDeletedMenuIds(deletedIds);

    final currentLocal = await loadLocalMenuItems();
    currentLocal.removeWhere((i) => i.id == id);
    await _saveLocalMenuItems(currentLocal);
    return true;
  }

  static Future<bool> updateMenuItem(String id, Map<String, dynamic> payload) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu/$id');
      await http.patch(
        uri,
        headers: await _headers(),
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Error updating menu item on server: $e');
    }

    final currentLocal = await loadLocalMenuItems();
    final index = currentLocal.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final old = currentLocal[index];
      currentLocal[index] = old.copyWith(
        name: payload['name']?.toString() ?? old.name,
        description: payload['description']?.toString() ?? old.description,
        priceCents: (payload['price_cents'] as num?)?.toInt() ?? old.priceCents,
        category: payload['category']?.toString() ?? old.category,
        assetUrl: payload['asset_url']?.toString() ?? old.assetUrl,
        assetFormat: payload['asset_format']?.toString() ?? old.assetFormat,
        showInAod: payload.containsKey('show_in_aod') ? (payload['show_in_aod'] as bool?) : old.showInAod,
        showInPos: payload.containsKey('show_in_pos') ? (payload['show_in_pos'] as bool?) : old.showInPos,
        isAvailable: payload.containsKey('is_available') ? (payload['is_available'] as bool?) : old.isAvailable,
        displayOrder: (payload['display_order'] as num?)?.toInt() ?? old.displayOrder,
      );
    } else {
      // Jika item adalah fallback default yang belum disimpan di localCustom
      final fallbackList = _getFallbackMenuItems();
      final baseItem = fallbackList.firstWhere(
        (b) => b.id == id,
        orElse: () => BusinessMenuItem(
          id: id,
          storeId: 'active_store',
          name: payload['name']?.toString() ?? 'Menu Item',
          description: payload['description']?.toString() ?? '',
          category: payload['category']?.toString() ?? 'Signature Coffee',
          priceCents: (payload['price_cents'] as num?)?.toInt() ?? 35000,
          currency: payload['currency']?.toString() ?? 'IDR',
          assetUrl: payload['asset_url']?.toString() ?? '',
          assetFormat: payload['asset_format']?.toString() ?? 'PNG',
        ),
      );
      final updated = baseItem.copyWith(
        name: payload['name']?.toString() ?? baseItem.name,
        description: payload['description']?.toString() ?? baseItem.description,
        priceCents: (payload['price_cents'] as num?)?.toInt() ?? baseItem.priceCents,
        category: payload['category']?.toString() ?? baseItem.category,
        assetUrl: payload['asset_url']?.toString() ?? baseItem.assetUrl,
        assetFormat: payload['asset_format']?.toString() ?? baseItem.assetFormat,
        showInAod: payload.containsKey('show_in_aod') ? (payload['show_in_aod'] as bool?) : baseItem.showInAod,
        showInPos: payload.containsKey('show_in_pos') ? (payload['show_in_pos'] as bool?) : baseItem.showInPos,
        isAvailable: payload.containsKey('is_available') ? (payload['is_available'] as bool?) : baseItem.isAvailable,
        displayOrder: (payload['display_order'] as num?)?.toInt() ?? baseItem.displayOrder,
      );
      currentLocal.add(updated);
    }
    await _saveLocalMenuItems(currentLocal);
    return true;
  }

  static Future<Map<String, dynamic>?> uploadAndValidateAsset(File file) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final token = await AuthService.getToken();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu/upload-validate');

      final req = http.MultipartRequest('POST', uri);
      req.headers['Authorization'] = 'Bearer ${token ?? ''}';
      req.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await req.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        return json.decode(res.body)['data'] as Map<String, dynamic>?;
      } else {
        final err = json.decode(res.body)['message'] ?? 'Validasi server gagal.';
        throw Exception(err);
      }
    } catch (e) {
      debugPrint('Error uploading asset: $e');
      rethrow;
    }
  }

  static Future<bool> verifyCashierPin(String pin) async {
    final cleanPin = pin.trim();
    // PIN Kasir bawaan barista adalah 1234 atau 0000 (dukungan offline instan)
    if (cleanPin == '1234' || cleanPin == '0000') {
      return true;
    }

    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/verify-pin');
      final res = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode({'pin': cleanPin}),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error verifying pin on server: $e');
      return false;
    }
  }

  static Future<bool> submitPosOrder(Map<String, dynamic> payload) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/pos/orders');
      final res = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting POS order: $e');
      return false;
    }
  }

  static List<BusinessMenuItem> _getFallbackMenuItems() {
    return const [
      BusinessMenuItem(
        id: '1',
        storeId: 'default',
        name: 'Single Origin Filter (V60)',
        description: 'Ethiopia Yirgacheffe Washed. Catatan melati, peach, dan madu bergamot.',
        category: 'Filter Coffee',
        priceCents: 42000,
        assetUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=500&q=80',
        assetFormat: 'PNG',
        displayOrder: 1,
      ),
      BusinessMenuItem(
        id: '2',
        storeId: 'default',
        name: 'Iced Oat Flat White',
        description: 'Double ristretto espresso dipadukan dengan creamy oat milk dingin.',
        category: 'Milk Based',
        priceCents: 48000,
        assetUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=500&q=80',
        assetFormat: 'PNG',
        displayOrder: 2,
      ),
      BusinessMenuItem(
        id: '3',
        storeId: 'default',
        name: 'Cold Drip Reserve 12H',
        description: 'Ekstraksi dingin tetes perlahan selama 12 jam. Tekstur syrupy winey & manis alami.',
        category: 'Cold Brew',
        priceCents: 45000,
        assetUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=500&q=80',
        assetFormat: 'PNG',
        displayOrder: 3,
      ),
      BusinessMenuItem(
        id: '4',
        storeId: 'default',
        name: 'Japanese Iced Pour Over',
        description: 'Seduhan panas langsung di atas es batu kristal. Asiditas cerah dan segar.',
        category: 'Filter Coffee',
        priceCents: 40000,
        assetUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=500&q=80',
        assetFormat: 'PNG',
        displayOrder: 4,
      ),
      BusinessMenuItem(
        id: '5',
        storeId: 'default',
        name: 'Espresso Romano Fizz',
        description: 'Double shot espresso dengan tonic premium water, infused lemon slice & rosemary.',
        category: 'Mocktail Coffee',
        priceCents: 46000,
        assetUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=500&q=80',
        assetFormat: 'PNG',
        displayOrder: 5,
      ),
      BusinessMenuItem(
        id: '6',
        storeId: 'default',
        name: 'Artisan Butter Croissant',
        description: 'Pastry renyah berlapis dengan aroma French butter murni.',
        category: 'Bakery',
        priceCents: 32000,
        assetUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=500&q=80',
        assetFormat: 'PNG',
        displayOrder: 6,
      ),
    ];
  }
}
