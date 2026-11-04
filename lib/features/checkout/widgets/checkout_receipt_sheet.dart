import 'package:flutter/material.dart';
import '../../../models/marketplace_model.dart';
import '../../../services/language_service.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class CheckoutReceiptSheet {
  static void show(BuildContext context, MarketplaceOrder order) {
    final isEn = LanguageService.isEnglish;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 36, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Text(
                isEn ? 'Payment Successful!' : 'Pesanan Berhasil Dibuat!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Your order has been forwarded to the roastery for freshly roasted batch packaging.'
                    : 'Pesanan telah diteruskan ke roastery untuk segera disangrai dan dikemas segar.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(isEn ? 'Order Number' : 'Nomor Pesanan', order.orderId, isBold: true),
                    const Divider(height: 14),
                    _buildReceiptRow(isEn ? 'Estimated Delivery' : 'Estimasi Sampai', order.estimatedDelivery),
                    const Divider(height: 14),
                    _buildReceiptRow(isEn ? 'Courier' : 'Layanan Kurir', order.courierName),
                    const Divider(height: 14),
                    _buildReceiptRow(isEn ? 'Payment' : 'Metode Bayar', order.paymentMethod),
                    const Divider(height: 14),
                    _buildReceiptRow(isEn ? 'Total Paid' : 'Total Pembayaran', CurrencyFormatter.formatRp(order.total), isBold: true, color: AppTheme.primaryBrown),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close sheet
                  Navigator.pop(context); // back to marketplace
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEn ? 'Back to Marketplace' : 'Kembali ke Marketplace',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
