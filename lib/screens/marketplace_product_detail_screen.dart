import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/marketplace_model.dart';
import '../services/language_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class MarketplaceProductDetailScreen extends StatefulWidget {
  final MarketplaceProduct product;

  const MarketplaceProductDetailScreen({super.key, required this.product});

  @override
  State<MarketplaceProductDetailScreen> createState() => _MarketplaceProductDetailScreenState();
}

class _MarketplaceProductDetailScreenState extends State<MarketplaceProductDetailScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService.instance;

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
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryBrown,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.cart_fill, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      color: AppTheme.primaryBrown,
                      child: const Center(
                        child: Icon(Icons.coffee, size: 70, color: Colors.white54),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.roasteryName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.origin} • ${p.roasteryCity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Specs Ribbon (Rating, Roast, Stock, Freshness)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpecChip(
                          icon: Icons.star,
                          iconColor: Colors.amber,
                          title: '${p.rating} ★',
                          subtitle: '${p.reviewCount} ${isEn ? "reviews" : "ulasan"}',
                        ),
                        Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
                        _buildSpecChip(
                          icon: CupertinoIcons.flame_fill,
                          iconColor: Colors.orange,
                          title: p.roastProfile,
                          subtitle: isEn ? 'Roast Profile' : 'Profil Sangrai',
                        ),
                        Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
                        _buildSpecChip(
                          icon: CupertinoIcons.checkmark_shield_fill,
                          iconColor: Colors.green,
                          title: '${p.stock} Left',
                          subtitle: isEn ? 'Fresh Stock' : 'Stok Segar',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tasting Notes & Flavors
                  Text(
                    isEn ? 'Sensory Tasting Notes' : 'Profil Sensorik & Rasa',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.tastingNotes.map((note) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6EFE7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2D4C3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.sparkles, size: 12, color: AppTheme.primaryBrown),
                            const SizedBox(width: 4),
                            Text(
                              note,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Origin & Lot Technical Details
                  Text(
                    isEn ? 'Farm & Processing Specifications' : 'Spesifikasi Kebun & Proses',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(isEn ? 'Processing' : 'Proses Pasca Panen', p.process),
                        const Divider(height: 16),
                        _buildDetailRow(isEn ? 'Variety' : 'Varietas Kopi', p.variety),
                        const Divider(height: 16),
                        _buildDetailRow(isEn ? 'Altitude' : 'Ketinggian Kebun', p.altitudeMasl),
                        const Divider(height: 16),
                        _buildDetailRow(isEn ? 'Producer' : 'Produser / Koperasi', p.producer),
                        const Divider(height: 16),
                        _buildDetailRow(isEn ? 'Freshness' : 'Waktu Sangrai', p.roastDate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Recommended Brew Method
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.lightbulb_fill, color: AppTheme.primaryBrown, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? 'Roaster Recommended Recipe' : 'Saran Seduh dari Roaster',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.recommendedMethod,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Story / Description
                  Text(
                    isEn ? 'About this Lot' : 'Tentang Kopi Ini',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.description,
                    style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 22),

                  // 1. Choose Bag Size
                  Text(
                    isEn ? 'Select Packaging Size' : 'Pilih Ukuran Kemasan',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _bagSizes.map((size) {
                      final isSel = _selectedBagSize == size;
                      final price = p.getPriceForSize(size);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedBagSize = size;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.primaryBrown : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.3),
                                  width: isSel ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    size,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSel ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrency(price),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSel ? AppTheme.accentGold : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 2. Choose Grind Option
                  Text(
                    isEn ? 'Select Grind Profile' : 'Pilih Profil Gilingan',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _grindOptions.map((opt) {
                      final isSel = _selectedGrind == opt;
                      return ChoiceChip(
                        label: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppTheme.primaryBrown,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSel ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedGrind = opt;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 3. Quantity Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEn ? 'Quantity' : 'Jumlah Pesanan',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.minus, size: 14),
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.plus, size: 14),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Bottom Action Bar
      bottomSheet: Container(
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
                    isEn ? 'Total Price' : 'Total Harga',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Text(
                    _formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Add to Cart
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _marketplaceService.addToCart(
                      product: p,
                      bagSize: _selectedBagSize,
                      grindOption: _selectedGrind,
                      quantity: _quantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEn
                              ? 'Added to Cart: ${p.name} ($_selectedBagSize)'
                              : 'Ditambahkan ke keranjang: ${p.name} ($_selectedBagSize)',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryBrown),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(CupertinoIcons.cart_badge_plus, size: 16, color: AppTheme.primaryBrown),
                  label: Text(
                    isEn ? '+ Cart' : '+ Keranjang',
                    style: const TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Buy Now
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _marketplaceService.addToCart(
                      product: p,
                      bagSize: _selectedBagSize,
                      grindOption: _selectedGrind,
                      quantity: _quantity,
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEn ? 'Buy Now' : 'Beli Sekarang',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
      ],
    );
  }
}
