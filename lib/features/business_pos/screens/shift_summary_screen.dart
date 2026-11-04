import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/thermal_receipt_service.dart';

class ShiftSummaryScreen extends StatelessWidget {
  final int totalSales;
  final int totalOrders;
  final int cashTotal;
  final int qrisTotal;
  final int cardTotal;
  final int discountTotal;
  final VoidCallback onResetShift;

  const ShiftSummaryScreen({
    super.key,
    required this.totalSales,
    required this.totalOrders,
    required this.cashTotal,
    required this.qrisTotal,
    required this.cardTotal,
    required this.discountTotal,
    required this.onResetShift,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        title: const Row(
          children: [
            Icon(CupertinoIcons.chart_bar_square_fill, color: Color(0xFFD4AF37), size: 20),
            SizedBox(width: 10),
            Text('Rekap Kasir & Tutup Shift Bar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shift Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF221F1A), Color(0xFF151412)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('SHIFT AKTIF', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      const Spacer(),
                      Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Total Pendapatan Kotor (Gross Sales)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    ThermalReceiptService.formatCurrency(totalSales),
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.bag_fill, color: Colors.white60, size: 14),
                      const SizedBox(width: 6),
                      Text('$totalOrders Transaksi Selesai', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Breakdown Matrix
            const Text(
              'Rincian Berdasarkan Metode Bayar:',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildPaymentRow(
              title: 'Uang Tunai (Cash in Drawer)',
              icon: CupertinoIcons.money_dollar_circle_fill,
              color: Colors.greenAccent,
              amount: cashTotal,
            ),
            const SizedBox(height: 8),
            _buildPaymentRow(
              title: 'QRIS Statis / Dinamis',
              icon: CupertinoIcons.qrcode,
              color: Colors.cyanAccent,
              amount: qrisTotal,
            ),
            const SizedBox(height: 8),
            _buildPaymentRow(
              title: 'Kartu Debit / EDC EDC Card',
              icon: CupertinoIcons.creditcard_fill,
              color: Colors.orangeAccent,
              amount: cardTotal,
            ),
            const SizedBox(height: 8),
            _buildPaymentRow(
              title: 'Diskon Promosi Bar Terpakai',
              icon: CupertinoIcons.tag_fill,
              color: Colors.redAccent,
              amount: discountTotal,
              isNegative: true,
            ),

            const SizedBox(height: 24),

            // Operational Advice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.info_circle_fill, color: Color(0xFFD4AF37), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pastikan uang fisik di laci kasir telah dihitung dan sesuai dengan nominal "Uang Tunai" sebelum menutup shift.',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mencetak rekap shift ke printer thermal...')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(CupertinoIcons.printer, size: 16),
                    label: const Text('Cetak Rekap Shift', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Tutup Shift Sekarang?', style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'Transaksi saat ini akan diarsipkan dan register kasir akan di-reset untuk shift berikutnya.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.white54))),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                              child: const Text('Tutup Shift'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        onResetShift();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF2E7D32),
                              content: Text('Shift berhasil ditutup! Register kasir siap untuk shift baru.'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(CupertinoIcons.lock_shield_fill, size: 16),
                    label: const Text('Tutup Shift', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow({
    required String title,
    required IconData icon,
    required Color color,
    required int amount,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13))),
          Text(
            isNegative ? '-${ThermalReceiptService.formatCurrency(amount)}' : ThermalReceiptService.formatCurrency(amount),
            style: TextStyle(color: isNegative ? Colors.redAccent : color, fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
