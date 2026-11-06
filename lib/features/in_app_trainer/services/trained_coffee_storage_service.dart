import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../domain/trained_coffee_class_model.dart';

/// Penyimpanan model kopi hasil pelatihan Transfer Learning (Offline-First + Cloud Sync).
class TrainedCoffeeStorageService {
  static const String _storageKey = 'coffee_labs_trained_classes_v1';
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  /// Menyimpan model yang baru dilatih ke local disk & sinkronisasi ke backend Rust.
  static Future<void> saveModel(TrainedCoffeeClassModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final existingMap = await _loadRawMap(prefs);

    existingMap[model.classSlug] = model.toJson();

    final encoded = json.encode(existingMap);
    await prefs.setString(_storageKey, encoded);
    changeNotifier.value++;

    // Background sync ke Rust Axum backend
    _syncToBackendSilently(model);
  }

  /// Mengambil semua model kelas kopi yang pernah dilatih di HP ini.
  static Future<List<TrainedCoffeeClassModel>> getAllModels() async {
    final prefs = await SharedPreferences.getInstance();
    final existingMap = await _loadRawMap(prefs);

    final list = <TrainedCoffeeClassModel>[];
    for (final entry in existingMap.values) {
      try {
        if (entry is Map<String, dynamic>) {
          list.add(TrainedCoffeeClassModel.fromJson(entry));
        } else if (entry is Map) {
          list.add(TrainedCoffeeClassModel.fromJson(Map<String, dynamic>.from(entry)));
        }
      } catch (e) {
        debugPrint('Error parsing trained coffee model: $e');
      }
    }

    // Urutkan dari yang paling baru dilatih
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Mengambil model berdasarkan slug kelas (misal: `fugol_arabica_gayo_natural`).
  static Future<TrainedCoffeeClassModel?> getModelBySlug(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final existingMap = await _loadRawMap(prefs);
    final raw = existingMap[slug];
    if (raw == null) return null;

    try {
      if (raw is Map<String, dynamic>) {
        return TrainedCoffeeClassModel.fromJson(raw);
      } else if (raw is Map) {
        return TrainedCoffeeClassModel.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return null;
  }

  /// Menghapus model kelas lokal.
  static Future<void> deleteModel(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final existingMap = await _loadRawMap(prefs);
    if (existingMap.containsKey(slug)) {
      existingMap.remove(slug);
      await prefs.setString(_storageKey, json.encode(existingMap));
      changeNotifier.value++;
    }
  }

  static Future<Map<String, dynamic>> _loadRawMap(SharedPreferences prefs) async {
    final rawStr = prefs.getString(_storageKey);
    if (rawStr == null || rawStr.isEmpty) return {};
    try {
      final decoded = json.decode(rawStr);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  /// Sinkronisasi bobot model ke server backend secara senyap di background
  static void _syncToBackendSilently(TrainedCoffeeClassModel model) {
    Future.microtask(() async {
      try {
        final baseUrl = await AuthService.getBaseUrl();
        final uri = Uri.parse('$baseUrl/api/v1/beans/transfer-learning/register');
        final metadata = model.coffeeMetadata;

        final body = json.encode({
          'class_slug': model.classSlug,
          'roastery_name': metadata['roastery_name'] ?? metadata['brand'] ?? 'Artisan Roastery',
          'bean_name': metadata['bean_name'] ?? model.displayTitle,
          'varietal': metadata['varietal'],
          'process': metadata['process'],
          'tasting_notes': metadata['tasting_notes'],
          'altitude_masl': metadata['altitude_masl'],
          'recommended_recipe_id': metadata['recommended_recipe_id'],
          'weights_vector': model.weightsVector960,
          'sub_centroids': model.subCentroids,
          'cosine_threshold': model.cosineThreshold,
          'augmented_samples_count': model.augmentedSampleCount,
          'validation_accuracy': model.validationAccuracy,
        });

        await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Silent transfer learning cloud sync note: $e');
      }
    });
  }
}
