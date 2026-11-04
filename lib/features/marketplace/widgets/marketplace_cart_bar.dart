import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/cart_screen.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class MarketplaceCartBar extends StatelessWidget {
  final bool isEn;
  final MarketplaceService marketplaceService;

  const MarketplaceCartBar({
    super.key,
    required this.isEn,
    required this.marketplaceService,
  });

  @override
  Widget build(BuildContext context) {
    final cartCount = marketplaceService.cartCount;
    if (cartCount == 0) return const SizedBox.shrink();

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
                  '$cartCount ${isEn ? "items in cart" : "item di keranjang"}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                Text(
                  CurrencyFormatter.formatRp(marketplaceService.cartSubtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(CupertinoIcons.cart_badge_plus, size: 16),
              label: Text(
                isEn ? 'View Cart' : 'Lihat Keranjang',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
