import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../screens/checkout_screen.dart';
import '../../../services/language_service.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../cart/widgets/cart_empty_state.dart';
import '../../cart/widgets/cart_item_tile.dart';
import '../../cart/widgets/cart_summary_card.dart';
import '../utils/currency_formatter.dart';

/// Tab 4 Marketplace: Keranjang Belanja terintegrasi di dalam bottom navbar
/// (harga transparan tanpa voucher, langsung ke Checkout QRIS).
class MarketplaceCartTab extends StatelessWidget {
  final MarketplaceService marketplaceService;
  final VoidCallback onExploreTap;

  const MarketplaceCartTab({
    super.key,
    required this.marketplaceService,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final items = marketplaceService.cartItems;
    final subtotal = marketplaceService.cartSubtotal;
    const shipping = 18000;
    final grandTotal = (subtotal + shipping).clamp(0, 99999999);

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.primaryBrown,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 14,
            12,
            14,
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.cart_fill, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'Shopping Cart (${marketplaceService.cartCount})'
                      : 'Keranjang (${marketplaceService.cartCount})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: marketplaceService.clearCart,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  child: Text(
                    isEn ? 'Clear' : 'Kosongkan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? CartEmptyState(
                  isEn: isEn,
                  onExplore: onExploreTap,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  children: [
                    ...items.map((item) => CartItemTile(item: item)),
                    const SizedBox(height: 12),
                    CartSummaryCard(
                      isEn: isEn,
                      subtotal: subtotal,
                      shipping: shipping,
                      discount: 0,
                      grandTotal: grandTotal,
                    ),
                  ],
                ),
        ),
        if (items.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEDE4D7))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEn ? 'Total Payment' : 'Total Pembayaran',
                        style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                      ),
                      Text(
                        CurrencyFormatter.formatRp(grandTotal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.qrcode, size: 15),
                  label: Text(
                    isEn ? 'Checkout QRIS' : 'Checkout QRIS',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
