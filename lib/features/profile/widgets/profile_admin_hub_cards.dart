import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/admin_approval_screen.dart';
import '../../../screens/admin_feedback_screen.dart';
import '../../../screens/admin_trial_control_screen.dart';
import '../../../screens/admin_version_screen.dart';
import '../../../services/trial_service.dart';
import '../../admin_control/presentation/screens/admin_control_panel_screen.dart';
import '../../affiliate/presentation/screens/admin_affiliate_payout_queue_screen.dart';
import '../../monitoring/presentation/screens/platform_monitoring_dashboard_screen.dart';
import '../../qris_billing/presentation/screens/merchant_qris_bridge_admin_screen.dart';
import '../../../theme/app_theme.dart';

class ProfileAdminHubCards extends StatelessWidget {
  final int totalUsersCount;
  final int newRegistrationsCount;
  final int pendingFeedbackCount;
  final VoidCallback onRefresh;

  const ProfileAdminHubCards({
    super.key,
    this.totalUsersCount = 0,
    this.newRegistrationsCount = 0,
    required this.pendingFeedbackCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Seksi Admin yang Ramping & Eksklusif
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.shield_lefthalf_fill, size: 12.5, color: AppTheme.primaryBrown),
                  const SizedBox(width: 5),
                  const Text(
                    'PANEL KONTROL ADMIN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Superadmin',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
        ),

        // Kartu Aksi Kompak & Profesional
        _buildAdminFeatureLockAndPricingCard(context),
        const SizedBox(height: 8),
        _buildAdminMonitoringHubCard(context),
        const SizedBox(height: 8),
        _buildAdminAffiliatePayoutCard(context),
        const SizedBox(height: 8),
        _buildAdminQrisBridgeCard(context),
        const SizedBox(height: 8),
        _buildAdminTrialControlCard(context),
        const SizedBox(height: 8),
        _buildAdminApprovalCard(context),
        const SizedBox(height: 8),
        _buildAdminFeedbackHubCard(context),
        const SizedBox(height: 8),
        _buildAdminVersionHubCard(context),
      ],
    );
  }

  Widget _buildAdminFeatureLockAndPricingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFCA5A5).withValues(alpha: 0.55),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F1D1D).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminControlPanelScreen(),
              ),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.lock_shield_fill,
                    color: Color(0xFFFDE68A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kontrol Lock Fitur & Harga Pro/Bisnis',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Lock Maintenance / Coming Soon / Updated & Harga Live',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    '⚡ REAL-TIME',
                    style: TextStyle(
                      fontSize: 9.2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: Colors.white.withValues(alpha: 0.78),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminAffiliatePayoutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF34D399).withValues(alpha: 0.45),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminAffiliatePayoutQueueScreen(),
              ),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.money_dollar_circle_fill,
                    color: Color(0xFF6EE7B7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ACC Penarikan Saldo Afiliasi',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Transfer Bank/E-Wallet, Upload Bukti & Refund',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PAYOUT',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminQrisBridgeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1611), Color(0xFF3A2518)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.45),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MerchantQrisBridgeAdminScreen(),
              ),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.qrcode,
                    color: Color(0xFFD4A373),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Merchant QRIS Bridge & Rekonsiliasi',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Livin\' Merchant Listener, Uji CRC-16 & Approve Manual',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'QRIS',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF12100E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTrialControlCard(BuildContext context) {
    final policy = TrialService.currentPolicySync;
    final isFull7d = policy.isFull7DayNonBusiness;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFull7d
              ? const [Color(0xFF14532D), Color(0xFF166534)]
              : const [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFECA400).withValues(alpha: 0.4),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminTrialControlScreen()),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isFull7d
                        ? CupertinoIcons.sparkles
                        : CupertinoIcons.slider_horizontal_3,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Kontrol Trial & 7 Hari Full Non-Bisnis',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFull7d
                            ? 'Aktif: Trial 7 Hari Full (Non-Bisnis)'
                            : 'Switch akun non-pembeli & atur izin fitur',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isFull7d
                        ? const Color(0xFFDCFCE7)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    isFull7d ? '7H FULL' : 'ATUR',
                    style: TextStyle(
                      color: isFull7d ? const Color(0xFF14532D) : Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminMonitoringHubCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E2F16), Color(0xFF6B4423)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECA400).withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlatformMonitoringDashboardScreen()),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(CupertinoIcons.chart_bar_alt_fill, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Live Monitoring & User Online',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pantau user online, screen time & resep V60',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.82)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    '● LIVE',
                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(CupertinoIcons.chevron_forward, color: Colors.white.withValues(alpha: 0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminApprovalCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF382216), Color(0xFF513220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1810).withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminApprovalScreen()),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(CupertinoIcons.person_badge_plus, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Manajemen Pengguna & Pendaftaran',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalUsersCount > 0
                            ? '$totalUsersCount Barista terdaftar${newRegistrationsCount > 0 ? " • $newRegistrationsCount baru" : ""}'
                            : 'Kelola database barista & pendaftaran',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.82)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (newRegistrationsCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$newRegistrationsCount Baru',
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Icon(CupertinoIcons.chevron_forward, color: Colors.white.withValues(alpha: 0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminFeedbackHubCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()),
            ).then((_) => onRefresh());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pusat Feedback User',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pendingFeedbackCount > 0
                            ? '$pendingFeedbackCount masukan baru belum ditinjau'
                            : 'Kelola laporan bug, ide fitur & saran seduh',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.82)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (pendingFeedbackCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$pendingFeedbackCount Baru',
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Icon(CupertinoIcons.chevron_forward, color: Colors.white.withValues(alpha: 0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminVersionHubCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF311B92), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF311B92).withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminVersionScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(CupertinoIcons.bolt_badge_a_fill, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Version Gatekeeper & OTA',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kontrol Shorebird OTA Patch & Rilis Native',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.82)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade300.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: Colors.purple.shade200.withValues(alpha: 0.5), width: 0.8),
                  ),
                  child: const Text(
                    'Axum Gate',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(CupertinoIcons.chevron_forward, color: Colors.white.withValues(alpha: 0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
