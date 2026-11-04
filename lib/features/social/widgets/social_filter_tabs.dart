import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class SocialFilterTabs extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const SocialFilterTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'all', 'label': 'Semua Feed', 'icon': CupertinoIcons.layers_fill},
      {'id': 'popular', 'label': '🔥 Terpopuler', 'icon': CupertinoIcons.flame_fill},
      {'id': 'recipes', 'label': '📖 Resep Kopi', 'icon': CupertinoIcons.book_fill},
    ];

    return Row(
      children: tabs.map((t) {
        final active = activeTab == t['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (activeTab != t['id']) {
                onTabChanged(t['id'] as String);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text(
                  t['label'] as String,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: active ? FontWeight.bold : FontWeight.w600,
                    color: active ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
