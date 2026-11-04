import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/roastery.dart';
import '../../../theme/app_theme.dart';

class RoasteryDetailSheet extends StatefulWidget {
  final Roastery roastery;

  const RoasteryDetailSheet({super.key, required this.roastery});

  static void show(BuildContext context, Roastery roastery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoasteryDetailSheet(roastery: roastery),
    );
  }

  @override
  State<RoasteryDetailSheet> createState() => _RoasteryDetailSheetState();
}

class _RoasteryDetailSheetState extends State<RoasteryDetailSheet> {
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/roasteries/${r.id}.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.primaryBrown,
                      child: const Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 28),
                    ),
                  ),
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
