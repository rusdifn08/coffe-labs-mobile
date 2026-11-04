import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class CartSummaryCard extends StatelessWidget {
  final bool isEn;
  final int subtotal;
  final int shipping;
  final int discount;
  final int grandTotal;

  const CartSummaryCard({
    super.key,
    required this.isEn,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.grandTotal,
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
        children: [
          _buildSummaryRow(isEn ? 'Subtotal' : 'Subtotal Produk', CurrencyFormatter.formatRp(subtotal)),
          const SizedBox(height: 6),
          _buildSummaryRow(
            isEn ? 'Courier Shipping' : 'Ongkos Kirim',
            shipping == 0 ? (isEn ? 'FREE' : 'GRATIS') : CurrencyFormatter.formatRp(shipping),
          ),
          if (discount > 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              isEn ? 'Voucher Discount' : 'Diskon Promo',
              '-${CurrencyFormatter.formatRp(discount)}',
              valueColor: Colors.green,
            ),
          ],
          const Divider(height: 18),
          _buildSummaryRow(
            isEn ? 'Total Payment' : 'Total Pembayaran',
            CurrencyFormatter.formatRp(grandTotal),
            isBold: true,
            fontSize: 15,
            valueColor: AppTheme.primaryBrown,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 12,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.textDark : AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
