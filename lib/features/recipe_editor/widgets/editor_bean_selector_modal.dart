import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';
import 'editor_bean_grid_card.dart';

class EditorBeanSelectorModal {
  static void show({
    required BuildContext context,
    required String initialBeanName,
    required String initialVariety,
    required String initialRoast,
    required String initialProcess,
    required void Function(String name, String variety, String roast, String process) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        String selectedOriginFilter = 'Semua';
        int visibleCount = 10;

        String tempBeanName = initialBeanName;
        String tempVariety = initialVariety;
        String tempRoast = initialRoast;
        String tempProcess = initialProcess;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredBeans = BrewVisualCatalog.beans.where((b) {
              final matchesQuery = b.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  b.region.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  b.defaultVariety.toLowerCase().contains(searchQuery.toLowerCase());
              if (!matchesQuery) return false;

              if (selectedOriginFilter == 'Sumatra 🇮🇩' || selectedOriginFilter == 'Sumatra') {
                return b.region.toLowerCase().contains('sumatra') ||
                    b.region.toLowerCase().contains('aceh') ||
                    b.region.toLowerCase().contains('bengkulu') ||
                    b.region.toLowerCase().contains('lampung');
              } else if (selectedOriginFilter == 'Jawa 🇮🇩' || selectedOriginFilter == 'Jawa') {
                return b.region.toLowerCase().contains('jawa') ||
                    b.region.toLowerCase().contains('garut') ||
                    b.region.toLowerCase().contains('bandung');
              } else if (selectedOriginFilter == 'Bali & Nusra 🇮🇩' || selectedOriginFilter == 'Bali & Nusra') {
                return b.region.toLowerCase().contains('bali') ||
                    b.region.toLowerCase().contains('ntt') ||
                    b.region.toLowerCase().contains('ntb') ||
                    b.region.toLowerCase().contains('lombok') ||
                    b.region.toLowerCase().contains('flores');
              } else if (selectedOriginFilter == 'Sulawesi 🇮🇩' || selectedOriginFilter == 'Sulawesi') {
                return b.region.toLowerCase().contains('sulawesi') ||
                    b.region.toLowerCase().contains('toraja') ||
                    b.region.toLowerCase().contains('enrekang');
              } else if (selectedOriginFilter == 'Papua 🇮🇩' || selectedOriginFilter == 'Papua') {
                return b.region.toLowerCase().contains('papua') ||
                    b.region.toLowerCase().contains('wamena');
              } else if (selectedOriginFilter == 'Internasional 🌍' || selectedOriginFilter == 'Internasional') {
                return !b.region.contains('🇮🇩');
              }
              return true;
            }).toList();

            final displayedBeans = filteredBeans.take(visibleCount).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title Bar & Close
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Biji Kopi / Single Origin',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tap kartu biji kopi atau sesuaikan varietas & proses di bawah',
                              style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted, size: 24),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Search & Filter Dropdown Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCream,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              onChanged: (val) {
                                setModalState(() {
                                  searchQuery = val;
                                  visibleCount = 10;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Cari nama biji, daerah, varietas...',
                                hintStyle: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                                border: InputBorder.none,
                                icon: Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          color: AppTheme.surfaceWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedOriginFilter != 'Semua' ? AppTheme.primaryBrown : AppTheme.bgCream,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              CupertinoIcons.line_horizontal_3_decrease,
                              color: selectedOriginFilter != 'Semua' ? Colors.white : AppTheme.primaryBrown,
                              size: 19,
                            ),
                          ),
                          onSelected: (val) {
                            setModalState(() {
                              selectedOriginFilter = val;
                              visibleCount = 10;
                            });
                          },
                          itemBuilder: (context) => [
                            'Semua',
                            'Jawa 🇮🇩',
                            'Sumatra 🇮🇩',
                            'Bali & Nusra 🇮🇩',
                            'Sulawesi 🇮🇩',
                            'Papua 🇮🇩',
                            'Internasional 🌍',
                          ].map((f) {
                            return PopupMenuItem(
                              value: f,
                              child: Row(
                                children: [
                                  if (selectedOriginFilter == f)
                                    const Icon(CupertinoIcons.checkmark, size: 16, color: AppTheme.primaryBrown)
                                  else
                                    const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Text(f, style: TextStyle(fontWeight: selectedOriginFilter == f ? FontWeight.bold : FontWeight.normal)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Quick Region Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: ['Semua', 'Jawa 🇮🇩', 'Sumatra 🇮🇩', 'Bali & Nusra 🇮🇩', 'Sulawesi 🇮🇩', 'Papua 🇮🇩', 'Internasional 🌍'].map((reg) {
                        final isSel = selectedOriginFilter == reg;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(reg, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textDark),
                            backgroundColor: AppTheme.bgCream,
                            onSelected: (_) {
                              setModalState(() {
                                selectedOriginFilter = reg;
                                visibleCount = 10;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 14),

                  // SCROLLABLE BODY (2-GRID COFFEE + MORE BUTTON + CUSTOMIZATION PANEL)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${displayedBeans.length} dari ${filteredBeans.length} Kopi',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            if (selectedOriginFilter != 'Semua')
                              TextButton(
                                onPressed: () => setModalState(() {
                                  selectedOriginFilter = 'Semua';
                                  visibleCount = 10;
                                }),
                                child: const Text('Reset Filter', style: TextStyle(fontSize: 11, color: AppTheme.primaryBrown)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 2-GRID CARD LAYOUT
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.88,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: displayedBeans.length,
                          itemBuilder: (context, index) {
                            final bean = displayedBeans[index];
                            final isSelected = tempBeanName == bean.name;

                            return EditorBeanGridCard(
                              bean: bean,
                              isSelected: isSelected,
                              onTap: () {
                                setModalState(() {
                                  tempBeanName = bean.name;
                                  tempVariety = bean.defaultVariety;
                                  tempProcess = bean.process;
                                  tempRoast = bean.roast;
                                });
                              },
                            );
                          },
                        ),

                        // TOMBOL MORE / TAMPILKAN LEBIH BANYAK (2x5 -> 2x10 -> 2x15...)
                        if (filteredBeans.length > visibleCount) ...[
                          const SizedBox(height: 14),
                          Center(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBrown,
                                side: const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              ),
                              icon: const Icon(CupertinoIcons.chevron_down_circle_fill, size: 18),
                              label: Text(
                                'Tampilkan Lebih Banyak ($visibleCount / ${filteredBeans.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  visibleCount += 10;
                                });
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // CUSTOMIZATION PANEL (VARIETAS, ROAST, PROSES DI BAWAHNYA)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Kustomisasi Profil Biji Terpilih:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // VARIETAS
                              const Text('Varietas Kopi:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: BrewVisualCatalog.varieties.map((v) {
                                    final sel = tempVariety == v;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(v, style: const TextStyle(fontSize: 11)),
                                        selected: sel,
                                        selectedColor: AppTheme.accentAmber,
                                        labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600),
                                        onSelected: (_) => setModalState(() => tempVariety = v),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // ROAST LEVEL
                              const Text('Tingkat Roasting (Roast Level):', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: BrewVisualCatalog.roastLevels.map((r) {
                                  final sel = tempRoast == r;
                                  Color roastColor = const Color(0xFFD7CCC8);
                                  if (r == 'Light') roastColor = const Color(0xFFD7CCC8);
                                  if (r == 'Light-Medium') roastColor = const Color(0xFFBCAAA4);
                                  if (r == 'Medium') roastColor = const Color(0xFF8D6E63);
                                  if (r == 'Medium-Dark') roastColor = const Color(0xFF5D4037);
                                  if (r == 'Dark') roastColor = const Color(0xFF3E2723);

                                  return ChoiceChip(
                                    avatar: CircleAvatar(radius: 5, backgroundColor: roastColor),
                                    label: Text(r, style: const TextStyle(fontSize: 11)),
                                    selected: sel,
                                    selectedColor: AppTheme.primaryBrown,
                                    labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600),
                                    onSelected: (_) => setModalState(() => tempRoast = r),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // PROCESS
                              const Text('Proses Pasca-Panen (Process):', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: BrewVisualCatalog.processes.map((p) {
                                    final sel = tempProcess == p;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(p, style: const TextStyle(fontSize: 11)),
                                        selected: sel,
                                        selectedColor: AppTheme.primaryBrown,
                                        labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600),
                                        onSelected: (_) => setModalState(() => tempProcess = p),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(CupertinoIcons.checkmark_alt, color: Colors.white),
                      label: Text(
                        'Gunakan Biji: $tempBeanName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        onSelected(tempBeanName, tempVariety, tempRoast, tempProcess);
                        Navigator.pop(ctx);
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
