import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:ml_linalg/vector.dart';
import '../../bean_scanner/services/cognitive_bean_analyzer.dart';
import '../domain/trained_coffee_class_model.dart';
import 'augmentation_pipeline_isolate.dart';
import 'visual_bag_embedder.dart';

/// Hasil pelatihan transfer learning On-Device
class TransferLearningTrainingResult {
  final String classSlug;
  final List<double> weightsVector;
  final List<List<double>> subCentroids;
  final double cosineThreshold;
  final double validationAccuracy;
  final int epochsRun;
  final Duration elapsed;

  const TransferLearningTrainingResult({
    required this.classSlug,
    required this.weightsVector,
    required this.subCentroids,
    required this.cosineThreshold,
    required this.validationAccuracy,
    required this.epochsRun,
    required this.elapsed,
  });
}

/// Telemetri progres epoch pelatihan untuk UI modal
class TrainingTelemetry {
  final int epoch;
  final int totalEpochs;
  final double currentLoss;
  final double currentAccuracy;

  const TrainingTelemetry({
    required this.epoch,
    required this.totalEpochs,
    required this.currentLoss,
    required this.currentAccuracy,
  });
}

/// Engine On-Device Transfer Learning:
/// 1. Embedding visual 512-D deterministik (VisualBagEmbedder, dihitung di isolate augmentasi).
/// 2. Pelatihan Cosine-Margin Classifier Head dengan AdamW Optimizer selama 60 Epochs.
class OnDeviceTransferLearner {
  static const int featureDim = VisualBagEmbedder.dim;

  /// Stage 0 scanner: cosine visual minimum untuk dianggap kemasan yang sama.
  static const double visualMatchThreshold = 0.80;

