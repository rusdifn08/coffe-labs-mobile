import 'package:flutter/material.dart';
import '../features/cart/widgets/cart_checkout_bottom_bar.dart';
import '../features/cart/widgets/cart_empty_state.dart';
import '../features/cart/widgets/cart_item_tile.dart';
import '../features/cart/widgets/cart_summary_card.dart';
import '../features/cart/widgets/cart_voucher_card.dart';
import '../services/language_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService.instance;

  @override
  void initState() {
    super.initState();
    _marketplaceService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _marketplaceService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final items = _marketplaceService.cartItems;
    final subtotal = _marketplaceService.cartSubtotal;
    final discount = _marketplaceService.voucherDiscount;
    const defaultShipping = 18000;
    final shipping = _marketplaceService.appliedVoucher?.contains('FREESHIP') == true ? 0 : defaultShipping;
    final grandTotal = (subtotal + shipping - discount).clamp(0, 99999999);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          isEn ? 'Shopping Cart' : 'Keranjang Belanja',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                _marketplaceService.clearCart();
              },
              child: Text(
                isEn ? 'Clear' : 'Kosongkan',
                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? CartEmptyState(
              isEn: isEn,
              onExplore: () => Navigator.pop(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                // Cart Items List
                ...items.map((item) => CartItemTile(item: item)),

                const SizedBox(height: 8),

                // Voucher Promo Box
                CartVoucherCard(
                  isEn: isEn,
                  marketplaceService: _marketplaceService,
                ),

                const SizedBox(height: 14),

                // Order Price Summary
                CartSummaryCard(
                  isEn: isEn,
                  subtotal: subtotal,
                  shipping: shipping,
                  discount: discount,
                  grandTotal: grandTotal,
                ),
              ],
            ),
      // Bottom Checkout Button
      bottomSheet: items.isNotEmpty
          ? CartCheckoutBottomBar(
              isEn: isEn,
              grandTotal: grandTotal,
            )
          : null,
    );
  }
}
