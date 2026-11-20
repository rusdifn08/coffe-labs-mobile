import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class RoasteryClusterFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedCluster;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final ValueChanged<String> onClusterSelected;

  static const List<String> clusterOptions = [
    'Semua',
    'Roastery Bisnis',
    'Klaster I: Ritel Nasional & Skala Industri',
    'Klaster II: Pelopor & Kurator Gelombang Ketiga',
    'Klaster III: Spesialis Kompetisi & Eksperimental',
    'Klaster IV: Roastery Regional & Komunitas Lokal',
    'Klaster V: Roastery Boutique, Mikro & Artisanal',
  ];

  const RoasteryClusterFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedCluster,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onClusterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 13.5, color: AppTheme.textDark),
            decoration: InputDecoration(
              hintText: 'Cari roastery, varian, atau varietas...',
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              prefixIcon: const Icon(
                CupertinoIcons.search,
                size: 19,
                color: AppTheme.textMuted,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.clear_circled_solid,
                          size: 18, color: AppTheme.textMuted),
                      onPressed: onSearchCleared,
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceWhite,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE9E0D4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE9E0D4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppTheme.primaryBrown, width: 1.4),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: clusterOptions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cluster = clusterOptions[index];
              final isSelected = selectedCluster == cluster;
              final isBusinessChip = cluster == 'Roastery Bisnis';

              return ChoiceChip(
                avatar: isBusinessChip
                    ? Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color:
                            isSelected ? Colors.white : AppTheme.accentGold,
                      )
                    : null,
                label: Text(cluster),
                selected: isSelected,
                onSelected: (_) => onClusterSelected(cluster),
                selectedColor: const Color(0xFF5C3A21),
                backgroundColor: AppTheme.surfaceWhite,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF5C3A21)
                      : const Color(0xFFE3D8C8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
          ),
        ),
      ],
    );
  }
}
