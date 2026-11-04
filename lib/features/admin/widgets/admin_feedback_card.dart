import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/feedback_item.dart';
import '../../../theme/app_theme.dart';

class AdminFeedbackCard extends StatelessWidget {
  final FeedbackItem feedback;
  final VoidCallback onDelete;
  final VoidCallback onUpdateStatus;

  const AdminFeedbackCard({
    super.key,
    required this.feedback,
    required this.onDelete,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final cat = feedback.categoryInfo;
    final statusColor = FeedbackStatusHelper.getColor(feedback.status);
    final statusLabel = FeedbackStatusHelper.getLabel(feedback.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Category badge + Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        cat.label,
                        style: TextStyle(color: cat.color, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              feedback.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
            ),
            const SizedBox(height: 4),

            // Feature affected & Rating
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Fitur: ${feedback.featureAffected}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (starIdx) {
                    return Icon(
                      starIdx < feedback.rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      size: 12,
                      color: Colors.amber,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              feedback.description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
            ),

            // Admin notes if present
            if (feedback.adminNotes != null && feedback.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(CupertinoIcons.pencil_circle_fill, size: 14, color: Colors.purple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Catatan Admin: ${feedback.adminNotes}',
                        style: const TextStyle(fontSize: 11, color: Colors.purple, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.dividerColor),
            const SizedBox(height: 10),

            // Sender Info & Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oleh @${feedback.username} (${feedback.userRole}) · ${feedback.deviceInfo}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.trash, size: 18, color: Colors.redAccent),
                      tooltip: 'Hapus',
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onUpdateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(CupertinoIcons.pencil, size: 13),
                      label: const Text('Update Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