  /// Melatih Head Adaptif untuk Kelas Kopi Baru menggunakan 30 sampel hasil augmentasi 10x.
  static Future<TransferLearningTrainingResult> trainNewClass({
    required String classSlug,
    required List<AugmentedImageTensor> augmentedSamples,
    List<TrainedCoffeeClassModel> existingModels = const [],
    void Function(TrainingTelemetry)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 1. Embedding L2-normalized (30 citra -> [30 x 512]) sudah dihitung di isolate augmentasi
    final embeddings = <Vector>[];
    final sampleMapByAngle = <String, List<Vector>>{};

    for (final sample in augmentedSamples) {
      if (sample.embedding.length != featureDim) continue;
      final vec = Vector.fromList(sample.embedding);
      embeddings.add(vec);

      sampleMapByAngle.putIfAbsent(sample.sampleId, () => []).add(vec);
    }

    if (embeddings.isEmpty) {
      throw StateError('Tidak ada sampel augmentasi valid untuk pelatihan.');
    }

    // 2. Inisialisasi Prototipe Rata-rata dan K=3 Sub-Centroids (Depan, Kiri, Kanan)
    final meanVec = _computeCentroid(embeddings);
    final subCentroids = <List<double>>[];
    for (final entry in sampleMapByAngle.entries) {
      final angleCentroid = _computeCentroid(entry.value);
      subCentroids.add(angleCentroid.toList());
    }

    // Sub-centroid ekstra: prototipe rata-rata seluruh augmentasi (dipakai saat matching)
    subCentroids.insert(0, meanVec.toList());

    // 3. Bank Sampel Negatif (Model yang sudah pernah dilatih sebelumnya + synthetic negatives)
    final negativeVectors = <Vector>[];
    for (final m in existingModels) {
      if (m.classSlug != classSlug && m.weightsVector.length == featureDim) {
        negativeVectors.add(Vector.fromList(m.weightsVector));
      }
    }
    // Tambahkan synthetic orthogonal negatives agar margin terkalibrasi meskipun ini kelas pertama
    while (negativeVectors.length < 8) {
      negativeVectors.add(_generateSyntheticNegative(meanVec, seed: negativeVectors.length + 1));
    }

    // 4. On-Device AdamW Optimization (60 Epochs dengan Additive Angular Margin)
    const int totalEpochs = 60;
    const double lr = 0.01;
    const double weightDecay = 1e-4;
    const double beta1 = 0.9;
    const double beta2 = 0.999;
    const double eps = 1e-8;
    const double scale = 30.0;
    const double margin = 0.25;

    // Bobot kelas yang dilatih: w_c (dimensi 960)
    final wData = Float32List.fromList(meanVec.toList());
    final mMoments = Float32List(featureDim);
    final vMoments = Float32List(featureDim);

    double finalAcc = 0.98;

    for (int epoch = 1; epoch <= totalEpochs; epoch++) {
      final gradAcc = Float32List(featureDim);
      double epochLoss = 0.0;
      int correctPredictions = 0;

      final currentWeightVec = Vector.fromList(wData);

      // Hitung gradien terhadap seluruh 45 sampel positif
      for (final z in embeddings) {
        // Cosine similarity positif
        final posCos = currentWeightVec.dot(z);
        final marginCos = posCos - margin;
        final posExp = math.exp((scale * marginCos).clamp(-20.0, 20.0));

        // Cosine similarity negatif terhadap bank kelas lain
        double negSumExp = 0.0;
        double maxNegCos = -1.0;
        for (final negW in negativeVectors) {
          final negCos = negW.dot(z);
          if (negCos > maxNegCos) maxNegCos = negCos;
          negSumExp += math.exp((scale * negCos).clamp(-20.0, 20.0));
        }

        final denom = posExp + negSumExp;
        final pProb = (posExp / denom).clamp(1e-7, 1.0 - 1e-7);
        final sampleLoss = -math.log(pProb);
        epochLoss += sampleLoss;

        if (posCos > maxNegCos) {
          correctPredictions++;
        }

        // Turunan loss terhadap w_c: (p - 1) * scale * z
        final factor = (pProb - 1.0) * scale;
        for (int d = 0; d < featureDim; d++) {
          gradAcc[d] += (factor * z[d]).toDouble();
        }
      }

      final nSamples = embeddings.length.toDouble();
      epochLoss /= nSamples;
      final currentAcc = (correctPredictions / embeddings.length).clamp(0.0, 1.0);
      finalAcc = currentAcc;

      // Update bobot AdamW
      for (int d = 0; d < featureDim; d++) {
        final g = (gradAcc[d] / nSamples) + (weightDecay * wData[d]);
        mMoments[d] = beta1 * mMoments[d] + (1.0 - beta1) * g;
        vMoments[d] = beta2 * vMoments[d] + (1.0 - beta2) * g * g;

        final mHat = mMoments[d] / (1.0 - math.pow(beta1, epoch));
        final vHat = vMoments[d] / (1.0 - math.pow(beta2, epoch));

        wData[d] -= (lr * mHat / (math.sqrt(vHat) + eps)).toDouble();
      }

      // Normalisasi L2 ke unit sphere setiap epoch
      _l2NormalizeArray(wData);

      // Kirim telemetri setiap interval epoch
      if (epoch % 5 == 0 || epoch == totalEpochs) {
        onProgress?.call(TrainingTelemetry(
          epoch: epoch,
          totalEpochs: totalEpochs,
          currentLoss: epochLoss,
          currentAccuracy: currentAcc,
        ));
      }
    }

    // 5. Hitung Ambang Batas Cosine Threshold (tau_c) pada Persentil ke-5
    final finalW = Vector.fromList(wData);
    final positiveScores = embeddings.map((z) => finalW.dot(z)).toList()..sort();
    final p5Index = (positiveScores.length * 0.05).floor().clamp(0, positiveScores.length - 1);
    final calculatedThreshold = (positiveScores[p5Index] - 0.03).clamp(0.68, 0.88);

    stopwatch.stop();

    return TransferLearningTrainingResult(
      classSlug: classSlug,
      weightsVector: wData.toList(),
      subCentroids: subCentroids,
      cosineThreshold: calculatedThreshold,
      validationAccuracy: finalAcc,
      epochsRun: totalEpochs,
      elapsed: stopwatch.elapsed,
    );
  }

  /// Token OCR khas kemasan (tanpa kata generik) untuk sidik jari teks model terlatih.
  static List<String> ocrSignatureTokens(String text) {
    final seen = <String>{};
    for (final raw in text.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
      if (raw.length < 3 || RegExp(r'^\d+$').hasMatch(raw) || _ocrStopTokens.contains(raw)) continue;
      seen.add(raw);
      if (seen.length >= 24) break;
    }
    return seen.toList();
  }

  /// Fraksi token model yang ditemukan (fuzzy, toleran typo OCR) di teks hasil scan.
  static ({double score, int matched}) ocrOverlap(List<String> modelTokens, String scanText) {
    if (modelTokens.isEmpty) return (score: 0.0, matched: 0);
    final scanTokens = ocrSignatureTokens(scanText);
    int matched = 0;
    for (final t in modelTokens) {
      if (scanTokens.any((s) => s == t || CognitiveBeanAnalyzer.jaroWinkler(s, t) >= 0.9)) matched++;
    }
    return (score: matched / modelTokens.length, matched: matched);
  }

  /// STAGE 0: cocokkan foto scan (beberapa crop) + teks OCR ke seluruh model lokal.
  /// Embedding dihitung di background isolate agar decode foto 12MP tidak membuat UI patah.
  static Future<TrainedCoffeeMatch?> matchImage({
    required List<String> imagePaths,
    required List<TrainedCoffeeClassModel> models,
    String ocrText = '',
  }) async {
    if (models.isEmpty) return null;
    final queries = await Isolate.run(
      () => imagePaths.map(VisualBagEmbedder.embedFile).whereType<Float32List>().toList(),
    );
    return matchEmbeddings(queries: queries, models: models, ocrText: ocrText);
  }

  /// Logika skor Stage 0 (dipisah agar bisa diuji tanpa file/isolate).
  static TrainedCoffeeMatch? matchEmbeddings({
    required List<Float32List> queries,
    required List<TrainedCoffeeClassModel> models,
    String ocrText = '',
  }) {
    TrainedCoffeeMatch? best;
    for (final model in models) {
      double visual = -1.0;
      final prototypes = [model.weightsVector, ...model.subCentroids];
      for (final q in queries) {
        for (final p in prototypes) {
          if (p.length != q.length) continue; // model lama (960-D) dilewati, perlu dilatih ulang
          visual = math.max(visual, VisualBagEmbedder.cosine(p, q));
        }
      }

      final ocr = ocrOverlap(model.ocrSignatureTokens, ocrText);
      final isMatch = visual >= visualMatchThreshold ||
          (ocr.score >= 0.5 && ocr.matched >= 2 && visual >= 0.60) ||
          (ocr.score >= 0.75 && ocr.matched >= 2);
      final fused = math.max(visual, ocr.score);

      final candidate = TrainedCoffeeMatch(
        model: model,
        similarityScore: fused,
        visualScore: visual,
        ocrScore: ocr.score,
        isAboveThreshold: isMatch,
      );
      if (best == null ||
          (candidate.isAboveThreshold && !best.isAboveThreshold) ||
          (candidate.isAboveThreshold == best.isAboveThreshold && fused > best.similarityScore)) {
        best = candidate;
      }
    }
    return best;
  }

  static const Set<String> _ocrStopTokens = {
    'kopi', 'coffee', 'bean', 'beans', 'roastery', 'roasters', 'roaster', 'roasted', 'roast',
    'roasting', 'arabica', 'arabika', 'robusta', 'fresh', 'better', 'brew', 'date', 'net',
    'netto', 'weight', 'gram', 'grams', 'the', 'and', 'for', 'dari', 'untuk', 'dan', 'yang',
    'premium', 'quality', 'specialty', 'single', 'origin', 'whole', 'biji', 'bubuk', 'halal',
    'best', 'before', 'exp', 'process', 'proses', 'indonesia', 'pirt', 'berat', 'bersih',
  };

  // --- Helper Matematika Tensor ---

  static Vector _computeCentroid(List<Vector> vectors) {
    final sum = Float32List(featureDim);
    for (final v in vectors) {
      for (int i = 0; i < featureDim; i++) {
        sum[i] += v[i];
      }
    }
    final n = vectors.length.toDouble();
    for (int i = 0; i < featureDim; i++) {
      sum[i] /= n;
    }
    _l2NormalizeArray(sum);
    return Vector.fromList(sum);
  }

  static Vector _generateSyntheticNegative(Vector posCentroid, {required int seed}) {
    final rng = math.Random(seed);
    final arr = Float32List(featureDim);
    for (int i = 0; i < featureDim; i++) {
      arr[i] = (rng.nextDouble() - 0.5);
    }
    // Gram-Schmidt orthogonalization terhadap centroid positif
    final randVec = Vector.fromList(arr);
    final proj = posCentroid * randVec.dot(posCentroid);
    final ortho = randVec - proj;
    final outList = ortho.toList();
    final outArr = Float32List.fromList(outList);
    _l2NormalizeArray(outArr);
    return Vector.fromList(outArr);
  }

  static void _l2NormalizeArray(Float32List arr) {
    double sumSq = 0.0;
    for (int i = 0; i < arr.length; i++) {
      sumSq += arr[i] * arr[i];
    }
    final norm = math.sqrt(sumSq);
    if (norm > 1e-12) {
      for (int i = 0; i < arr.length; i++) {
        arr[i] = (arr[i] / norm).toDouble();
      }
    }
  }
}

/// Hasil evaluasi Stage 0 (visual + OCR) terhadap model terlatih
class TrainedCoffeeMatch {
  final TrainedCoffeeClassModel model;
  final double similarityScore; // max(visual, ocr)
  final double visualScore;
  final double ocrScore;
  final bool isAboveThreshold;

  const TrainedCoffeeMatch({
    required this.model,
    required this.similarityScore,
    this.visualScore = 0.0,
    this.ocrScore = 0.0,
    required this.isAboveThreshold,
  });
}
