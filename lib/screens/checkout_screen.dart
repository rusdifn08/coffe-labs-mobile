import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/checkout/widgets/checkout_address_card.dart';
import '../features/checkout/widgets/checkout_breakdown_card.dart';
import '../features/checkout/widgets/checkout_courier_selector.dart';
import '../features/checkout/widgets/checkout_payment_selector.dart';
import '../features/checkout/widgets/checkout_receipt_sheet.dart';
import '../features/checkout/widgets/qris_payment_sheet.dart';
import '../features/marketplace/utils/currency_formatter.dart';
import '../services/language_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService.instance;

  String _recipientName = 'Rusdi Coffee Enthusiast';
  String _phoneNumber = '+62 812-3456-7890';
  String _shippingAddress =
      'Jl. Thamrin Boulevard No. 28, Menteng, Jakarta Pusat, DKI Jakarta 10350';

  String _selectedCourier = 'SiCepat BEST (1 Day)';
  int _courierFee = 20000;

  // Pembayaran marketplace saat ini eksklusif hanya via QRIS.
  final String _selectedPayment = 'QRIS';

  final List<Map<String, dynamic>> _courierOptions = [
    {
      'name': 'GoSend / GrabExpress Instant',
      'desc': 'Hari Ini (3-4 Jam)',
      'fee': 28000,
      'icon': CupertinoIcons.bolt_fill,
    },
    {
      'name': 'SiCepat BEST (1 Day)',
      'desc': 'Besok Sore',
      'fee': 20000,
      'icon': CupertinoIcons.airplane,
    },
    {
      'name': 'J&T Express / Anteraja Regular',
      'desc': '2-3 Hari Kerja',
      'fee': 14000,
      'icon': CupertinoIcons.cube_box_fill,
    },
  ];

  final List<Map<String, dynamic>> _paymentOptions = const [
    {
      'id': 'QRIS',
      'label': 'QRIS (Semua E-Wallet & Mobile Banking)',
      'subtitle':
          'Pembayaran eksklusif via scan QRIS: GoPay, OVO, DANA, ShopeePay, BCA, Livin\', BRImo (0% Biaya Admin)',
      'icon': CupertinoIcons.qrcode,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final subtotal = _marketplaceService.cartSubtotal;
    const discount = 0;
    const hasFreeShip = false;
    final finalShipping = _courierFee;
    final total = (subtotal + finalShipping).clamp(0, 99999999);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          isEn ? 'QRIS Checkout' : 'Konfirmasi Checkout (QRIS)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          CheckoutAddressCard(
            isEn: isEn,
            recipientName: _recipientName,
            phoneNumber: _phoneNumber,
            shippingAddress: _shippingAddress,
            onAddressUpdated: (name, phone, address) {
              setState(() {
                _recipientName = name;
                _phoneNumber = phone;
                _shippingAddress = address;
              });
            },
          ),
          const SizedBox(height: 14),
          CheckoutCourierSelector(
            isEn: isEn,
            hasFreeShip: hasFreeShip,
            selectedCourier: _selectedCourier,
            courierOptions: _courierOptions,
            onCourierSelected: (name, fee) {
              setState(() {
                _selectedCourier = name;
                _courierFee = fee;
              });
            },
          ),
          const SizedBox(height: 14),
          CheckoutPaymentSelector(
            isEn: isEn,
            selectedPayment: _selectedPayment,
            paymentOptions: _paymentOptions,
            onPaymentSelected: (_) {},
          ),
          const SizedBox(height: 14),
          CheckoutBreakdownCard(
            isEn: isEn,
            subtotal: subtotal,
            courierFee: _courierFee,
            hasFreeShip: hasFreeShip,
            discount: discount,
            total: total,
          ),
        ],
      ),
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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Total QRIS' : 'Total Bayar QRIS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    Text(
                      CurrencyFormatter.formatRp(total),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: subtotal <= 0
                    ? null
                    : () => _handlePlaceQrisOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(CupertinoIcons.qrcode, size: 16),
                label: const Text(
                  'Bayar via QRIS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceQrisOrder(BuildContext context) async {
    final pendingOrder = await _marketplaceService.createQrisOrder(
      recipientName: _recipientName,
      phoneNumber: _phoneNumber,
      shippingAddress: _shippingAddress,
      courierName: _selectedCourier,
      shippingFee: _courierFee,
    );
    if (!context.mounted) return;

    final paidOrder = await QrisPaymentSheet.show(context, pendingOrder);
    if (paidOrder != null && context.mounted) {
      CheckoutReceiptSheet.show(context, paidOrder);
    }
  }
}
