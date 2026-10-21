import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/roastery_catalog.dart';
import '../models/roastery.dart';
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
          Container(
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
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari roastery, varian, atau varietas...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      icon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                              onPressed: () => setState(() => _searchQuery = ''),
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
                    itemCount: _clusters.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final c = _clusters[idx];
                      final isSel = _selectedCluster == c;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCluster = c),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final roastery = filtered[index];
                      return _buildRoasteryCard(context, roastery);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoasteryCard(BuildContext context, Roastery roastery) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRoasteryDetail(context, roastery),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top badge & rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${roastery.lineups.length} Varian',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.star_fill, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${roastery.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Roastery Icon & Name
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.primaryBrown, size: 24),
              ),
              const SizedBox(height: 10),

              Text(
                roastery.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(CupertinoIcons.location_solid, size: 11, color: AppTheme.accentGold),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      roastery.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Sales highlight badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  roastery.salesHighlight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // View lineup button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat Lineup',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(CupertinoIcons.chevron_right, size: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoasteryDetail(BuildContext context, Roastery roastery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RoasteryDetailSheet(roastery: roastery),
    );
  }
}

class _RoasteryDetailSheet extends StatefulWidget {
  final Roastery roastery;
  const _RoasteryDetailSheet({required this.roastery});

  @override
  State<_RoasteryDetailSheet> createState() => _RoasteryDetailSheetState();
}

class _RoasteryDetailSheetState extends State<_RoasteryDetailSheet> {
  String _selectedRoastFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final r = widget.roastery;
    final filteredLineups = r.lineups.where((item) {
      if (_selectedRoastFilter == 'Semua') return true;
      return item.roastProfile.toLowerCase().contains(_selectedRoastFilter.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Roastery
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.location_solid, size: 12, color: AppTheme.accentGold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              r.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.cluster,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Description box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
              ),
              child: Text(
                r.description,
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Lineup filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Katalog Lineup Kopi (${filteredLineups.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoastFilter,
                    icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua Sangrai')),
                      DropdownMenuItem(value: 'Light', child: Text('Light Roast')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium Roast')),
                      DropdownMenuItem(value: 'Dark', child: Text('Dark Roast')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRoastFilter = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Coffee Lineup List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: filteredLineups.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = filteredLineups[idx];
                return _buildLineupItemCard(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupItemCard(BuildContext context, CoffeeLineupItem item) {
    Color roastColor = Colors.brown;
    final rLower = item.roastProfile.toLowerCase();
    if (rLower.contains('light')) {
      roastColor = Colors.orange.shade700;
    } else if (rLower.contains('dark')) {
      roastColor = Colors.brown.shade900;
    } else {
      roastColor = Colors.brown.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              if (item.badge != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Origin & Variety
          Row(
            children: [
              const Icon(CupertinoIcons.map_pin_ellipse, size: 12, color: AppTheme.primaryBrown),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.origin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          Row(
            children: [
              const Icon(CupertinoIcons.leaf_arrow_circlepath, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Varietas: ${item.variety}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chips (Roast & Process)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roastColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.roastProfile,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: roastColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.process,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tasting Notes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.sparkles, size: 13, color: AppTheme.accentGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.tastingNotes,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.price100g,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryBrown),
                      ),
                      const Text(' / 100g  •  ', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Text(
                        item.price200g,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryBrown),
                      ),
                      const Text(' / 200g', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                  Text(
                    item.originalPackage,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 18, color: AppTheme.primaryBrown),
                tooltip: 'Salin Detail Biji',
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: '${item.name} (${item.origin}) - Varietas: ${item.variety}, Proses: ${item.process}. Tasting Notes: ${item.tastingNotes}. Harga: ${item.price100g}/100g, ${item.price200g}/200g',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detail ${item.name} disalin ke clipboard!'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
