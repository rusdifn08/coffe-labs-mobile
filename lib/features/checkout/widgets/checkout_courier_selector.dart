import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class CheckoutCourierSelector extends StatelessWidget {
  final bool isEn;
  final bool hasFreeShip;
  final String selectedCourier;
  final List<Map<String, dynamic>> courierOptions;
  final Function(String name, int fee) onCourierSelected;

  const CheckoutCourierSelector({
    super.key,
    required this.isEn,
    required this.hasFreeShip,
    required this.selectedCourier,
    required this.courierOptions,
    required this.onCourierSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Select Delivery Service' : 'Pilih Kurir Pengiriman',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        ...courierOptions.map((c) {
          final isSel = selectedCourier == c['name'];
          final fee = c['fee'] as int;
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
                child: Icon(c['icon'] as IconData, size: 18, color: AppTheme.primaryBrown),
              ),
              title: Text(
                c['name'] as String,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                c['desc'] as String,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              trailing: Text(
                hasFreeShip ? (isEn ? 'FREE' : 'GRATIS') : CurrencyFormatter.formatRp(fee),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: hasFreeShip ? Colors.green : AppTheme.primaryBrown,
                ),
              ),
              onTap: () => onCourierSelected(c['name'] as String, fee),
            ),
          );
        }),
      ],
    );
  }
}
