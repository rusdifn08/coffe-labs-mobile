import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService.instance;
  final TextEditingController _voucherCtrl = TextEditingController();
  String? _voucherError;

  @override
  void initState() {
    super.initState();
    _marketplaceService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _marketplaceService.removeListener(_onServiceUpdate);
    _voucherCtrl.dispose();
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.cart, size: 40, color: AppTheme.primaryBrown),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEn ? 'Your Cart is Empty' : 'Keranjang Masih Kosong',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEn
                          ? 'Explore fresh artisan beans from 50+ award-winning roasteries!'
                          : 'Jelajahi biji kopi segar dari 50+ roastery juara nasional!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEn ? 'Explore Beans' : 'Cari Biji Kopi',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                // Cart Items List
                ...items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: AppTheme.bgCream,
                            child: Image.asset(
                              item.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => const Icon(Icons.coffee, color: AppTheme.primaryBrown),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.roasteryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.bagSize} • ${item.grindOption}',
                                style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatCurrency(item.totalPrice),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                  // Stepper
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgCream,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _marketplaceService.updateQuantity(item.cartKey, -1);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Icon(CupertinoIcons.minus, size: 12),
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _marketplaceService.updateQuantity(item.cartKey, 1);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Icon(CupertinoIcons.plus, size: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Voucher Promo Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.tag_fill, size: 16, color: AppTheme.accentAmber),
                          const SizedBox(width: 6),
                          Text(
                            isEn ? 'Voucher & Promo Code' : 'Voucher & Kode Promo',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_marketplaceService.appliedVoucher != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 14, color: Colors.green),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _marketplaceService.appliedVoucher!,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _marketplaceService.removeVoucher();
                                },
                                child: const Icon(Icons.close, size: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _voucherCtrl,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: isEn ? 'Enter promo code' : 'Masukkan kode voucher',
                                  hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  filled: true,
                                  fillColor: AppTheme.bgCream,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_voucherCtrl.text.trim().isNotEmpty) {
                                  final success = _marketplaceService.applyVoucher(_voucherCtrl.text);
                                  if (!success) {
                                    setState(() {
                                      _voucherError = isEn ? 'Invalid promo code' : 'Kode promo tidak valid';
                                    });
                                  } else {
                                    setState(() {
                                      _voucherError = null;
                                    });
                                    _voucherCtrl.clear();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBrown,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                isEn ? 'Apply' : 'Pakai',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      if (_voucherError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _voucherError!,
                            style: const TextStyle(color: Colors.red, fontSize: 10.5),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Quick Tap Promo Chips
                      Wrap(
                        spacing: 6,
                        children: [
                          _buildPromoChip('COFFEEFIRST (-15%)'),
                          _buildPromoChip('FREESHIP (Free Delivery)'),
                          _buildPromoChip('BARISTA20 (-20%)'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Order Price Summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(isEn ? 'Subtotal' : 'Subtotal Produk', _formatCurrency(subtotal)),
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        isEn ? 'Courier Shipping' : 'Ongkos Kirim',
                        shipping == 0 ? (isEn ? 'FREE' : 'GRATIS') : _formatCurrency(shipping),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          isEn ? 'Voucher Discount' : 'Diskon Promo',
                          '-${_formatCurrency(discount)}',
                          valueColor: Colors.green,
                        ),
                      ],
                      const Divider(height: 18),
                      _buildSummaryRow(
                        isEn ? 'Total Payment' : 'Total Pembayaran',
                        _formatCurrency(grandTotal),
                        isBold: true,
                        fontSize: 15,
                        valueColor: AppTheme.primaryBrown,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      // Bottom Checkout Button
      bottomSheet: items.isNotEmpty
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
                          isEn ? 'Total Payment' : 'Total Tagihan',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                        Text(
                          _formatCurrency(grandTotal),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEn ? 'Checkout Now →' : 'Checkout Sekarang →',
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

  Widget _buildPromoChip(String label) {
    return InkWell(
      onTap: () {
        final code = label.split(' ')[0];
        _marketplaceService.applyVoucher(code);
        setState(() {
          _voucherError = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 12,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.textDark : AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
