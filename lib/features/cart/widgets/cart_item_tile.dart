import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/marketplace_model.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final marketplaceService = MarketplaceService.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: AppTheme.bgCream,
              child: Image.asset(
                item.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => const Icon(Icons.coffee, color: AppTheme.primaryBrown),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.roasteryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.bagSize} • ${item.grindOption}',
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.formatRp(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    // Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              marketplaceService.updateQuantity(item.cartKey, -1);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(CupertinoIcons.minus, size: 12),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          InkWell(
                            onTap: () {
                              marketplaceService.updateQuantity(item.cartKey, 1);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(CupertinoIcons.plus, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
