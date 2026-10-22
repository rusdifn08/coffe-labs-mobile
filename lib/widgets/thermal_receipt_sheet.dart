import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/receipt_print_service.dart';
import '../theme/app_theme.dart';

class ThermalReceiptSheet extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final List<String>? tastingNotes;

  const ThermalReceiptSheet({super.key, required this.recipe, this.tastingNotes});

  static Future<void> show(BuildContext context, Map<String, dynamic> recipe, {List<String>? tastingNotes}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThermalReceiptSheet(recipe: recipe, tastingNotes: tastingNotes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptText = ReceiptPrintService.generateThermalReceiptText(recipe, tastingNotes: tastingNotes);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.printer_fill, color: AppTheme.primaryBrown, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Struk Seduh Kasir (Thermal POS)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      'Format struk kasir Bluetooth 58mm untuk pelanggan coffee shop',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Realistic Thermal Receipt Paper Preview
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sawtooth / Perforated top indicator
                    Center(
                      child: Text(
                        '- - - - - - - - - - - - - - - - - - - -',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      receiptText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: Color(0xFF222222),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              // Tombol Salin Teks Struk
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await ReceiptPrintService.copyReceiptToClipboard(recipe, tastingNotes: tastingNotes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Format struk thermal berhasil disalin ke clipboard!'),
                          backgroundColor: AppTheme.primaryBrown,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
                  label: const Text('Salin Struk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),

              // Tombol Print ke Bluetooth Thermal Printer
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    await ReceiptPrintService.copyReceiptToClipboard(recipe, tastingNotes: tastingNotes);
                    await ReceiptPrintService.launchThermalPrintIntent(recipe, tastingNotes: tastingNotes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🖨️ Struk siap dicetak ke printer thermal bluetooth!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(CupertinoIcons.printer_fill, size: 16),
                  label: const Text('Print via Bluetooth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
