import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RoasteryClusterFilters extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> clusters;
  final String selectedCluster;
  final ValueChanged<String> onSelectCluster;

  const RoasteryClusterFilters({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.clusters,
    required this.selectedCluster,
    required this.onSelectCluster,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: AppTheme.bgCream,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari roastery, varian, atau varietas...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                icon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                border: InputBorder.none,
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                        onPressed: () => onSearchChanged(''),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: clusters.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final c = clusters[idx];
                final isSel = selectedCluster == c;
                return GestureDetector(
                  onTap: () => onSelectCluster(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        c,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? Colors.white : AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
