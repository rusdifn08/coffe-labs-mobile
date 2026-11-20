import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';

import '../../domain/live_brew_mirror_models.dart';

enum SeatQrPrintLayout {
  tableTentA6('Table Tent A6 (105x148mm)'),
  seatSticker60mm('Stiker Kursi / Bar (60x60mm)'),
  a4MultiGrid('Sheet A4 Cetak Massal (6/Lembar)');

  final String label;
  const SeatQrPrintLayout(this.label);
}

class CafeSeatQrPrintService {
  CafeSeatQrPrintService._();

  /// Membangun PDF Vektor 300 DPI siap cetak untuk 1 atau banyak meja/kursi sekaligus.
  static Future<Uint8List> buildSeatQrPdfBytes({
    required BusinessBrandingModel branding,
    required List<CafeSeatModel> seats,
    required SeatQrPrintLayout layout,
  }) async {
    final doc = pw.Document(
      title: '${branding.cafeDisplayName} — Live Brew QR Studio',
      author: 'Coffee Labs Business POS',
    );
    final safeSeats = seats.isEmpty ? const <CafeSeatModel>[] : seats;

    if (layout == SeatQrPrintLayout.tableTentA6) {
      for (final seat in safeSeats) {
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a6,
            margin: const pw.EdgeInsets.all(14),
            build: (_) => _buildTableTentCard(branding, seat, compact: false),
          ),
        );
      }
    } else if (layout == SeatQrPrintLayout.seatSticker60mm) {
      final stickerFormat = PdfPageFormat(
        60 * PdfPageFormat.mm,
        60 * PdfPageFormat.mm,
        marginAll: 4 * PdfPageFormat.mm,
      );
      for (final seat in safeSeats) {
        doc.addPage(
          pw.Page(
            pageFormat: stickerFormat,
            build: (_) => _buildCompactSticker(branding, seat),
          ),
        );
      }
    } else {
      // Sheet A4 Multi-Grid (2 kolom x 3 baris = 6 meja per lembar)
      for (var i = 0; i < safeSeats.length; i += 6) {
        final chunk = safeSeats.skip(i).take(6).toList();
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(16),
            build: (_) => pw.GridView(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
              children: chunk
                  .map((s) => _buildTableTentCard(branding, s, compact: true))
                  .toList(),
            ),
          ),
        );
      }
    }

    return doc.save();
  }

  static pw.Widget _buildTableTentCard(
    BusinessBrandingModel branding,
    CafeSeatModel seat, {
    required bool compact,
  }) {
    final gold = PdfColor.fromHex('#D4A373');
    final dark = PdfColor.fromHex('#12100E');
    final cream = PdfColor.fromHex('#F9F5EE');

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: cream,
        border: pw.Border.all(color: gold, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      padding: pw.EdgeInsets.all(compact ? 10 : 14),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: compact ? 6 : 9,
            ),
            decoration: pw.BoxDecoration(
              color: dark,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  branding.cafeDisplayName.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: gold,
                    fontSize: compact ? 9 : 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  seat.seatLabel.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: compact ? 15 : 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(compact ? 6 : 10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              border: pw.Border.all(color: gold, width: 1),
            ),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(
                errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
              ),
              data: seat.brandedUrl,
              width: compact ? 96 : 138,
              height: compact ? 96 : 138,
              color: dark,
            ),
          ),
          pw.Column(
            children: [
              pw.Text(
                'Scan untuk Pantau Progress Pesanan & Live Brew Barista',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: dark,
                  fontSize: compact ? 7.5 : 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                seat.brandedUrl.replaceFirst('https://', ''),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: compact ? 6.5 : 7.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${seat.zoneArea} | Kode: ${seat.numericFallbackCode}',
                style: pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: compact ? 6 : 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCompactSticker(
    BusinessBrandingModel branding,
    CafeSeatModel seat,
  ) {
    final dark = PdfColor.fromHex('#12100E');
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          '${branding.cafeDisplayName} - ${seat.seatLabel}',
          maxLines: 1,
          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(
            errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
          ),
          data: seat.brandedUrl,
          width: 98,
          height: 98,
          color: dark,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Scan Live Brew & Status Pesanan',
          style: const pw.TextStyle(fontSize: 6.5),
        ),
      ],
    );
  }

  static Future<void> openNativePdfPrintDialog({
    required BusinessBrandingModel branding,
    required List<CafeSeatModel> seats,
    required SeatQrPrintLayout layout,
  }) async {
    await Printing.layoutPdf(
      name: '${branding.cafeSlug}_${layout.name}.pdf',
      onLayout: (_) => buildSeatQrPdfBytes(
        branding: branding,
        seats: seats,
        layout: layout,
      ),
    );
  }

  static Future<void> sharePdfFile({
    required BusinessBrandingModel branding,
    required List<CafeSeatModel> seats,
    required SeatQrPrintLayout layout,
  }) async {
    final bytes = await buildSeatQrPdfBytes(
      branding: branding,
      seats: seats,
      layout: layout,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${branding.cafeSlug}_livebrew_qr.pdf',
    );
  }

  /// Mode 2: Pindai printer Bluetooth thermal POS yang sudah ter-pair di perangkat.
  static Future<List<BluetoothInfo>> scanPairedThermalPrinters() async {
    try {
      final enabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!enabled) return const [];
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (_) {
      return const [];
    }
  }

  /// Cetak stiker/struk QR Code hardware ESC/POS langsung ke printer thermal 58mm / 80mm.
  static Future<bool> printSeatQrToThermalBluetooth({
    required String macAddress,
    required BusinessBrandingModel branding,
    required CafeSeatModel seat,
    bool paper80mm = false,
  }) async {
    final connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddress,
    );
    if (!connected) return false;

    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paper80mm ? PaperSize.mm80 : PaperSize.mm58,
      profile,
    );
    final bytes = <int>[];
    bytes.addAll(generator.reset());
    bytes.addAll(
      generator.text(
        branding.cafeDisplayName.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        seat.seatLabel.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        seat.zoneArea,
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.qrcode(
        seat.brandedUrl,
        align: PosAlign.center,
        size: QRSize.size6,
        cor: QRCorrection.H,
      ),
    );
    bytes.addAll(generator.feed(1));
    bytes.addAll(
      generator.text(
        'Scan untuk Live Brew 1:1 & Status Pesanan',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(
      generator.text(
        seat.brandedUrl.replaceFirst('https://', ''),
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(
      generator.text(
        'Kode: ${seat.numericFallbackCode}',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return PrintBluetoothThermal.writeBytes(bytes);
  }
}
