import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:coffee_hub_mobile/services/auth_service.dart';
import '../../domain/models/coffee_annotation_class.dart';

class VisionCloudSyncService {
  static Future<List<CoffeeAnnotationClass>> fetchGlobalClasses() async {
    try {
      final token = await AuthService.getToken();
      final baseUrl = await AuthService.getBaseUrl();
      final url = Uri.parse('$baseUrl/api/v1/vision/classes');

      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          final classes = <CoffeeAnnotationClass>[];
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              classes.add(CoffeeAnnotationClass.fromMap(item));
            }
          }
          return classes;
        }
      }
    } catch (e) {
      debugPrint('VisionCloudSyncService.fetchGlobalClasses notice: $e');
    }
    return [];
  }

  static Future<bool> syncClassToCloud({
    required String classSlug,
    required String brand,
    required String coffeeName,
    required String process,
    List<String> tastingNotes = const [],
    List<double>? centroidVector,
  }) async {
    try {
      final token = await AuthService.getToken();
      final baseUrl = await AuthService.getBaseUrl();
      final url = Uri.parse('$baseUrl/api/v1/vision/classes/sync');

      final body = json.encode({
        'class_slug': classSlug,
        'brand': brand,
        'coffee_name': coffeeName,
        'process': process,
        'tasting_notes': tastingNotes,
        'centroid_vector': ?centroidVector,
      });

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('VisionCloudSyncService.syncClassToCloud notice: $e');
      return false;
    }
  }
}
