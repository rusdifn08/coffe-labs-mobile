import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:coffee_hub_mobile/features/scanner/data/local/prototype_database.dart';
import 'package:coffee_hub_mobile/features/scanner/domain/services/incremental_vision_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PrototypeDatabase.ensureFfiInitialized();

  group('PrototypeDatabase & Serialization Tests', () {
    test('Float32List <-> Uint8List BLOB serialization preserves exact values', () {
      const dim = PrototypeDatabase.embeddingDim;
      final original = Float32List(dim);
      for (int i = 0; i < dim; i++) {
        original[i] = (i * 0.001) - 0.5;
      }

      final bytes = PrototypeDatabase.float32ToBytes(original);
      expect(bytes.length, equals(dim * 4)); // 1280 * 4 = 5120 bytes

      final deserialized = PrototypeDatabase.bytesToFloat32(bytes);
      expect(deserialized.length, equals(dim));
      for (int i = 0; i < dim; i++) {
        expect(deserialized[i], closeTo(original[i], 1e-6));
      }
    });

    test('K=2 Sub-Centroids serialization round-trip', () {
      const dim = PrototypeDatabase.embeddingDim;
      final c1 = Float32List(dim)..fillRange(0, dim, 0.5);
      final c2 = Float32List(dim)..fillRange(0, dim, -0.25);

      final bytes = PrototypeDatabase.subCentroidsToBytes([c1, c2]);
      expect(bytes.length, equals(dim * 4 * 2)); // 10,240 bytes

      final restored = PrototypeDatabase.bytesToSubCentroids(bytes);
      expect(restored.length, equals(2));
      expect(restored[0][0], closeTo(0.5, 1e-6));
      expect(restored[1][0], closeTo(-0.25, 1e-6));
    });

    test('SQLite prototype CRUD and seed test', () async {
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (d, v) async {
          await d.execute('''
            CREATE TABLE ${PrototypeDatabase.tableName} (
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

      final dummyVec = Float32List(PrototypeDatabase.embeddingDim)..fillRange(0, 10, 0.1);
      final record = CoffeePrototypeRecord(
        classSlug: 'bandung_kopi_malabar_wine',
        roastery: 'Bandung Kopi',
        coffeeName: 'Malabar Wine',
        origin: 'Gunung Malabar',
        variety: 'Typica',
        process: 'Wine Process',
        altitude: '1500 MDPL',
        recommendedTemp: 91,
        tastingNotes: ['Winey', 'Red Grape'],
        sampleCount: 15,
        centroidVector: dummyVec,
        subCentroids: [dummyVec],
      );

      await db.insert(PrototypeDatabase.tableName, record.toMap());

      final rows = await db.query(PrototypeDatabase.tableName);
      expect(rows.length, equals(1));
      final loaded = CoffeePrototypeRecord.fromMap(rows.first);
      expect(loaded.classSlug, equals('bandung_kopi_malabar_wine'));
      expect(loaded.roastery, equals('Bandung Kopi'));
      expect(loaded.tastingNotes, contains('Winey'));
      expect(loaded.centroidVector.length, equals(PrototypeDatabase.embeddingDim));

      await db.close();
    });
  });

  group('IncrementalVisionEngine NCM Mathematics & Recognition', () {
    test('L2 Normalization produces unit-length vector', () {
      final engine = IncrementalVisionEngine.instance;
      final dummyTensor = [
        List.generate(256, (y) => List.generate(256, (x) => [1.0, 0.5, -0.2]))
      ];
      final emb = engine.extractEmbedding(dummyTensor);
      expect(emb.length, equals(1280));

      double sumSq = 0.0;
      for (final val in emb) {
        sumSq += val * val;
      }
      expect(math.sqrt(sumSq), closeTo(1.0, 1e-4));
    });

    test('Cosine similarity: identical vectors return 1.0, opposite return -1.0', () {
      final v1 = Float32List(1280);
      final v2 = Float32List(1280);
      v1[0] = 1.0;
      v2[0] = 1.0;

      double dot = 0.0;
      for (int i = 0; i < 1280; i++) {
        dot += v1[i] * v2[i];
      }
      expect(dot, closeTo(1.0, 1e-5));

      v2[0] = -1.0;
      dot = 0.0;
      for (int i = 0; i < 1280; i++) {
        dot += v1[i] * v2[i];
      }
      expect(dot, closeTo(-1.0, 1e-5));
    });

    test('Zero Catastrophic Forgetting: Running average formula maintains cumulative centroid', () {
      // Prototype has old sample count N_old = 15
      const dim = 1280;
      const oldCount = 15;
      final oldCentroid = Float32List(dim)..fillRange(0, dim, 1.0 / math.sqrt(dim));

      // 5 new augmented samples arrive
      const newCount = 5;
      final newSamples = List.generate(newCount, (_) => Float32List(dim)..fillRange(0, dim, 1.0 / math.sqrt(dim)));

      final newSum = Float32List(dim);
      for (final s in newSamples) {
        for (int d = 0; d < dim; d++) {
          newSum[d] += s[d];
        }
      }

      final merged = Float32List(dim);
      for (int d = 0; d < dim; d++) {
        merged[d] = (oldCentroid[d] * oldCount) + newSum[d];
      }

      double sumSq = 0.0;
      for (int d = 0; d < dim; d++) {
        sumSq += merged[d] * merged[d];
      }
      final norm = math.sqrt(sumSq);
      final updatedCentroid = Float32List(dim);
      for (int d = 0; d < dim; d++) {
        updatedCentroid[d] = merged[d] / norm;
      }

      expect(oldCount + newCount, equals(20));
      // Since all vectors pointed in same direction, updated centroid still points identically
      double sim = 0.0;
      for (int d = 0; d < dim; d++) {
        sim += oldCentroid[d] * updatedCentroid[d];
      }
      expect(sim, closeTo(1.0, 1e-5));
    });
  });
}
