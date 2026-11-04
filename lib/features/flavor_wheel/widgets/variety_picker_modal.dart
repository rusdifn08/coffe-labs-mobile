import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../data/coffee_varieties_catalog.dart';

class VarietyPickerModal {
  static void show({
    required BuildContext context,
    required String effectiveVariety,
    required ValueChanged<String> onSelectVariety,
    required ValueChanged<String> onSelectCustom,
  }) {
    String searchQuery = '';
    String selectedCategory = 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final filtered = CoffeeVarietiesCatalog.all.where((v) {
              final matchCat = selectedCategory == 'Semua' || v.category.contains(selectedCategory);
              final q = searchQuery.toLowerCase();
              final matchQuery = q.isEmpty ||
                  v.name.toLowerCase().contains(q) ||
                  v.origin.toLowerCase().contains(q) ||
                  v.tasteProfile.toLowerCase().contains(q);
              return matchCat && matchQuery;
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.82,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 22),
                          SizedBox(width: 8),
                          Text('Katalog Lengkap Varietas Kopi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari varietas (Bourbon, Typica, Geisha, S-795)...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: Color(0xFF2E7D32)),
                      filled: true,
                      fillColor: AppTheme.bgCream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 10),
                  // Kategori Chip
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Bourbon', 'Nusantara', 'Eksotik', 'Spesies'].map((cat) {
                        final isSel = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat == 'Semua' ? 'Semua (${CoffeeVarietiesCatalog.all.length})' : cat),
                            selected: isSel,
                            selectedColor: const Color(0xFF2E7D32),
                            backgroundColor: AppTheme.bgCream,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : AppTheme.textDark,
                            ),
                            onSelected: (_) => setModalState(() => selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Varietas tidak ditemukan dalam katalog.', style: TextStyle(color: AppTheme.textMuted)),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    onSelectCustom(searchQuery);
                                    Navigator.pop(ctx);
                                  },
                                  icon: const Icon(CupertinoIcons.plus, size: 16),
                                  label: Text('Gunakan "$searchQuery" sebagai Kustom'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final item = filtered[idx];
                              final isCurrent = effectiveVariety.toLowerCase().contains(item.name.toLowerCase());
                              return Container(
                                decoration: BoxDecoration(
                                  color: isCurrent ? const Color(0xFF2E7D32).withValues(alpha: 0.08) : AppTheme.bgCream,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent ? const Color(0xFF2E7D32) : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.origin,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.tasteProfile,
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
                                      ),
                                    ),
                                    trailing: Icon(
                                      isCurrent ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.chevron_right,
                                      color: isCurrent ? const Color(0xFF2E7D32) : AppTheme.textMuted,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      onSelectVariety(item.name);
                                      Navigator.pop(ctx);
                                    },
                                  ),
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
  }
}
