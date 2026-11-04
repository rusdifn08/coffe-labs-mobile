import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';

class EditorBeanGridCard extends StatelessWidget {
  final BeanVisualItem bean;
  final bool isSelected;
  final VoidCallback onTap;

  const EditorBeanGridCard({
    super.key,
    required this.bean,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? bean.color.withValues(alpha: 0.12) : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? bean.color : Colors.grey.shade300,
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bean.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(bean.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 6),
            Text(
              bean.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? bean.color : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              bean.region,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                bean.defaultVariety,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? bean.color : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
