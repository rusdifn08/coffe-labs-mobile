import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Tab filter feed minimalis bergaya garis bawah ala Threads (termasuk tab Tersimpan).
class SocialFilterTabs extends StatelessWidget {
  final String activeTab;
  final int savedCount;
  final ValueChanged<String> onTabChanged;

  const SocialFilterTabs({
    super.key,
    required this.activeTab,
    this.savedCount = 0,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (id: 'all', label: 'Semua'),
      (id: 'popular', label: 'Terpopuler'),
      (id: 'recipes', label: 'Resep'),
      (id: 'saved', label: savedCount > 0 ? 'Tersimpan ($savedCount)' : 'Tersimpan'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: tabs.map((t) {
            final active = activeTab == t.id;
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (activeTab != t.id) {
                    onTabChanged(t.id);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Text(
                        t.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.8,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? AppTheme.primaryBrown
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2.2,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryBrown
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const Divider(height: 1, thickness: 1, color: AppTheme.dividerColor),
      ],
    );
  }
}
