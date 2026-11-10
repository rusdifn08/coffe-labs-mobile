import 'dart:convert';
import 'package:flutter/material.dart';

/// Class metadata for coffee packaging classes in the In-App Studio.
class CoffeeAnnotationClass {
  final int? id;
  final String classSlug; // canonical {brand}_{nama_kopi}_{proses}
  final String displayName;
  final String colorHex;
  final String brand;
  final String coffeeName;
  final String process;
  final int imageCount;
  final List<String> tastingNotes;
  final String origin;
  final String variety;
  final String altitude;
  final int recommendedTemp;
  final DateTime createdAt;

  const CoffeeAnnotationClass({
    this.id,
    required this.classSlug,
    required this.displayName,
    required this.colorHex,
    required this.brand,
    required this.coffeeName,
    required this.process,
    this.imageCount = 0,
    this.tastingNotes = const [],
    this.origin = 'Indonesia',
    this.variety = 'Arabica Specialty',
    this.altitude = '1400 MDPL',
    this.recommendedTemp = 91,
    required this.createdAt,
  });

  Color get color {
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF6D28D9); // Roboflow Purple fallback
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'class_slug': classSlug,
      'display_name': displayName,
      'color_hex': colorHex,
      'brand': brand,
      'coffee_name': coffeeName,
      'process': process,
      'image_count': imageCount,
      'tasting_notes_json': json.encode(tastingNotes),
      'origin': origin,
      'variety': variety,
      'altitude': altitude,
      'recommended_temp': recommendedTemp,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CoffeeAnnotationClass.fromMap(Map<String, dynamic> map) {
    List<String> notes = [];
    try {
      final rawNotes = map['tasting_notes_json'];
      if (rawNotes is String && rawNotes.isNotEmpty) {
        final decoded = json.decode(rawNotes);
        if (decoded is List) {
          notes = decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}

    return CoffeeAnnotationClass(
      id: map['id'] as int?,
      classSlug: map['class_slug'] as String,
      displayName: (map['display_name'] as String?) ?? map['class_slug'] as String,
      colorHex: (map['color_hex'] as String?) ?? '#6D28D9',
      brand: (map['brand'] as String?) ?? '',
      coffeeName: (map['coffee_name'] as String?) ?? '',
      process: (map['process'] as String?) ?? '',
      imageCount: (map['image_count'] as num?)?.toInt() ?? 0,
      tastingNotes: notes,
      origin: (map['origin'] as String?) ?? 'Indonesia',
      variety: (map['variety'] as String?) ?? 'Arabica Specialty',
      altitude: (map['altitude'] as String?) ?? '1400 MDPL',
      recommendedTemp: (map['recommended_temp'] as num?)?.toInt() ?? 91,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CoffeeAnnotationClass copyWith({
    int? id,
    String? classSlug,
    String? displayName,
    String? colorHex,
    String? brand,
    String? coffeeName,
    String? process,
    int? imageCount,
    List<String>? tastingNotes,
    String? origin,
    String? variety,
    String? altitude,
    int? recommendedTemp,
    DateTime? createdAt,
  }) {
    return CoffeeAnnotationClass(
      id: id ?? this.id,
      classSlug: classSlug ?? this.classSlug,
      displayName: displayName ?? this.displayName,
      colorHex: colorHex ?? this.colorHex,
      brand: brand ?? this.brand,
      coffeeName: coffeeName ?? this.coffeeName,
      process: process ?? this.process,
      imageCount: imageCount ?? this.imageCount,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      origin: origin ?? this.origin,
      variety: variety ?? this.variety,
      altitude: altitude ?? this.altitude,
      recommendedTemp: recommendedTemp ?? this.recommendedTemp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
