import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/marketplace_model.dart';
import '../../../theme/app_theme.dart';
import '../../marketplace/utils/currency_formatter.dart';
import '../../marketplace/widgets/coffee_bag_product_visual.dart';

class MarketplaceVariantSelection {
  final String bagSize;
  final String grindOption;
  final int quantity;
  final bool buyNow;

  const MarketplaceVariantSelection({
    required this.bagSize,
    required this.grindOption,
    required this.quantity,
    required this.buyNow,
  });
}

class MarketplaceVariantPickerSheet extends StatefulWidget {
  final MarketplaceProduct product;
  final String initialSize;
  final String initialGrind;
  final int initialQty;
  final bool buyNow;

  const MarketplaceVariantPickerSheet({
    super.key,
    required this.product,
    required this.initialSize,
    required this.initialGrind,
    required this.initialQty,
    required this.buyNow,
  });

  static Future<MarketplaceVariantSelection?> show(
    BuildContext context, {
    required MarketplaceProduct product,
    String initialSize = '200g',
    String initialGrind = 'Biji Utuh (Whole Bean)',
    int initialQty = 1,
    required bool buyNow,
  }) {
    return showModalBottomSheet<MarketplaceVariantSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => MarketplaceVariantPickerSheet(
        product: product,
        initialSize: initialSize,
        initialGrind: initialGrind,
        initialQty: initialQty,
        buyNow: buyNow,
      ),
    );
  }

  @override
  State<MarketplaceVariantPickerSheet> createState() =>
      _MarketplaceVariantPickerSheetState();
}

class _MarketplaceVariantPickerSheetState
    extends State<MarketplaceVariantPickerSheet> {
  late String _size;
  late String _grind;
  late int _qty;

  static const _sizes = ['100g', '200g', '250g'];
  static const _grinds = [
    'Biji Utuh (Whole Bean)',
    'Giling Sedang (V60/Filter)',
    'Giling Halus (Espresso)',
    'Aeropress',
    'Giling Kasar (Cold Brew)',
  ];

  @override
  void initState() {
    super.initState();
    _size = _sizes.contains(widget.initialSize) ? widget.initialSize : '200g';
    _grind = widget.initialGrind;
    _qty = widget.initialQty < 1 ? 1 : widget.initialQty;
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = widget.product.getPriceForSize(_size);
    final total = unitPrice * _qty;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: CoffeeBagProductVisual(
                  product: widget.product,
                  size: 82,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.formatRp(unitPrice),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok tersedia: ${widget.product.stock} kemasan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      'Dipilih: $_size • $_grind',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(CupertinoIcons.xmark_circle_fill,
                    color: AppTheme.textMuted),
              ),
            ],
          ),
          const Divider(height: 22),
          const Text(
            'Pilih Berat Kemasan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sizes.map((s) {
              final active = _size == s;
              return ChoiceChip(
                label: Text('$s (${CurrencyFormatter.formatRp(widget.product.getPriceForSize(s))})'),
                selected: active,
                onSelected: (_) => setState(() => _size = s),
                selectedColor: const Color(0xFFFFF1E6),
                backgroundColor: const Color(0xFFF6F4F0),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: active ? const Color(0xFFC2410C) : AppTheme.textDark,
                ),
                side: BorderSide(
                  color: active
                      ? const Color(0xFFEA580C)
                      : const Color(0xFFE6DCCE),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            'Pilih Gilingan (Grind Size)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _grinds.map((g) {
              final active = _grind == g;
              return ChoiceChip(
                label: Text(g),
                selected: active,
                onSelected: (_) => setState(() => _grind = g),
                selectedColor: const Color(0xFFFFF1E6),
                backgroundColor: const Color(0xFFF6F4F0),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: active ? const Color(0xFFC2410C) : AppTheme.textDark,
                ),
                side: BorderSide(
                  color: active
                      ? const Color(0xFFEA580C)
                      : const Color(0xFFE6DCCE),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 22),
          Row(
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              _qtyBtn(
                icon: CupertinoIcons.minus,
                onTap: _qty > 1 ? () => setState(() => _qty--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_qty',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              _qtyBtn(
                icon: CupertinoIcons.plus,
                onTap: () => setState(() => _qty++),
              ),
            ],
          ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEE6DA))),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  MarketplaceVariantSelection(
                    bagSize: _size,
                    grindOption: _grind,
                    quantity: _qty,
                    buyNow: widget.buyNow,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.buyNow
                      ? 'Beli Sekarang via QRIS (${CurrencyFormatter.formatRp(total)})'
                      : 'Masukkan Keranjang (${CurrencyFormatter.formatRp(total)})',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F4F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE3D8C8)),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null ? AppTheme.textDark : AppTheme.textMuted,
        ),
      ),
    );
  }
}
