import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/thermal_receipt_service.dart';

class ReceiptPreviewModal extends StatelessWidget {
  final ThermalReceiptData data;
  final VoidCallback onNewTransaction;

  const ReceiptPreviewModal({
    super.key,
    required this.data,
    required this.onNewTransaction,
  });

  static void show(
    BuildContext context, {
    required ThermalReceiptData data,
    required VoidCallback onNewTransaction,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => ReceiptPreviewModal(
        data: data,
        onNewTransaction: onNewTransaction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptText = ThermalReceiptService.generate58mmPlainText(data);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 680),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF9F6), // Thermal Paper Off-White
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Paper Header Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFECEAE4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.printer_fill, color: Color(0xFF4A3426), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Struk Thermal Kasir (58mm)',
                      style: TextStyle(color: Color(0xFF2C1E14), fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark, color: Colors.black54, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable Monospace Thermal Paper Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Coffee Labs Emblem
                      const Icon(Icons.local_cafe, size: 36, color: Color(0xFF3E2723)),
                      const SizedBox(height: 10),
                      SelectableText(
                        receiptText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: Colors.black87,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Printer & Share Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EEE9),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: receiptText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Teks struk berhasil disalin ke clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF3E2723),
                              side: const BorderSide(color: Color(0xFF8D6E63)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
                            label: const Text('Salin Struk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF2E7D32),
                                  content: Row(
                                    children: [
                                      Icon(CupertinoIcons.checkmark_alt, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Perintah cetak dikirim ke printer thermal bluetooth.'),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(CupertinoIcons.printer_fill, size: 16),
                            label: const Text('Cetak Struk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onNewTransaction();
                        },
                        child: const Text('Mulai Transaksi Baru', style: TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
