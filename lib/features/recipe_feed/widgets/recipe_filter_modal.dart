import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../../services/language_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';
import '../../brew_methods/models/brew_method_item.dart';
import '../utils/recipe_filter_matcher.dart';
import 'flavor_notes_filter_section.dart';

class RecipeFilterModal {
  static void show({
    required BuildContext context,
    required String selectedPourFilter,
    required String selectedDripperFilter,
    String selectedBaristaFilter = 'Semua',
    String selectedCategory = 'All',
    required String selectedOriginFilter,
    required String selectedNoteFilter,
    String selectedNoteCategoryTab = 'floral',
    List<Map<String, dynamic>> uniqueBaristas = const [],
    List<String> categories = const [],
    List<String> pourFilterOptions = const [],
    List<String> originFilterOptions = const [],
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
    final allLabel = isEn ? 'All' : 'Semua';

    // Working state inside modal
    int currentPourCount = RecipeFilterMatcher.parsePourCount(selectedPourFilter);
    String currentPour = currentPourCount > 0
        ? RecipeFilterMatcher.formatPourFilter(currentPourCount, isEnglish: isEn)
        : allLabel;
    String currentMethod = selectedDripperFilter;
    String currentOrigin = selectedOriginFilter;
    String currentNote = selectedNoteFilter;
    String activeNoteCategoryModal = selectedNoteCategoryTab;

    // Normalize legacy origin strings so the flag/icon chips highlight properly
    if (currentOrigin.contains('Indonesia')) {
      currentOrigin = 'Indonesia';
    } else if (currentOrigin.contains('Internasional') ||
        currentOrigin.contains('International')) {
      currentOrigin = isEn ? 'International' : 'Internasional';
    } else if (currentOrigin.contains('Es') || currentOrigin.contains('Iced')) {
      currentOrigin = isEn ? '❄️ Iced' : '❄️ Es';
    } else if (currentOrigin.contains('Cepat') || currentOrigin.contains('Fast')) {
      currentOrigin = isEn ? '⚡ Fast (≤ 2:15)' : '⚡ Cepat (≤ 2:15)';
    } else if (currentOrigin.isEmpty || currentOrigin == 'Semua' || currentOrigin == 'All') {
      currentOrigin = allLabel;
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
              if (currentPourCount > 0) c++;
              if (currentMethod != 'Semua' && currentMethod != 'All' && currentMethod.isNotEmpty) {
                c++;
              }
              if (currentNote != 'Semua' && currentNote != 'All' && currentNote.isNotEmpty) {
                c++;
              }
              if (currentOrigin != 'Semua' && currentOrigin != 'All' && currentOrigin.isNotEmpty) {
                c++;
              }
              return c;
            }

            final activeCount = getModalActiveFilterCount();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.48,
              maxChildSize: 0.92,
              builder: (_, scrollCtrl) {
                return Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Modal Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 14, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.slider_horizontal_3,
                                  color: AppTheme.primaryBrown,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isEn ? 'Recipe Filters' : 'Filter Resep Lengkap',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (activeCount > 0)
                                TextButton(
                                  onPressed: () {
                                    setModalState(() {
                                      currentPourCount = 0;
                                      currentPour = allLabel;
                                      currentMethod = allLabel;
                                      currentOrigin = allLabel;
                                      currentNote = allLabel;
                                      activeNoteCategoryModal = 'floral';
                                    });
                                    onResetAll();
                                  },
                                  child: Text(
                                    isEn ? 'Reset' : 'Reset',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                  color: AppTheme.textMuted,
                                ),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Scrollable Filter Body
                    Expanded(
                      child: ListView(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        children: [
                          // 1. METODE SEDUH (dengan ikon 3D)
                          _filterSectionTitle(
                            CupertinoIcons.cube_box_fill,
                            isEn ? 'Brew Method' : 'Metode Seduh',
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 116,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _methodFilterCard(
                                  title: allLabel,
                                  selected: currentMethod == 'Semua' ||
                                      currentMethod == 'All' ||
                                      currentMethod.isEmpty,
                                  imageAsset: null,
                                  onTap: () {
                                    setModalState(() => currentMethod = allLabel);
                                  },
                                ),
                                ...BrewMethodItem.allMethods.map((method) {
                                  final selected =
                                      currentMethod.toLowerCase() == method.filterKey.toLowerCase() ||
                                          currentMethod.toLowerCase() == method.title.toLowerCase() ||
                                          currentMethod.toLowerCase() == method.titleId.toLowerCase();
                                  return _methodFilterCard(
                                    title: isEn ? method.title : method.titleId,
                                    selected: selected,
                                    imageAsset: method.imageAsset,
                                    onTap: () {
                                      setModalState(() {
                                        currentMethod = selected ? allLabel : method.filterKey;
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. TASTING NOTES (Inti saja)
                          FlavorNotesFilterSection(
                            activeNoteCategoryModal: activeNoteCategoryModal,
                            selectedNoteFilter: currentNote,
                            onCategoryTabChanged: (tabId) {
                              setModalState(() => activeNoteCategoryModal = tabId);
                            },
                            onNoteFilterChanged: (newFilter) {
                              setModalState(() => currentNote = newFilter);
                            },
                          ),
                          const SizedBox(height: 24),

                          // 3. ASAL BARISTA & DURASI (Bendera Indonesia saja + ikon simpel)
                          _filterSectionTitle(
                            CupertinoIcons.globe,
                            isEn ? 'Barista Origin & Duration' : 'Asal Barista & Durasi',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _originChip(
                                selected: currentOrigin == 'Semua' || currentOrigin == 'All',
                                onTap: () => setModalState(() => currentOrigin = allLabel),
                                child: Text(
                                  allLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (currentOrigin == 'Semua' || currentOrigin == 'All')
                                        ? Colors.white
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                              // Indonesia: ikon bendera Indonesia saja agar simpel
                              Tooltip(
                                message: isEn ? 'Indonesian Baristas' : 'Barista Indonesia',
                                child: Semantics(
                                  label: 'Indonesia',
                                  button: true,
                                  selected: currentOrigin == 'Indonesia',
                                  child: _originChip(
                                    key: const Key('origin_indonesia_flag_btn'),
                                    selected: currentOrigin == 'Indonesia',
                                    horizontalPadding: 12,
                                    onTap: () => setModalState(() {
                                      currentOrigin =
                                          currentOrigin == 'Indonesia' ? allLabel : 'Indonesia';
                                    }),
                                    child: const BaristaFlagBadge(
                                      countryCode: 'id',
                                      width: 26,
                                      height: 19,
                                      borderRadius: 4,
                                    ),
                                  ),
                                ),
                              ),
                              // Internasional: ikon globe simpel
                              Tooltip(
                                message: isEn ? 'International Baristas' : 'Barista Internasional',
                                child: Semantics(
                                  label: isEn ? 'International' : 'Internasional',
                                  button: true,
                                  selected: currentOrigin == 'Internasional' ||
                                      currentOrigin == 'International',
                                  child: _originChip(
                                    key: const Key('origin_international_btn'),
                                    selected: currentOrigin == 'Internasional' ||
                                        currentOrigin == 'International',
                                    horizontalPadding: 13,
                                    onTap: () => setModalState(() {
                                      final intlVal =
                                          isEn ? 'International' : 'Internasional';
                                      currentOrigin =
                                          (currentOrigin == 'Internasional' ||
                                                  currentOrigin == 'International')
                                              ? allLabel
                                              : intlVal;
                                    }),
                                    child: Icon(
                                      CupertinoIcons.globe,
                                      size: 18,
                                      color: (currentOrigin == 'Internasional' ||
                                              currentOrigin == 'International')
                                          ? Colors.white
                                          : AppTheme.primaryBrown,
                                    ),
                                  ),
                                ),
                              ),
                              // Resep Pakai Es
                              _originChip(
                                selected: currentOrigin.contains('Es') ||
                                    currentOrigin.contains('Iced'),
                                onTap: () => setModalState(() {
                                  final icedVal = isEn ? '❄️ Iced' : '❄️ Es';
                                  currentOrigin = (currentOrigin.contains('Es') ||
                                          currentOrigin.contains('Iced'))
                                      ? allLabel
                                      : icedVal;
                                }),
                                child: Text(
                                  isEn ? '❄️ Iced' : '❄️ Es',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (currentOrigin.contains('Es') ||
                                            currentOrigin.contains('Iced'))
                                        ? Colors.white
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                              // Cepat ≤ 2:15
                              _originChip(
                                selected: currentOrigin.contains('Cepat') ||
                                    currentOrigin.contains('Fast'),
                                onTap: () => setModalState(() {
                                  final fastVal =
                                      isEn ? '⚡ Fast (≤ 2:15)' : '⚡ Cepat (≤ 2:15)';
                                  currentOrigin = (currentOrigin.contains('Cepat') ||
                                          currentOrigin.contains('Fast'))
                                      ? allLabel
                                      : fastVal;
                                }),
                                child: Text(
                                  isEn ? '⚡ ≤ 2:15' : '⚡ ≤ 2:15',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (currentOrigin.contains('Cepat') ||
                                            currentOrigin.contains('Fast'))
                                        ? Colors.white
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 4. JUMLAH POURING (di paling bawah, HANYA stepper - dan +)
                          _filterSectionTitle(
                            CupertinoIcons.drop_fill,
                            isEn ? 'Pour Count' : 'Jumlah Pouring',
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: currentPourCount > 0
                                    ? AppTheme.primaryBrown.withValues(alpha: 0.45)
                                    : AppTheme.primaryBrown.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentPourCount == 0
                                            ? (isEn ? 'Any Pour Count' : 'Semua Jumlah Pouring')
                                            : (isEn
                                                ? '${currentPourCount}x Pouring'
                                                : '${currentPourCount}x Pouring'),
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currentPourCount == 0
                                            ? (isEn
                                                ? 'Tap + to filter by exact pours'
                                                : 'Tekan + untuk atur jumlah tuangan')
                                            : (isEn
                                                ? 'Show recipes with exactly $currentPourCount pour(s)'
                                                : 'Tampilkan resep dengan $currentPourCount kali tuangan'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _stepperButton(
                                      key: const Key('pour_decrement_btn'),
                                      icon: CupertinoIcons.minus,
                                      enabled: currentPourCount > 0,
                                      onTap: () {
                                        if (currentPourCount <= 0) return;
                                        setModalState(() {
                                          currentPourCount--;
                                          currentPour = RecipeFilterMatcher.formatPourFilter(
                                            currentPourCount,
                                            isEnglish: isEn,
                                          );
                                        });
                                      },
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 44),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        currentPourCount == 0 ? '-' : '${currentPourCount}x',
                                        key: const Key('pour_count_value'),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: currentPourCount > 0
                                              ? AppTheme.primaryBrown
                                              : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                    _stepperButton(
                                      key: const Key('pour_increment_btn'),
                                      icon: CupertinoIcons.plus,
                                      enabled: currentPourCount < RecipeFilterMatcher.maxPourCount,
                                      onTap: () {
                                        if (currentPourCount >= RecipeFilterMatcher.maxPourCount) {
                                          return;
                                        }
                                        setModalState(() {
                                          currentPourCount++;
                                          currentPour = RecipeFilterMatcher.formatPourFilter(
                                            currentPourCount,
                                            isEnglish: isEn,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            onApplyFilters(
                              pourFilter: currentPour,
                              dripperFilter: currentMethod,
                              baristaFilter: allLabel,
                              category: selectedCategory,
                              originFilter: currentOrigin,
                              noteFilter: currentNote,
                              noteCategoryTab: activeNoteCategoryModal,
                            );
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.check_mark, size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  activeCount > 0
                                      ? (isEn
                                          ? 'Apply Filter ($activeCount)'
                                          : 'Terapkan Filter ($activeCount)')
                                      : (isEn ? 'Apply Filter' : 'Terapkan Filter'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
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
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _methodFilterCard({
    required String title,
    required bool selected,
    required String? imageAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 94,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppTheme.primaryBrown
                : AppTheme.primaryBrown.withValues(alpha: 0.14),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: selected ? Colors.white : AppTheme.bgCream.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: imageAsset != null
                  ? OptimizedCoffeeImage(
                      imageUrlOrAsset: imageAsset,
                      width: 46,
                      height: 46,
                      fit: BoxFit.contain,
                      errorWidget: Icon(
                        Icons.coffee_rounded,
                        size: 26,
                        color: Colors.brown.shade300,
                      ),
                    )
                  : Icon(
                      CupertinoIcons.square_grid_2x2_fill,
                      color: AppTheme.primaryBrown,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                height: 1.15,
                color: selected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _originChip({
    Key? key,
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
    double horizontalPadding = 14,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppTheme.primaryBrown
                : AppTheme.primaryBrown.withValues(alpha: 0.16),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [child],
        ),
      ),
    );
  }

  static Widget _stepperButton({
    Key? key,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primaryBrown : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? AppTheme.primaryBrown
                : AppTheme.primaryBrown.withValues(alpha: 0.14),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : AppTheme.textMuted.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
