import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/marketplace_model.dart';
import '../../../screens/marketplace_product_detail_screen.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class MarketplaceProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final bool isEn;
  final VoidCallback onAddedToCart;

  const MarketplaceProductCard({
    super.key,
    required this.product,
    required this.isEn,
    required this.onAddedToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MarketplaceProductDetailScreen(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Roastery & Badge Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.roasteryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                  if (product.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Bean Image / Card Banner with Roast Profile
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      color: AppTheme.bgCream,
                      child: Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(
                          child: Icon(Icons.coffee, color: AppTheme.primaryBrown, size: 36),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.roastProfile,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),

              // Origin
              Text(
                product.origin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),

              // Tasting Notes Chips (up to 2 notes)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: product.tastingNotes.take(2).map((note) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6EFE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A583A),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Rating & Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.formatRp(product.price100g),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      const Text(
                        '/ 100g',
                        style: TextStyle(fontSize: 8.5, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  // Add Button
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      MarketplaceService.instance.addToCart(
                        product: product,
                        bagSize: '100g',
                        grindOption: 'Whole Beans',
                        quantity: 1,
                      );
                      onAddedToCart();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.plus, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
