import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import '../models/resolved_coffee_bean.dart';
import 'cognitive_bean_analyzer.dart';

class BeanScannerApiService {
  static Future<ResolvedCoffeeBean> resolveBean({
    required String rawFullText,
    required List<Map<String, dynamic>> blocks,
    required String croppedImagePath,
  }) async {
    // 1. First run instant on-device Cognitive AI Analysis
    final localCognitiveBean = CognitiveBeanAnalyzer.analyze(
      rawFullText: rawFullText,
      blocksDto: blocks,
      localImagePath: croppedImagePath,
    );

    try {
      final baseUrl = await AuthService.getBaseUrl();
      final token = await AuthService.getToken();
      final uri = Uri.parse('$baseUrl/api/v1/beans/scan-resolve');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final payload = {
        'raw_full_text': rawFullText.trim(),
        'blocks': blocks,
      };

      final res = await http.post(
        uri,
        headers: headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = json.decode(res.body);
        final data = body['data'] as Map<String, dynamic>;
        var serverResolved = ResolvedCoffeeBean.fromJson(data, localImagePath: croppedImagePath);

        // GROUND TRUTH RULE: The physical scanned bag is the Ground Truth!
        // Never let generic backend catalog rows overwrite explicit or non-generic OCR features!
        if (localCognitiveBean.notesSource == 'OCR_EXPLICIT') {
          serverResolved = serverResolved.copyWith(
            tastingNotes: localCognitiveBean.tastingNotes,
            notesSource: 'OCR_EXPLICIT',
          );
        }

        // Preserve local bean name if local found a specific product name
        if (localCognitiveBean.beanName.isNotEmpty &&
            !localCognitiveBean.beanName.toLowerCase().startsWith('specialty coffee') &&
            !localCognitiveBean.beanName.toLowerCase().startsWith('roastery washed')) {
          serverResolved = serverResolved.copyWith(
            beanName: localCognitiveBean.beanName,
          );
        }

        // Preserve local roastery if local found a specific roastery / brand / farmer
        if (localCognitiveBean.roasteryName.isNotEmpty &&
            localCognitiveBean.roasteryName != 'Specialty Roastery' &&
            !localCognitiveBean.roasteryName.toLowerCase().startsWith('specialty coffee')) {
          serverResolved = serverResolved.copyWith(
            roasteryName: localCognitiveBean.roasteryName,
          );
        }

        // Preserve local process if local detected specific process (Natural, Anaerobic, Wine, Honey)
        if (localCognitiveBean.process != 'Full Washed' || rawFullText.toLowerCase().contains('washed')) {
          serverResolved = serverResolved.copyWith(
            process: localCognitiveBean.process,
          );
        }

        // Preserve local origin if specific
        if (localCognitiveBean.origin != 'Single Origin, Indonesia') {
          serverResolved = serverResolved.copyWith(
            origin: localCognitiveBean.origin,
          );
        }

        // Preserve local variety if specific
        if (!localCognitiveBean.isAiInferredVariety) {
          serverResolved = serverResolved.copyWith(
            variety: localCognitiveBean.variety,
            isAiInferredVariety: false,
          );
        }

        // Preserve local altitude if specific
        if (!localCognitiveBean.isAiInferredAltitude) {
          serverResolved = serverResolved.copyWith(
            altitudeMasl: localCognitiveBean.altitudeMasl,
            isAiInferredAltitude: false,
          );
        }

        // If server response didn't include classified blocks, preserve client-side bounding boxes
        if (serverResolved.classifiedBlocks.isEmpty && localCognitiveBean.classifiedBlocks.isNotEmpty) {
          return serverResolved.copyWith(classifiedBlocks: localCognitiveBean.classifiedBlocks);
        }
        return serverResolved;
      }
    } catch (e) {
      debugPrint('Error resolving bean with backend, using Cognitive on-device AI: $e');
    }

    // High-intelligence offline/on-device fallback:
    return localCognitiveBean;
  }
}
