import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/admin_approval_screen.dart';
import '../../../screens/admin_feedback_screen.dart';
import '../../../screens/admin_version_screen.dart';
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

        // 3 Kartu Aksi Kompak & Profesional
        _buildAdminApprovalCard(context),
        const SizedBox(height: 8),
        _buildAdminFeedbackHubCard(context),
        const SizedBox(height: 8),
        _buildAdminVersionHubCard(context),
      ],
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
