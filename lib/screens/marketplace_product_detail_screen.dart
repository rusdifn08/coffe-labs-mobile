import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/widgets/optimized_coffee_image.dart';
import '../data/roastery_catalog.dart';
import '../features/marketplace/utils/currency_formatter.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_bottom_bar.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_header.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_specs.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_variants.dart';
import '../features/roastery/screens/roastery_detail_screen.dart';
import '../models/marketplace_model.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class MarketplaceProductDetailScreen extends StatefulWidget {
  final MarketplaceProduct product;

  const MarketplaceProductDetailScreen({super.key, required this.product});

  @override
  State<MarketplaceProductDetailScreen> createState() =>
      _MarketplaceProductDetailScreenState();
}

class _MarketplaceProductDetailScreenState
    extends State<MarketplaceProductDetailScreen> {
  String _selectedBagSize = '200g';
  String _selectedGrind = 'Biji Utuh (Whole Bean)';
  int _quantity = 1;

  final List<String> _bagSizes = ['100g', '200g', '250g'];
  final List<String> _grindOptions = [
    'Biji Utuh (Whole Bean)',
    'Giling Sedang (V60/Filter)',
    'Giling Halus (Espresso)',
    'Aeropress',
    'Giling Kasar (Cold Brew)',
  ];

  void _visitRoastery() {
    final p = widget.product;
    final found = RoasteryCatalog.list.where((r) => r.id == p.roasteryId);
    if (found.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoasteryDetailScreen(roastery: found.first),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final p = widget.product;
    final currentUnitPrice = p.getPriceForSize(_selectedBagSize);
    final totalPrice = currentUnitPrice * _quantity;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        slivers: [
          MarketplaceDetailHeader(product: p),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shopee-Style Price & Sales Header Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDE4D7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              CurrencyFormatter.formatRp(currentUnitPrice),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFC2410C),
                              ),
                            ),
                            if (p.originalPrice200g != null &&
                                p.discountPct > 0) ...[
                              Text(
                                CurrencyFormatter.formatRp(p.originalPrice200g!),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${p.discountPct}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (p.isMallRoastery)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B4513),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'Roastery Mall',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 15, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 3),
                            Text(
                              p.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '  |  ${p.formattedSoldCount}  |  QRIS Ready',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kartu Profil Toko Penjual Roastery
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDE4D7)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F1E8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: OptimizedCoffeeImage(
                              imageUrlOrAsset: p.roasteryLogoUrl,
                              width: 38,
                              height: 38,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.roasteryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.location_solid,
                                      size: 11, color: AppTheme.textMuted),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      p.roasteryCity,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _visitRoastery,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBrown,
                            side: const BorderSide(color: AppTheme.primaryBrown),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Kunjungi Roastery',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  MarketplaceDetailSpecs(
                    product: p,
                    isEn: isEn,
                  ),
                  const SizedBox(height: 18),

                  MarketplaceDetailVariants(
                    product: p,
                    isEn: isEn,
                    selectedBagSize: _selectedBagSize,
                    bagSizes: _bagSizes,
                    onSelectBagSize: (s) => setState(() => _selectedBagSize = s),
                    selectedGrind: _selectedGrind,
                    grindOptions: _grindOptions,
                    onSelectGrind: (g) => setState(() => _selectedGrind = g),
                    quantity: _quantity,
                    onIncrementQuantity: () => setState(() => _quantity++),
                    onDecrementQuantity: () =>
                        setState(() => _quantity > 1 ? _quantity-- : null),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MarketplaceDetailBottomBar(
        product: p,
        isEn: isEn,
        selectedBagSize: _selectedBagSize,
        selectedGrind: _selectedGrind,
        quantity: _quantity,
        totalPrice: totalPrice,
        onVariantUpdated: (sel) {
          setState(() {
            _selectedBagSize = sel.bagSize;
            _selectedGrind = sel.grindOption;
            _quantity = sel.quantity;
          });
        },
      ),
    );
  }
}
