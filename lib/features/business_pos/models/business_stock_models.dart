import 'package:flutter/material.dart';

enum StockCategory {
  beans,
  dairy,
  syrup,
  packaging,
  other;

  String get label {
    switch (this) {
      case StockCategory.beans:
        return 'Biji Kopi';
      case StockCategory.dairy:
        return 'Susu & Dairy';
      case StockCategory.syrup:
        return 'Sirup & Rasa';
      case StockCategory.packaging:
        return 'Packaging & Cup';
      case StockCategory.other:
        return 'Bahan Lain';
    }
  }

  IconData get icon {
    switch (this) {
      case StockCategory.beans:
        return Icons.coffee_rounded;
      case StockCategory.dairy:
        return Icons.local_drink_rounded;
      case StockCategory.syrup:
        return Icons.liquor_rounded;
      case StockCategory.packaging:
        return Icons.takeout_dining_rounded;
      case StockCategory.other:
        return Icons.inventory_2_rounded;
    }
  }
}

enum StockStatus {
  safe,
  low,
  outOfStock;

  String get label {
    switch (this) {
      case StockStatus.safe:
        return 'Aman';
      case StockStatus.low:
        return 'Menipis';
      case StockStatus.outOfStock:
        return 'Habis';
    }
  }

  Color get color {
    switch (this) {
      case StockStatus.safe:
        return const Color(0xFF10B981);
      case StockStatus.low:
        return const Color(0xFFF59E0B);
      case StockStatus.outOfStock:
        return const Color(0xFFEF4444);
    }
  }
}

class StockItem {
  final String id;
  final String name;
  final StockCategory category;
  final double currentQty;
  final double minQty;
  final String unit; // 'g', 'ml', 'pcs', 'lembar'
  final int costPerUnit; // Rupiah
  final String supplier;
  final double usagePerServing; // misal 18g kopi / cup, 150ml susu / cup
  final DateTime lastUpdated;
  final String notes;

  const StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentQty,
    required this.minQty,
    required this.unit,
    this.costPerUnit = 0,
    this.supplier = 'Roastery Partner',
    this.usagePerServing = 18.0,
    required this.lastUpdated,
    this.notes = '',
  });

  StockStatus get status {
    if (currentQty <= 0) return StockStatus.outOfStock;
    if (currentQty <= minQty) return StockStatus.low;
    return StockStatus.safe;
  }

  /// Perkiraan cangkir / porsi minuman yang masih bisa disajikan dari bahan ini
  int get estimatedServingsRemaining {
    if (usagePerServing <= 0 || currentQty <= 0) return 0;
    return (currentQty / usagePerServing).floor();
  }

  double get stockPercentage {
    if (minQty <= 0) return 1.0;
    final ratio = currentQty / (minQty * 2.5);
    return ratio.clamp(0.0, 1.0);
  }

  String get formattedQty {
    if (currentQty == currentQty.roundToDouble()) {
      return '${currentQty.toInt()} $unit';
    }
    return '${currentQty.toStringAsFixed(1)} $unit';
  }

  StockItem copyWith({
    String? name,
    StockCategory? category,
    double? currentQty,
    double? minQty,
    String? unit,
    int? costPerUnit,
    String? supplier,
    double? usagePerServing,
    DateTime? lastUpdated,
    String? notes,
  }) {
    return StockItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentQty: currentQty ?? this.currentQty,
      minQty: minQty ?? this.minQty,
      unit: unit ?? this.unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplier: supplier ?? this.supplier,
      usagePerServing: usagePerServing ?? this.usagePerServing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'currentQty': currentQty,
      'minQty': minQty,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'supplier': supplier,
      'usagePerServing': usagePerServing,
      'lastUpdated': lastUpdated.toIso8601String(),
      'notes': notes,
    };
  }

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: StockCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => StockCategory.other,
      ),
      currentQty: (json['currentQty'] as num?)?.toDouble() ?? 0.0,
      minQty: (json['minQty'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'g',
      costPerUnit: (json['costPerUnit'] as num?)?.toInt() ?? 0,
      supplier: json['supplier']?.toString() ?? 'Coffee Labs Partner',
      usagePerServing: (json['usagePerServing'] as num?)?.toDouble() ?? 18.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes']?.toString() ?? '',
    );
  }
}

class StockMovementLog {
  final String id;
  final String stockItemId;
  final String itemName;
  final double deltaQty;
  final String unit;
  final String actionType; // 'Restock', 'Pemakaian', 'Waste/Tumpah', 'Penyesuaian'
  final String barista;
  final DateTime timestamp;
  final String note;

  const StockMovementLog({
    required this.id,
    required this.stockItemId,
    required this.itemName,
    required this.deltaQty,
    required this.unit,
    required this.actionType,
    required this.barista,
    required this.timestamp,
    required this.note,
  });

  bool get isAddition => deltaQty > 0;

  String get formattedDelta {
    final prefix = deltaQty > 0 ? '+' : '';
    if (deltaQty == deltaQty.roundToDouble()) {
      return '$prefix${deltaQty.toInt()} $unit';
    }
    return '$prefix${deltaQty.toStringAsFixed(1)} $unit';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockItemId': stockItemId,
      'itemName': itemName,
      'deltaQty': deltaQty,
      'unit': unit,
      'actionType': actionType,
      'barista': barista,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory StockMovementLog.fromJson(Map<String, dynamic> json) {
    return StockMovementLog(
      id: json['id']?.toString() ?? '',
      stockItemId: json['stockItemId']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      deltaQty: (json['deltaQty'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'g',
      actionType: json['actionType']?.toString() ?? 'Penyesuaian',
      barista: json['barista']?.toString() ?? 'Barista Utama',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: json['note']?.toString() ?? '',
    );
  }
}
