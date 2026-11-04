import 'package:flutter/material.dart';

class WaterProfile {
  final String name;
  final String origin;
  final int ghPpm;
  final int khPpm;
  final String description;
  final int calciumDropsPerLiter;
  final int magnesiumDropsPerLiter;
  final int sodiumDropsPerLiter;
  final int potassiumDropsPerLiter;
  final double bakingSodaGramsPerLiter;
  final double epsomSaltGramsPerLiter;
  final Color accentColor;

  const WaterProfile({
    required this.name,
    required this.origin,
    required this.ghPpm,
    required this.khPpm,
    required this.description,
    required this.calciumDropsPerLiter,
    required this.magnesiumDropsPerLiter,
    required this.sodiumDropsPerLiter,
    required this.potassiumDropsPerLiter,
    required this.bakingSodaGramsPerLiter,
    required this.epsomSaltGramsPerLiter,
    required this.accentColor,
  });

  double get bufferRatio => khPpm > 0 ? (ghPpm / khPpm) : ghPpm.toDouble();

  String get sensoryDiagnosis {
    if (bufferRatio > 3.0) {
      return 'High Clarity & Bright Acidity: Buffer rendah memaksimalkan letupan asam buah sitrat/malat (Sempurna untuk Geisha & Light Washed).';
    }
    if (bufferRatio >= 1.6) {
      return 'Balanced Golden Cup: Keseimbangan optimal rasa manis alami, body sirup, dan keasaman bersih (All-rounder harian).';
    }
    return 'Heavy Buffer: Rasa asam tertahan lembut dengan body kental (Cocok untuk Natural fermentasi & Dark roast).';
  }
}
