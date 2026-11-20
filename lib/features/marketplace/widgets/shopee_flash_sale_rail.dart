import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/marketplace_model.dart';
import '../../../screens/marketplace_product_detail_screen.dart';
import '../utils/currency_formatter.dart';
import 'coffee_bag_product_visual.dart';

class ShopeeFlashSaleRail extends StatefulWidget {
  final List<MarketplaceProduct> deals;
  final VoidCallback onSeeAllTap;

  const ShopeeFlashSaleRail({
    super.key,
    required this.deals,
    required this.onSeeAllTap,
  });

  @override
  State<ShopeeFlashSaleRail> createState() => _ShopeeFlashSaleRailState();
}

class _ShopeeFlashSaleRailState extends State<ShopeeFlashSaleRail> {
  final ValueNotifier<int> _secondsRemaining = ValueNotifier<int>(8078);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining.value > 0) {
        _secondsRemaining.value -= 1;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsRemaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(12, 10, 0, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Flexible(
                  child: Text(
                    '⚡ FRESH DEALS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFEA580C),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                ValueListenableBuilder<int>(
                  valueListenable: _secondsRemaining,
                  builder: (_, sec, _) {
                    final h = (sec ~/ 3600).toString().padLeft(2, '0');
                    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
                    final s = (sec % 60).toString().padLeft(2, '0');
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _timeBox(h),
                        const Text(':',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 10)),
                        _timeBox(m),
                        const Text(':',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 10)),
                        _timeBox(s),
                      ],
                    );
                  },
                ),
                const Spacer(),
                InkWell(
                  onTap: widget.onSeeAllTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Semua',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_right,
                          size: 11.5, color: Color(0xFFEA580C)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 174,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 12),
              itemCount: widget.deals.take(10).length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final item = widget.deals[idx];
                return RepaintBoundary(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MarketplaceProductDetailScreen(product: item),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 118,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDE2D3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: CoffeeBagProductVisual(
                                  product: item,
                                  size: 118,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(11),
                                  ),
                                ),
                              ),
                              if (item.discountPct > 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEA580C),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(11),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      '-${item.discountPct}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 5, 6, 4),
                            child: Column(
                              children: [
                                Text(
                                  CurrencyFormatter.formatRp(item.price200g),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFC2410C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '🔥 Sisa ${item.flashSaleStockLeft} bag',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String val) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1610),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
