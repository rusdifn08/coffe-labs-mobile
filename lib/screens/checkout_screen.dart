import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/checkout/widgets/checkout_address_card.dart';
import '../features/checkout/widgets/checkout_breakdown_card.dart';
import '../features/checkout/widgets/checkout_courier_selector.dart';
import '../features/checkout/widgets/checkout_payment_selector.dart';
import '../features/checkout/widgets/checkout_receipt_sheet.dart';
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
  String _shippingAddress = 'Jl. Thamrin Boulevard No. 28, Menteng, Jakarta Pusat, DKI Jakarta 10350';

  String _selectedCourier = 'SiCepat BEST (1 Day)';
  int _courierFee = 20000;

  String _selectedPayment = 'QRIS';

  final List<Map<String, dynamic>> _courierOptions = [
    {
      'name': 'GoSend / GrabExpress Instant',
      'desc': 'Today (3-4 Hours)',
      'fee': 28000,
      'icon': CupertinoIcons.bolt_fill,
    },
    {
      'name': 'SiCepat BEST (1 Day)',
      'desc': 'Tomorrow afternoon',
      'fee': 20000,
      'icon': CupertinoIcons.airplane,
    },
    {
      'name': 'J&T Express / Anteraja Regular',
      'desc': '2-3 Business Days',
      'fee': 14000,
      'icon': CupertinoIcons.cube_box_fill,
    },
  ];

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'id': 'QRIS',
      'label': 'QRIS (Gopay/OVO/ShopeePay/BCA)',
      'subtitle': 'Instant dynamic scan & 0% admin fee',
      'icon': CupertinoIcons.qrcode,
    },
    {
      'id': 'BCA VA',
      'label': 'BCA Virtual Account',
      'subtitle': 'Automatic 24/7 bank confirmation',
      'icon': CupertinoIcons.creditcard_fill,
    },
    {
      'id': 'Mandiri VA',
      'label': 'Mandiri Virtual Account',
      'subtitle': 'Livin\' by Mandiri payment',
      'icon': CupertinoIcons.creditcard,
    },
    {
      'id': 'GoPay',
      'label': 'GoPay / GoPay Later',
      'subtitle': 'Direct in-app wallet deduction',
      'icon': CupertinoIcons.money_dollar_circle_fill,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final subtotal = _marketplaceService.cartSubtotal;
    final discount = _marketplaceService.voucherDiscount;
    final hasFreeShip = _marketplaceService.appliedVoucher?.contains('FREESHIP') == true;
    final finalShipping = hasFreeShip ? 0 : _courierFee;
    final total = (subtotal + finalShipping - discount).clamp(0, 99999999);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          isEn ? 'Order Checkout' : 'Konfirmasi Checkout',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // 1. Delivery Address Card
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

          // 2. Select Courier Service
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

          // 3. Payment Method
          CheckoutPaymentSelector(
            isEn: isEn,
            selectedPayment: _selectedPayment,
            paymentOptions: _paymentOptions,
            onPaymentSelected: (id) => setState(() => _selectedPayment = id),
          ),

          const SizedBox(height: 14),

          // 4. Order Breakdown
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
      // Sticky Place Order Bar
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
                    isEn ? 'Total to Pay' : 'Total Bayar',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  Text(
                    CurrencyFormatter.formatRp(total),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _handlePlaceOrder(context, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(CupertinoIcons.checkmark_shield_fill, size: 16),
                label: Text(
                  isEn ? 'Place Order & Pay' : 'Bayar Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, int total) async {
    // Show processing indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!context.mounted) return;
    Navigator.pop(context); // close loader

    final order = await _marketplaceService.placeOrder(
      recipientName: _recipientName,
      phoneNumber: _phoneNumber,
      shippingAddress: _shippingAddress,
      courierName: _selectedCourier,
      shippingFee: _courierFee,
      paymentMethod: _selectedPayment,
    );

    if (!context.mounted) return;

    // Show Order Confirmation Receipt Modal
    CheckoutReceiptSheet.show(context, order);
  }
}
