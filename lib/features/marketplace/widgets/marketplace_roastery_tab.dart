import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/roastery_catalog.dart';
import '../../../models/roastery.dart';
import '../../../theme/app_theme.dart';

/// Tab 2 Marketplace: Direktori Official Roastery bergaya Tokopedia Official Store.
class MarketplaceRoasteryTab extends StatefulWidget {
  final ValueChanged<Roastery> onOpenRoasteryCatalog;

  const MarketplaceRoasteryTab({
    super.key,
    required this.onOpenRoasteryCatalog,
  });

  @override
  State<MarketplaceRoasteryTab> createState() => _MarketplaceRoasteryTabState();
}

class _MarketplaceRoasteryTabState extends State<MarketplaceRoasteryTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final roasteries = RoasteryCatalog.list.where((r) {
      if (q.isEmpty) return true;
      return r.name.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
    }).toList(growable: false);

    return Column(
      children: [
        Container(
          color: AppTheme.primaryBrown,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 12,
            16,
            14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Official Roastery Store',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama roastery atau kota (Jakarta, Bandung, Bali...)',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9C8E82)),
                    prefixIcon: Icon(CupertinoIcons.search, size: 17, color: Color(0xFF9C8E82)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            itemCount: roasteries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final r = roasteries[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDE4D7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.bgCream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE7D9C6)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            r.name.isNotEmpty ? r.name[0].toUpperCase() : 'R',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      r.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    size: 14,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.location_solid,
                                    size: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      '${r.location} · ★ ${r.rating.toStringAsFixed(1)} · ${r.lineups.length} produk',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textDark,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => widget.onOpenRoasteryCatalog(r),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          side: BorderSide(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Lihat ${r.lineups.length} Produk di Etalase',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
