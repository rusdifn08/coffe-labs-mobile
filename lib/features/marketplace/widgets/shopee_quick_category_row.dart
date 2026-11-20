import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ShopeeCategoryOption {
  final String key;
  final String label;
  final IconData icon;
  final Color tint;

  const ShopeeCategoryOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.tint,
  });
}

class ShopeeQuickCategoryRow extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const List<ShopeeCategoryOption> options = [
    ShopeeCategoryOption(
      key: 'All',
      label: 'Semua',
      icon: CupertinoIcons.square_grid_2x2_fill,
      tint: Color(0xFF6B4423),
    ),
    ShopeeCategoryOption(
      key: 'Single Origin',
      label: 'Single Origin',
      icon: Icons.coffee_rounded,
      tint: Color(0xFF8B4513),
    ),
    ShopeeCategoryOption(
      key: 'Espresso',
      label: 'Espresso',
      icon: CupertinoIcons.bolt_fill,
      tint: Color(0xFFC2410C),
    ),
    ShopeeCategoryOption(
      key: 'Filter V60',
      label: 'Filter V60',
      icon: CupertinoIcons.drop_fill,
      tint: Color(0xFF0369A1),
    ),
    ShopeeCategoryOption(
      key: 'Wine / Anaerob',
      label: 'Wine / Anaerob',
      icon: CupertinoIcons.sparkles,
      tint: Color(0xFF881337),
    ),
    ShopeeCategoryOption(
      key: 'Natural',
      label: 'Natural',
      icon: CupertinoIcons.sun_max_fill,
      tint: Color(0xFFD97706),
    ),
    ShopeeCategoryOption(
      key: 'Washed',
      label: 'Washed',
      icon: Icons.water_drop_rounded,
      tint: Color(0xFF0F766E),
    ),
    ShopeeCategoryOption(
      key: 'Alat Seduh',
      label: 'Alat Seduh',
      icon: CupertinoIcons.wrench_fill,
      tint: Color(0xFF475569),
    ),
  ];

  const ShopeeQuickCategoryRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final opt = options[index];
            final active = selectedCategory == opt.key;
            return InkWell(
              onTap: () => onCategorySelected(opt.key),
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 66,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: active
                            ? opt.tint
                            : opt.tint.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: active
                            ? null
                            : Border.all(
                                color: opt.tint.withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                      ),
                      child: Icon(
                        opt.icon,
                        size: 20,
                        color: active ? Colors.white : opt.tint,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      opt.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? opt.tint : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
