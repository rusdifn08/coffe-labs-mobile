import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/performance/transition_aware_deferred_builder.dart';
import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../qris_billing/domain/qris_billing_models.dart';
import '../../../qris_billing/presentation/screens/subscription_plan_selector_screen.dart';
import '../../models/affiliate_models.dart';
import '../controllers/affiliate_controller.dart';
import '../widgets/withdraw_affiliate_balance_sheet.dart';

class AffiliateHubScreen extends ConsumerStatefulWidget {
  const AffiliateHubScreen({super.key});

  @override
  ConsumerState<AffiliateHubScreen> createState() => _AffiliateHubScreenState();
}

class _AffiliateHubScreenState extends ConsumerState<AffiliateHubScreen> {
  int _selectedTab = 0; // 0 = Riwayat Komisi, 1 = Riwayat Penarikan

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(affiliateDashboardProvider.notifier).loadDashboard(),
    );
  }

  Future<void> _showCustomizeCodeDialog(AffiliateWalletModel wallet) async {
    final ctrl = TextEditingController(text: wallet.affiliateCode);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1714),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Ubah Kode Referral Kustom (1× Gratis)',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gunakan 4–16 huruf kapital / angka (contoh: BARISTABUDI atau V60SENJA). Perubahan hanya berlaku 1 kali.',
              style: TextStyle(color: Color(0xFFCBBFB2), fontSize: 11.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Color(0xFFF9F5EE),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF12100E),
                hintText: 'BARISTABUDI',
                hintStyle: const TextStyle(color: Color(0xFF78716C)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A373),
              foregroundColor: const Color(0xFF12100E),
            ),
            onPressed: () async {
              final ok = await ref
                  .read(affiliateDashboardProvider.notifier)
                  .customizeCode(ctrl.text.trim());
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      ok ? const Color(0xFF166534) : const Color(0xFF991B1B),
                  content: Text(
                    ok
                        ? 'Kode referral kustom berhasil disimpan!'
                        : (ref.read(affiliateDashboardProvider).errorMessage ??
                            'Gagal mengubah kode referral.'),
                  ),
                ),
              );
            },
            child: const Text(
              'Simpan Kode',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _shareCode(AffiliateWalletModel wallet, AffiliateProgramTerms terms) {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Yuk upgrade Coffee Labs Pro atau Business pakai kode referral saya: ${wallet.affiliateCode} '
            'untuk langsung dapat diskon ${terms.buyerDiscountPercent}%!\n'
            'Daftar / buka di sini: ${wallet.shareLink}',
      ),
    );
  }

  void _showProofImageViewer(String imageUrl, String ticketNo) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1C1714),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bukti Transfer $ticketNo',
                      style: const TextStyle(
                        color: Color(0xFFF9F5EE),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: OptimizedCoffeeImage(
                    imageUrlOrAsset: imageUrl,
                    width: double.infinity,
                    height: 360,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(affiliateDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48,
        title: const Text(
          'Program Afiliasi Coffee Labs',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan Saldo',
            onPressed: () =>
                ref.read(affiliateDashboardProvider.notifier).loadDashboard(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4A373)),
          ),
        ],
      ),
      body: TransitionAwareDeferredBuilder(
        lightweightPlaceholder: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A373)),
        ),
        heavyBuilder: (_) {
          if (state.isLoading && state.dashboard == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4A373)),
            );
          }
          final dash = state.dashboard;
          if (dash == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFD4A373),
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage ?? 'Gagal memuat data afiliasi.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFCBBFB2)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(affiliateDashboardProvider.notifier)
                          .loadDashboard(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!dash.isEligiblePro || dash.wallet == null) {
            return _buildProUpgradeGate(dash.terms);
          }

          return RefreshIndicator(
            color: const Color(0xFFD4A373),
            onRefresh: () =>
                ref.read(affiliateDashboardProvider.notifier).loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              children: [
                _buildHeroBalanceCard(dash.wallet!, dash.terms),
                const SizedBox(height: 12),
                _buildReferralCodeCard(dash.wallet!, dash.terms),
                const SizedBox(height: 12),
                _buildHistoryTabs(dash),
                const SizedBox(height: 10),
                if (_selectedTab == 0)
                  ..._buildCommissionList(dash.recentConversions)
                else
                  ..._buildWithdrawalList(dash.recentWithdrawals),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProUpgradeGate(AffiliateProgramTerms terms) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B1D12), Color(0xFF1C1714)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4A373).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A373),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'KHUSUS AKUN PRO & BUSINESS',
                  style: TextStyle(
                    color: Color(0xFF12100E),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Jadi Partner Afiliasi Coffee Labs & Raih Komisi 20%!',
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Setiap akun Coffee Labs Pro & Business otomatis mendapatkan kode referral pribadi. '
                'Bagikan kode Anda ke sesama pecinta kopi — teman Anda hemat ${terms.buyerDiscountPercent}% dan Anda langsung dapat komisi ${terms.commissionPercent}%!',
                style: const TextStyle(
                  color: Color(0xFFCBBFB2),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _benefitRow(
                'Komisi ${formatRupiahIdr(terms.proExampleCommissionIdr)} setiap teman upgrade Pro',
              ),
              _benefitRow(
                'Komisi ${formatRupiahIdr(terms.businessExampleCommissionIdr)} setiap kafe upgrade Business',
              ),
              _benefitRow(
                'Tarik langsung ke BCA, Mandiri, BRI, GoPay, DANA, OVO (Min. ${formatRupiahIdr(terms.minWithdrawalIdr)})',
              ),
              _benefitRow(
                'Proses pencairan manual transparan 1×24 jam kerja • Biaya Admin Rp 0',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A373),
                    foregroundColor: const Color(0xFF12100E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionPlanSelectorScreen(
                              initialTier: 'pro',
                            ),
                          ),
                        )
                        .then(
                          (_) => ref
                              .read(affiliateDashboardProvider.notifier)
                              .loadDashboard(),
                        );
                  },
                  icon: const Icon(CupertinoIcons.sparkles, size: 17),
                  label: const Text(
                    'Upgrade ke Pro (Rp 99.000) & Aktifkan Afiliasi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _benefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.checkmark_alt_circle_fill,
            color: Color(0xFF22C55E),
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFF9F5EE),
                fontSize: 11.8,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBalanceCard(
    AffiliateWalletModel wallet,
    AffiliateProgramTerms terms,
  ) {
    final canWithdraw = wallet.availableBalanceIdr >= terms.minWithdrawalIdr;
    final progress = (wallet.availableBalanceIdr / terms.minWithdrawalIdr)
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1D12), Color(0xFF1C1714)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFFD4A373),
                size: 16,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'SALDO AFILIASI TERSEDIA',
                  style: TextStyle(
                    color: Color(0xFFD4A373),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  'KOMISI ${terms.commissionPercent}%',
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            wallet.formattedAvailable,
            style: const TextStyle(
              color: Color(0xFFF9F5EE),
              fontSize: 27,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'Diproses Admin: ${wallet.formattedLocked}',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Total Komisi: ${wallet.formattedTotalEarned} (${wallet.totalSuccessfulReferrals} referral)',
                style: const TextStyle(
                  color: Color(0xFFCBBFB2),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!canWithdraw) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white12,
                color: const Color(0xFFD4A373),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Kumpulkan ${formatRupiahIdr(terms.minWithdrawalIdr - wallet.availableBalanceIdr)} lagi untuk mencapai minimal tarik ${formatRupiahIdr(terms.minWithdrawalIdr)}.',
              style: const TextStyle(color: Color(0xFFA8A29E), fontSize: 10.5),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: canWithdraw
                    ? const Color(0xFF22C55E)
                    : Colors.white.withValues(alpha: 0.12),
                foregroundColor:
                    canWithdraw ? const Color(0xFF052E16) : Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: canWithdraw
                  ? () => WithdrawAffiliateBalanceSheet.show(
                        context,
                        wallet: wallet,
                        terms: terms,
                      )
                  : null,
              icon: const Icon(Icons.payments_rounded, size: 17),
              label: Text(
                canWithdraw
                    ? 'Tarik Saldo ke Bank / E-Wallet'
                    : 'Tarik Saldo (Minimal ${formatRupiahIdr(terms.minWithdrawalIdr)})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(
    AffiliateWalletModel wallet,
    AffiliateProgramTerms terms,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KODE REFERRAL ANDA (Komisi ${terms.commissionPercent}% • Pembeli Hemat ${terms.buyerDiscountPercent}%)',
            style: const TextStyle(
              color: Color(0xFFD4A373),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12100E),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    wallet.affiliateCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4A373),
                  side: const BorderSide(color: Color(0xFFD4A373)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: wallet.affiliateCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kode ${wallet.affiliateCode} berhasil disalin!',
                      ),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
              ),
              if (!wallet.isCustomCodeClaimed) ...[
                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF9F5EE),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () => _showCustomizeCodeDialog(wallet),
                  child: const Icon(Icons.edit_rounded, size: 16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A373),
                foregroundColor: const Color(0xFF12100E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              onPressed: () => _shareCode(wallet, terms),
              icon: const Icon(CupertinoIcons.share, size: 16),
              label: const Text(
                'Bagikan Kode & Link Afiliasi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTabs(AffiliateDashboardModel dash) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabBtn(
            'Riwayat Komisi (${dash.recentConversions.length})',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _tabBtn(
            'Riwayat Penarikan (${dash.recentWithdrawals.length})',
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD4A373) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF12100E) : const Color(0xFFCBBFB2),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCommissionList(List<AffiliateConversionItem> list) {
    if (list.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Belum ada komisi masuk. Bagikan kode referral Anda ke teman barista atau pemilik kafe untuk mulai mendapatkan komisi 20%!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA8A29E), fontSize: 12),
          ),
        ),
      ];
    }
    final df = DateFormat('dd MMM yyyy, HH:mm');
    return list.map((c) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1714),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF4ADE80),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${c.buyerUsername} upgrade ${c.planDisplayLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    df.format(c.createdAt.toLocal()),
                    style: const TextStyle(
                      color: Color(0xFF9C8F82),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${formatRupiahIdr(c.commissionEarnedIdr)}',
              style: const TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildWithdrawalList(List<AffiliateWithdrawalItem> list) {
    if (list.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Belum ada riwayat penarikan saldo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA8A29E), fontSize: 12),
          ),
        ),
      ];
    }
    final df = DateFormat('dd MMM, HH:mm');
    return list.map((w) {
      final badgeColor = w.isCompleted
          ? const Color(0xFF22C55E)
          : (w.isRejected || w.isCancelled
              ? const Color(0xFFEF4444)
              : const Color(0xFFF59E0B));
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1714),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${w.ticketNumber} • ${w.bankOrWalletLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  formatRupiahIdr(w.netTransferAmountIdr),
                  style: const TextStyle(
                    color: Color(0xFFD4A373),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${w.accountNumber} a/n ${w.accountHolderName}',
              style: const TextStyle(color: Color(0xFFCBBFB2), fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    w.statusLabelId,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'SLA: ${df.format(w.slaDeadlineAt.toLocal())}',
                  style: const TextStyle(
                    color: Color(0xFF9C8F82),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (w.rejectionReason != null && w.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Alasan: ${w.rejectionReason}',
                style: const TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 11,
                ),
              ),
            ],
            if (w.isCompleted &&
                w.transferProofCloudinaryUrl != null &&
                w.transferProofCloudinaryUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4ADE80),
                  side: const BorderSide(color: Color(0xFF22C55E)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                onPressed: () => _showProofImageViewer(
                  w.transferProofCloudinaryUrl!,
                  w.ticketNumber,
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 15),
                label: const Text(
                  'Lihat Bukti Transfer',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
            if (w.isPending) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref
                      .read(affiliateDashboardProvider.notifier)
                      .cancelWithdrawal(w.id),
                  child: const Text(
                    'Batalkan Penarikan',
                    style: TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }
}
