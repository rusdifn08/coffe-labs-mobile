import '../data/barista_catalog.dart';
import '../utils/barista_utils.dart';

class RecipeSanitizer {
  static int toInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  static num toNum(dynamic value, num fallback) {
    if (value == null) return fallback;
    if (value is num) return value;
    return num.tryParse(value.toString().trim()) ?? fallback;
  }

  static String nonEmptyString(dynamic value, String fallback) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  static String offlineAssetOrPath(dynamic value) {
    final s = value?.toString().trim() ?? '';
    if (s.isEmpty || s.startsWith('http')) {
      return 'assets/images/avatars/generic_fallback.jpg';
    }
    return s;
  }

  /// Menjamin tidak ada satupun field resep atau step yang bernilai null.
  static Map<String, dynamic> sanitizeRecipe(Map<dynamic, dynamic> raw, {int fallbackId = 1}) {
    final id = toInt(raw['id'], fallbackId);
    final title = nonEmptyString(raw['title'], 'Custom Brew Recipe');
    final author = nonEmptyString(raw['author'], 'Barista');
    var category = nonEmptyString(raw['category'], 'V60');
    if (category == 'V60 Pour Over') category = 'V60';
    if (category == 'Japanese Iced') category = 'Japanese';

    final method = nonEmptyString(raw['method'], category);
    final beanName = nonEmptyString(raw['beanName'], 'Specialty Single Origin');
    final grindSize = nonEmptyString(raw['grindSize'], 'Medium (22 Klik Comandante)');
    final waterTempCelsius = toInt(raw['waterTempCelsius'], 92);
    final coffeeWeightGrams = toNum(raw['coffeeWeightGrams'], 15);
    final iceWeightGrams = toInt(
      raw['iceWeightGrams'],
      category.toLowerCase().contains('iced') ? 90 : 0,
    );

    final rawSteps = raw['steps'];
    final List<Map<String, dynamic>> sanitizedSteps = [];
    int sumDuration = 0;
    int sumWater = 0;

    if (rawSteps is List && rawSteps.isNotEmpty) {
      for (int i = 0; i < rawSteps.length; i++) {
        final s = rawSteps[i];
        if (s is Map) {
          final stepTitle = nonEmptyString(s['title'], 'Step ${i + 1}');
          final duration = toInt(s['durationSeconds'] ?? s['timeSeconds'], 30);
          final waterAdded = toInt(s['waterAddedGrams'] ?? s['waterGrams'], 0);
          sumDuration += duration;
          sumWater += waterAdded;

          String defaultInstruction;
          if (waterAdded > 0 && i == 0) {
            defaultInstruction =
                'Tuang ${waterAdded}g air ($waterTempCelsius°C) secara merata untuk fase blooming & degassing selama ${duration}s.';
          } else if (waterAdded > 0) {
            defaultInstruction =
                'Tuang ${waterAdded}g air secara spiral stabil hingga mencapai total ${sumWater}g pada timbangan dalam ${duration}s.';
          } else {
            defaultInstruction =
                'Tahan fase imersi / biarkan air terekstraksi dan mengalir turun (drawdown) selama ${duration}s.';
          }

          final instruction = nonEmptyString(s['instruction'], defaultInstruction);

          sanitizedSteps.add({
            'stepOrder': i + 1,
            'title': stepTitle,
            'durationSeconds': duration,
            'waterAddedGrams': waterAdded,
            'timeSeconds': duration,
            'waterGrams': waterAdded,
            'cumulativeWaterGrams': sumWater,
            'instruction': instruction,
          });
        }
      }
    }

    if (sanitizedSteps.isEmpty) {
      final fallbackWater = toInt(raw['totalWaterWeightGrams'], 225);
      final bloomWater = (fallbackWater * 0.2).round().clamp(30, 60);
      final mainWater = (fallbackWater - bloomWater).clamp(50, 500);
      sanitizedSteps.addAll([
        {
          'stepOrder': 1,
          'title': '1. Blooming',
          'durationSeconds': 35,
          'waterAddedGrams': bloomWater,
          'timeSeconds': 35,
          'waterGrams': bloomWater,
          'cumulativeWaterGrams': bloomWater,
          'instruction': 'Tuang ${bloomWater}g air secara merata dan goyangkan dripper lembut.',
        },
        {
          'stepOrder': 2,
          'title': '2. Main Pour',
          'durationSeconds': 95,
          'waterAddedGrams': mainWater,
          'timeSeconds': 95,
          'waterGrams': mainWater,
          'cumulativeWaterGrams': bloomWater + mainWater,
          'instruction': 'Tuang ${mainWater}g air secara spiral stabil hingga mencapai ${bloomWater + mainWater}g.',
        },
      ]);
      sumDuration = 130;
      sumWater = bloomWater + mainWater;
    }

    final rawTotalWater = toInt(raw['totalWaterWeightGrams'], 0);
    final totalWaterWeightGrams = rawTotalWater > 0 ? rawTotalWater : (sumWater > 0 ? sumWater : 225);

    final rawTotalTime = toInt(raw['totalTimeSeconds'], 0);
    final totalTimeSeconds = rawTotalTime > 0 ? rawTotalTime : (sumDuration > 0 ? sumDuration : 130);

    final authorProfile = BaristaCatalog.resolve(author, imageUrl: raw['authorAvatarUrl']?.toString());
    final catalogAvatar = authorProfile.imageAsset;

    String avatarUrl;
    if (raw['isCustom'] == true) {
      avatarUrl = offlineAssetOrPath(raw['authorAvatarUrl'] ?? raw['authorImageUrl']);
    } else if (catalogAvatar != null && !catalogAvatar.contains('generic_fallback')) {
      avatarUrl = catalogAvatar;
    } else {
      final candidate = (raw['authorAvatarUrl'] ?? raw['authorImageUrl'])?.toString();
      if (candidate != null &&
          !candidate.contains('avatar_') &&
          !candidate.contains('generic_fallback')) {
        avatarUrl = offlineAssetOrPath(candidate);
      } else {
        avatarUrl = 'assets/images/avatars/generic_fallback.jpg';
      }
    }

    final slug = BaristaUtils.slugFromAuthor(author);
    final catalogCover = BaristaCatalog.coverForSlug(slug);
    String coverUrl;
    if (raw['isCustom'] == true) {
      coverUrl = offlineAssetOrPath(raw['coverImageUrl'] ?? raw['authorImageUrl'] ?? avatarUrl);
    } else if (catalogCover != null) {
      coverUrl = catalogCover;
    } else {
      coverUrl = offlineAssetOrPath(raw['coverImageUrl'] ?? raw['authorImageUrl'] ?? avatarUrl);
    }

    return {
      'id': id,
      'title': title,
      'author': author,
      'coverImageUrl': coverUrl,
      'authorAvatarUrl': avatarUrl,
      'authorImageUrl': coverUrl,
      'beanName': beanName,
      'variety': nonEmptyString(raw['variety'] ?? raw['beanVariety'], 'Specialty Arabica'),
      'process': nonEmptyString(raw['process'] ?? raw['beanProcess'], ''),
      'roastLevel': nonEmptyString(raw['roastLevel'], 'Light-Medium'),
      'method': method,
      'category': category,
      'waterTempCelsius': waterTempCelsius,
      'grindSize': grindSize,
      'coffeeWeightGrams': coffeeWeightGrams,
      'totalWaterWeightGrams': totalWaterWeightGrams,
      'iceWeightGrams': iceWeightGrams,
      'waterPpm': nonEmptyString(raw['waterPpm'], '70-85 ppm'),
      'tastingNotes': nonEmptyString(raw['tastingNotes'], 'Balanced Sweetness, Clean Acidity, Aromatic Finish'),
      'totalTimeSeconds': totalTimeSeconds,
      'description': nonEmptyString(
        raw['description'],
        'Resep seduh profesional menggunakan $method pada suhu $waterTempCelsius°C dengan gilingan $grindSize.',
      ),
      'isCustom': raw['isCustom'] == true,
      'createdAt': nonEmptyString(raw['createdAt'], DateTime.now().toIso8601String()),
      'steps': sanitizedSteps,
    };
  }
}
