import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class CheckoutBreakdownCard extends StatelessWidget {
  final bool isEn;
  final int subtotal;
  final int courierFee;
  final bool hasFreeShip;
  final int discount;
  final int total;

  const CheckoutBreakdownCard({
    super.key,
    required this.isEn,
    required this.subtotal,
    required this.courierFee,
    required this.hasFreeShip,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Payment Breakdown' : 'Rincian Pembayaran',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _buildRow(isEn ? 'Items Subtotal' : 'Subtotal Produk', CurrencyFormatter.formatRp(subtotal)),
          const SizedBox(height: 6),
          _buildRow(
            isEn ? 'Shipping Fee' : 'Biaya Pengiriman',
            hasFreeShip ? (isEn ? 'FREE' : 'GRATIS') : CurrencyFormatter.formatRp(courierFee),
            color: hasFreeShip ? Colors.green : null,
          ),
          if (discount > 0) ...[
            const SizedBox(height: 6),
            _buildRow(
              isEn ? 'Voucher Discount' : 'Potongan Diskon',
              '-${CurrencyFormatter.formatRp(discount)}',
              color: Colors.green,
            ),
          ],
          const Divider(height: 18),
          _buildRow(
            isEn ? 'Total Payment' : 'Total Pembayaran',
            CurrencyFormatter.formatRp(total),
            isBold: true,
            fontSize: 15,
            color: AppTheme.primaryBrown,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, double fontSize = 12, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
