import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ShopeeStickySearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final int cartCount;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onCameraSearchTap;
  final VoidCallback onCartTap;
  final VoidCallback onHistoryTap;

  const ShopeeStickySearchHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.cartCount,
    required this.onBack,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCameraSearchTap,
    required this.onCartTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primaryBrown,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 22),
              onPressed: onBack,
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(
                      CupertinoIcons.search,
                      size: 16,
                      color: Color(0xFF9C8E82),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textDark,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Cari kopi, roastery, notes...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9C8E82),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      InkWell(
                        onTap: onClearSearch,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 16,
                            color: Color(0xFF9C8E82),
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: onCameraSearchTap,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Icon(
                          CupertinoIcons.camera,
                          size: 18,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  tooltip: 'Keranjang Belanja',
                  icon: const Icon(
                    CupertinoIcons.cart_fill,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: onCartTap,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartCount > 99 ? '99+' : '$cartCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              tooltip: 'Riwayat Pesanan',
              icon: const Icon(
                CupertinoIcons.doc_text,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onHistoryTap,
            ),
          ],
        ),
      ),
    );
  }
}
