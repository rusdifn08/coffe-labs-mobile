import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/qris_billing_models.dart';

/// Kartu Standee QRIS Resmi Indonesia (Standar Bank Indonesia / ASPI)
/// dengan aksen pita merah diagonal QRIS, lockup QRIS + GPN, nama merchant
/// "Coffee Labs Indonesia", quiet zone QR tinggi untuk akurasi scan 100%,
/// serta panel nominal & kode unik bergaya fintech modern.
class IndonesiaQrisStandeeCard extends StatelessWidget {
  static const String brandMerchantTitle = 'Coffee Labs Indonesia';

  static const Color qrisRed = Color(0xFFD9232E);
  static const Color qrisDarkRed = Color(0xFFB31922);
  static const Color gpnNavy = Color(0xFF1D3B8B);
  static const Color inkDark = Color(0xFF171412);
  static const Color inkMuted = Color(0xFF6B625B);
  static const Color espresso = Color(0xFF3E2723);

  final DynamicQrisInvoiceModel invoice;

  const IndonesiaQrisStandeeCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DDD3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1810).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: CustomPaint(
          painter: _QrisIndonesiaRibbonPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Official QRIS Indonesia + GPN Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: _buildQrisLogoLockup()),
                    const SizedBox(width: 8),
                    _buildGpnBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFEEE8E0)),
                const SizedBox(height: 8),

                // 2. Merchant Identity: Coffee Labs Indonesia
                const Text(
                  brandMerchantTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: inkDark,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NMID : ${invoice.nmid}  •  A01',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: inkMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Crisp Scannable EMVCo QR Code with Official Red Corner Frame
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE5E0D8),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    foregroundPainter: _QrCornerBracketsPainter(color: qrisRed),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: QrImageView(
                        data: invoice.dynamicQrisPayload,
                        version: QrVersions.auto,
                        size: 164,
                        gapless: true,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF111111),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 4. Fintech Amount Breakdown Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFE9E1D6)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TOTAL PEMBAYARAN',
                        style: TextStyle(
                          color: inkMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            invoice.formattedTotal,
                            style: const TextStyle(
                              color: inkDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: invoice.totalPayableIdr.toString(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: espresso,
                                    content: Text(
                                      'Nominal ${invoice.formattedTotal} disalin!',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD6C7B5),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.doc_on_clipboard,
                                      size: 11.5,
                                      color: espresso,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Salin Nominal',
                                      style: TextStyle(
                                        color: espresso,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Harga Paket ${invoice.formattedBase} + Kode Unik Rp ${invoice.uniqueCodeIdr}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: inkMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (invoice.appliedReferralCode != null &&
                          invoice.buyerDiscountIdr > 0) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            'Referral ${invoice.appliedReferralCode} • Diskon ${formatRupiahIdr(invoice.buyerDiscountIdr)}',
                            style: const TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 12,
                            color: Color(0xFF047857),
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Nominal otomatis sesuai saat QRIS dipindai',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 5. Official National QRIS Footer & Supported Channels
                const Text(
                  'SATU QRIS UNTUK SEMUA • BCA • MANDIRI • BRI • BNI • GOPAY • OVO • DANA',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF7D746B),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dicetak oleh: ${invoice.acquirerCode} (Bank Mandiri) • Standar Bank Indonesia',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9A9188),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrisLogoLockup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: qrisRed,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 7),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QRIS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: inkDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'QR Code Standar Pembayaran Nasional',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: inkMuted,
                  fontSize: 7.3,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGpnBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5DDD3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 12,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [qrisRed, gpnNavy],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 4.5),
          const Text(
            'GPN',
            style: TextStyle(
              color: qrisRed,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aksen pita merah diagonal khas Standee QRIS Indonesia (Bank Indonesia / ASPI).
class _QrisIndonesiaRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()..color = IndonesiaQrisStandeeCard.qrisRed;
    final darkRedPaint = Paint()..color = IndonesiaQrisStandeeCard.qrisDarkRed;

    // Pita merah ramping di tepi atas
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 4.5), redPaint);

    // Segitiga aksen diagonal kanan bawah (ikonik QRIS Indonesia)
    final bottomRight = Path()
      ..moveTo(size.width - 54, size.height)
      ..lineTo(size.width, size.height - 54)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(bottomRight, redPaint);

    final bottomRightShade = Path()
      ..moveTo(size.width - 30, size.height)
      ..lineTo(size.width, size.height - 30)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(bottomRightShade, darkRedPaint);

    // Aksen segitiga kecil kiri bawah (simetri ringan tanpa mengganggu konten)
    final bottomLeft = Path()
      ..moveTo(0, size.height - 22)
      ..lineTo(22, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      bottomLeft,
      Paint()..color = IndonesiaQrisStandeeCard.qrisRed.withValues(alpha: 0.14),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bingkai sudut merah presisi di sekeliling kotak QR agar tampak seperti standee resmi.
class _QrCornerBracketsPainter extends CustomPainter {
  final Color color;

  const _QrCornerBracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 14.0;
    const inset = 1.0;

    // Top-left
    canvas.drawLine(const Offset(inset, inset + len), const Offset(inset, inset), paint);
    canvas.drawLine(const Offset(inset, inset), const Offset(inset + len, inset), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - inset - len, inset), Offset(size.width - inset, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), paint);

    // Bottom-left
    canvas.drawLine(Offset(inset, size.height - inset - len), Offset(inset, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), paint);

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - inset - len, size.height - inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset - len),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrCornerBracketsPainter oldDelegate) =>
      oldDelegate.color != color;
}
