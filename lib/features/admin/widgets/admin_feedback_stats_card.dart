import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/feedback_item.dart';
import '../../../theme/app_theme.dart';

class AdminFeedbackStatsCard extends StatelessWidget {
  final FeedbackStatsData stats;

  const AdminFeedbackStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  iconColor: AppTheme.primaryBrown,
                  label: 'Total Masukan',
                  value: '${stats.total}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.clock_fill,
                  iconColor: Colors.orange,
                  label: 'Belum Ditinjau',
                  value: '${stats.pending}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.star_fill,
                  iconColor: Colors.amber,
                  label: 'Rata-rata Rating',
                  value: '⭐ ${stats.averageRating.toStringAsFixed(1)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('🐛', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('${stats.bugReports} Bug Report', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('${stats.featureRequests} Ide Fitur', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text('${stats.resolved} Selesai', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }
}
