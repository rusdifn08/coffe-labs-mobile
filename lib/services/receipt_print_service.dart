import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiptPrintService {
  /// Menghasilkan teks struk kasir profesional untuk thermal printer (58mm / 32 kolom)
  static String generateThermalReceiptText(Map<String, dynamic> recipe, {List<String>? tastingNotes}) {
    final title = recipe['title']?.toString() ?? 'Specialty Brew';
    final author = recipe['author']?.toString() ?? 'Coffee Labs Barista';
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
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final steps = recipe['steps'] as List<dynamic>? ?? [];

    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('        ☕ COFFEE LABS ☕       ');
    buffer.writeln('      SPECIALTY COFFEE HUB      ');
    buffer.writeln('================================');
    buffer.writeln('Waktu   : $dateStr');
    buffer.writeln('Barista : $author');
    buffer.writeln('Resep   : $title');
    buffer.writeln('Metode  : $method');
    buffer.writeln('--------------------------------');
    buffer.writeln('PARAMETER SEDUH:');
    buffer.writeln('  Kopi (Dose)  : ${coffeeWeight}g');
    if (iceWeight > 0) {
      buffer.writeln('  Es Batu      : ${iceWeight}g');
      buffer.writeln('  Air Panas    : ${waterWeight}ml');
      buffer.writeln('  Total Yield  : ${waterWeight + iceWeight}g');
    } else {
      buffer.writeln('  Air (Yield)  : ${waterWeight}ml');
    }
    buffer.writeln('  Rasio Seduh  : 1 : $ratio');
    buffer.writeln('  Ukuran Giling: $grindSize');
    buffer.writeln('  Suhu Air     : $waterTemp°C');
    buffer.writeln('--------------------------------');
    buffer.writeln('TAHAPAN TUANGAN (POUR PROFILE):');

    if (steps.isNotEmpty) {
      int accumulatedWater = 0;
      int accumulatedTime = 0;
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        final dur = step['durationSeconds'] ?? 30;
        final water = step['waterWeightGrams'] ?? 0;
        accumulatedWater += (water as num).toInt();
        final startSec = accumulatedTime;
        accumulatedTime += (dur as num).toInt();
        final endSec = accumulatedTime;

        final startFormatted = '${(startSec ~/ 60).toString().padLeft(2, '0')}:${(startSec % 60).toString().padLeft(2, '0')}';
        final endFormatted = '${(endSec ~/ 60).toString().padLeft(2, '0')}:${(endSec % 60).toString().padLeft(2, '0')}';

        if (water > 0) {
          buffer.writeln('  ${i + 1}. $startFormatted-$endFormatted | +${water}g (${accumulatedWater}g)');
        } else {
          buffer.writeln('  ${i + 1}. $startFormatted-$endFormatted | Drawdown (${accumulatedWater}g)');
        }
      }
    } else {
      buffer.writeln('  1. Tuang air perlahan & stabil');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('PROFIL RASA (TASTING NOTES):');
    buffer.writeln('  $notes');
    buffer.writeln('--------------------------------');
    buffer.writeln('   SELAMAT MENIKMATI KOPI ANDA! ');
    buffer.writeln('    Diseduh Presisi & Penuh Rasa ');
    buffer.writeln('   IG: @coffeelabs.specialty    ');
    buffer.writeln('================================\n\n\n');

    return buffer.toString();
  }

  /// Menghasilkan format raw ESC/POS bytes untuk Bluetooth printer thermal
  static Uint8List generateEscPosBytes(Map<String, dynamic> recipe, {List<String>? tastingNotes}) {
    final text = generateThermalReceiptText(recipe, tastingNotes: tastingNotes);
    final List<int> bytes = [];

    // ESC @: Inisialisasi printer
    bytes.addAll([0x1B, 0x40]);
    // ESC a 1: Center align
    bytes.addAll([0x1B, 0x61, 0x01]);
    // ESC E 1: Bold on
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll(utf8.encode("☕ COFFEE LABS SPECIALTY ☕\n"));
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

  /// Salin teks struk ke clipboard perangkat
  static Future<void> copyReceiptToClipboard(Map<String, dynamic> recipe, {List<String>? tastingNotes}) async {
    final text = generateThermalReceiptText(recipe, tastingNotes: tastingNotes);
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Membuka aplikasi Print Spooler Bluetooth thermal seperti RawBT atau printer thermal Android
  static Future<bool> launchThermalPrintIntent(Map<String, dynamic> recipe, {List<String>? tastingNotes}) async {
    final text = generateThermalReceiptText(recipe, tastingNotes: tastingNotes);
    final encoded = Uri.encodeComponent(text);

    // Coba protokol RawBT (spooler printer bluetooth kasir standar industri di Android)
    final rawBtUri = Uri.parse('rawbt:data:text/plain;base64,${base64Encode(utf8.encode(text))}');
    try {
      if (await canLaunchUrl(rawBtUri)) {
        return await launchUrl(rawBtUri);
      }
    } catch (_) {}

    // Fallback: Kirim teks struk via intent universal
    final shareUri = Uri.parse('sms:?body=$encoded');
    try {
      if (await canLaunchUrl(shareUri)) {
        return await launchUrl(shareUri);
      }
    } catch (_) {}

    // Fallback: Salin ke clipboard
    await copyReceiptToClipboard(recipe, tastingNotes: tastingNotes);
    return true;
  }
}
