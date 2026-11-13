import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';

class InteractiveBeanChatBubble extends StatelessWidget {
  final CoffeeBeanCardAttachment card;

  const InteractiveBeanChatBubble({super.key, required this.card});

  Color _processColor(String process) {
    final lower = process.toLowerCase();
    if (lower.contains('wine')) return const Color(0xFF881337);
    if (lower.contains('natural') || lower.contains('anaerobic')) {
      return const Color(0xFFB45309);
    }
    if (lower.contains('honey')) return const Color(0xFFD97706);
    return AppTheme.primaryBrown;
  }

  @override
  Widget build(BuildContext context) {
    final procColor = _processColor(card.process);

    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderWarm, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.rosette,
                  color: AppTheme.primaryBrown,
                  size: 13,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  card.roastery,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightBrown,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: procColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: procColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  card.process,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: procColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.beanName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                CupertinoIcons.map_pin_ellipse,
                size: 12,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  card.origin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (card.tastingNotes.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: card.tastingNotes
                  .take(5)
                  .map(
                    (note) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
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
