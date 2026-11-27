import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Generates a branded high-DPI Coffee Labs Live Brew QR Card PNG image
/// complete with recipe/bean details, barista info, scannable QR code,
/// and instructions inside the image — ready to send directly via WhatsApp
/// or any messenger along with the clickable live URL.
class LiveBrewQrCardExporter {
  LiveBrewQrCardExporter._();

  static const double _cardWidth = 900;
  static const double _cardHeight = 1180;

  /// Renders the complete QR poster card into PNG bytes off-screen.
  static Future<Uint8List> buildQrCardPngBytes({
    required String liveUrl,
    required String title,
    String? subtitle,
    String? baristaName,
    String? specLine,
    String? seatLabel,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, _cardWidth, _cardHeight),
    );

    // 1. Warm Cream Background (#FAF3E8)
    final bgPaint = Paint()..color = const Color(0xFFFAF3E8);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _cardWidth, _cardHeight),
      bgPaint,
    );

    // 2. Main Elevated White Card
    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(48, 48, _cardWidth - 96, _cardHeight - 96),
      const Radius.circular(42),
    );
    canvas.drawRRect(
      cardRect,
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = const Color(0xFFE7DDD3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // 3. Top Header Pill (Green Live Dot + Coffee Labs Live Brew)
    const pillW = 430.0;
    const pillH = 54.0;
    final pillRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH((_cardWidth - pillW) / 2, 92, pillW, pillH),
      const Radius.circular(27),
    );
    canvas.drawRRect(pillRect, Paint()..color = const Color(0xFFF0FDF4));
    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = const Color(0xFF86EFAC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Glowing green dot
    canvas.drawCircle(
      const Offset((_cardWidth - pillW) / 2 + 34, 92 + pillH / 2),
      9,
      Paint()..color = const Color(0xFF16A34A),
    );
    _drawCenteredText(
      canvas,
      text: 'COFFEE LABS • LIVE BREW 1:1',
      y: 105,
      xOffset: 16,
      maxWidth: pillW - 40,
      style: const TextStyle(
        color: Color(0xFF15803D),
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );

    // 4. Title (Recipe / Cafe Name)
    double cursorY = 172;
    cursorY += _drawCenteredText(
      canvas,
      text: title.trim().isEmpty ? 'Coffee Labs Live Brew' : title.trim(),
      y: cursorY,
      maxWidth: _cardWidth - 160,
      maxLines: 2,
      style: const TextStyle(
        color: Color(0xFF2C1810),
        fontSize: 40,
        fontWeight: FontWeight.w900,
        height: 1.18,
      ),
    );

    // 5. Optional Subtitle (Barista / Seat / Spec)
    final infoParts = <String>[
      if (seatLabel != null && seatLabel.trim().isNotEmpty) seatLabel.trim(),
      if (baristaName != null && baristaName.trim().isNotEmpty)
        'Barista: ${baristaName.trim()}',
      if (subtitle != null && subtitle.trim().isNotEmpty) subtitle.trim(),
    ];
    if (infoParts.isNotEmpty) {
      cursorY += 10;
      cursorY += _drawCenteredText(
        canvas,
        text: infoParts.join(' • '),
        y: cursorY,
        maxWidth: _cardWidth - 160,
        maxLines: 2,
        style: const TextStyle(
          color: Color(0xFF78665A),
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      );
    }

    if (specLine != null && specLine.trim().isNotEmpty) {
      cursorY += 14;
      final specRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(110, cursorY, _cardWidth - 220, 50),
        const Radius.circular(16),
      );
      canvas.drawRRect(specRect, Paint()..color = const Color(0xFFFAF3E8));
      canvas.drawRRect(
        specRect,
        Paint()
          ..color = const Color(0xFFE7DDD3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawCenteredText(
        canvas,
        text: specLine.trim(),
        y: cursorY + 11,
        maxWidth: _cardWidth - 250,
        maxLines: 1,
        style: const TextStyle(
          color: Color(0xFF5D3A1A),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      );
      cursorY += 66;
    } else {
      cursorY += 24;
    }

    // 6. Framed High-Contrast Scannable QR Code
    const qrBoxSize = 468.0;
    const qrInnerPad = 26.0;
    final qrTop = cursorY.clamp(310.0, 415.0);
    final qrLeft = (_cardWidth - qrBoxSize) / 2;
    final qrRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(qrLeft, qrTop, qrBoxSize, qrBoxSize),
      const Radius.circular(30),
    );
    canvas.drawRRect(qrRRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      qrRRect,
      Paint()
        ..color = const Color(0xFF5D3A1A).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    final qrPainter = QrPainter(
      data: liveUrl,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF2C1810),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF2C1810),
      ),
    );

    canvas.save();
    canvas.translate(qrLeft + qrInnerPad, qrTop + qrInnerPad);
    qrPainter.paint(
      canvas,
      const Size(qrBoxSize - qrInnerPad * 2, qrBoxSize - qrInnerPad * 2),
    );
    canvas.restore();

    // 7. Description & Live Link Footer Inside Card
    double footerY = qrTop + qrBoxSize + 30;
    footerY += _drawCenteredText(
      canvas,
      text: 'Scan QR Code atau klik tautan untuk pantau seduhan secara langsung',
      y: footerY,
      maxWidth: _cardWidth - 170,
      maxLines: 2,
      style: const TextStyle(
        color: Color(0xFF2C1810),
        fontSize: 23,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    );

    footerY += 16;
    final urlRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(96, footerY, _cardWidth - 192, 56),
      const Radius.circular(16),
    );
    canvas.drawRRect(urlRect, Paint()..color = const Color(0xFF5D3A1A));
    _drawCenteredText(
      canvas,
      text: liveUrl.replaceFirst('https://', ''),
      y: footerY + 14,
      maxWidth: _cardWidth - 220,
      maxLines: 1,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _cardWidth.toInt(),
      _cardHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      throw StateError('Gagal merender gambar kartu QR Live Brew.');
    }
    return byteData.buffer.asUint8List();
  }

  static double _drawCenteredText(
    Canvas canvas, {
    required String text,
    required double y,
    required double maxWidth,
    required TextStyle style,
    int maxLines = 1,
    double xOffset = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);
    final dx = ((_cardWidth - tp.width) / 2) + xOffset;
    tp.paint(canvas, Offset(dx, y));
    return tp.height;
  }

  /// Generates PNG file and opens native share sheet (WhatsApp / Messenger)
  /// with BOTH the branded QR Card Image AND full clickable description caption.
  static Future<void> shareQrCardWithCaption({
    required String liveUrl,
    required String title,
    String? subtitle,
    String? baristaName,
    String? specLine,
    String? seatLabel,
  }) async {
    final captionBuffer = StringBuffer()
      ..writeln('☕ *Live Brew Coffee Labs*')
      ..writeln('*$title*');
    if (specLine != null && specLine.trim().isNotEmpty) {
      captionBuffer.writeln(specLine.trim());
    }
    if (seatLabel != null && seatLabel.trim().isNotEmpty) {
      captionBuffer.writeln('Meja/Kursi: ${seatLabel.trim()}');
    }
    if (baristaName != null && baristaName.trim().isNotEmpty) {
      captionBuffer.writeln('Barista: ${baristaName.trim()}');
    }
    captionBuffer
      ..writeln()
      ..writeln('Scan QR di gambar atau buka link langsung:')
      ..write(liveUrl);

    try {
      final pngBytes = await buildQrCardPngBytes(
        liveUrl: liveUrl,
        title: title,
        subtitle: subtitle,
        baristaName: baristaName,
        specLine: specLine,
        seatLabel: seatLabel,
      );
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/coffee_labs_live_brew_qr_$ts.png');
      await file.writeAsBytes(pngBytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png', name: 'LiveBrew-QR.png')],
          text: captionBuffer.toString(),
          subject: 'Coffee Labs Live Brew — $title',
        ),
      );
    } catch (_) {
      // Safe fallback to text share if temporary storage is unavailable
      await SharePlus.instance.share(
        ShareParams(text: captionBuffer.toString()),
      );
    }
  }
}
