import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Coffee Prototype Record for Class-Incremental Continual Learning
class CoffeePrototypeRecord {
  final int? id;
  final String classSlug;
  final String roastery;
  final String coffeeName;
  final String origin;
  final String variety;
  final String process;
  final String altitude;
  final int recommendedTemp;
  final List<String> tastingNotes;
  final int sampleCount;
  final Float32List centroidVector; // 1280-D unit norm
  final List<Float32List> subCentroids; // K=2 sub-prototypes (front & angled views)
  final DateTime updatedAt;

  CoffeePrototypeRecord({
    this.id,
    required this.classSlug,
    required this.roastery,
    required this.coffeeName,
    required this.origin,
    required this.variety,
    required this.process,
    required this.altitude,
    this.recommendedTemp = 90,
    required this.tastingNotes,
    required this.sampleCount,
    required this.centroidVector,
    this.subCentroids = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'class_slug': classSlug,
      'roastery': roastery,
      'coffee_name': coffeeName,
      'origin': origin,
      'variety': variety,
      'process': process,
      'altitude': altitude,
      'recommended_temp': recommendedTemp,
      'tasting_notes_json': json.encode(tastingNotes),
      'sample_count': sampleCount,
      'centroid_blob': PrototypeDatabase.float32ToBytes(centroidVector),
      'sub_centroids_blob': PrototypeDatabase.subCentroidsToBytes(subCentroids),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CoffeePrototypeRecord.fromMap(Map<String, dynamic> map) {
    List<String> notes = [];
    try {
      final rawNotes = map['tasting_notes_json'];
      if (rawNotes is String) {
        final decoded = json.decode(rawNotes);
        if (decoded is List) {
          notes = decoded.map((e) => e.toString()).toList();
        }
      } else if (rawNotes is List) {
        notes = rawNotes.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    final centroidBytes = map['centroid_blob'] as Uint8List;
    final centroid = PrototypeDatabase.bytesToFloat32(centroidBytes);

    final subCentroidsBytes = map['sub_centroids_blob'] as Uint8List?;
    final subCentroids = subCentroidsBytes != null
        ? PrototypeDatabase.bytesToSubCentroids(subCentroidsBytes)
        : <Float32List>[];

    return CoffeePrototypeRecord(
      id: map['id'] as int?,
      classSlug: map['class_slug'] as String,
      roastery: map['roastery'] as String,
      coffeeName: map['coffee_name'] as String,
      origin: map['origin'] as String,
      variety: map['variety'] as String,
      process: map['process'] as String,
      altitude: map['altitude'] as String,
      recommendedTemp: (map['recommended_temp'] as num?)?.toInt() ?? 90,
      tastingNotes: notes,
      sampleCount: (map['sample_count'] as num?)?.toInt() ?? 1,
      centroidVector: centroid,
      subCentroids: subCentroids,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  CoffeePrototypeRecord copyWith({
    int? id,
    String? classSlug,
    String? roastery,
    String? coffeeName,
    String? origin,
    String? variety,
    String? process,
    String? altitude,
    int? recommendedTemp,
    List<String>? tastingNotes,
    int? sampleCount,
    Float32List? centroidVector,
    List<Float32List>? subCentroids,
    DateTime? updatedAt,
  }) {
    return CoffeePrototypeRecord(
      id: id ?? this.id,
      classSlug: classSlug ?? this.classSlug,
      roastery: roastery ?? this.roastery,
      coffeeName: coffeeName ?? this.coffeeName,
      origin: origin ?? this.origin,
      variety: variety ?? this.variety,
      process: process ?? this.process,
      altitude: altitude ?? this.altitude,
      recommendedTemp: recommendedTemp ?? this.recommendedTemp,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      sampleCount: sampleCount ?? this.sampleCount,
      centroidVector: centroidVector ?? this.centroidVector,
      subCentroids: subCentroids ?? this.subCentroids,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PrototypeDatabase {
  static const String tableName = 'coffee_class_prototypes';
  static const String dbName = 'coffee_prototypes.db';
  static const int embeddingDim = 1280;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static bool _ffiInitialized = false;

  /// Ensures SQLite FFI is initialized once safely on desktop platforms
  static void ensureFfiInitialized() {
    if (kIsWeb) return;
    if (_ffiInitialized) return;
    _ffiInitialized = true;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      try {
        if (databaseFactory != databaseFactoryFfi) {
          databaseFactory = databaseFactoryFfi;
        }
      } catch (_) {
        databaseFactory = databaseFactoryFfi;
      }
    }
  }

  static Future<Database> _initDatabase() async {
    // Platform guard: Desktop Windows/Linux/macOS or tests require sqflite_common_ffi
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not supported on web.');
    }
    ensureFfiInitialized();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_slug TEXT UNIQUE NOT NULL,
            roastery TEXT NOT NULL,
            coffee_name TEXT NOT NULL,
            origin TEXT NOT NULL,
            variety TEXT NOT NULL,
            process TEXT NOT NULL,
            altitude TEXT NOT NULL,
            recommended_temp INTEGER NOT NULL DEFAULT 90,
            tasting_notes_json TEXT NOT NULL,
            sample_count INTEGER NOT NULL,
            centroid_blob BLOB NOT NULL,
            sub_centroids_blob BLOB,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Serialization Utilities ---

  /// Serializes Float32List (1280 floats = 5120 bytes) to Uint8List BLOB
  static Uint8List float32ToBytes(Float32List vector) {
    return vector.buffer.asUint8List(vector.offsetInBytes, vector.lengthInBytes);
  }

  /// Deserializes Uint8List BLOB to Float32List (1280 floats)
  static Float32List bytesToFloat32(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    final count = bytes.lengthInBytes ~/ 4;
    final result = Float32List(count);
    for (int i = 0; i < count; i++) {
      result[i] = byteData.getFloat32(i * 4, Endian.host);
    }
    return result;
  }

  /// Serializes K=2 sub-centroids (2 * 5120 = 10,240 bytes)
  static Uint8List subCentroidsToBytes(List<Float32List> subCentroids) {
    final builder = BytesBuilder(copy: false);
    for (final vec in subCentroids) {
      builder.add(float32ToBytes(vec));
    }
    return builder.toBytes();
  }

  /// Deserializes K=2 sub-centroids
  static List<Float32List> bytesToSubCentroids(Uint8List bytes) {
    final subCentroids = <Float32List>[];
    const bytesPerVector = embeddingDim * 4;
    final totalVectors = bytes.length ~/ bytesPerVector;
    for (int i = 0; i < totalVectors; i++) {
      final slice = bytes.sublist(i * bytesPerVector, (i + 1) * bytesPerVector);
      subCentroids.add(bytesToFloat32(slice));
    }
    return subCentroids;
  }

  // --- CRUD & Seed Operations ---

  /// Seed initial starter classes from assets/data/initial_classes.json if table is empty
  static Future<void> seedInitialClassesIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName')) ?? 0;
    if (count > 0) return;

    try {
      final jsonStr = await rootBundle.loadString('assets/data/initial_classes.json');
      final list = json.decode(jsonStr) as List;

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          // Generate deterministic seed prototype vector (1280-D unit norm)
          final seedVector = _generateSeedVector(item['class_slug']?.toString() ?? 'seed');
          final record = CoffeePrototypeRecord(
            classSlug: item['class_slug']?.toString() ?? 'unknown_coffee',
            roastery: item['roastery']?.toString() ?? 'Specialty Roastery',
            coffeeName: item['coffee_name']?.toString() ?? 'Specialty Coffee',
            origin: item['origin']?.toString() ?? 'Single Origin, Indonesia',
            variety: item['variety']?.toString() ?? 'Arabica Specialty',
            process: item['process']?.toString() ?? 'Natural',
            altitude: item['altitude']?.toString() ?? '1400 - 1800 MDPL',
            recommendedTemp: (item['recommended_temp'] as num?)?.toInt() ?? 90,
            tastingNotes: (item['tasting_notes'] as List?)?.map((e) => e.toString()).toList() ?? ['Floral', 'Fruity'],
            sampleCount: (item['sample_count'] as num?)?.toInt() ?? 15,
            centroidVector: seedVector,
            subCentroids: [seedVector, seedVector],
          );
          await upsertPrototype(record);
        }
      }
      debugPrint('PrototypeDatabase: Successfully seeded initial starter prototypes.');
    } catch (e) {
      debugPrint('PrototypeDatabase: Seed error ($e)');
    }
  }

  static Float32List _generateSeedVector(String seedKey) {
    final vec = Float32List(embeddingDim);
    int hash = seedKey.codeUnits.fold(0x811c9dc5, (acc, c) => ((acc ^ c) * 0x01000193) & 0xFFFFFFFF);
    for (int i = 0; i < embeddingDim; i++) {
      hash = ((hash ^ (i * 31)) * 1664525 + 1013904223) & 0x7FFFFFFF;
      final val = ((hash % 2000) - 1000) / 1000.0;
      vec[i] = val;
    }
    // Strict L2 normalization
    final l2Norm = _l2Norm(vec);
    for (int i = 0; i < embeddingDim; i++) {
      vec[i] = (vec[i] / (l2Norm > 1e-12 ? l2Norm : 1.0));
    }
    return vec;
  }

  static double _l2Norm(Float32List v) {
    double sum = 0.0;
    for (int i = 0; i < v.length; i++) {
      sum += v[i] * v[i];
    }
    final norm = math.sqrt(sum);
    return norm > 1e-12 ? norm : 1.0;
  }

  /// Loads all stored coffee prototype records from SQLite
  static Future<List<CoffeePrototypeRecord>> loadAllPrototypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: 'updated_at DESC');
    return maps.map((m) => CoffeePrototypeRecord.fromMap(m)).toList();
  }

  /// Inserts or updates a coffee prototype class in SQLite
  static Future<void> upsertPrototype(CoffeePrototypeRecord record) async {
    final db = await database;
    await db.insert(
      tableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves prototype by slug
  static Future<CoffeePrototypeRecord?> getPrototypeBySlug(String classSlug) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'class_slug = ?',
      whereArgs: [classSlug],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CoffeePrototypeRecord.fromMap(maps.first);
  }

  /// Deletes prototype by slug
  static Future<void> deletePrototype(String classSlug) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'class_slug = ?',
      whereArgs: [classSlug],
    );
  }

  /// Closes database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
