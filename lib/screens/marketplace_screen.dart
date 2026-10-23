import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/marketplace_model.dart';
import '../services/language_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'marketplace_product_detail_screen.dart';

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

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
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
            onPressed: () => _showOrderHistorySheet(context),
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
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBrown, Color(0xFF2C1810)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEn ? 'SPECIALTY ROASTERY DIRECT' : 'LANGSUNG DARI ROASTERY',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.accentGold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn ? 'Fresh Beans from 50+ Top Roasters' : 'Biji Segar dari 50+ Roastery Nasional',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEn
                              ? 'Roasted to order. Use voucher COFFEEFIRST for 15% discount.'
                              : 'Disangrai segar tiap batch. Gunakan voucher COFFEEFIRST untuk diskon 15%.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.accentGold, size: 26),
                  ),
                ],
              ),
            ),
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

          // 3. Process & Category Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.25),
                      ),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          // 4. Roast Profile Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Text(
                    isEn ? 'Roast:' : 'Sangrai:',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _roastFilters.map((rf) {
                          final isSel = _selectedRoast == rf;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _selectedRoast = rf;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSel ? AppTheme.accentGold.withValues(alpha: 0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel ? AppTheme.accentGold : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  rf,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.normal,
                                    color: isSel ? AppTheme.primaryBrown : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filtered[index];
                        return _buildProductCard(context, product, isEn);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
        ],
      ),
      // Sticky bottom Cart quick bar if items in cart
      bottomSheet: cartCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$cartCount ${isEn ? "items in cart" : "item di keranjang"}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                        Text(
                          _formatCurrency(_marketplaceService.cartSubtotal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(CupertinoIcons.cart_badge_plus, size: 16),
                      label: Text(
                        isEn ? 'View Cart' : 'Lihat Keranjang',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProductCard(BuildContext context, MarketplaceProduct product, bool isEn) {
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
                        _formatCurrency(product.price100g),
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
                      _marketplaceService.addToCart(
                        product: product,
                        bagSize: '100g',
                        grindOption: 'Whole Beans',
                        quantity: 1,
                      );
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

  void _showOrderHistorySheet(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final orders = _marketplaceService.orders;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      isEn ? 'Your Orders & Fresh Roasts' : 'Pesanan & Sangrai Segar Anda',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.bag, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 10),
                            Text(
                              isEn ? 'No orders yet' : 'Belum ada pesanan',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEn ? 'Your placed coffee orders will appear here' : 'Pesanan biji kopi Anda akan tercatat di sini',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final o = orders[idx];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCream,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      o.orderId,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        o.status,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...o.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${item.quantity}x ',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${item.product.name} (${item.bagSize}, ${item.grindOption})',
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(item.totalPrice),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${o.courierName} • ${o.paymentMethod}',
                                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                                    ),
                                    Text(
                                      _formatCurrency(o.total),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBrown,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
