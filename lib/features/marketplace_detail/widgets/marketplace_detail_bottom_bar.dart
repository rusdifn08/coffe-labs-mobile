import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/marketplace_model.dart';
import '../../../screens/checkout_screen.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class MarketplaceDetailBottomBar extends StatelessWidget {
  final MarketplaceProduct product;
  final bool isEn;
  final String selectedBagSize;
  final String selectedGrind;
  final int quantity;
  final int totalPrice;

  const MarketplaceDetailBottomBar({
    super.key,
    required this.product,
    required this.isEn,
    required this.selectedBagSize,
    required this.selectedGrind,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Total Price' : 'Total Harga',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                Text(
                  CurrencyFormatter.formatRp(totalPrice),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Add to Cart
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  MarketplaceService.instance.addToCart(
                    product: product,
                    bagSize: selectedBagSize,
                    grindOption: selectedGrind,
                    quantity: quantity,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEn
                            ? 'Added to Cart: ${product.name} ($selectedBagSize)'
                            : 'Ditambahkan ke keranjang: ${product.name} ($selectedBagSize)',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBrown),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(CupertinoIcons.cart_badge_plus, size: 16, color: AppTheme.primaryBrown),
                label: Text(
                  isEn ? '+ Cart' : '+ Keranjang',
                  style: const TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Buy Now
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await MarketplaceService.instance.addToCart(
                    product: product,
                    bagSize: selectedBagSize,
                    grindOption: selectedGrind,
                    quantity: quantity,
                  );
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEn ? 'Buy Now' : 'Beli Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
