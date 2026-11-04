import 'flavor_notes_filter_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../utils/barista_utils.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../models/note_category_item.dart';

class RecipeFilterModal {
  static void show({
    required BuildContext context,
    required String selectedPourFilter,
    required String selectedDripperFilter,
    required String selectedBaristaFilter,
    required String selectedCategory,
    required String selectedOriginFilter,
    required String selectedNoteFilter,
    required String selectedNoteCategoryTab,
    required List<Map<String, dynamic>> uniqueBaristas,
    required List<String> categories,
    required List<String> pourFilterOptions,
    required List<String> originFilterOptions,
    required void Function({
      required String pourFilter,
      required String dripperFilter,
      required String baristaFilter,
      required String category,
      required String originFilter,
      required String noteFilter,
      required String noteCategoryTab,
    }) onApplyFilters,
    required VoidCallback onResetAll,
  }) {
    final isEn = LanguageService.isEnglish;

    // Temporary working state inside the modal
    String currentPour = selectedPourFilter;
    String currentDripper = selectedDripperFilter;
    String currentBarista = selectedBaristaFilter;
    String currentCategory = selectedCategory;
    String currentOrigin = selectedOriginFilter;
    String currentNote = selectedNoteFilter;
    String activeNoteCategoryModal = selectedNoteCategoryTab;

    if (currentNote != 'Semua' && currentNote != 'All') {
      for (final cat in noteCategories) {
        if (currentNote == '${cat.emoji} ${cat.label}' ||
            currentNote == '${cat.emoji} ${cat.labelEn}' ||
            currentNote == 'Semua ${cat.label}' ||
            currentNote == 'All ${cat.labelEn}' ||
            currentNote == cat.label ||
            currentNote == cat.labelEn) {
          activeNoteCategoryModal = cat.id;
          break;
        }
        final inGroup = BrewVisualCatalog.flavorNotes
            .where((fn) => cat.groups.contains(fn.group))
            .any((fn) => fn.label == currentNote);
        if (inGroup) {
          activeNoteCategoryModal = cat.id;
          break;
        }
      }
    }

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
            int getModalActiveFilterCount() {
              int c = 0;
              if (currentCategory != 'All') c++;
              if (currentPour != 'Semua' && currentPour != 'All') c++;
              if (currentDripper != 'Semua' && currentDripper != 'All') c++;
              if (currentBarista != 'Semua' && currentBarista != 'All') c++;
              if (currentNote != 'Semua' && currentNote != 'All') c++;
              if (currentOrigin != 'Semua' && currentOrigin != 'All') c++;
              return c;
            }

            final activeCount = getModalActiveFilterCount();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.84,
              minChildSize: 0.5,
              maxChildSize: 0.94,
              builder: (_, scrollCtrl) {
                return Column(
                  children: [
                    // Modal Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isEn ? 'All Recipe Filters' : 'Filter Resep Lengkap',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              if (activeCount > 0)
                                TextButton(
                                  onPressed: () {
                                    setModalState(() {
                                      currentPour = isEn ? 'All' : 'Semua';
                                      currentDripper = isEn ? 'All' : 'Semua';
                                      currentBarista = isEn ? 'All' : 'Semua';
                                      currentCategory = 'All';
                                      currentOrigin = isEn ? 'All' : 'Semua';
                                      currentNote = isEn ? 'All' : 'Semua';
                                      activeNoteCategoryModal = 'floral';
                                    });
                                    onResetAll();
                                  },
                                  child: Text(
                                    isEn ? 'Reset All' : 'Reset Semua',
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        children: [
                          // 1. FILTER BY JUMLAH POURING
                          _filterSectionTitle(
                            CupertinoIcons.drop_fill,
                            isEn ? '1. Pour Count / Structure' : '1. Jumlah Pouring / Struktur Tuangan',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pourFilterOptions.map((opt) {
                              final selected = currentPour == opt;
                              return ChoiceChip(
                                label: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: selected ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: AppTheme.primaryBrown,
                                backgroundColor: AppTheme.surfaceWhite,
                                onSelected: (_) {
                                  setModalState(() => currentPour = opt);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),

                          // 2. FILTER BY DRIPPER / ALAT SEDUH
                          _filterSectionTitle(
                            CupertinoIcons.cube_box_fill,
                            isEn ? '2. Dripper / Brewing Gear' : '2. Pilih Dripper / Alat Seduh',
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 106,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _dripperFilterCard(
                                  shortName: isEn ? 'All' : 'Semua',
                                  subtitle: isEn ? 'All Gear' : 'Semua Alat',
                                  selected: currentDripper == 'Semua' || currentDripper == 'All',
                                  item: null,
                                  onTap: () {
                                    setModalState(() => currentDripper = isEn ? 'All' : 'Semua');
                                  },
                                ),
                                ...BrewVisualCatalog.drippers.map((d) {
                                  final selected = currentDripper == d.shortName;
                                  return _dripperFilterCard(
                                    shortName: d.shortName,
                                    subtitle: d.defaultCategory,
                                    selected: selected,
                                    item: d,
                                    onTap: () {
                                      setModalState(() => currentDripper = d.shortName);
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // 3. FILTER BY BARISTA
                          _filterSectionTitle(
                            CupertinoIcons.person_2_fill,
                            isEn ? '3. Barista / Brewer' : '3. Pilih Barista / Brewer',
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 104,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: uniqueBaristas.length + 1,
                              itemBuilder: (context, idx) {
                                if (idx == 0) {
                                  final sel = currentBarista == 'Semua' || currentBarista == 'All';
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() => currentBarista = isEn ? 'All' : 'Semua');
                                    },
                                    child: Container(
                                      width: 78,
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: sel ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: sel ? Colors.white24 : AppTheme.bgCream,
                                            child: Icon(CupertinoIcons.person_3_fill, size: 18, color: sel ? Colors.white : AppTheme.primaryBrown),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            isEn ? 'All' : 'Semua',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : AppTheme.textDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                final b = uniqueBaristas[idx - 1];
                                final name = b['name'] as String;
                                final sel = currentBarista == name;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() => currentBarista = name);
                                  },
                                  child: Container(
                                    width: 82,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: sel ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: sel ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                                        width: sel ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        BaristaAvatar(
                                          imageUrl: b['imageUrl'] as String?,
                                          radius: 22,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          name,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: sel ? Colors.white : AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 22),

                          // 4. FILTER BY TEKNIK / KATEGORI
                          _filterSectionTitle(
                            CupertinoIcons.lab_flask_solid,
                            isEn ? '4. Brew Method' : '4. Teknik Seduh',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((cat) {
                              final selected = currentCategory == cat;
                              return ChoiceChip(
                                label: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: selected ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: AppTheme.primaryBrown,
                                backgroundColor: AppTheme.surfaceWhite,
                                onSelected: (_) {
                                  setModalState(() => currentCategory = cat);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),

                          FlavorNotesFilterSection(
                            activeNoteCategoryModal: activeNoteCategoryModal,
                            selectedNoteFilter: currentNote,
                            onCategoryTabChanged: (tabId) {
                              setModalState(() {
                                activeNoteCategoryModal = tabId;
                              });
                            },
                            onNoteFilterChanged: (newFilter) {
                              setModalState(() {
                                currentNote = newFilter;
                              });
                            },
                          ),
                          const SizedBox(height: 22),

                          // 6. FILTER BY ASAL & DURASI
                          _filterSectionTitle(
                            CupertinoIcons.globe,
                            isEn ? '6. Barista Origin & Duration' : '6. Asal Barista & Durasi',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: originFilterOptions.map((opt) {
                              final selected = currentOrigin == opt;
                              return ChoiceChip(
                                label: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: selected ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: AppTheme.accentAmber,
                                backgroundColor: AppTheme.surfaceWhite,
                                onSelected: (_) {
                                  setModalState(() => currentOrigin = opt);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    // Apply Button
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            onApplyFilters(
                              pourFilter: currentPour,
                              dripperFilter: currentDripper,
                              baristaFilter: currentBarista,
                              category: currentCategory,
                              originFilter: currentOrigin,
                              noteFilter: currentNote,
                              noteCategoryTab: activeNoteCategoryModal,
                            );
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.check_mark, size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                activeCount > 0
                                    ? (isEn ? 'Apply Filter ($activeCount)' : 'Terapkan Filter ($activeCount)')
                                    : (isEn ? 'Apply Filter' : 'Terapkan Filter'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  static Widget _filterSectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBrown),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
      ],
    );
  }

  static Widget _dripperFilterCard({
    required String shortName,
    required String subtitle,
    required bool selected,
    required DripperVisualItem? item,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 98,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item != null)
              DripperGraphicBadge(item: item, size: 42)
            else
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? Colors.white24 : AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(CupertinoIcons.square_grid_2x2_fill, color: selected ? Colors.white : AppTheme.primaryBrown, size: 20),
              ),
            const SizedBox(height: 6),
            Text(
              shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppTheme.textDark,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                color: selected ? Colors.white70 : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
