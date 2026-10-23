import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid, size: 16, color: AppTheme.primaryBrown),
                        const SizedBox(width: 6),
                        Text(
                          isEn ? 'Shipping Address' : 'Alamat Pengiriman',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _showEditAddressDialog(context),
                      child: Text(
                        isEn ? 'Edit' : 'Ubah',
                        style: const TextStyle(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$_recipientName ($_phoneNumber)',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _shippingAddress,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Select Courier Service
          Text(
            isEn ? 'Select Delivery Service' : 'Pilih Kurir Pengiriman',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          ..._courierOptions.map((c) {
            final isSel = _selectedCourier == c['name'];
            final fee = c['fee'] as int;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSel ? AppTheme.primaryBrown : Colors.transparent,
                  width: isSel ? 1.5 : 1.0,
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(c['icon'] as IconData, size: 18, color: AppTheme.primaryBrown),
                ),
                title: Text(
                  c['name'] as String,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  c['desc'] as String,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                trailing: Text(
                  hasFreeShip ? (isEn ? 'FREE' : 'GRATIS') : _formatCurrency(fee),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: hasFreeShip ? Colors.green : AppTheme.primaryBrown,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedCourier = c['name'] as String;
                    _courierFee = fee;
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 14),

          // 3. Payment Method
          Text(
            isEn ? 'Payment Method' : 'Metode Pembayaran',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          ..._paymentOptions.map((p) {
            final isSel = _selectedPayment == p['id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSel ? AppTheme.primaryBrown : Colors.transparent,
                  width: isSel ? 1.5 : 1.0,
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(p['icon'] as IconData, size: 18, color: AppTheme.primaryBrown),
                ),
                title: Text(
                  p['label'] as String,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  p['subtitle'] as String,
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                ),
                trailing: Icon(
                  isSel ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                  color: isSel ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.4),
                  size: 20,
                ),
                onTap: () {
                  setState(() {
                    _selectedPayment = p['id'] as String;
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 14),

          // 4. Order Breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Payment Breakdown' : 'Rincian Pembayaran',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 10),
                _buildRow(isEn ? 'Items Subtotal' : 'Subtotal Produk', _formatCurrency(subtotal)),
                const SizedBox(height: 6),
                _buildRow(
                  isEn ? 'Shipping Fee' : 'Biaya Pengiriman',
                  hasFreeShip ? (isEn ? 'FREE' : 'GRATIS') : _formatCurrency(_courierFee),
                  color: hasFreeShip ? Colors.green : null,
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 6),
                  _buildRow(
                    isEn ? 'Voucher Discount' : 'Potongan Diskon',
                    '-${_formatCurrency(discount)}',
                    color: Colors.green,
                  ),
                ],
                const Divider(height: 18),
                _buildRow(
                  isEn ? 'Total Payment' : 'Total Pembayaran',
                  _formatCurrency(total),
                  isBold: true,
                  fontSize: 15,
                  color: AppTheme.primaryBrown,
                ),
              ],
            ),
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
                    _formatCurrency(total),
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
    final isEn = LanguageService.isEnglish;

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
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 36, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Text(
                isEn ? 'Payment Successful!' : 'Pesanan Berhasil Dibuat!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'Your order has been forwarded to the roastery for freshly roasted batch packaging.'
                    : 'Pesanan telah diteruskan ke roastery untuk segera disangrai dan dikemas segar.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildRow(isEn ? 'Order Number' : 'Nomor Pesanan', order.orderId, isBold: true),
                    const Divider(height: 14),
                    _buildRow(isEn ? 'Estimated Delivery' : 'Estimasi Sampai', order.estimatedDelivery),
                    const Divider(height: 14),
                    _buildRow(isEn ? 'Courier' : 'Layanan Kurir', order.courierName),
                    const Divider(height: 14),
                    _buildRow(isEn ? 'Payment' : 'Metode Bayar', order.paymentMethod),
                    const Divider(height: 14),
                    _buildRow(isEn ? 'Total Paid' : 'Total Pembayaran', _formatCurrency(order.total), isBold: true, color: AppTheme.primaryBrown),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close sheet
                  Navigator.pop(context); // back to marketplace
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEn ? 'Back to Marketplace' : 'Kembali ke Marketplace',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditAddressDialog(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final nameCtrl = TextEditingController(text: _recipientName);
    final phoneCtrl = TextEditingController(text: _phoneNumber);
    final addrCtrl = TextEditingController(text: _shippingAddress);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEn ? 'Edit Shipping Address' : 'Ubah Alamat Pengiriman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Recipient Name' : 'Nama Penerima',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Phone Number' : 'Nomor Telepon',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addrCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Full Street Address' : 'Alamat Lengkap',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isEn ? 'Cancel' : 'Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _recipientName = nameCtrl.text.trim();
                  _phoneNumber = phoneCtrl.text.trim();
                  _shippingAddress = addrCtrl.text.trim();
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
              child: Text(isEn ? 'Save' : 'Simpan', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, double fontSize = 12, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
