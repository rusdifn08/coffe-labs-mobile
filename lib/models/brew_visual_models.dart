import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DripperVisualItem {
  final String name;
  final String shortName;
  final String subtitle;
  final String defaultCategory;
  final String shapeType; // v60, iced_v60, switch, origami, flat, aeropress, frenchpress, clever, chemex, pulsar, phin
  final Color color;

  const DripperVisualItem({
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.defaultCategory,
    required this.shapeType,
    required this.color,
  });
}

class BeanVisualItem {
  final String name;
  final String region;
  final String defaultVariety;
  final String process;
  final String roast;
  final List<String> defaultNotes;
  final Color color;
  final String emoji;

  const BeanVisualItem({
    required this.name,
    required this.region,
    this.defaultVariety = 'Arabica',
    required this.process,
    required this.roast,
    required this.defaultNotes,
    required this.color,
    required this.emoji,
  });
}

class FlavorNoteVisualItem {
  final String label;
  final String group;
  final String emoji;
  final Color color;

  const FlavorNoteVisualItem({
    required this.label,
    required this.group,
    required this.emoji,
    required this.color,
  });
}

class GrinderModel {
  final String id;
  final String name;
  final String brand;
  final String typeDescription;
  final String imagePath;
  final bool isElectric;
  final int minClicks;
  final int maxClicks;
  final int defaultClicks;
  final double micronsPerClick;
  final int fineClick;
  final int medFineClick;
  final int mediumClick;
  final int medCoarseClick;
  final int coarseClick;

  const GrinderModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.typeDescription,
    required this.imagePath,
    this.isElectric = false,
    required this.minClicks,
    required this.maxClicks,
    required this.defaultClicks,
    required this.micronsPerClick,
    required this.fineClick,
    required this.medFineClick,
    required this.mediumClick,
    required this.medCoarseClick,
    required this.coarseClick,
  });

  int getClicksForPreset(String preset) {
    switch (preset.toLowerCase()) {
      case 'fine':
        return fineClick;
      case 'medium-fine':
      case 'med-fine':
        return medFineClick;
      case 'medium':
        return mediumClick;
      case 'medium-coarse':
      case 'med-coarse':
        return medCoarseClick;
      case 'coarse':
        return coarseClick;
      default:
        return mediumClick;
    }
  }

  String estimateMicrons(int clicks) {
    final um = (clicks * micronsPerClick).round();
    return '$um µm';
  }
}

