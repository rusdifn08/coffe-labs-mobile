import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../../qris_billing/domain/qris_billing_models.dart';
import '../../controllers/system_control_sync_controller.dart';
import '../../models/admin_control_models.dart';

/// Tab 2 Panel Admin Mobile: Pengaturan Harga Penjualan Pro & Business Real-Time.
class AdminPricingTabView extends ConsumerWidget {
  final List<DynamicPlanPricingItem> plans;
  final bool isMutating;

  const AdminPricingTabView({
    super.key,
    required this.plans,
    required this.isMutating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affCfg = ref.watch(affiliateControlProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _AdminAffiliateControlCard(
          key: ValueKey(
            'aff_${affCfg.affiliateCommissionPercent}_${affCfg.allowFreeTierAffiliates}_${affCfg.buyerDiscountPercent}',
          ),
          config: affCfg,
          isMutating: isMutating,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF92400E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Perubahan harga langsung aktif real-time di layar Upgrade, QRIS Dinamis & Komisi Afiliasi ${affCfg.affiliateCommissionPercent}%. Invoice QRIS yang masih PENDING tetap aman.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF78350F),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...plans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AdminPlanPriceEditorCard(
              key: ValueKey('${plan.planCode}_${plan.basePriceIdr}_${plan.isActive}'),
              plan: plan,
              isMutating: isMutating,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminAffiliateControlCard extends ConsumerStatefulWidget {
  final AffiliateControlConfig config;
  final bool isMutating;

  const _AdminAffiliateControlCard({
    super.key,
    required this.config,
    required this.isMutating,
  });

  @override
  ConsumerState<_AdminAffiliateControlCard> createState() =>
      _AdminAffiliateControlCardState();
}

class _AdminAffiliateControlCardState
    extends ConsumerState<_AdminAffiliateControlCard> {
  late int _commissionPct;
  late int _discountPct;
  late bool _allowFreeTier;
  late bool _isProgramActive;

  @override
  void initState() {
    super.initState();
    _commissionPct = widget.config.affiliateCommissionPercent;
    _discountPct = widget.config.buyerDiscountPercent;
    _allowFreeTier = widget.config.allowFreeTierAffiliates;
    _isProgramActive = widget.config.isProgramActive;
  }

  Future<void> _saveAffiliate() async {
    final ok = await ref
        .read(systemControlProvider.notifier)
        .updateAffiliateConfig(
          isProgramActive: _isProgramActive,
          affiliateCommissionPercent: _commissionPct,
          buyerDiscountPercent: _discountPct,
          allowFreeTierAffiliates: _allowFreeTier,
          minWithdrawalIdr: widget.config.minWithdrawalIdr,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF047857) : const Color(0xFFDC2626),
        content: Text(
          ok
              ? 'Aturan Afiliasi ($_commissionPct% • ${_allowFreeTier ? "Pro & Free" : "Khusus Pro"}) aktif real-time!'
              : 'Gagal menyimpan aturan afiliasi.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF047857).withValues(alpha: 0.4),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'KONTROL AFILIASI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Komisi $_commissionPct% • ${_allowFreeTier ? "Pro & Free" : "Khusus Pro"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _isProgramActive,
                activeThumbColor: const Color(0xFF047857),
                onChanged: (v) => setState(() => _isProgramActive = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Pilih Persentase Komisi Afiliator:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [10, 15, 20, 25].map((pct) {
              final selected = _commissionPct == pct;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _commissionPct = pct),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryBrown
                            : AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryBrown
                              : AppTheme.borderWarm,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: selected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            '2. Kontrol Akses Peserta Afiliasi:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _allowFreeTier = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: !_allowFreeTier
                          ? AppTheme.primaryBrown
                          : AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_allowFreeTier
                            ? AppTheme.primaryBrown
                            : AppTheme.borderWarm,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '🔒 Khusus Pro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: !_allowFreeTier
                            ? Colors.white
                            : AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _allowFreeTier = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _allowFreeTier
                          ? const Color(0xFF047857)
                          : AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _allowFreeTier
                            ? const Color(0xFF047857)
                            : AppTheme.borderWarm,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '🌍 Pro & Free',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color:
                            _allowFreeTier ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF047857),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              onPressed: widget.isMutating ? null : _saveAffiliate,
              icon: const Icon(Icons.bolt_rounded, size: 16),
              label: const Text(
                'Terapkan Komisi & Akses Afiliasi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPlanPriceEditorCard extends ConsumerStatefulWidget {
  final DynamicPlanPricingItem plan;
  final bool isMutating;

  const _AdminPlanPriceEditorCard({
    super.key,
    required this.plan,
    required this.isMutating,
  });

  @override
  ConsumerState<_AdminPlanPriceEditorCard> createState() =>
      _AdminPlanPriceEditorCardState();
}

class _AdminPlanPriceEditorCardState
    extends ConsumerState<_AdminPlanPriceEditorCard> {
  late TextEditingController _priceCtrl;
  late TextEditingController _origCtrl;
  late TextEditingController _badgeCtrl;
  late TextEditingController _daysCtrl;
  late bool _isActive;
  late bool _isHighlighted;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(text: widget.plan.basePriceIdr.toString());
    _origCtrl = TextEditingController(
      text: widget.plan.originalPriceIdr?.toString() ?? '',
    );
    _badgeCtrl = TextEditingController(text: widget.plan.promoBadgeText ?? '');
    _daysCtrl = TextEditingController(text: widget.plan.durationDays.toString());
    _isActive = widget.plan.isActive;
    _isHighlighted = widget.plan.isHighlighted;
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _origCtrl.dispose();
    _badgeCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    final orig = int.tryParse(_origCtrl.text.trim());
    final days = int.tryParse(_daysCtrl.text.trim()) ?? widget.plan.durationDays;

    if (price < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga jual minimal Rp 1.000.')),
      );
      return;
    }

    final ok = await ref.read(systemControlProvider.notifier).updatePlanPricing(
          planCode: widget.plan.planCode,
          displayName: widget.plan.displayName,
          basePriceIdr: price,
          originalPriceIdr: (orig != null && orig > 0) ? orig : null,
          promoBadgeText: _badgeCtrl.text.trim().isEmpty ? null : _badgeCtrl.text.trim(),
          durationDays: days < 1 ? 30 : days,
          isActive: _isActive,
          isHighlighted: _isHighlighted,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF047857) : const Color(0xFFDC2626),
        content: Text(
          ok
              ? 'Harga ${widget.plan.planCode} (${formatRupiahIdr(price)}) tersinkron real-time!'
              : (ref.read(systemControlProvider).errorMessage ??
                  'Gagal menyimpan harga.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final livePrice = int.tryParse(_priceCtrl.text.trim()) ?? widget.plan.basePriceIdr;
    final disc10 = (livePrice * 0.9).round();
    final comm20 = (livePrice * 0.2).round();
    final isBiz = widget.plan.isBusiness;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isActive
              ? AppTheme.primaryBrown.withValues(alpha: 0.35)
              : AppTheme.borderWarm,
          width: _isActive ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isBiz
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  widget.plan.planCode,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isBiz
                        ? const Color(0xFF92400E)
                        : const Color(0xFF3730A3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.plan.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _isActive,
                activeThumbColor: const Color(0xFF047857),
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Harga Jual (Rp)',
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _origCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Coret (Rp)',
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _badgeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Badge Promo',
                    hintText: 'POPULER',
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 104,
                child: TextField(
                  controller: _daysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Durasi (Hr)',
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F0),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                Text(
                  'QRIS: ${formatRupiahIdr(livePrice)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                Text(
                  'Referral -10%: ${formatRupiahIdr(disc10)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                Text(
                  'Afiliasi 20%: ${formatRupiahIdr(comm20)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.isMutating ? null : _save,
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text(
                'Simpan & Update Real-Time',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
