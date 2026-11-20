import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/marketplace_model.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';
import '../../marketplace/utils/qris_payload_builder.dart';

class QrisPaymentSheet extends StatefulWidget {
  final MarketplaceOrder pendingOrder;

  const QrisPaymentSheet({
    super.key,
    required this.pendingOrder,
  });

  static Future<MarketplaceOrder?> show(
    BuildContext context,
    MarketplaceOrder pendingOrder,
  ) {
    return showModalBottomSheet<MarketplaceOrder>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => QrisPaymentSheet(pendingOrder: pendingOrder),
    );
  }

  @override
  State<QrisPaymentSheet> createState() => _QrisPaymentSheetState();
}

class _QrisPaymentSheetState extends State<QrisPaymentSheet> {
  final ValueNotifier<int> _secondsLeft = ValueNotifier<int>(15 * 60);
  Timer? _timer;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft.value > 0) {
        _secondsLeft.value -= 1;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsLeft.dispose();
    super.dispose();
  }

  Future<void> _confirmPaid() async {
    setState(() => _isConfirming = true);
    try {
      final paid = await MarketplaceService.instance.confirmQrisOrderPayment(
        widget.pendingOrder.orderId,
      );
      if (mounted) {
        Navigator.pop(context, paid);
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.pendingOrder;
    final qrData = (order.qrisPayload != null && order.qrisPayload!.isNotEmpty)
        ? order.qrisPayload!
        : MarketplaceQrisPayloadBuilder.buildDynamicPayload(
            orderCode: order.orderId,
            totalIdr: order.total,
          );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6CBBF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 8, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'QRIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Pembayaran QRIS Dinamis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: _isConfirming ? null : () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark_circle_fill,
                      color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE7DED2)),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                children: [
                  // Timer Kadaluarsa
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Icon(CupertinoIcons.clock_fill,
                            size: 14, color: Color(0xFFEA580C)),
                        const Text(
                          'Selesaikan sebelum',
                          style: TextStyle(
                              fontSize: 11.5, color: AppTheme.textDark),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _secondsLeft,
                          builder: (_, sec, _) {
                            final m = (sec ~/ 60).toString().padLeft(2, '0');
                            final s = (sec % 60).toString().padLeft(2, '0');
                            return Text(
                              '$m:$s',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFC2410C),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Kartu QR Code Nyata
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE2D5)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          MarketplaceQrisPayloadBuilder.merchantName,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'NMID: ${MarketplaceQrisPayloadBuilder.nmid} • ${order.orderId}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFE2D8CA), width: 1.2),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 158,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF2E1A0E),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF2E1A0E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Total Tagihan QRIS',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRp(order.total),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Scan QR dari GoPay, OVO, DANA, ShopeePay, BCA Mobile, Livin\', BRImo, & bank QRIS lainnya.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: qrData));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payload QRIS disalin ke clipboard.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.doc_on_doc, size: 14),
                          label: const Text(
                            'Salin Kode QRIS',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBrown,
                            side: const BorderSide(color: Color(0xFFD6CBBF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isConfirming ? null : _confirmPaid,
                      icon: _isConfirming
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(CupertinoIcons.checkmark_seal_fill,
                              size: 18),
                      label: Text(
                        _isConfirming
                            ? 'Memverifikasi Pembayaran...'
                            : 'Saya Sudah Bayar QRIS',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
