import 'dart:math' as math;

enum ScaleBrand {
  timemore,
  coffeeLabsC3,
  acaia,
  felicita,
  bookoo,
  generic,
}

enum ScaleBrewMode {
  pourOver,
  espresso,
  general,
}

extension ScaleBrewModeX on ScaleBrewMode {
  String label({required bool isEn}) {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return 'Pour-Over';
      case ScaleBrewMode.espresso:
        return 'Espresso';
      case ScaleBrewMode.general:
        return isEn ? 'General' : 'Umum';
    }
  }

  String subtitle({required bool isEn}) {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return isEn
            ? 'Flow curve, bloom & ratio guidance'
            : 'Kurva debit, bloom & panduan rasio';
      case ScaleBrewMode.espresso:
        return isEn
            ? 'Yield tracker, shot timer & g/s curve'
            : 'Target yield, shot timer & kurva g/s';
      case ScaleBrewMode.general:
        return isEn
            ? '0.1g precision weighing & stopwatch'
            : 'Timbang presisi 0.1g & stopwatch';
    }
  }

  double get defaultDoseGrams {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return 15.0;
      case ScaleBrewMode.espresso:
        return 18.0;
      case ScaleBrewMode.general:
        return 15.0;
    }
  }

  double get defaultRatio {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return 15.0;
      case ScaleBrewMode.espresso:
        return 2.0;
      case ScaleBrewMode.general:
        return 15.0;
    }
  }

  double get idealFlowMin {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return 2.8;
      case ScaleBrewMode.espresso:
        return 1.0;
      case ScaleBrewMode.general:
        return 1.0;
    }
  }

  double get idealFlowMax {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return 5.5;
      case ScaleBrewMode.espresso:
        return 2.5;
      case ScaleBrewMode.general:
        return 6.0;
    }
  }

  String get storageKey {
    switch (this) {
      case ScaleBrewMode.pourOver:
        return 'pour_over';
      case ScaleBrewMode.espresso:
        return 'espresso';
      case ScaleBrewMode.general:
        return 'general';
    }
  }

  static ScaleBrewMode fromStorageKey(String? raw) {
    switch (raw) {
      case 'espresso':
        return ScaleBrewMode.espresso;
      case 'general':
        return ScaleBrewMode.general;
      case 'pour_over':
      default:
        return ScaleBrewMode.pourOver;
    }
  }
}

class SmartScaleDevice {
  final String id;
  final String name;
  final int rssi;
  final ScaleBrand brand;
  final bool isConnected;

  const SmartScaleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.brand,
    this.isConnected = false,
  });

  SmartScaleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    ScaleBrand? brand,
    bool? isConnected,
  }) {
    return SmartScaleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      brand: brand ?? this.brand,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  String get brandLabel {
    switch (brand) {
      case ScaleBrand.timemore:
        return 'TIMEMORE (Black Mirror Dot / Nano / Basic)';
      case ScaleBrand.coffeeLabsC3:
        return 'Coffee Labs Scale C3 • BLE 5.2';
      case ScaleBrand.acaia:
        return 'Acaia (Pearl / Lunar / Pyxis)';
      case ScaleBrand.felicita:
        return 'Felicita (Arc / Incline / Parallel)';
      case ScaleBrand.bookoo:
        return 'Bookoo (Themis Mini Scale)';
      case ScaleBrand.generic:
        return 'Bluetooth 5.2 Weight Scale (BLE)';
    }
  }

  String get shortBrand {
    switch (brand) {
      case ScaleBrand.timemore:
        return 'TIMEMORE';
      case ScaleBrand.coffeeLabsC3:
        return 'COFFEE LABS C3';
      case ScaleBrand.acaia:
        return 'ACAIA';
      case ScaleBrand.felicita:
        return 'FELICITA';
      case ScaleBrand.bookoo:
        return 'BOOKOO';
      case ScaleBrand.generic:
        return 'BLE SCALE';
    }
  }

  String get signalLabel {
    if (rssi >= -60) return 'Sangat Kuat';
    if (rssi >= -75) return 'Stabil';
    return 'Cukup';
  }
}

class ScaleReading {
  final double weightGrams;
  final double flowRateGramsPerSec;
  final bool isStable;
  final DateTime timestamp;
  final int? batteryPercent;
  final int? scaleTimerSeconds;

  const ScaleReading({
    required this.weightGrams,
    required this.flowRateGramsPerSec,
    required this.isStable,
    required this.timestamp,
    this.batteryPercent,
    this.scaleTimerSeconds,
  });

  factory ScaleReading.zero() {
    return ScaleReading(
      weightGrams: 0.0,
      flowRateGramsPerSec: 0.0,
      isStable: true,
      timestamp: DateTime.now(),
      batteryPercent: null,
      scaleTimerSeconds: 0,
    );
  }
}

