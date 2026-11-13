import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_thread_models.dart';

class ThreadScannedBeanBadge extends StatelessWidget {
  final ScannedCoffeeBagTagAttachment bean;

  const ThreadScannedBeanBadge({super.key, required this.bean});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.viewfinder_circle_fill,
                size: 16,
                color: AppTheme.primaryBrown,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${bean.roastery} • ${bean.beanName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AI ${bean.confidencePct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${bean.origin} • ${bean.process} • ${bean.altitudeMasl}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),
          if (bean.tastingNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: bean.tastingNotes
                  .take(5)
                  .map(
                    (note) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
