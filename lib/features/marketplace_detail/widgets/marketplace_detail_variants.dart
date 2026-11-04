import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/marketplace_model.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class MarketplaceDetailVariants extends StatelessWidget {
  final MarketplaceProduct product;
  final bool isEn;
  final String selectedBagSize;
  final List<String> bagSizes;
  final ValueChanged<String> onSelectBagSize;
  final String selectedGrind;
  final List<String> grindOptions;
  final ValueChanged<String> onSelectGrind;
  final int quantity;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;

  const MarketplaceDetailVariants({
    super.key,
    required this.product,
    required this.isEn,
    required this.selectedBagSize,
    required this.bagSizes,
    required this.onSelectBagSize,
    required this.selectedGrind,
    required this.grindOptions,
    required this.onSelectGrind,
    required this.quantity,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Choose Bag Size
        Text(
          isEn ? 'Select Packaging Size' : 'Pilih Ukuran Kemasan',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Row(
          children: bagSizes.map((size) {
            final isSel = selectedBagSize == size;
            final price = product.getPriceForSize(size);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelectBagSize(size),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primaryBrown : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.3),
                        width: isSel ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          size,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSel ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatRp(price),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSel ? AppTheme.accentGold : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 2. Choose Grind Option
        Text(
          isEn ? 'Select Grind Profile' : 'Pilih Profil Gilingan',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: grindOptions.map((opt) {
            final isSel = selectedGrind == opt;
            return ChoiceChip(
              label: Text(
                opt,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel ? Colors.white : AppTheme.textDark,
                ),
              ),
              selected: isSel,
              selectedColor: AppTheme.primaryBrown,
              backgroundColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSel ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              onSelected: (val) => onSelectGrind(opt),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 3. Quantity Stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? 'Quantity' : 'Jumlah Pesanan',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.minus, size: 14),
                    onPressed: quantity > 1 ? onDecrementQuantity : null,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.plus, size: 14),
                    onPressed: onIncrementQuantity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
