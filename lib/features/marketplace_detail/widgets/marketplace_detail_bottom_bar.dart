import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/roastery_catalog.dart';
import '../../../models/marketplace_model.dart';
import '../../../screens/checkout_screen.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../roastery/screens/roastery_detail_screen.dart';
import 'marketplace_variant_picker_sheet.dart';

class MarketplaceDetailBottomBar extends StatelessWidget {
  final MarketplaceProduct product;
  final bool isEn;
  final String selectedBagSize;
  final String selectedGrind;
  final int quantity;
  final int totalPrice;
  final void Function(MarketplaceVariantSelection sel)? onVariantUpdated;

  const MarketplaceDetailBottomBar({
    super.key,
    required this.product,
    required this.isEn,
    required this.selectedBagSize,
    required this.selectedGrind,
    required this.quantity,
    required this.totalPrice,
    this.onVariantUpdated,
  });

  Future<void> _openVariantPicker(
    BuildContext context, {
    required bool buyNow,
  }) async {
    final res = await MarketplaceVariantPickerSheet.show(
      context,
      product: product,
      initialSize: selectedBagSize,
      initialGrind: selectedGrind,
      initialQty: quantity,
      buyNow: buyNow,
    );
    if (res == null || !context.mounted) return;
    onVariantUpdated?.call(res);

    await MarketplaceService.instance.addToCart(
      product: product,
      bagSize: res.bagSize,
      grindOption: res.grindOption,
      quantity: res.quantity,
    );
    if (!context.mounted) return;

    if (res.buyNow) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ditambahkan ke keranjang: ${product.name} (${res.bagSize})',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _visitRoastery(BuildContext context) {
    final match = RoasteryCatalog.list.where((r) => r.id == product.roasteryId);
    if (match.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoasteryDetailScreen(roastery: match.first),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toko ${product.roasteryName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEEE6DA))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => _visitRoastery(context),
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: AppTheme.primaryBrown,
                      size: 20,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Roastery',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              height: 28,
              color: const Color(0xFFE7DED2),
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openVariantPicker(context, buyNow: false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBrown),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  CupertinoIcons.cart_badge_plus,
                  size: 16,
                  color: AppTheme.primaryBrown,
                ),
                label: const Text(
                  '+ Keranjang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openVariantPicker(context, buyNow: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Beli Sekarang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
