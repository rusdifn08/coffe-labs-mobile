import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/bean_scanner/widgets/smart_bean_camera_popup_modal.dart';
import '../features/marketplace/widgets/marketplace_bottom_nav_bar.dart';
import '../features/marketplace/widgets/marketplace_cart_tab.dart';
import '../features/marketplace/widgets/marketplace_filter_sheet.dart';
import '../features/marketplace/widgets/marketplace_official_roastery_rail.dart';
import '../features/marketplace/widgets/marketplace_orders_tab.dart';
import '../features/marketplace/widgets/marketplace_roastery_tab.dart';
import '../features/marketplace/widgets/marketplace_wishlist_tab.dart';
import '../features/marketplace/widgets/shopee_coffee_product_card.dart';
import '../features/marketplace/widgets/shopee_quick_category_row.dart';
import '../features/marketplace/widgets/shopee_sort_filter_bar.dart';
import '../features/marketplace/widgets/shopee_sticky_search_header.dart';
import '../models/marketplace_model.dart';
import '../models/roastery.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';

/// Specialty Coffee Marketplace bergaya Shopee / Tokopedia dengan bottom navbar 5 tab
/// (Beranda · Roastery · Favorit · Keranjang · Pesanan), harga transparan tanpa voucher & Fresh Deals.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  int _activeTab = 0; // 0=Beranda, 1=Roastery, 2=Favorit, 3=Keranjang, 4=Pesanan
  String _selectedCategory = 'All';
  String _selectedRoast = 'All';
  String _selectedProcess = 'All';
  String _selectedSort = 'relevant';
  String _searchQuery = '';
  String? _selectedRoasteryId;
  String? _selectedRoasteryName;

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
      if (_selectedRoasteryId != null && p.roasteryId != _selectedRoasteryId) {
        return false;
      }

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
          final ratingCmp = b.rating.compareTo(a.rating);
          if (ratingCmp != 0) return ratingCmp;
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

  void _selectRoastery(Roastery roastery, {bool jumpToHome = false}) {
    setState(() {
      if (!jumpToHome && _selectedRoasteryId == roastery.id) {
        _selectedRoasteryId = null;
        _selectedRoasteryName = null;
      } else {
        _selectedRoasteryId = roastery.id;
        _selectedRoasteryName = roastery.name;
      }
      if (jumpToHome) _activeTab = 0;
    });
  }

  void _clearAllFilters() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'All';
      _selectedRoast = 'All';
      _selectedProcess = 'All';
      _selectedRoasteryId = null;
      _selectedRoasteryName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = _marketplaceService.cartCount;
    final favCount = _marketplaceService.favoriteCount;
    final orderCount = _marketplaceService.orders.length;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: IndexedStack(
        index: _activeTab,
        children: [
          _buildHomeTab(cartCount),
          MarketplaceRoasteryTab(
            onOpenRoasteryCatalog: (r) => _selectRoastery(r, jumpToHome: true),
          ),
          MarketplaceWishlistTab(
            marketplaceService: _marketplaceService,
            onExploreTap: () => setState(() => _activeTab = 0),
          ),
          MarketplaceCartTab(
            marketplaceService: _marketplaceService,
            onExploreTap: () => setState(() => _activeTab = 0),
          ),
          MarketplaceOrdersTab(
            marketplaceService: _marketplaceService,
            onExploreTap: () => setState(() => _activeTab = 0),
          ),
        ],
      ),
      bottomNavigationBar: MarketplaceBottomNavBar(
        currentIndex: _activeTab,
        favoriteCount: favCount,
        cartCount: cartCount,
        orderCount: orderCount,
        onTap: (idx) => setState(() => _activeTab = idx),
      ),
    );
  }

  Widget _buildHomeTab(int cartCount) {
    final filtered = _getFilteredProducts();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // 1. Sticky Search Header + Kamera AI + Pintasan Keranjang & Pesanan
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
          onCartTap: () => setState(() => _activeTab = 3),
          onHistoryTap: () => setState(() => _activeTab = 4),
        ),

        // 2. Kategori Cepat Kopi & Alat Seduh
        SliverToBoxAdapter(
          child: ShopeeQuickCategoryRow(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
          ),
        ),

        // 3. Trust Guarantee Strip + Rail Official Roastery Pilihan (Tanpa Voucher & Fresh Deals)
        SliverToBoxAdapter(
          child: MarketplaceOfficialRoasteryRail(
            selectedRoasteryId: _selectedRoasteryId,
            onRoasterySelected: (r) => _selectRoastery(r),
            onSeeAllRoasteries: () => setState(() => _activeTab = 1),
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

        // Banner chip aktif jika sedang memfilter etalase roastery tertentu
        if (_selectedRoasteryName != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      size: 15,
                      color: AppTheme.primaryBrown,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Etalase: $_selectedRoasteryName (${filtered.length} produk)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedRoasteryId = null;
                        _selectedRoasteryName = null;
                      }),
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 17,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 5. Grid 2 Kolom Produk Kopi Profesional
        filtered.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 46,
                        color: AppTheme.textMuted,
                      ),
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
                        'Ubah kata kunci pencarian atau reset filter kategori',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _clearAllFilters,
                        child: const Text('Tampilkan Semua Produk'),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.52,
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
    );
  }
}
