import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/subscription_plan.dart';
import '../../../services/subscription_service.dart';
import '../../../theme/app_theme.dart';

class SubscriptionCheckoutSheet extends StatefulWidget {
  final SubscriptionPlan initialPlan;

  const SubscriptionCheckoutSheet({
    super.key,
    this.initialPlan = SubscriptionPlan.pro,
  });

  static Future<void> show(BuildContext context, {SubscriptionPlan? plan}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionCheckoutSheet(
        initialPlan: plan ?? SubscriptionPlan.pro,
      ),
    );
  }

  @override
  State<SubscriptionCheckoutSheet> createState() => _SubscriptionCheckoutSheetState();
}

class _SubscriptionCheckoutSheetState extends State<SubscriptionCheckoutSheet> {
  late SubscriptionPlan _selectedPlan;
  String _selectedPaymentMethod = 'QRIS Instant';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'QRIS Instant',
      'name': 'QRIS (GoPay, OVO, Dana, ShopeePay, BCA)',
      'icon': CupertinoIcons.qrcode,
      'isFast': true,
    },
    {
      'id': 'Transfer BCA Virtual Account',
      'name': 'BCA Virtual Account',
      'icon': CupertinoIcons.creditcard,
      'isFast': false,
    },
    {
      'id': 'Transfer Mandiri / BRI',
      'name': 'Mandiri & BRI Virtual Account',
      'icon': CupertinoIcons.building_2_fill,
      'isFast': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.initialPlan;
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    // Simulasi proses pembayaran gerbang transaksi payment gateway
    await Future.delayed(const Duration(milliseconds: 1200));

    await SubscriptionService.activatePlan(
      _selectedPlan,
      paymentMethod: _selectedPaymentMethod,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.pop(context);

    _showCelebrationDialog(context, _selectedPlan);
  }

  void _showCelebrationDialog(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.sparkles, color: Colors.orange, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Aktivasi ${plan.title} Berhasil!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Selamat! Akun Anda kini memiliki akses penuh ${plan.badgeLabel}. Bebas iklan selamanya, seluruh 409+ resep juara dunia & lab ekstraksi telah terbuka.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Mulai Nikmati Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.bag_fill, color: AppTheme.primaryBrown, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Lisensi Coffee Labs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      Text(
                        'Tingkatkan pengalaman menyeduh Anda tanpa batas',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 20),

          // Content Scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlanCard(SubscriptionPlan.pro),
                  const SizedBox(height: 14),
                  _buildPlanCard(SubscriptionPlan.business),
                  const SizedBox(height: 20),
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 10),
                  ..._paymentMethods.map((m) => _buildPaymentTile(m)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Text(
                        _selectedPlan.priceLabel,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Aktifkan ${_selectedPlan.title.replaceFirst("Coffee Labs ", "")}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final bool isSelected = _selectedPlan.id == plan.id;
    final bool isBusiness = plan.tier == SubscriptionTier.business;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? (isBusiness ? Colors.amber.shade50 : AppTheme.bgCream) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? (isBusiness ? Colors.amber.shade800 : AppTheme.primaryBrown) : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isBusiness ? Colors.amber : AppTheme.primaryBrown).withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                          ),
                          if (plan.isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBrown,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'POPULER',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(plan.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Text(
                  plan.priceLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isBusiness ? Colors.amber.shade900 : AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '• ${plan.billingPeriod}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            ...plan.features.take(4).map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_alt_circle_fill,
                          size: 14,
                          color: isBusiness ? Colors.amber.shade800 : Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.bgCream : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedPaymentMethod = method['id'] as String),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(method['icon'] as IconData, size: 22, color: AppTheme.primaryBrown),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    method['name'] as String,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                ),
                Icon(
                  isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                  color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
