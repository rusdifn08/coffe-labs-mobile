import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';

class CartVoucherCard extends StatefulWidget {
  final bool isEn;
  final MarketplaceService marketplaceService;

  const CartVoucherCard({
    super.key,
    required this.isEn,
    required this.marketplaceService,
  });

  @override
  State<CartVoucherCard> createState() => _CartVoucherCardState();
}

class _CartVoucherCardState extends State<CartVoucherCard> {
  final TextEditingController _voucherCtrl = TextEditingController();
  String? _voucherError;

  @override
  void dispose() {
    _voucherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEn;
    final marketplaceService = widget.marketplaceService;

    return Container(
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
          if (marketplaceService.appliedVoucher != null)
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
                      marketplaceService.appliedVoucher!,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      marketplaceService.removeVoucher();
                      setState(() {});
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
                      final success = marketplaceService.applyVoucher(_voucherCtrl.text);
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
    );
  }

  Widget _buildPromoChip(String label) {
    return InkWell(
      onTap: () {
        final code = label.split(' ')[0];
        widget.marketplaceService.applyVoucher(code);
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
}
