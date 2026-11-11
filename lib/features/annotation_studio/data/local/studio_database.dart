import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/coffee_annotation_class.dart';
import '../../domain/models/studio_image_item.dart';

/// Local SQLite Database for In-App Mobile Roboflow Annotation Studio
class StudioDatabase {
  static const String dbName = 'coffee_annotation_studio.db';
  static const String imagesTable = 'studio_images';
  static const String classesTable = 'coffee_classes';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not supported on web.');
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      if (databaseFactory != databaseFactoryFfi) {
        databaseFactory = databaseFactoryFfi;
      }
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $classesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_slug TEXT UNIQUE NOT NULL,
            display_name TEXT NOT NULL,
            color_hex TEXT NOT NULL,
            brand TEXT NOT NULL,
            coffee_name TEXT NOT NULL,
            process TEXT NOT NULL,
            image_count INTEGER NOT NULL DEFAULT 0,
            tasting_notes_json TEXT,
            origin TEXT,
            variety TEXT,
            altitude TEXT,
            recommended_temp INTEGER NOT NULL DEFAULT 91,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $imagesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path TEXT NOT NULL,
            status TEXT NOT NULL,
            is_rejected INTEGER NOT NULL DEFAULT 0,
            rejection_reason TEXT,
            class_slug TEXT,
            brand TEXT,
            coffee_name TEXT,
            process TEXT,
            polygon_json TEXT,
            bbox_json TEXT,
            ocr_lines_json TEXT,
            is_new_class INTEGER NOT NULL DEFAULT 1,
            confidence REAL NOT NULL DEFAULT 0.0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Seed & Import Operations ---

  /// Seed classes from assets/data/coffee.json if classesTable is empty
  static Future<int> seedInitialClassesIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $classesTable'),
        ) ??
        0;

    if (count > 0) return count;

    try {
      final jsonStr = await rootBundle.loadString('assets/data/coffee.json');
      return await importClassesFromJson(jsonStr);
    } catch (e) {
      debugPrint('Notice: Error seeding coffee.json: $e');
      return 0;
    }
  }

  /// Import classes from JSON string (array of objects)
  static Future<int> importClassesFromJson(String jsonString) async {
    final db = await database;
    final List decoded = json.decode(jsonString);
    int imported = 0;

    final batch = db.batch();
    for (final item in decoded) {
      if (item is Map<String, dynamic>) {
        final slug = item['class_slug']?.toString() ?? 'unknown_coffee';
        final notes = item['tasting_notes'] is List
            ? json.encode(item['tasting_notes'])
            : json.encode([]);

        batch.insert(
          classesTable,
          {
            'class_slug': slug,
            'display_name': item['display_name'] ?? slug.replaceAll('_', ' ').toUpperCase(),
            'color_hex': item['color_hex'] ?? '#6D28D9',
            'brand': item['brand'] ?? '',
            'coffee_name': item['coffee_name'] ?? '',
            'process': item['process'] ?? '',
            'image_count': 0,
            'tasting_notes_json': notes,
            'origin': item['origin'] ?? 'Indonesia',
            'variety': item['variety'] ?? 'Arabica Specialty',
            'altitude': item['altitude'] ?? '1400 MDPL',
            'recommended_temp': item['recommended_temp'] ?? 91,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        imported++;
      }
    }
    await batch.commit(noResult: true);
    return imported;
  }

  // --- Image CRUD Operations ---

  static Future<int> insertImage(StudioImageItem item) async {
    final db = await database;
    final id = await db.insert(imagesTable, item.toMap());
    await updateClassImageCounts();
    return id;
  }

  static Future<void> updateImage(StudioImageItem item) async {
    final db = await database;
    if (item.id != null) {
      await db.update(
        imagesTable,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      await updateClassImageCounts();
    }
  }

  static Future<void> deleteImage(int id) async {
    final db = await database;
    await db.delete(imagesTable, where: 'id = ?', whereArgs: [id]);
    await updateClassImageCounts();
  }

  static Future<int> deleteAllRejectedImages() async {
    final db = await database;
    final deleted = await db.delete(
      imagesTable,
      where: "is_rejected = 1 OR status = 'rejected_non_coffee'",
    );
    await updateClassImageCounts();
    return deleted;
  }

  static Future<void> markNullBackground(int id) async {
    final db = await database;
    await db.update(
      imagesTable,
      {
        'status': 'null_background',
        'is_rejected': 1,
        'rejection_reason': 'Ditandai sebagai latar belakang null',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<StudioImageItem>> getAllImages({String? filterTab}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (filterTab == 'unassigned') {
      maps = await db.query(
        imagesTable,
        where: "(status = 'unassigned' OR status = 'annotating') AND is_rejected = 0",
        orderBy: 'id DESC',
      );
    } else if (filterTab == 'annotated') {
      maps = await db.query(
        imagesTable,
        where: "status = 'annotated' AND is_rejected = 0",
        orderBy: 'id DESC',
      );
    } else if (filterTab == 'rejected') {
      maps = await db.query(
        imagesTable,
        where: "is_rejected = 1 OR status = 'rejected_non_coffee' OR status = 'null_background'",
        orderBy: 'id DESC',
      );
    } else {
      // All
      maps = await db.query(imagesTable, orderBy: 'id DESC');
    }

    return maps.map((m) => StudioImageItem.fromMap(m)).toList();
  }

  // --- Class CRUD Operations ---

  static Future<List<CoffeeAnnotationClass>> getAllClasses() async {
    final db = await database;
    final maps = await db.query(classesTable, orderBy: 'display_name ASC');
    return maps.map((m) => CoffeeAnnotationClass.fromMap(m)).toList();
  }

  static Future<CoffeeAnnotationClass?> getClassBySlug(String slug) async {
    final db = await database;
    final maps = await db.query(
      classesTable,
      where: 'class_slug = ?',
      whereArgs: [slug],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CoffeeAnnotationClass.fromMap(maps.first);
  }

  static Future<void> upsertClass(CoffeeAnnotationClass cls) async {
    final db = await database;
    await db.insert(
      classesTable,
      cls.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateClassImageCounts() async {
    final db = await database;
    final counts = await db.rawQuery('''
      SELECT class_slug, COUNT(*) as cnt 
      FROM $imagesTable 
      WHERE is_rejected = 0 AND class_slug IS NOT NULL AND status = 'annotated'
      GROUP BY class_slug
    ''');

    // Reset all to 0
    await db.rawUpdate('UPDATE $classesTable SET image_count = 0');

    // Set real counts
    for (final row in counts) {
      final slug = row['class_slug'] as String?;
      final cnt = (row['cnt'] as num?)?.toInt() ?? 0;
      if (slug != null) {
        await db.rawUpdate(
          'UPDATE $classesTable SET image_count = ? WHERE class_slug = ?',
          [cnt, slug],
        );
      }
    }
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(imagesTable);
    await db.delete(classesTable);
  }
}
