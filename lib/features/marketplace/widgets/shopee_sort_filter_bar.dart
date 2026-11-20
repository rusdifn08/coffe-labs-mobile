import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ShopeeSortFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedSort;
  final String selectedRoast;
  final ValueChanged<String> onSortSelected;
  final VoidCallback onFilterTap;

  const ShopeeSortFilterHeaderDelegate({
    required this.selectedSort,
    required this.selectedRoast,
    required this.onSortSelected,
    required this.onFilterTap,
  });

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final hasExtraFilter = selectedRoast != 'All';

    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEE6DA)),
          bottom: BorderSide(color: Color(0xFFE7DED2)),
        ),
      ),
      child: Row(
        children: [
          _tabItem('Terkait', 'relevant'),
          _divider(),
          _tabItem('Terbaru', 'latest'),
          _divider(),
          _tabItem('Terlaris', 'bestseller'),
          _divider(),
          Expanded(
            child: InkWell(
              onTap: () {
                final next = selectedSort == 'price_asc'
                    ? 'price_desc'
                    : 'price_asc';
                onSortSelected(next);
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Harga',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: (selectedSort == 'price_asc' ||
                                  selectedSort == 'price_desc')
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: (selectedSort == 'price_asc' ||
                                  selectedSort == 'price_desc')
                              ? const Color(0xFFEA580C)
                              : AppTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      selectedSort == 'price_desc'
                          ? CupertinoIcons.arrow_down
                          : (selectedSort == 'price_asc'
                              ? CupertinoIcons.arrow_up
                              : CupertinoIcons.arrow_up_arrow_down),
                      size: 11,
                      color: (selectedSort == 'price_asc' ||
                              selectedSort == 'price_desc')
                          ? const Color(0xFFEA580C)
                          : AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _divider(),
          InkWell(
            onTap: onFilterTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 13,
                    color: hasExtraFilter
                        ? const Color(0xFFEA580C)
                        : AppTheme.textDark,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          hasExtraFilter ? FontWeight.w800 : FontWeight.w600,
                      color: hasExtraFilter
                          ? const Color(0xFFEA580C)
                          : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 18, color: const Color(0xFFEBE3D7));
  }

  Widget _tabItem(String label, String key) {
    final active = selectedSort == key;
    return Expanded(
      child: InkWell(
        onTap: () => onSortSelected(key),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? const Color(0xFFEA580C) : Colors.transparent,
                width: 2.2,
              ),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? const Color(0xFFEA580C) : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ShopeeSortFilterHeaderDelegate oldDelegate) {
    return oldDelegate.selectedSort != selectedSort ||
        oldDelegate.selectedRoast != selectedRoast;
  }
}
