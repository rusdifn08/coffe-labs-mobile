import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/language_service.dart';
import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class MarketplaceOrderHistorySheet extends StatelessWidget {
  final MarketplaceService marketplaceService;

  const MarketplaceOrderHistorySheet({
    super.key,
    required this.marketplaceService,
  });

  static void show(BuildContext context, MarketplaceService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MarketplaceOrderHistorySheet(marketplaceService: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final orders = marketplaceService.orders;

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
                  onPressed: () => Navigator.pop(context),
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
                                      CurrencyFormatter.formatRp(item.totalPrice),
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
                                  CurrencyFormatter.formatRp(o.total),
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
  }
}
