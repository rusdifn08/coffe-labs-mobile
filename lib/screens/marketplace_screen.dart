import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/marketplace/widgets/marketplace_cart_bar.dart';
import '../features/marketplace/widgets/marketplace_filter_section.dart';
import '../features/marketplace/widgets/marketplace_header_banner.dart';
import '../features/marketplace/widgets/marketplace_order_history_sheet.dart';
import '../features/marketplace/widgets/marketplace_product_card.dart';
import '../models/marketplace_model.dart';
import '../services/language_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedCategory = 'All';
  String _selectedRoast = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Single Origin',
    'House Blend',
    'Washed',
    'Natural',
    'Anaerobic',
  ];

  final List<String> _roastFilters = [
    'All',
    'Light',
    'Medium',
    'Medium-Dark',
    'Dark',
  ];

  @override
  void initState() {
    super.initState();
    _marketplaceService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _marketplaceService.removeListener(_onServiceUpdate);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<MarketplaceProduct> _getFilteredProducts() {
    final query = _searchQuery.toLowerCase();
    return _marketplaceService.products.where((p) {
      // Search text
      if (query.isNotEmpty) {
        final match = p.name.toLowerCase().contains(query) ||
            p.roasteryName.toLowerCase().contains(query) ||
            p.origin.toLowerCase().contains(query) ||
            p.tastingNotes.any((n) => n.toLowerCase().contains(query));
        if (!match) return false;
      }

      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Single Origin' && p.origin.toLowerCase().contains('blend')) {
          return false;
        }
        if (_selectedCategory == 'House Blend' && !p.origin.toLowerCase().contains('blend')) {
          return false;
        }
        if (_selectedCategory == 'Washed' && !p.process.toLowerCase().contains('washed')) {
          return false;
        }
        if (_selectedCategory == 'Natural' && !p.process.toLowerCase().contains('natural')) {
          return false;
        }
        if (_selectedCategory == 'Anaerobic' && !p.process.toLowerCase().contains('anaerobic')) {
          return false;
        }
      }

      // Roast filter
      if (_selectedRoast != 'All') {
        if (!p.roastProfile.toLowerCase().contains(_selectedRoast.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final filtered = _getFilteredProducts();
    final cartCount = _marketplaceService.cartCount;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          isEn ? 'Roastery Marketplace' : 'Marketplace Roastery',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          // Order History
          IconButton(
            tooltip: isEn ? 'Order History' : 'Riwayat Pesanan',
            icon: const Icon(CupertinoIcons.doc_text_search),
            onPressed: () => MarketplaceOrderHistorySheet.show(context, _marketplaceService),
          ),
          // Shopping Cart with live counter
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: isEn ? 'Shopping Cart' : 'Keranjang Belanja',
                icon: const Icon(CupertinoIcons.cart_fill, color: AppTheme.primaryBrown),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Promo Spotlight Banner
          SliverToBoxAdapter(
            child: MarketplaceHeaderBanner(isEn: isEn),
          ),

          // 2. Search Field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: isEn ? 'Search beans, roasteries, tasting notes...' : 'Cari biji kopi, roastery, profil rasa...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // 3 & 4. Process & Category + Roast Filter Chips
          SliverToBoxAdapter(
            child: MarketplaceFilterSection(
              isEn: isEn,
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
              roastFilters: _roastFilters,
              selectedRoast: _selectedRoast,
              onSelectRoast: (rf) => setState(() => _selectedRoast = rf),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // 5. Products Grid
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(CupertinoIcons.search, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          isEn ? 'No coffee beans found' : 'Tidak ada biji kopi ditemukan',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEn ? 'Try adjusting your search or category filters' : 'Coba ubah kata kunci atau filter kategori Anda',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 275,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filtered[index];
                        return MarketplaceProductCard(
                          product: product,
                          isEn: isEn,
                          onAddedToCart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEn
                                      ? 'Added ${product.name} (100g) to cart'
                                      : 'Berhasil menambahkan ${product.name} (100g) ke keranjang',
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
        ],
      ),
      // Sticky bottom Cart quick bar if items in cart
      bottomSheet: MarketplaceCartBar(
        isEn: isEn,
        marketplaceService: _marketplaceService,
      ),
    );
  }
}
