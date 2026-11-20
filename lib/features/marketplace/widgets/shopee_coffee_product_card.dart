import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/marketplace_model.dart';
import '../../../screens/marketplace_product_detail_screen.dart';
import '../../../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'coffee_bag_product_visual.dart';

class ShopeeCoffeeProductCard extends StatelessWidget {
  final MarketplaceProduct product;

  const ShopeeCoffeeProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
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
                          top: 6,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B4513),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Mall',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      if (product.discountPct > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '-${product.discountPct}%',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                    ],
                  ),
                ),
                // Card Body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.roasteryName} - ${product.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.2,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                                  const Color(0xFFFFF7ED),
                                  const Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                CurrencyFormatter.formatRp(product.price200g),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ),
                            if (product.originalPrice200g != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  CurrencyFormatter.formatRp(
                                      product.originalPrice200g!),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppTheme.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFF59E0B)),
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
                            const Icon(CupertinoIcons.location_solid,
                                size: 10, color: AppTheme.textMuted),
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
        borderRadius: BorderRadius.circular(4),
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
