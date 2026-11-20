import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/optimized_coffee_image.dart';
import '../features/profile/widgets/subscription_checkout_sheet.dart';
import '../features/roastery/controllers/roastery_catalog_controller.dart';
import '../features/roastery/screens/business_roastery_studio_screen.dart';
import '../features/roastery/screens/roastery_detail_screen.dart';
import '../features/roastery/widgets/roastery_cluster_filters.dart';
import '../features/roastery/widgets/roastery_grid_card.dart';
import '../models/roastery.dart';
import '../models/subscription_plan.dart';
import '../theme/app_theme.dart';

class CoffeeRoasteryScreen extends ConsumerStatefulWidget {
  const CoffeeRoasteryScreen({super.key});

  @override
  ConsumerState<CoffeeRoasteryScreen> createState() =>
      _CoffeeRoasteryScreenState();
}

class _CoffeeRoasteryScreenState extends ConsumerState<CoffeeRoasteryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCluster = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Roastery> _filterRoasteries(List<Roastery> source) {
    final q = _searchQuery.trim().toLowerCase();
    return source.where((r) {
      final matchesCluster = _selectedCluster == 'Semua'
          ? true
          : (_selectedCluster == RoasteryCatalogController.businessClusterLabel
              ? (r.isVerifiedBusiness ||
                  r.cluster == RoasteryCatalogController.businessClusterLabel)
              : r.cluster == _selectedCluster);
      if (!matchesCluster) return false;
      if (q.isEmpty) return true;
      return r.name.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.specialties.toLowerCase().contains(q) ||
          r.lineups.any(
            (l) =>
                l.name.toLowerCase().contains(q) ||
                l.origin.toLowerCase().contains(q) ||
                l.variety.toLowerCase().contains(q),
          );
    }).toList();
  }

  void _openRoasteryDetail(Roastery roastery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoasteryDetailScreen(roastery: roastery),
      ),
    );
  }

  Future<void> _openStudio({bool openAddLineup = false}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessRoasteryStudioScreen(
          openAddLineupImmediately: openAddLineup,
        ),
      ),
    );
  }

  void _showNonBusinessPrompt() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD6CBBF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFDF3D7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Color(0xFFC28E1A),
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Buka Etalase Roastery Anda di Coffee Labs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fitur Business Roastery Studio eksklusif untuk akun Coffee Labs Business. Daftarkan 1 profil Roastery resmi toko Anda & publikasikan katalog biji kopi langsung ke komunitas!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  SubscriptionCheckoutSheet.show(
                    context,
                    plan: SubscriptionPlan.business,
                  );
                },
                icon: const Icon(Icons.bolt_rounded),
                label: const Text(
                  'Upgrade ke Business (Rp 249.000)',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(roasteryCatalogProvider);
    final merged = catalogState.allMergedRoasteries;
    final filtered = _filterRoasteries(merged);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E8D7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${merged.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Coffee Roasteries',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: InkWell(
                onTap: () => catalogState.isBusinessUser
                    ? _openStudio()
                    : _showNonBusinessPrompt(),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: catalogState.isBusinessUser
                        ? const Color(0xFF5C3A21)
                        : const Color(0xFFFDF3D7),
                    borderRadius: BorderRadius.circular(14),
                    border: catalogState.isBusinessUser
                        ? null
                        : Border.all(color: const Color(0xFFE7D08D)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        catalogState.isBusinessUser
                            ? Icons.storefront_rounded
                            : Icons.workspace_premium_rounded,
                        size: 14,
                        color: catalogState.isBusinessUser
                            ? Colors.white
                            : const Color(0xFF8C6209),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        catalogState.isBusinessUser
                            ? (catalogState.myRoastery != null
                                ? 'Studio'
                                : '+ Roastery')
                            : 'Buka Toko',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: catalogState.isBusinessUser
                              ? Colors.white
                              : const Color(0xFF8C6209),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          RoasteryClusterFilters(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedCluster: _selectedCluster,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onSearchCleared: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onClusterSelected: (c) => setState(() => _selectedCluster = c),
          ),
          const SizedBox(height: 10),
          if (catalogState.isBusinessUser) _buildBusinessStudioBanner(catalogState),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryBrown,
              onRefresh: () =>
                  ref.read(roasteryCatalogProvider.notifier).refreshCatalog(),
              child: filtered.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Column(
                            children: [
                              Icon(CupertinoIcons.search,
                                  size: 40, color: AppTheme.textMuted),
                              SizedBox(height: 10),
                              Text(
                                'Tidak ada roastery yang cocok',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final roastery = filtered[index];
                        return RoasteryGridCard(
                          roastery: roastery,
                          onTap: () => _openRoasteryDetail(roastery),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStudioBanner(RoasteryCatalogState state) {
    final mine = state.myRoastery;

    if (mine == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: InkWell(
          onTap: () => _openStudio(),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A2E1B), Color(0xFF6B4429)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFFFFD56B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktifkan Profil Roastery Toko Anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '1 Akun Business = 1 Roastery resmi dengan lineup unlimited.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Buat Sekarang',
                    style: TextStyle(
                      color: Color(0xFF2B1A0E),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7D49E)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F1E8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OptimizedCoffeeImage(
                  imageUrlOrAsset: mine.imageUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          mine.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded,
                          size: 14, color: AppTheme.accentGold),
                    ],
                  ),
                  Text(
                    '${mine.effectiveLineupCount} Varian Aktif • Business Studio',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _openStudio(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Kelola',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () => _openStudio(openAddLineup: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('+ Kopi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
