import 'package:flutter/material.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_bottom_bar.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_header.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_specs.dart';
import '../features/marketplace_detail/widgets/marketplace_detail_variants.dart';
import '../models/marketplace_model.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class MarketplaceProductDetailScreen extends StatefulWidget {
  final MarketplaceProduct product;

  const MarketplaceProductDetailScreen({super.key, required this.product});

  @override
  State<MarketplaceProductDetailScreen> createState() => _MarketplaceProductDetailScreenState();
}

class _MarketplaceProductDetailScreenState extends State<MarketplaceProductDetailScreen> {
  String _selectedBagSize = '200g';
  String _selectedGrind = 'Whole Beans';
  int _quantity = 1;

  final List<String> _bagSizes = ['100g', '200g', '250g'];
  final List<String> _grindOptions = [
    'Whole Beans',
    'V60 / Filter',
    'Espresso',
    'Aeropress',
    'Cold Brew / French Press',
  ];

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
          // 1. Hero Image Header SliverAppBar
          MarketplaceDetailHeader(product: p),

          // 2. Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Specs, Tasting notes, Lot specs, Story
                  MarketplaceDetailSpecs(
                    product: p,
                    isEn: isEn,
                  ),
                  const SizedBox(height: 22),

                  // Variants (Bag size, Grind, Quantity)
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
                    onDecrementQuantity: () => setState(() => _quantity--),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Bottom Action Bar
      bottomSheet: MarketplaceDetailBottomBar(
        product: p,
        isEn: isEn,
        selectedBagSize: _selectedBagSize,
        selectedGrind: _selectedGrind,
        quantity: _quantity,
        totalPrice: totalPrice,
      ),
    );
  }
}
