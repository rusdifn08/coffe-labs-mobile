import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/business_pos_models.dart';
import 'auth_service.dart';

class BusinessPosApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
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
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu');
      final res = await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final list = json.decode(res.body)['data'] as List?;
        if (list != null) {
          return list.map((item) => BusinessMenuItem.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching menu list: $e');
    }
    return _getFallbackMenuItems();
  }

  static Future<BusinessMenuItem?> createMenuItem(Map<String, dynamic> payload) async {
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
        return BusinessMenuItem.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error creating menu item: $e');
    }
    return null;
  }

  static Future<bool> deleteMenuItem(String id) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/menu/$id');
      final res = await http.delete(uri, headers: await _headers()).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      return false;
    }
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
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/business/verify-pin');
      final res = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode({'pin': pin}),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error verifying pin: $e');
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