class WeightDataPoint {
  final double elapsedSeconds;
  final double weight;
  final double flowRate;

  const WeightDataPoint({
    required this.elapsedSeconds,
    required this.weight,
    required this.flowRate,
  });

  Map<String, dynamic> toJson() => {
        't': double.parse(elapsedSeconds.toStringAsFixed(1)),
        'w': double.parse(weight.toStringAsFixed(1)),
        'f': double.parse(flowRate.toStringAsFixed(2)),
      };

  factory WeightDataPoint.fromJson(Map<String, dynamic> json) {
    return WeightDataPoint(
      elapsedSeconds: (json['t'] as num?)?.toDouble() ?? 0.0,
      weight: (json['w'] as num?)?.toDouble() ?? 0.0,
      flowRate: (json['f'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Complete telemetry snapshot of a real BLE scale brewing session.
class ScaleBrewLog {
  final String id;
  final DateTime createdAt;
  final ScaleBrewMode mode;
  final String recipeTitle;
  final String methodName;
  final String deviceName;
  final double coffeeDoseGrams;
  final double targetWaterGrams;
  final double finalWeightGrams;
  final int durationSeconds;
  final double avgFlowRate;
  final double peakFlowRate;
  final List<WeightDataPoint> points;
  final String? notes;

  const ScaleBrewLog({
    required this.id,
    required this.createdAt,
    required this.mode,
    required this.recipeTitle,
    required this.methodName,
    required this.deviceName,
    required this.coffeeDoseGrams,
    required this.targetWaterGrams,
    required this.finalWeightGrams,
    required this.durationSeconds,
    required this.avgFlowRate,
    required this.peakFlowRate,
    required this.points,
    this.notes,
  });

  double get actualRatio =>
      coffeeDoseGrams > 0 ? finalWeightGrams / coffeeDoseGrams : 0.0;

  double get yieldPercent => targetWaterGrams > 0
      ? ((finalWeightGrams / targetWaterGrams) * 100.0).clamp(0.0, 200.0)
      : 0.0;

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Build clean telemetry summary ready to post to Social Coffee or share externally.
  String toCommunitySummary({required bool isEn}) {
    final modeText = mode.label(isEn: isEn);
    final yieldLabel = mode == ScaleBrewMode.espresso
        ? (isEn ? 'Espresso Yield' : 'Yield Espresso')
        : (isEn ? 'Total Water' : 'Total Air');
    return isEn
        ? '☕ Smart Scale Brew Log — $recipeTitle ($modeText)\n'
            '• Scale: $deviceName\n'
            '• Dose: ${coffeeDoseGrams.toStringAsFixed(1)} g | $yieldLabel: ${finalWeightGrams.toStringAsFixed(1)} g (1:${actualRatio.toStringAsFixed(1)})\n'
            '• Brew Time: $formattedDuration | Avg Flow: ${avgFlowRate.toStringAsFixed(1)} g/s (Peak ${peakFlowRate.toStringAsFixed(1)} g/s)\n'
            '${notes != null && notes!.trim().isNotEmpty ? '• Notes: ${notes!.trim()}\n' : ''}'
            '#CoffeeLabs #SmartScale #BrewCurve'
        : '☕ Log Kurva Seduhan Smart Scale — $recipeTitle ($modeText)\n'
            '• Timbangan: $deviceName\n'
            '• Dosis: ${coffeeDoseGrams.toStringAsFixed(1)} g | $yieldLabel: ${finalWeightGrams.toStringAsFixed(1)} g (1:${actualRatio.toStringAsFixed(1)})\n'
            '• Waktu Seduh: $formattedDuration | Debit Rata-rata: ${avgFlowRate.toStringAsFixed(1)} g/s (Puncak ${peakFlowRate.toStringAsFixed(1)} g/s)\n'
            '${notes != null && notes!.trim().isNotEmpty ? '• Catatan: ${notes!.trim()}\n' : ''}'
            '#CoffeeLabs #SmartScale #KurvaSeduh';
  }

  /// Build recipe snapshot compatible with `SocialService.createPost` so other baristas can copy it.
  Map<String, dynamic> toSocialRecipeSnapshot() {
    final int safeDose = math.max(1, coffeeDoseGrams.round());
    final int safeWater = math.max(1, finalWeightGrams.round());
    final int safeDuration = math.max(15, durationSeconds);
    return {
      'title': recipeTitle,
      'method': methodName,
      'category': mode == ScaleBrewMode.espresso ? 'Espresso' : 'V60',
      'coffeeWeightGrams': safeDose,
      'totalWaterWeightGrams': safeWater,
      'totalTimeSeconds': safeDuration,
      'waterTempCelsius': mode == ScaleBrewMode.espresso ? 93 : 92,
      'grindSize': mode == ScaleBrewMode.espresso ? 'Fine' : 'Medium-Fine',
      'description':
          'Direkam via $deviceName • Debit rata-rata ${avgFlowRate.toStringAsFixed(1)} g/s • Puncak ${peakFlowRate.toStringAsFixed(1)} g/s',
      'scaleTelemetry': {
        'deviceName': deviceName,
        'mode': mode.storageKey,
        'avgFlowRate': double.parse(avgFlowRate.toStringAsFixed(2)),
        'peakFlowRate': double.parse(peakFlowRate.toStringAsFixed(2)),
        'actualRatio': double.parse(actualRatio.toStringAsFixed(2)),
        'points': points.take(60).map((e) => e.toJson()).toList(),
      },
      'steps': [
        {
          'stepOrder': 1,
          'title': mode == ScaleBrewMode.espresso ? 'Ekstraksi Shot' : 'Ekstraksi Kurva Smart Scale',
          'durationSeconds': safeDuration,
          'waterAddedGrams': safeWater,
          'instruction':
              'Target ${finalWeightGrams.toStringAsFixed(1)}g dalam $formattedDuration dengan laju rata-rata ${avgFlowRate.toStringAsFixed(1)} g/s.',
        },
      ],
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'mode': mode.storageKey,
        'recipeTitle': recipeTitle,
        'methodName': methodName,
        'deviceName': deviceName,
        'coffeeDoseGrams': coffeeDoseGrams,
        'targetWaterGrams': targetWaterGrams,
        'finalWeightGrams': finalWeightGrams,
        'durationSeconds': durationSeconds,
        'avgFlowRate': avgFlowRate,
        'peakFlowRate': peakFlowRate,
        'points': points.map((p) => p.toJson()).toList(),
        'notes': notes,
      };

  factory ScaleBrewLog.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    final parsedPoints = <WeightDataPoint>[];
    if (rawPoints is List) {
      for (final item in rawPoints) {
        if (item is Map) {
          parsedPoints.add(
            WeightDataPoint.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return ScaleBrewLog(
      id: (json['id'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      mode: ScaleBrewModeX.fromStorageKey(json['mode']?.toString()),
      recipeTitle: (json['recipeTitle'] ?? 'Sesi Seduh').toString(),
      methodName: (json['methodName'] ?? 'Manual Brew').toString(),
      deviceName: (json['deviceName'] ?? 'BLE Smart Scale').toString(),
      coffeeDoseGrams: (json['coffeeDoseGrams'] as num?)?.toDouble() ?? 15.0,
      targetWaterGrams: (json['targetWaterGrams'] as num?)?.toDouble() ?? 225.0,
      finalWeightGrams: (json['finalWeightGrams'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      avgFlowRate: (json['avgFlowRate'] as num?)?.toDouble() ?? 0.0,
      peakFlowRate: (json['peakFlowRate'] as num?)?.toDouble() ?? 0.0,
      points: parsedPoints,
      notes: json['notes']?.toString(),
    );
  }
}

/// Hardware compatibility catalog shown in the BLE scanner sheet.
class SupportedScaleHardware {
  final String name;
  final String protocol;
  final ScaleBrand brand;
  final bool isUpcoming;
  final String badgeText;

  const SupportedScaleHardware({
    required this.name,
    required this.protocol,
    required this.brand,
    this.isUpcoming = false,
    required this.badgeText,
  });

  static const List<SupportedScaleHardware> catalog = [
    SupportedScaleHardware(
      name: 'TIMEMORE Black Mirror Dot / Nano / Basic',
      protocol: 'Bluetooth 5.2 • 0.1g Real-Time Flow',
      brand: ScaleBrand.timemore,
      badgeText: 'SIAP',
    ),
    SupportedScaleHardware(
      name: 'Coffee Labs Scale C3',
      protocol: 'Coffee Labs Native BLE 5.2 • Auto-Sync',
      brand: ScaleBrand.coffeeLabsC3,
      isUpcoming: true,
      badgeText: 'SEGERA HADIR',
    ),
    SupportedScaleHardware(
      name: 'Acaia Pearl / Lunar / Pyxis',
      protocol: 'Acaia BLE Protocol • Tare & Timer',
      brand: ScaleBrand.acaia,
      badgeText: 'SIAP',
    ),
    SupportedScaleHardware(
      name: 'Felicita Arc / Incline & Bookoo Themis',
      protocol: 'BLE Smart Scale • Standard 0x181D / 0xFFE0',
      brand: ScaleBrand.felicita,
      badgeText: 'SIAP',
    ),
  ];
}
