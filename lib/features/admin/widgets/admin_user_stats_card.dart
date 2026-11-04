import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminUserStatsCard extends StatelessWidget {
  final int totalUsers;
  final int newRegistrationsCount;
  final int activeUsers;

  const AdminUserStatsCard({
    super.key,
    required this.totalUsers,
    required this.newRegistrationsCount,
    required this.activeUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetric(
              label: 'Total Pengguna',
              value: '$totalUsers',
              icon: CupertinoIcons.person_3_fill,
              color: AppTheme.primaryBrown,
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          Expanded(
            child: _buildMetric(
              label: 'Pendaftaran Baru',
              value: '$newRegistrationsCount',
              icon: CupertinoIcons.bell_fill,
              color: Colors.orange.shade800,
              highlight: newRegistrationsCount > 0,
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          Expanded(
            child: _buildMetric(
              label: 'Barista Aktif',
              value: '$activeUsers',
              icon: CupertinoIcons.checkmark_seal_fill,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: highlight ? color : AppTheme.textMuted,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
