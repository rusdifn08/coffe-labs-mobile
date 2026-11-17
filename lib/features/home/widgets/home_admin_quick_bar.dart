import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../theme/app_theme.dart';

/// Strip navigasi cepat Admin di Dashboard Home untuk langsung menuju
/// Monitoring User Online Live, Manajemen User, Feedback, dan OTA Version.
class HomeAdminQuickBar extends StatelessWidget {
  final bool isEn;

  const HomeAdminQuickBar({super.key, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.dot_radiowaves_left_right,
                  color: Color(0xFF43A047),
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn ? 'ADMIN & LIVE MONITORING' : 'NAVIGASI ADMIN & USER ONLINE',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFEA),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Command',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _pill(
                  label: isEn ? 'Online Users' : 'User Online Live',
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  bg: AppTheme.primaryBrown,
                  fg: Colors.white,
                  isPrimary: true,
                  onTap: () => context.push(AppRoutes.adminMonitoring),
                ),
                const SizedBox(width: 8),
                _pill(
                  label: isEn ? 'Users & Tier' : 'Manajemen Users',
                  icon: CupertinoIcons.person_2_fill,
                  bg: const Color(0xFFF6EFEA),
                  fg: AppTheme.primaryBrown,
                  onTap: () => context.push(AppRoutes.adminApproval),
                ),
                const SizedBox(width: 8),
                _pill(
                  label: 'Feedback',
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  bg: const Color(0xFFE8F3FA),
                  fg: const Color(0xFF1976D2),
                  onTap: () => context.push(AppRoutes.adminFeedback),
                ),
                const SizedBox(width: 8),
                _pill(
                  label: 'OTA & Version',
                  icon: CupertinoIcons.bolt_badge_a_fill,
                  bg: const Color(0xFFFFF8E1),
                  fg: const Color(0xFFB45309),
                  onTap: () => context.push(AppRoutes.adminVersion),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: AppTheme.borderWarm, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
