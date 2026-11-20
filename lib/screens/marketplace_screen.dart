import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/bean_scanner/widgets/smart_bean_camera_popup_modal.dart';
import '../features/marketplace/widgets/marketplace_cart_bar.dart';
import '../features/marketplace/widgets/marketplace_filter_sheet.dart';
import '../features/marketplace/widgets/marketplace_order_history_sheet.dart';
import '../features/marketplace/widgets/shopee_coffee_product_card.dart';
import '../features/marketplace/widgets/shopee_compact_promo_carousel.dart';
import '../features/marketplace/widgets/shopee_flash_sale_rail.dart';
import '../features/marketplace/widgets/shopee_quick_category_row.dart';
import '../features/marketplace/widgets/shopee_sort_filter_bar.dart';
import '../features/marketplace/widgets/shopee_sticky_search_header.dart';
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
  String _selectedProcess = 'All';
  String _selectedSort = 'relevant';
  String _searchQuery = '';

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
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _marketplaceService.products.where((p) {
      if (query.isNotEmpty) {
        final match = p.name.toLowerCase().contains(query) ||
            p.roasteryName.toLowerCase().contains(query) ||
            p.origin.toLowerCase().contains(query) ||
            p.roasteryCity.toLowerCase().contains(query) ||
            p.tastingNotes.any((n) => n.toLowerCase().contains(query));
        if (!match) return false;
      }

      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Natural') {
          if (!p.process.toLowerCase().contains('natural')) return false;
        } else if (_selectedCategory == 'Washed') {
          if (!p.process.toLowerCase().contains('washed')) return false;
        } else if (p.category != _selectedCategory) {
          return false;
        }
      }

      if (_selectedRoast != 'All') {
        if (!p.roastProfile
            .toLowerCase()
            .contains(_selectedRoast.toLowerCase())) {
          return false;
        }
      }

      if (_selectedProcess != 'All') {
        if (!p.process
            .toLowerCase()
            .contains(_selectedProcess.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    switch (_selectedSort) {
      case 'latest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'bestseller':
        filtered.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'price_asc':
        filtered.sort((a, b) => a.price200g.compareTo(b.price200g));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price200g.compareTo(a.price200g));
        break;
      case 'relevant':
      default:
        filtered.sort((a, b) {
          if (a.isFlashSale != b.isFlashSale) return a.isFlashSale ? -1 : 1;
          return b.soldCount.compareTo(a.soldCount);
        });
        break;
    }

    return filtered;
  }

  Future<void> _openFilterModal() async {
    final res = await MarketplaceFilterSheet.show(
      context,
      initialRoast: _selectedRoast,
      initialProcess: _selectedProcess,
    );
    if (res != null && mounted) {
      setState(() {
        _selectedRoast = res.roast;
        _selectedProcess = res.process;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final filtered = _getFilteredProducts();
    final cartCount = _marketplaceService.cartCount;
    final flashDeals = _marketplaceService.flashSaleProducts;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Paling Atas: Sticky Search Bar + Kamera AI + Keranjang + Riwayat
          ShopeeStickySearchHeader(
            searchController: _searchCtrl,
            searchQuery: _searchQuery,
            cartCount: cartCount,
            onBack: () => Navigator.pop(context),
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onClearSearch: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
            onCameraSearchTap: () => SmartBeanCameraPopupModal.show(context),
            onCartTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            onHistoryTap: () =>
                MarketplaceOrderHistorySheet.show(context, _marketplaceService),
          ),

          // 2. Di Bawah Search Bar: Menu-Menu Berderet ke Samping (Kategori Shopee)
          SliverToBoxAdapter(
            child: ShopeeQuickCategoryRow(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
          ),

          // 3. Banner Promo Tipis + Flash Roast Deals
          const SliverToBoxAdapter(
            child: ShopeeCompactPromoCarousel(),
          ),

          SliverToBoxAdapter(
            child: ShopeeFlashSaleRail(
              deals: flashDeals,
              onSeeAllTap: () => setState(() => _selectedSort = 'bestseller'),
            ),
          ),

          // 4. Sticky Sort & Filter Bar menempel di bawah Search
          SliverPersistentHeader(
            pinned: true,
            delegate: ShopeeSortFilterHeaderDelegate(
              selectedSort: _selectedSort,
              selectedRoast: _selectedRoast,
              onSortSelected: (sort) => setState(() => _selectedSort = sort),
              onFilterTap: _openFilterModal,
            ),
          ),

          // 5. Grid 2 Kolom Produk Kopi Bergaya Shopee
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(CupertinoIcons.search,
                            size: 46, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada produk kopi ditemukan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ubah kata kunci pencarian atau pilih kategori lain',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                              _selectedRoast = 'All';
                              _selectedProcess = 'All';
                            });
                          },
                          child: const Text('Tampilkan Semua Produk'),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    10,
                    10,
                    10,
                    cartCount > 0 ? 86 : 24,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.54,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ShopeeCoffeeProductCard(
                        product: filtered[index],
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomSheet: MarketplaceCartBar(
        isEn: isEn,
        marketplaceService: _marketplaceService,
      ),
    );
  }
}
