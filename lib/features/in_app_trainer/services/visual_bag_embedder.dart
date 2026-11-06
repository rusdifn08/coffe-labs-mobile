import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Deterministic offline 512-D visual fingerprint of a coffee bag crop.
///
/// Layout (each block Hellinger-normalized, zero-mean centered, L2-normalized, weighted):
/// - [0..255]   4x4 spatial grid HSV histograms (8 saturation-weighted hue + 4 sat + 4 val bins)
/// - [256..319] global hue(16) x value(4) histogram (saturation-weighted)
/// - [320..447] 4x4 spatial grid edge-orientation histograms (8 bins, HOG-like)
/// - [448..511] 64-bit perceptual difference hash (dHash) as +1/-1
///
/// Centering matters: raw histograms are non-negative, so two unrelated bags would
/// otherwise still score a high cosine similarity.
/// shortcut: no TFLite backbone (no model binary/dependency in the app), add MobileNet
/// embeddings as an extra block if a .tflite model is ever bundled.
class VisualBagEmbedder {
  static const int dim = 512;
  static const int size = 224;

  static Float32List embed(img.Image src) {
    final im = (src.width == size && src.height == size)
        ? src
        : img.copyResize(src, width: size, height: size, interpolation: img.Interpolation.linear);

    final gray = Float32List(size * size);
    final gridHsv = Float32List(256);
    final globalHv = Float32List(64);

    for (int y = 0; y < size; y++) {
      final cellRow = (y * 4) ~/ size;
      for (int x = 0; x < size; x++) {
        final p = im.getPixel(x, y);
        final r = p.r / 255.0, g = p.g / 255.0, b = p.b / 255.0;
        final mx = math.max(r, math.max(g, b));
        final mn = math.min(r, math.min(g, b));
        final delta = mx - mn;
        final s = mx <= 0 ? 0.0 : delta / mx;
        double h = 0.0;
        if (delta > 1e-6) {
          if (mx == r) {
            h = ((g - b) / delta) % 6.0;
          } else if (mx == g) {
            h = (b - r) / delta + 2.0;
          } else {
            h = (r - g) / delta + 4.0;
          }
          h /= 6.0;
          if (h < 0) h += 1.0;
        }
        gray[y * size + x] = 0.299 * r + 0.587 * g + 0.114 * b;

        final base = (cellRow * 4 + (x * 4) ~/ size) * 16;
        gridHsv[base + _bin(h, 8)] += s; // grey pixels carry no hue vote
        gridHsv[base + 8 + _bin(s, 4)] += 1;
        gridHsv[base + 12 + _bin(mx, 4)] += 1;
        globalHv[_bin(h, 16) * 4 + _bin(mx, 4)] += s;
      }
    }

    // Edge orientation histograms (unsigned gradient angle, magnitude weighted).
    final hog = Float32List(128);
    for (int y = 1; y < size - 1; y++) {
      final cellRow = (y * 4) ~/ size;
      for (int x = 1; x < size - 1; x++) {
        final gx = gray[y * size + x + 1] - gray[y * size + x - 1];
        final gy = gray[(y + 1) * size + x] - gray[(y - 1) * size + x];
        final mag = math.sqrt(gx * gx + gy * gy);
        if (mag < 1e-4) continue;
        var ang = math.atan2(gy, gx);
        if (ang < 0) ang += math.pi;
        hog[(cellRow * 4 + (x * 4) ~/ size) * 8 + _bin(ang / math.pi, 8)] += mag;
      }
    }

    // dHash on a 9x8 block-averaged grayscale thumbnail.
    final hash = Float32List(64);
    const cw = size / 9, ch = size / 8;
    final thumb = List.generate(8, (_) => List<double>.filled(9, 0));
    for (int y = 0; y < size; y++) {
      final ry = math.min(7, y ~/ ch);
      for (int x = 0; x < size; x++) {
        thumb[ry][math.min(8, x ~/ cw)] += gray[y * size + x];
      }
    }
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        hash[r * 8 + c] = thumb[r][c] > thumb[r][c + 1] ? 1.0 : -1.0;
      }
    }

    for (int cell = 0; cell < 16; cell++) {
      _hellingerCentered(gridHsv, cell * 16, 8);
      _hellingerCentered(gridHsv, cell * 16 + 8, 4);
      _hellingerCentered(gridHsv, cell * 16 + 12, 4);
      _hellingerCentered(hog, cell * 8, 8);
    }
    _hellingerCentered(globalHv, 0, 64);

    final out = Float32List(dim);
    _appendBlock(out, 0, gridHsv, 1.0);
    _appendBlock(out, 256, globalHv, 0.7);
    _appendBlock(out, 320, hog, 1.0);
    _appendBlock(out, 448, hash, 0.6);
    _l2(out);
    return out;
  }

  /// Decodes (EXIF-upright), resizes and embeds an image file. Null if undecodable.
  /// Top-level friendly: safe to call inside `Isolate.run`.
  static Float32List? embedFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return null;
    final decoded = img.decodeImage(file.readAsBytesSync());
    if (decoded == null) return null;
    return embed(img.bakeOrientation(decoded));
  }

  static double cosine(List<double> a, List<double> b) {
    if (a.length != b.length) return -1.0;
    double dot = 0, na = 0, nb = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na < 1e-12 || nb < 1e-12) return 0.0;
    return dot / math.sqrt(na * nb);
  }

  static int _bin(double v, int bins) => (v * bins).floor().clamp(0, bins - 1);

  static void _hellingerCentered(Float32List v, int start, int len) {
    double sum = 0;
    for (int i = start; i < start + len; i++) {
      sum += v[i];
    }
    if (sum <= 1e-12) {
      for (int i = start; i < start + len; i++) {
        v[i] = 0;
      }
      return;
    }
    double mean = 0;
    for (int i = start; i < start + len; i++) {
      v[i] = math.sqrt(v[i] / sum);
      mean += v[i];
    }
    mean /= len;
    for (int i = start; i < start + len; i++) {
      v[i] -= mean;
    }
  }

  static void _appendBlock(Float32List out, int offset, Float32List block, double weight) {
    double sq = 0;
    for (final v in block) {
      sq += v * v;
    }
    final norm = math.sqrt(sq);
    if (norm < 1e-12) return;
    for (int i = 0; i < block.length; i++) {
      out[offset + i] = block[i] / norm * weight;
    }
  }

  static void _l2(Float32List v) {
    double sq = 0;
    for (final x in v) {
      sq += x * x;
    }
    final n = math.sqrt(sq);
    if (n < 1e-12) return;
    for (int i = 0; i < v.length; i++) {
      v[i] /= n;
    }
  }
}
