import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'receipt_settings_service.dart';

class ReceiptPrintService {
  ReceiptPrintService._();

  /// Menghasilkan session code unik untuk setiap seduhan / resep
  static String generateSessionCode(Map<String, dynamic> recipe) {
    final now = DateTime.now();
    final dayStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final idHash = (recipe['id']?.toString() ?? recipe['title']?.toString() ?? '01')
        .hashCode
        .abs()
        .toString()
        .padLeft(3, '0');
    final code = idHash.length > 3 ? idHash.substring(idHash.length - 3) : idHash;
    return '#CLB-$dayStr-$code';
  }

  /// Parsing langkah-langkah tuangan resep secara akurat
  /// Mendukung format waterAddedGrams, waterWeightGrams, waterGrams, dll.
  static List<Map<String, dynamic>> parseRecipeSteps(
    dynamic rawSteps, {
    int totalWater = 225,
    int coffeeWeight = 15,
  }) {
    List<dynamic> list = [];
    if (rawSteps is List) {
      list = rawSteps;
    } else if (rawSteps is String && rawSteps.trim().startsWith('[')) {
      try {
        list = json.decode(rawSteps) as List<dynamic>;
      } catch (_) {}
    }

    final parsed = <Map<String, dynamic>>[];
    int sumWater = 0;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is Map) {
        final dur = (item['durationSeconds'] ?? item['duration'] ?? item['time'] ?? 30) as num;
        final w = (item['waterAddedGrams'] ??
            item['waterWeightGrams'] ??
            item['waterGrams'] ??
            item['water'] ??
            0) as num;
        final rawTitle = (item['title'] ?? item['name'] ?? item['stepTitle'] ?? '').toString().trim();
        final title = rawTitle.isNotEmpty ? rawTitle : (i == 0 ? 'Blooming' : 'Tuang ${i + 1}');
        sumWater += w.toInt();
        parsed.add({
          'title': title,
          'durationSeconds': dur.toInt(),
          'water': w.toInt(),
        });
      }
    }

    if (parsed.isEmpty) {
      final bloomWater = (coffeeWeight * 3).clamp(30, 60);
      final mainPour = totalWater > bloomWater ? totalWater - bloomWater : totalWater;
      return [
        {'title': 'Blooming', 'durationSeconds': 45, 'water': bloomWater},
        {'title': 'Main Pour', 'durationSeconds': 105, 'water': mainPour},
      ];
    }

    // Jika semua step bernilai 0g namun totalWater > 0, hitung otomatis pembagian rasio tuangan
    if (sumWater == 0 && totalWater > 0) {
      final bloomWater = (coffeeWeight * 3).clamp(30, (totalWater * 0.35).toInt());
      parsed[0]['water'] = bloomWater;
      if (parsed.length > 1) {
        final remaining = totalWater - bloomWater;
        final perPour = remaining ~/ (parsed.length - 1);
        for (int i = 1; i < parsed.length; i++) {
          parsed[i]['water'] = (i == parsed.length - 1)
              ? (remaining - perPour * (parsed.length - 2))
              : perPour;
        }
      } else {
        parsed[0]['water'] = totalWater;
      }
    }

    return parsed;
  }

  /// Menghasilkan format teks struk kasir profesional (58mm / 32 kolom karakter)
  /// Bebas dari seluruh tanda kurung (...) dan memiliki header proporsional
  static String generateThermalReceiptText(
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
    ReceiptSettings? settings,
  }) {
    final s = settings ?? ReceiptSettingsService.settingsNotifier.value;
    final title = recipe['title']?.toString() ?? 'Specialty Brew';
    final author = s.baristaName.isNotEmpty
        ? s.baristaName
        : (recipe['author']?.toString() ?? 'Coffee Labs Barista');
    final method = recipe['method']?.toString() ?? 'V60 Pour Over';
    final coffeeWeight = recipe['coffeeWeightGrams'] ?? 15;
    final waterWeight = recipe['totalWaterWeightGrams'] ?? 225;
    final iceWeight = recipe['iceWeightGrams'] ?? 0;
    final grindSize = recipe['grindSize']?.toString() ?? 'Medium-Fine';
    final waterTemp = recipe['waterTempCelsius'] ?? 92;
    final notes = (tastingNotes != null && tastingNotes.isNotEmpty)
        ? tastingNotes.join(' | ')
        : (recipe['tastingNotes']?.toString() ?? 'Sweet, Balanced, Clean');
    final ratio = (waterWeight / (coffeeWeight > 0 ? coffeeWeight : 1)).toStringAsFixed(1);
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final sessionCode = generateSessionCode(recipe);

    const int colWidth = 32;
    final buffer = StringBuffer();

    // 1. HEADER TOKO PROPORSIONAL
    buffer.writeln('=' * colWidth);
    final icon = s.icon.isNotEmpty ? s.icon : '☕';
    final store = s.storeName.toUpperCase();
    final headerTitle = '$icon $store $icon';
    buffer.writeln(_centerText(headerTitle, colWidth));
    buffer.writeln(_centerText(s.tagline.toUpperCase(), colWidth));
    buffer.writeln('=' * colWidth);

    // 2. METADATA TRANSAKSI & RESEP (Tanpa tanda kurung)
    buffer.writeln(_twoColumn('Waktu', dateStr, colWidth));
    buffer.writeln(_twoColumn('No. Sesi', sessionCode, colWidth));
    buffer.writeln(_twoColumn('Barista', author, colWidth));
    buffer.writeln(_twoColumn('Resep', title, colWidth));
    buffer.writeln(_twoColumn('Metode', method, colWidth));
    buffer.writeln('-' * colWidth);

    // 3. PARAMETER SEDUH (Tanpa tanda kurung seperti Dose atau Yield)
    buffer.writeln('PARAMETER SEDUH:');
    buffer.writeln('  Dosis Kopi   : ${coffeeWeight}g');
    if (iceWeight > 0) {
      buffer.writeln('  Es Batu      : ${iceWeight}g');
      buffer.writeln('  Air Panas    : ${waterWeight}ml');
      buffer.writeln('  Total Yield  : ${waterWeight + iceWeight}g');
    } else {
      buffer.writeln('  Total Air    : ${waterWeight}ml');
    }
    buffer.writeln('  Rasio Seduh  : 1 : $ratio');
    buffer.writeln('  Ukuran Giling: $grindSize');
    buffer.writeln('  Suhu Air     : $waterTemp°C');
    buffer.writeln('-' * colWidth);

    // 4. TAHAPAN TUANGAN (Tanpa tanda kurung, menampilkan nama step dan gramasi)
    buffer.writeln('TAHAPAN TUANGAN:');
    final parsedSteps = parseRecipeSteps(
      recipe['steps'],
      totalWater: (waterWeight as num).toInt(),
      coffeeWeight: (coffeeWeight as num).toInt(),
    );
    int accumulatedWater = 0;
    int accumulatedTime = 0;
    for (int i = 0; i < parsedSteps.length; i++) {
      final step = parsedSteps[i];
      final dur = step['durationSeconds'] as int;
      final water = step['water'] as int;
      final stepTitle = step['title'] as String;
      accumulatedWater += water;
      final startSec = accumulatedTime;
      accumulatedTime += dur;
      final endSec = accumulatedTime;

      final startFormatted =
          '${(startSec ~/ 60).toString().padLeft(2, '0')}:${(startSec % 60).toString().padLeft(2, '0')}';
      final endFormatted =
          '${(endSec ~/ 60).toString().padLeft(2, '0')}:${(endSec % 60).toString().padLeft(2, '0')}';

      buffer.writeln('  ${i + 1}. $startFormatted-$endFormatted : +${water}g - Total ${accumulatedWater}g');
      buffer.writeln('     $stepTitle');
    }
    buffer.writeln('-' * colWidth);

    // 5. CATATAN RASA (Tanpa tanda kurung)
    buffer.writeln('CATATAN RASA:');
    buffer.writeln('  $notes');
    buffer.writeln('-' * colWidth);

    // 6. FOOTER SLOGAN & MEDIA SOSIAL
    buffer.writeln(_centerText(s.footerNote.toUpperCase(), colWidth));
    buffer.writeln(_centerText(s.subFooter, colWidth));
    if (s.socialHandle.isNotEmpty) {
      buffer.writeln(_centerText('IG: ${s.socialHandle}', colWidth));
    }
    buffer.writeln('=' * colWidth);
    buffer.writeln('\n\n');

    return buffer.toString();
  }

  /// Menghasilkan format raw ESC/POS bytes untuk printer kasir thermal Bluetooth
  static Uint8List generateEscPosBytes(
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
    ReceiptSettings? settings,
  }) {
    final s = settings ?? ReceiptSettingsService.settingsNotifier.value;
    final text = generateThermalReceiptText(recipe, tastingNotes: tastingNotes, settings: s);
    final List<int> bytes = [];

    // ESC @: Inisialisasi printer
    bytes.addAll([0x1B, 0x40]);
    // ESC a 1: Center align
    bytes.addAll([0x1B, 0x61, 0x01]);
    // ESC E 1: Bold on
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll(utf8.encode("${s.icon} ${s.storeName} ${s.icon}\n"));
    // ESC E 0: Bold off
    bytes.addAll([0x1B, 0x45, 0x00]);
    // ESC a 0: Left align
    bytes.addAll([0x1B, 0x61, 0x00]);

    // Encode isi struk
    bytes.addAll(latin1.encode(text));

    // Feed and cut paper (GS V 66 0)
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(bytes);
  }

  /// Menghasilkan dokumen PDF mini roll receipt (ukuran 58mm standar kasir, sangat ringan < 15KB)
  static Future<Uint8List> generateReceiptPdf(
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
    ReceiptSettings? settings,
  }) async {
    final s = settings ?? ReceiptSettingsService.settingsNotifier.value;
    final pdf = pw.Document();

    final title = recipe['title']?.toString() ?? 'Specialty Brew';
    final author = s.baristaName.isNotEmpty
        ? s.baristaName
        : (recipe['author']?.toString() ?? 'Coffee Labs Barista');
    final method = recipe['method']?.toString() ?? 'V60 Pour Over';
    final coffeeWeight = recipe['coffeeWeightGrams'] ?? 15;
    final waterWeight = recipe['totalWaterWeightGrams'] ?? 225;
    final iceWeight = recipe['iceWeightGrams'] ?? 0;
    final grindSize = recipe['grindSize']?.toString() ?? 'Medium-Fine';
    final waterTemp = recipe['waterTempCelsius'] ?? 92;
    final notes = (tastingNotes != null && tastingNotes.isNotEmpty)
        ? tastingNotes.join(', ')
        : (recipe['tastingNotes']?.toString() ?? 'Sweet, Balanced, Clean');
    final ratio = (waterWeight / (coffeeWeight > 0 ? coffeeWeight : 1)).toStringAsFixed(1);
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final sessionCode = generateSessionCode(recipe);

    final rollFormat = PdfPageFormat(
      58 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 3.5 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: rollFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // HEADER TOKO
              pw.Center(
                child: pw.Text(
                  s.storeName.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: pw.Font.courierBold(),
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Center(
                child: pw.Text(
                  s.tagline.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: pw.Font.courier(),
                    fontSize: 7.5,
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '==============================',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
              ),
              pw.SizedBox(height: 3),

              // METADATA
              _pwRow('Waktu', dateStr),
              _pwRow('No. Sesi', sessionCode),
              _pwRow('Barista', author),
              _pwRow('Resep', title),
              _pwRow('Metode', method),
              pw.SizedBox(height: 3),
              pw.Text(
                '------------------------------',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
              ),
              pw.SizedBox(height: 3),

              // PARAMETER SEDUH
              pw.Text(
                'PARAMETER SEDUH:',
                style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: 8),
              ),
              _pwRow('  Dosis Kopi', '${coffeeWeight}g'),
              if (iceWeight > 0) ...[
                _pwRow('  Es Batu', '${iceWeight}g'),
                _pwRow('  Air Panas', '${waterWeight}ml'),
              ] else ...[
                _pwRow('  Total Air', '${waterWeight}ml'),
              ],
              _pwRow('  Rasio Seduh', '1 : $ratio'),
              _pwRow('  Ukuran Giling', grindSize),
              _pwRow('  Suhu Air', '$waterTemp°C'),
              pw.SizedBox(height: 3),
              pw.Text(
                '------------------------------',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
              ),
              pw.SizedBox(height: 3),

              // TAHAPAN TUANGAN
              pw.Text(
                'TAHAPAN TUANGAN:',
                style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: 8),
              ),
              ...() {
                final parsedSteps = parseRecipeSteps(
                  recipe['steps'],
                  totalWater: (waterWeight as num).toInt(),
                  coffeeWeight: (coffeeWeight as num).toInt(),
                );
                int accWater = 0;
                int accTime = 0;
                final List<pw.Widget> stepWidgets = [];
                for (int i = 0; i < parsedSteps.length; i++) {
                  final step = parsedSteps[i];
                  final dur = step['durationSeconds'] as int;
                  final water = step['water'] as int;
                  final stepTitle = step['title'] as String;
                  accWater += water;
                  final startSec = accTime;
                  accTime += dur;
                  final endSec = accTime;
                  final sFmt =
                      '${(startSec ~/ 60).toString().padLeft(2, '0')}:${(startSec % 60).toString().padLeft(2, '0')}';
                  final eFmt =
                      '${(endSec ~/ 60).toString().padLeft(2, '0')}:${(endSec % 60).toString().padLeft(2, '0')}';

                  final label = water > 0
                      ? '+$water g - Tot $accWater g'
                      : 'Drawdown - Tot $accWater g';
                  stepWidgets.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('  ${i + 1}. $sFmt-$eFmt',
                                  style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: 7)),
                              pw.Text(label,
                                  style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7)),
                            ],
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 10),
                            child: pw.Text(stepTitle,
                                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 6.5)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return stepWidgets;
              }(),
              pw.SizedBox(height: 3),
              pw.Text(
                '------------------------------',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
              ),
              pw.SizedBox(height: 3),

              // CATATAN RASA
              pw.Text(
                'CATATAN RASA:',
                style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: 8),
              ),
              pw.Text(
                '  $notes',
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7.5),
              ),
              pw.SizedBox(height: 4),

              // BARCODE
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: sessionCode,
                  width: 120,
                  height: 24,
                  drawText: true,
                  textStyle: pw.TextStyle(font: pw.Font.courier(), fontSize: 6),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '==============================',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
              ),

              // FOOTER
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  s.footerNote,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: pw.Font.courierBold(), fontSize: 7.5),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  s.subFooter,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
                ),
              ),
              if (s.socialHandle.isNotEmpty) ...[
                pw.Center(
                  child: pw.Text(
                    'IG: ${s.socialHandle}',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: pw.Font.courier(), fontSize: 6.5),
                  ),
                ),
              ],
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pwRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7)),
          pw.Flexible(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
            ),
          ),
        ],
      ),
    );
  }

  /// Ekspor atau cetak file PDF struk kecil
  static Future<void> exportOrPrintPdf(
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
    ReceiptSettings? settings,
  }) async {
    final pdfBytes = await generateReceiptPdf(recipe, tastingNotes: tastingNotes, settings: settings);
    final sessionCode = generateSessionCode(recipe);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Struk-Seduh-$sessionCode.pdf',
    );
  }

  /// Menangkap RepaintBoundary widget menjadi gambar PNG resolusi tinggi dan membagikannya
  static Future<bool> captureAndShareReceiptImage(
    GlobalKey boundaryKey, {
    required String recipeTitle,
    required String storeName,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/Struk_Seduh_${recipeTitle.replaceAll(' ', '_')}_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'Struk Seduh Presisi - $recipeTitle oleh $storeName',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error capturing receipt image: $e');
      return false;
    }
  }

  /// Salin teks struk ke clipboard perangkat
  static Future<void> copyReceiptToClipboard(
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
    ReceiptSettings? settings,
  }) async {
    final text = generateThermalReceiptText(recipe, tastingNotes: tastingNotes, settings: settings);
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Membuka aplikasi Print Spooler Bluetooth thermal seperti RawBT
  static Future<bool> launchThermalPrintIntent(
    Map<String, dynamic> recipe, {
    List<String>? tastingNotes,
    ReceiptSettings? settings,
  }) async {
    final text = generateThermalReceiptText(recipe, tastingNotes: tastingNotes, settings: settings);
    final encoded = Uri.encodeComponent(text);

    final rawBtUri = Uri.parse('rawbt:data:text/plain;base64,${base64Encode(utf8.encode(text))}');
    try {
      if (await canLaunchUrl(rawBtUri)) {
        return await launchUrl(rawBtUri);
      }
    } catch (_) {}

    final shareUri = Uri.parse('sms:?body=$encoded');
    try {
      if (await canLaunchUrl(shareUri)) {
        return await launchUrl(shareUri);
      }
    } catch (_) {}

    await copyReceiptToClipboard(recipe, tastingNotes: tastingNotes, settings: settings);
    return true;
  }

  // --- Helper Helpers String Formatting ---
  static String _centerText(String text, int width) {
    if (text.length >= width) return text;
    final pad = (width - text.length) ~/ 2;
    final left = ' ' * pad;
    final right = ' ' * (width - text.length - pad);
    return '$left$text$right';
  }

  static String _twoColumn(String left, String right, int width) {
    final total = left.length + right.length;
    if (total >= width - 1) {
      return '$left: $right';
    }
    final dots = ' ' * (width - left.length - right.length - 2);
    return '$left: $dots$right';
  }
}
