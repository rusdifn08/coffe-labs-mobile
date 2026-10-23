enum ScaleBrand {
  timemore,
  acaia,
  felicita,
  generic,
  simulated,
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
        return 'Timemore (Dot / Black Mirror)';
      case ScaleBrand.acaia:
        return 'Acaia (Pearl / Lunar)';
      case ScaleBrand.felicita:
        return 'Felicita (Arc / Incline)';
      case ScaleBrand.generic:
        return 'Standard BLE Scale';
      case ScaleBrand.simulated:
        return 'Virtual Smart Scale';
    }
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
      batteryPercent: 100,
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
}
