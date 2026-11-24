import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/marketplace_model.dart';
import '../../../screens/marketplace_product_detail_screen.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'coffee_bag_product_visual.dart';

/// Kartu produk kopi profesional bergaya Shopee Mall / Tokopedia Official Store:
/// harga bersih tanpa diskon/voucher palsu, badge Official terverifikasi, & tombol Wishlist.
class ShopeeCoffeeProductCard extends StatelessWidget {
  final MarketplaceProduct product;

  const ShopeeCoffeeProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final service = MarketplaceService.instance;
    final isFav = service.isFavorite(product.id);

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MarketplaceProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEDE4D7), width: 0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full-Bleed 1:1 Coffee Bag Visual
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CoffeeBagProductVisual(product: product),
                      if (product.isMallRoastery)
                        Positioned(
                          top: 8,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBrown,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 9,
                                  color: Color(0xFFFDE68A),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Official',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Tombol Wishlist elegan di kanan atas
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => service.toggleFavorite(product.id),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              size: 14,
                              color: isFav
                                  ? const Color(0xFFDC2626)
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.roastProfile,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Card Body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.roasteryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Flexible(
                              child: _microTag(
                                product.process,
                                const Color(0xFFFAF3EA),
                                AppTheme.primaryBrown,
                              ),
                            ),
                            if (product.badge != null &&
                                product.badge!.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: _microTag(
                                  product.badge!,
                                  const Color(0xFFF0FDF4),
                                  const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Text(
                          CurrencyFormatter.formatRp(product.price200g),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '| ${product.formattedSoldCount}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.location_solid,
                              size: 10,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                product.roasteryCity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _microTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
