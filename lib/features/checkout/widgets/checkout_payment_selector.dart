import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CheckoutPaymentSelector extends StatelessWidget {
  final bool isEn;
  final String selectedPayment;
  final List<Map<String, dynamic>> paymentOptions;
  final ValueChanged<String> onPaymentSelected;

  const CheckoutPaymentSelector({
    super.key,
    required this.isEn,
    required this.selectedPayment,
    required this.paymentOptions,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Payment Method' : 'Metode Pembayaran',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        ...paymentOptions.map((p) {
          final isSel = selectedPayment == p['id'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel ? AppTheme.primaryBrown : Colors.transparent,
                width: isSel ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(p['icon'] as IconData, size: 18, color: AppTheme.primaryBrown),
              ),
              title: Text(
                p['label'] as String,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                p['subtitle'] as String,
                style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
              ),
              trailing: Icon(
                isSel ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                color: isSel ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.4),
                size: 20,
              ),
              onTap: () => onPaymentSelected(p['id'] as String),
            ),
          );
        }),
      ],
    );
  }
}
