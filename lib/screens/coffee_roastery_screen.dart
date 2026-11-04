import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/roastery_catalog.dart';
import '../features/roastery/widgets/roastery_cluster_filters.dart';
import '../features/roastery/widgets/roastery_detail_sheet.dart';
import '../features/roastery/widgets/roastery_grid_card.dart';
import '../theme/app_theme.dart';

class CoffeeRoasteryScreen extends StatefulWidget {
  const CoffeeRoasteryScreen({super.key});

  @override
  State<CoffeeRoasteryScreen> createState() => _CoffeeRoasteryScreenState();
}

class _CoffeeRoasteryScreenState extends State<CoffeeRoasteryScreen> {
  String _searchQuery = '';
  String _selectedCluster = 'Semua';

  final List<String> _clusters = [
    'Semua',
    'Klaster I: Ritel Nasional',
    'Klaster II: Bandung & Jabar',
    'Klaster III: Jabodetabek',
    'Klaster IV: Jogja, Jateng & Jatim',
    'Klaster V: Bali & Nusantara',
  ];

  @override
  Widget build(BuildContext context) {
    final allRoasteries = RoasteryCatalog.list;
    final filtered = allRoasteries.where((r) {
      final matchesSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.specialties.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.lineups.any((l) =>
              l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.variety.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.process.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.tastingNotes.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCluster = _selectedCluster == 'Semua' ||
          (_selectedCluster == 'Klaster I: Ritel Nasional' && r.cluster.contains('Klaster I')) ||
          (_selectedCluster == 'Klaster II: Bandung & Jabar' && r.cluster.contains('Klaster II')) ||
          (_selectedCluster == 'Klaster III: Jabodetabek' && r.cluster.contains('Klaster III')) ||
          (_selectedCluster == 'Klaster IV: Jogja, Jateng & Jatim' && r.cluster.contains('Klaster IV')) ||
          (_selectedCluster == 'Klaster V: Bali & Nusantara' && r.cluster.contains('Klaster V'));

      return matchesSearch && matchesCluster;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              ),
              child: Text(
                '${filtered.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
            const Text('Coffee Roasteries'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header search & filter
          RoasteryClusterFilters(
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            clusters: _clusters,
            selectedCluster: _selectedCluster,
            onSelectCluster: (c) => setState(() => _selectedCluster = c),
          ),

          // 2-Column Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.flame, size: 48, color: AppTheme.primaryBrown.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          'Roastery tidak ditemukan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisExtent: 235,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final roastery = filtered[index];
                      return RoasteryGridCard(
                        roastery: roastery,
                        onTap: () => RoasteryDetailSheet.show(context, roastery),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
