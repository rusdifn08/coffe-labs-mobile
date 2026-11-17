import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Input pencarian minimalis bergaya Threads tanpa kotak card berbingkai tebal.
class SocialSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SocialSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Cari akun Coffee Labs, @username, atau barista...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(CupertinoIcons.search, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
              onChanged: onChanged,
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                CupertinoIcons.clear_circled_solid,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
