import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import 'shopee_coffee_product_card.dart';

/// Tab 3 Marketplace: Favorit / Wishlist Produk Kopi Tersimpan.
class MarketplaceWishlistTab extends StatelessWidget {
  final MarketplaceService marketplaceService;
  final VoidCallback onExploreTap;

  const MarketplaceWishlistTab({
    super.key,
    required this.marketplaceService,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = marketplaceService.favoriteProducts;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.primaryBrown,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 14,
            16,
            14,
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Favorit Saya (${favorites.length})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.heart,
                            size: 32,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum Ada Kopi Favorit',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ketuk ikon hati pada kartu biji kopi agar mudah dibandingkan dan dibeli nanti.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: onExploreTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Jelajahi Biji Kopi',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) => ShopeeCoffeeProductCard(
                    product: favorites[index],
                  ),
                ),
        ),
      ],
    );
  }
}
