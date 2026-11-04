import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AppTastingChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? color;

  const AppTastingChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBrown
              : (color ?? const Color(0xFFF6EFE7)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBrown
                : const Color(0xFFE2D4C3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryBrown,
          ),
        ),
      ),
    );
  }
}
