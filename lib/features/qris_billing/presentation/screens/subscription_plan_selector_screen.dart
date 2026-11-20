import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin_control/controllers/system_control_sync_controller.dart';
import '../../../affiliate/data/affiliate_api_service.dart';
import '../../../affiliate/models/affiliate_models.dart';
import '../../domain/qris_billing_models.dart';
import '../controllers/qris_checkout_controller.dart';
import 'dynamic_qris_checkout_screen.dart';

class SubscriptionPlanSelectorScreen extends ConsumerStatefulWidget {
  final String initialTier; // 'pro' | 'business'

  const SubscriptionPlanSelectorScreen({
    super.key,
    this.initialTier = 'pro',
  });

  @override
  ConsumerState<SubscriptionPlanSelectorScreen> createState() =>
      _SubscriptionPlanSelectorScreenState();
}

class _SubscriptionPlanSelectorScreenState
    extends ConsumerState<SubscriptionPlanSelectorScreen> {
  late String _selectedTier;
  final TextEditingController _referralCtrl = TextEditingController();
  ValidatedReferralPreview? _appliedReferral;
  bool _isValidatingReferral = false;
  String? _referralError;

  @override
  void initState() {
    super.initState();
    _selectedTier =
        widget.initialTier.toLowerCase() == 'business' ? 'business' : 'pro';
    Future.microtask(() => ref.read(qrisCheckoutProvider.notifier).loadPlans());
  }

  @override
  void dispose() {
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyReferralCode(SubscriptionPlanCatalogItem plan) async {
    final code = _referralCtrl.text.trim().toUpperCase();
    if (code.length < 4) {
      setState(() => _referralError = 'Masukkan kode referral minimal 4 karakter.');
      return;
    }
    setState(() {
      _isValidatingReferral = true;
      _referralError = null;
    });
    try {
      final preview = await ref
          .read(affiliateApiServiceProvider)
          .validateReferralCode(code: code, planCode: plan.planCode);
      if (!mounted) return;
      setState(() {
        _appliedReferral = preview;
        _referralCtrl.text = preview.normalizedCode;
        _isValidatingReferral = false;
        _referralError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appliedReferral = null;
        _isValidatingReferral = false;
        _referralError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _selectTier(String tier, SubscriptionPlanCatalogItem nextPlan) {
    if (_selectedTier == tier) return;
    setState(() => _selectedTier = tier);
    if (_appliedReferral != null) {
      _applyReferralCode(nextPlan);
    }
  }

  void _clearReferral() {
    setState(() {
      _appliedReferral = null;
      _referralError = null;
      _referralCtrl.clear();
    });
  }

  SubscriptionPlanCatalogItem _resolvePlan(
    List<SubscriptionPlanCatalogItem> plans,
    String tier,
  ) {
    final isBiz = tier == 'business';
    final targetCode = isBiz ? 'BUSINESS_LIFETIME' : 'PRO_LIFETIME';
    // Prioritaskan paket aktif dengan tier yang sesuai (mendukung Lifetime maupun Monthly/Yearly aktif dari Admin Control Panel)
    final activeForTier = plans
        .where((p) => p.isActive && p.isBusiness == isBiz)
        .toList();
    if (activeForTier.isNotEmpty) {
      final lifetimeMatch = activeForTier.where((p) => p.planCode == targetCode);
      if (lifetimeMatch.isNotEmpty) return lifetimeMatch.first;
      return activeForTier.first;
    }
    return plans.firstWhere(
      (p) => p.planCode == targetCode,
      orElse: () => SubscriptionPlanCatalogItem.defaultCatalog.firstWhere(
        (p) => p.planCode == targetCode,
        orElse: () => SubscriptionPlanCatalogItem.defaultCatalog.first,
      ),
    );
  }

  Future<void> _startQrisCheckout(SubscriptionPlanCatalogItem plan) async {
    final invoice = await ref
        .read(qrisCheckoutProvider.notifier)
        .startCheckout(
          plan.planCode,
          referralCode: _appliedReferral?.normalizedCode,
          discountIdr: _appliedReferral?.buyerDiscountIdr ?? 0,
        );
    if (!mounted) return;
    if (invoice == null) {
      final err = ref.read(qrisCheckoutProvider).errorMessage ??
          'Silakan login terlebih dahulu untuk melanjutkan pembayaran QRIS.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DynamicQrisCheckoutScreen(initialInvoice: invoice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrisCheckoutProvider);
    final liveDynamicPlans = ref.watch(dynamicPlansProvider);
    final effectivePlans = liveDynamicPlans.isNotEmpty
        ? liveDynamicPlans.map((p) => p.toSubscriptionPlanItem()).toList()
        : state.plans;
    final proPlan = _resolvePlan(effectivePlans, 'pro');
    final bizPlan = _resolvePlan(effectivePlans, 'business');
    final selectedPlan = _selectedTier == 'business' ? bizPlan : proPlan;

    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48,
        iconTheme: const IconThemeData(color: Color(0xFFF9F5EE)),
        title: const Text(
          'Pilih Lisensi Coffee Labs',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
              children: [
                // Compact Promo 2026 Strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B1D12), Color(0xFF1C1714)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A373),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PROMO AKHIR 2026',
                          style: TextStyle(
                            color: Color(0xFF12100E),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Sekali Bayar • Tanpa Biaya Bulanan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                _buildCompactPlanCard(
                  plan: proPlan,
                  isSelected: _selectedTier == 'pro',
                  badge: (proPlan.promoBadgeText != null &&
                          proPlan.promoBadgeText!.trim().isNotEmpty)
                      ? proPlan.promoBadgeText!.trim().toUpperCase()
                      : 'POPULER',
                  subtitle: 'Home Brewer & Barista Specialist',
                  onTap: () => _selectTier('pro', proPlan),
                ),
                const SizedBox(height: 10),
                _buildCompactPlanCard(
                  plan: bizPlan,
                  isSelected: _selectedTier == 'business',
                  badge: (bizPlan.promoBadgeText != null &&
                          bizPlan.promoBadgeText!.trim().isNotEmpty)
                      ? bizPlan.promoBadgeText!.trim().toUpperCase()
                      : 'KAFE & ROASTERY',
                  subtitle: 'Ekosistem POS, Kiosk AMOLED & Live Brew Meja',
                  onTap: () => _selectTier('business', bizPlan),
                ),
                const SizedBox(height: 10),
                _buildReferralInputBox(selectedPlan),
              ],
            ),
          ),

          // Compact Sticky Checkout CTA Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1714),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFD4A373).withValues(alpha: 0.35),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                selectedPlan.isBusiness
                                    ? 'Coffee Labs Business'
                                    : 'Coffee Labs Pro',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFD4A373),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (_appliedReferral != null) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF166534),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '-${_appliedReferral!.discountPercent}%',
                                  style: const TextStyle(
                                    color: Color(0xFFDCFCE7),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _appliedReferral != null
                                    ? formatRupiahIdr(
                                        selectedPlan.basePriceIdr -
                                            _appliedReferral!.buyerDiscountIdr,
                                      )
                                    : selectedPlan.priceLabel,
                                style: const TextStyle(
                                  color: Color(0xFFF9F5EE),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _appliedReferral != null
                                    ? selectedPlan.priceLabel
                                    : selectedPlan.normalPriceLabel,
                                style: const TextStyle(
                                  color: Color(0xFF9C8F82),
                                  fontSize: 10.5,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 6,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A373),
                          foregroundColor: const Color(0xFF12100E),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: state.isCreatingInvoice
                            ? null
                            : () => _startQrisCheckout(selectedPlan),
                        icon: state.isCreatingInvoice
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF12100E),
                                ),
                              )
                            : const Icon(CupertinoIcons.qrcode, size: 15),
                        label: Text(
                          state.isCreatingInvoice
                              ? 'Membuat QR...'
                              : 'Bayar via QRIS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralInputBox(SubscriptionPlanCatalogItem selectedPlan) {
    final applied = _appliedReferral;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: applied != null
              ? const Color(0xFF22C55E).withValues(alpha: 0.55)
              : const Color(0xFFD4A373).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                applied != null
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.tag_fill,
                size: 14,
                color: applied != null
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFD4A373),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Punya Kode Referral / Afiliasi? (Diskon 10%)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (applied != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF14532D).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kode ${applied.normalizedCode} aktif • Hemat ${formatRupiahIdr(applied.buyerDiscountIdr)} (${applied.discountPercent}%)',
                      style: const TextStyle(
                        color: Color(0xFFDCFCE7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _clearReferral,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Hapus',
                        style: TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _referralCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        color: Color(0xFFF9F5EE),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: CL-BARISTA',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8C7E71),
                          fontSize: 11.5,
                          letterSpacing: 0,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF12100E),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4A373),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A373),
                      foregroundColor: const Color(0xFF12100E),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isValidatingReferral
                        ? null
                        : () => _applyReferralCode(selectedPlan),
                    child: _isValidatingReferral
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF12100E),
                            ),
                          )
                        : const Text(
                            'Terapkan',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          if (_referralError != null) ...[
            const SizedBox(height: 6),
            Text(
              _referralError!,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactPlanCard({
    required SubscriptionPlanCatalogItem plan,
    required bool isSelected,
    required String badge,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final accent =
        plan.isBusiness ? const Color(0xFFF59E0B) : const Color(0xFFD4A373);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF241D18)
              : const Color(0xFF1C1714),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            plan.isBusiness
                                ? 'Coffee Labs Business'
                                : 'Coffee Labs Pro',
                            style: const TextStyle(
                              color: Color(0xFFF9F5EE),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFFCBBFB2),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.normalPriceLabel,
                      style: const TextStyle(
                        color: Color(0xFF9C8F82),
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      plan.priceLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Sekali Bayar',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 9),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_alt_circle_fill,
                      color: accent,
                      size: 13.5,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          color: Color(0xFFF9F5EE),
                          fontSize: 11.2,
                          height: 1.25,
                        ),
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
}
