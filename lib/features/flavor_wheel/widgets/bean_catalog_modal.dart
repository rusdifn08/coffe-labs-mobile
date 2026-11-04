import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/brew_visual_catalog.dart';

class BeanCatalogModal {
  static void show({
    required BuildContext context,
    required ValueChanged<BeanVisualItem> onSelectBean,
  }) {
    final List<BeanVisualItem> allBeans = BrewVisualCatalog.beans;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = allBeans.where((b) {
              final q = searchQuery.toLowerCase();
              return b.name.toLowerCase().contains(q) ||
                  b.region.toLowerCase().contains(q) ||
                  b.defaultVariety.toLowerCase().contains(q) ||
                  b.process.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              minChildSize: 0.45,
              maxChildSize: 0.94,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Pilih Biji Kopi Cupping',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (v) => setModalState(() => searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Cari kopi, daerah, atau varietas...',
                          prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollCtrl,
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final b = filtered[idx];
                            return Card(
                              elevation: 0,
                              color: AppTheme.surfaceWhite,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
                                  child: const Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 20),
                                ),
                                title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(
                                  '${b.region} • ${b.defaultVariety} • ${b.process}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                                trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: AppTheme.textMuted),
                                onTap: () {
                                  onSelectBean(b);
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
