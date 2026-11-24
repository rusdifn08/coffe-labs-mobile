import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/marketplace_service.dart';
import '../../../theme/app_theme.dart';
import '../../checkout/widgets/checkout_receipt_sheet.dart';
import '../../checkout/widgets/qris_payment_sheet.dart';
import '../utils/currency_formatter.dart';

/// Tab 5 Marketplace: Daftar Transaksi & Pesanan Saya bergaya Shopee / Tokopedia.
class MarketplaceOrdersTab extends StatefulWidget {
  final MarketplaceService marketplaceService;
  final VoidCallback onExploreTap;

  const MarketplaceOrdersTab({
    super.key,
    required this.marketplaceService,
    required this.onExploreTap,
  });

  @override
  State<MarketplaceOrdersTab> createState() => _MarketplaceOrdersTabState();
}

class _MarketplaceOrdersTabState extends State<MarketplaceOrdersTab> {
  String _statusFilter = 'all'; // 'all' | 'pending' | 'paid'

  @override
  Widget build(BuildContext context) {
    final allOrders = widget.marketplaceService.orders;
    final filtered = allOrders.where((o) {
      if (_statusFilter == 'pending') return o.paymentStatus != 'PAID';
      if (_statusFilter == 'paid') return o.paymentStatus == 'PAID';
      return true;
    }).toList(growable: false);

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.primaryBrown,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 14,
            16,
            14,
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.doc_text_fill, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pesanan Saya (${allOrders.length})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _OrderFilterChip(
                label: 'Semua',
                selected: _statusFilter == 'all',
                onTap: () => setState(() => _statusFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _OrderFilterChip(
                label: 'Menunggu QRIS',
                selected: _statusFilter == 'pending',
                onTap: () => setState(() => _statusFilter = 'pending'),
              ),
              const SizedBox(width: 8),
              _OrderFilterChip(
                label: 'Diproses / Lunas',
                selected: _statusFilter == 'paid',
                onTap: () => setState(() => _statusFilter = 'paid'),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEDE4D7)),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.bag,
                            size: 32,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum Ada Transaksi',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Riwayat pesanan biji kopi & status pembayaran QRIS Anda akan muncul di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: widget.onExploreTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Mulai Belanja Kopi',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final o = filtered[idx];
                    final isPaid = o.paymentStatus == 'PAID';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDE4D7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  o.orderId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  o.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isPaid
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...o.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '${item.quantity}× ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} (${item.bagSize}, ${item.grindOption})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    CurrencyFormatter.formatRp(item.totalPrice),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 16, color: Color(0xFFEDE4D7)),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${o.courierName} · ${o.paymentMethod}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatRp(o.total),
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBrown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isPaid)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final paid = await QrisPaymentSheet.show(
                                      context,
                                      o,
                                    );
                                    if (paid != null && context.mounted) {
                                      CheckoutReceiptSheet.show(context, paid);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEA580C),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(CupertinoIcons.qrcode, size: 14),
                                  label: const Text(
                                    'Bayar QRIS',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
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
    );
  }
}

class _OrderFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OrderFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : AppTheme.bgCream,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
