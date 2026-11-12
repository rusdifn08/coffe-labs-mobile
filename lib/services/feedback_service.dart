import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/feedback_item.dart';
import 'auth_service.dart';

class FeedbackService {
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);
  static final http.Client _client = http.Client();

  static FeedbackStatsData? _cachedStats;
  static DateTime? _cachedStatsTime;
  static const Duration _statsCacheTtl = Duration(seconds: 30);

  static const List<String> commonFeatures = [
    'Brew Timer & Stopwatch',
    'Koleksi Resep Manual Brew',
    'Cupping & Flavor Wheel',
    'Kalkulator Seduh & Rasio',
    'Akun & Sistem Login',
    'Basecamp & Komunitas',
    'Tampilan UI / Navigasi',
    'Performa & Kecepatan',
    'Lainnya',
  ];

  /// Mengirim feedback baru dari user (Bisa member resmi atau tamu/trial)
  static Future<bool> submitFeedback({
    required String category,
    required String featureAffected,
    required String title,
    required String description,
    required int rating,
    String? guestName,
  }) async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/feedback');
      final token = await AuthService.getToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      String devicePlatform = 'Mobile';
      if (kIsWeb) {
        devicePlatform = 'Web Browser';
      } else if (Platform.isAndroid) {
        devicePlatform = 'Android';
      } else if (Platform.isIOS) {
        devicePlatform = 'iOS';
      } else if (Platform.isWindows) {
        devicePlatform = 'Windows Desktop';
      }

      final body = json.encode({
        'category': category,
        'feature_affected': featureAffected,
        'title': title.trim(),
        'description': description.trim(),
        'rating': rating,
        'guest_name': guestName,
        'app_version': '2.0.0',
        'device_info': devicePlatform,
      });

      final response = await _client.post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 201) {
        _cachedStats = null;
        _cachedStatsTime = null;
        changeNotifier.value++;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      return false;
    }
  }

  /// Mengambil daftar feedback untuk Admin
  static Future<List<FeedbackItem>> getAdminFeedbacks({
    String? status,
    String? category,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final baseUrl = await AuthService.getBaseUrl();
      var urlStr = '$baseUrl/api/admin/feedbacks?';
      if (status != null && status.isNotEmpty) {
        urlStr += 'status=$status&';
      }
      if (category != null && category.isNotEmpty) {
        urlStr += 'category=$category&';
      }

      final response = await _client.get(
        Uri.parse(urlStr),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching admin feedbacks: $e');
      return [];
    }
  }

  /// Mengambil ringkasan statistik feedback untuk Admin (dengan cache TTL 30s)
  static Future<FeedbackStatsData?> getFeedbackStats({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh && _cachedStats != null && _cachedStatsTime != null) {
      if (now.difference(_cachedStatsTime!) < _statsCacheTtl) {
        return _cachedStats;
      }
    }

    try {
      final token = await AuthService.getToken();
      if (token == null) return _cachedStats;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/feedbacks/stats');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['data'] != null) {
          _cachedStats = FeedbackStatsData.fromJson(data['data'] as Map<String, dynamic>);
          _cachedStatsTime = DateTime.now();
          return _cachedStats;
        }
      }
      return _cachedStats;
    } on SocketException catch (e) {
      // Gracefully handle socket/offline exception without spamming console
      debugPrint('FeedbackService: network unavailable (${e.message})');
      return _cachedStats;
    } catch (e) {
      debugPrint('Error fetching feedback stats: $e');
      return _cachedStats;
    }
  }

  /// Memperbarui status feedback & catatan admin
  static Future<bool> updateFeedbackStatus(
    String feedbackId,
    String status, {
    String? adminNotes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/feedbacks/$feedbackId/status');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': status,
          'admin_notes': adminNotes,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _cachedStats = null;
        _cachedStatsTime = null;
        changeNotifier.value++;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating feedback status: $e');
      return false;
    }
  }

  /// Menghapus feedback dari sistem
  static Future<bool> deleteFeedback(String feedbackId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/feedbacks/$feedbackId');

      final response = await _client.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _cachedStats = null;
        _cachedStatsTime = null;
        changeNotifier.value++;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting feedback: $e');
      return false;
    }
  }
}
