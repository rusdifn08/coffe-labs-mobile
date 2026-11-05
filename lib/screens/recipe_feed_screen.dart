import '../features/recipe_feed/utils/recipe_filter_matcher.dart';
import '../features/recipe_feed/widgets/recipe_delete_dialog.dart';
import '../features/recipe_feed/widgets/recipe_feed_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../features/bean_scanner/controllers/selected_brew_bean_controller.dart';
import '../features/bean_scanner/models/resolved_coffee_bean.dart';
import '../features/recipes/controllers/recipe_list_controller.dart';
import '../services/api_service.dart';
import '../services/trial_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../services/main_navigation_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import '../features/recipe_feed/models/recipe_sort_option.dart';
import '../features/recipe_feed/widgets/recipe_filter_modal.dart';
import '../features/recipe_feed/widgets/recipe_sort_modal.dart';
import '../features/recipe_feed/widgets/recipe_feed_grid_card.dart';
import '../features/recipe_feed/widgets/landscape_recipe_inspector.dart';
import '../features/recipe_feed/widgets/trial_lock_dialog.dart';

/// Halaman Katalog Resep Dunia (World Recipes) dengan Riverpod ConsumerStatefulWidget.
class RecipeFeedScreen extends ConsumerStatefulWidget {
  final String? initialMethodFilter;
  final String? initialMethodTitle;

  const RecipeFeedScreen({
    super.key,
    this.initialMethodFilter,
    this.initialMethodTitle,
  });

  @override
  ConsumerState<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends ConsumerState<RecipeFeedScreen> {
  List<Map<String, dynamic>> _uniqueBaristas = [];
  bool _isTrial = false;

  // Filter States
  String _searchQuery = '';
  String _selectedMethodFilter = 'All';
  String? _currentMethodTitle;
  String _selectedCategory = 'All';
  String _selectedPourFilter = 'Semua';
  String _selectedDripperFilter = 'Semua';
  String _selectedBaristaFilter = 'Semua';
  String _selectedNoteFilter = 'Semua';
  String _selectedOriginFilter = 'Semua';
  String _selectedNoteCategoryTab = 'floral';
  RecipeSortOption _selectedSort = RecipeSortOption.defaultCurated;
  bool _isSplitMode = false;
  dynamic _selectedInspectionRecipe;

  List<String> get _categories => RecipeFilterMatcher.categories;
  List<String> get _pourFilterOptions => RecipeFilterMatcher.pourFilterOptions(LanguageService.isEnglish);
  List<String> get _originFilterOptions => RecipeFilterMatcher.originFilterOptions(LanguageService.isEnglish);

  @override
  void initState() {
    super.initState();
    if (widget.initialMethodFilter != null && widget.initialMethodFilter!.isNotEmpty) {
      _selectedMethodFilter = widget.initialMethodFilter!;
    }
    _currentMethodTitle = widget.initialMethodTitle;
    MainNavigationService.methodFilterNotifier.addListener(_onMethodFilterNavChange);
    _loadAuxiliaryData();
    TrialService.changeNotifier.addListener(_onTrialChanged);
    LanguageService.changeNotifier.addListener(_onLanguageChanged);
    _checkTrial();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _checkTrial() async {
    final t = await TrialService.isTrialMode();
    if (mounted) setState(() => _isTrial = t);
  }

  void _onTrialChanged() {
    _checkTrial();
  }

  @override
  void dispose() {
    TrialService.changeNotifier.removeListener(_onTrialChanged);
    LanguageService.changeNotifier.removeListener(_onLanguageChanged);
    MainNavigationService.methodFilterNotifier.removeListener(_onMethodFilterNavChange);
    super.dispose();
  }

  Future<void> _loadAuxiliaryData() async {
    try {
      final baristas = await ApiService.getUniqueBaristas();
      if (!mounted) return;
      setState(() {
        _uniqueBaristas = baristas;
      });
    } catch (_) {}
  }

  int get _activeFilterCount {
    int c = 0;
    if (_selectedMethodFilter != 'All') c++;
    if (_selectedCategory != 'All') c++;
    if (_selectedPourFilter != 'Semua' && _selectedPourFilter != 'All') c++;
    if (_selectedDripperFilter != 'Semua' && _selectedDripperFilter != 'All') c++;
    if (_selectedBaristaFilter != 'Semua' && _selectedBaristaFilter != 'All') c++;
    if (_selectedNoteFilter != 'Semua' && _selectedNoteFilter != 'All') c++;
    if (_selectedOriginFilter != 'Semua' && _selectedOriginFilter != 'All') c++;
    return c;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedMethodFilter = 'All';
      _selectedCategory = 'All';
      _selectedPourFilter = 'Semua';
      _selectedDripperFilter = 'Semua';
      _selectedBaristaFilter = 'Semua';
      _selectedNoteFilter = 'Semua';
      _selectedOriginFilter = 'Semua';
      _selectedNoteCategoryTab = 'floral';
      _selectedSort = RecipeSortOption.defaultCurated;
      _searchQuery = '';
    });
  }

  void _onMethodFilterNavChange() {
    final filter = MainNavigationService.methodFilterNotifier.value;
    final title = MainNavigationService.methodTitleNotifier.value;
    if (mounted && filter != null) {
      setState(() {
        _selectedMethodFilter = filter;
        _currentMethodTitle = title;
      });
    }
  }

  void _clearMethodFilterAndGoHome() {
    MainNavigationService.clearMethodFilter();
    setState(() {
      _selectedMethodFilter = 'All';
      _currentMethodTitle = null;
    });
    MainNavigationService.switchTab(0);
  }

  void _clearMethodFilterOnly() {
    MainNavigationService.clearMethodFilter();
    setState(() {
      _selectedMethodFilter = 'All';
      _currentMethodTitle = null;
    });
  }

  void _openFilterModal() {
    RecipeFilterModal.show(
      context: context,
      selectedPourFilter: _selectedPourFilter,
      selectedDripperFilter: _selectedDripperFilter,
      selectedBaristaFilter: _selectedBaristaFilter,
      selectedCategory: _selectedCategory,
      selectedOriginFilter: _selectedOriginFilter,
      selectedNoteFilter: _selectedNoteFilter,
      selectedNoteCategoryTab: _selectedNoteCategoryTab,
      uniqueBaristas: _uniqueBaristas,
      categories: _categories,
      pourFilterOptions: _pourFilterOptions,
      originFilterOptions: _originFilterOptions,
      onApplyFilters: ({
        required String pourFilter,
        required String dripperFilter,
        required String baristaFilter,
        required String category,
        required String originFilter,
        required String noteFilter,
        required String noteCategoryTab,
      }) {
        setState(() {
          _selectedPourFilter = pourFilter;
          _selectedDripperFilter = dripperFilter;
          _selectedBaristaFilter = baristaFilter;
          _selectedCategory = category;
          _selectedOriginFilter = originFilter;
          _selectedNoteFilter = noteFilter;
          _selectedNoteCategoryTab = noteCategoryTab;
        });
      },
      onResetAll: _resetAllFilters,
    );
  }

  void _openSortModal() {
    RecipeSortModal.show(
      context: context,
      currentSort: _selectedSort,
      onSortSelected: (sort) {
        setState(() {
          _selectedSort = sort;
        });
      },
    );
  }

  Future<void> _confirmDelete(int id, String title) async {
    final deleted = await RecipeDeleteDialog.show(context, id: id, title: title);
    if (deleted == true) {
      ref.read(recipeListControllerProvider.notifier).deleteRecipe(id);
    }
  }

  void _showTrialLockDialog() {
    RecipeTrialLockDialog.show(context);
  }

  void _openDetail(dynamic recipe, {int? index}) {
    if (_isTrial && index != null && index >= 10) {
      _showTrialLockDialog();
      return;
    }
    context.push(AppRoutes.recipeDetail, extra: recipe);
  }

  void _openBarista(dynamic recipe) {
    context.push(
      AppRoutes.baristaProfile,
      extra: {
        'rawAuthor': recipe['author']?.toString() ?? '',
        'imageUrl': BaristaUtils.imageUrlFromRecipe(recipe),
        'coverImageUrl': BaristaUtils.coverUrlFromRecipe(recipe),
      },
    );
  }

  void _surpriseMe(List<dynamic> pool) {
    if (pool.isEmpty) return;
    var source = pool;
    if (_isTrial && source.length > 10) {
      source = source.take(10).toList();
    }
    final picked = (List<dynamic>.from(source)..shuffle()).first;
    _openDetail(picked, index: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final recipesAsync = ref.watch(recipeListControllerProvider);

    return recipesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('World Recipes'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown)),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('World Recipes'), centerTitle: true),
        body: Center(child: Text('Gagal memuat resep: $err')),
      ),
      data: (allRecipes) {
        final List<dynamic> filteredRecipes = allRecipes.where((raw) {
          final r = ApiService.sanitizeRecipe(raw);
          final catLower = _selectedCategory.toLowerCase();
          bool matchesCategory = _selectedCategory == 'All' ||
              r['category'] == _selectedCategory ||
              (r['category'] ?? '').toString().toLowerCase().contains(catLower) ||
              (r['method'] ?? '').toString().toLowerCase().contains(catLower) ||
              (r['title'] ?? '').toString().toLowerCase().contains(catLower);
          final authorStr = (r['author'] ?? '').toString();
          final cleanAuthor = BaristaUtils.cleanName(authorStr);
          bool matchesBarista = _selectedBaristaFilter == 'Semua' ||
              _selectedBaristaFilter == 'All' ||
              cleanAuthor.toLowerCase() == _selectedBaristaFilter.toLowerCase();

          final isIndo = BaristaUtils.countryCode(authorStr) == 'id';
          final iceGrams = (r['iceWeightGrams'] ?? 0) as num;
          final isIced = iceGrams > 0 || (r['category'] ?? '').toString().toLowerCase().contains('iced');
          final totalSecs = (r['totalTimeSeconds'] ?? 180) as num;

          bool matchesOrigin = true;
          if (_selectedOriginFilter.contains('Indonesia')) {
            matchesOrigin = isIndo;
          } else if (_selectedOriginFilter.contains('Internasional') || _selectedOriginFilter.contains('International')) {
            matchesOrigin = !isIndo;
          } else if (_selectedOriginFilter.contains('Es') || _selectedOriginFilter.contains('Iced')) {
            matchesOrigin = isIced;
          } else if (_selectedOriginFilter.contains('Cepat') || _selectedOriginFilter.contains('Fast')) {
            matchesOrigin = totalSecs <= 135;
          }

          final q = _searchQuery.toLowerCase();
          bool matchesSearch = q.isEmpty ||
              authorStr.toLowerCase().contains(q) ||
              (r['title'] != null && r['title'].toString().toLowerCase().contains(q)) ||
              (r['method'] != null && r['method'].toString().toLowerCase().contains(q)) ||
              (r['beanName'] != null && r['beanName'].toString().toLowerCase().contains(q)) ||
              (r['tastingNotes'] != null && r['tastingNotes'].toString().toLowerCase().contains(q)) ||
              (r['category'] != null && r['category'].toString().toLowerCase().contains(q));

          final matchesMethod = RecipeFilterMatcher.matchesMethod(r, _selectedMethodFilter);

          return matchesCategory &&
              matchesMethod &&
              matchesBarista &&
              matchesOrigin &&
              RecipeFilterMatcher.matchesPour(r, _selectedPourFilter) &&
              RecipeFilterMatcher.matchesDripper(r, _selectedDripperFilter) &&
              RecipeFilterMatcher.matchesNote(r, _selectedNoteFilter) &&
              matchesSearch;
        }).toList();

        // Terapkan sortir berdasarkan 5 kategori (+ default)
        switch (_selectedSort) {
          case RecipeSortOption.alphabetical:
            filteredRecipes.sort((a, b) {
              final titleA = (a['title'] ?? '').toString().toLowerCase();
              final titleB = (b['title'] ?? '').toString().toLowerCase();
              return titleA.compareTo(titleB);
            });
            break;

          case RecipeSortOption.newest:
            filteredRecipes.sort((a, b) {
              final isCustomA = a['isCustom'] == true ? 1 : 0;
              final isCustomB = b['isCustom'] == true ? 1 : 0;
              if (isCustomA != isCustomB) return isCustomB.compareTo(isCustomA);
              final idA = int.tryParse(a['id']?.toString() ?? '') ?? 0;
              final idB = int.tryParse(b['id']?.toString() ?? '') ?? 0;
              return idB.compareTo(idA);
            });
            break;

          case RecipeSortOption.fastestBrew:
            filteredRecipes.sort((a, b) {
              final timeA = (a['totalTimeSeconds'] as num?)?.toInt() ?? 180;
              final timeB = (b['totalTimeSeconds'] as num?)?.toInt() ?? 180;
              return timeA.compareTo(timeB);
            });
            break;

          case RecipeSortOption.coffeeDose:
            filteredRecipes.sort((a, b) {
              final doseA = (a['coffeeWeightGrams'] as num?)?.toInt() ?? 15;
              final doseB = (b['coffeeWeightGrams'] as num?)?.toInt() ?? 15;
              return doseA.compareTo(doseB);
            });
            break;

          case RecipeSortOption.baristaName:
            filteredRecipes.sort((a, b) {
              final authorA = BaristaUtils.cleanName((a['author'] ?? '').toString()).toLowerCase();
              final authorB = BaristaUtils.cleanName((b['author'] ?? '').toString()).toLowerCase();
              return authorA.compareTo(authorB);
            });
            break;

          case RecipeSortOption.defaultCurated:
            break;
        }

        final scannedBean = ref.watch(selectedBrewBeanProvider);
        if (scannedBean != null && scannedBean.recommendedRecipes.isNotEmpty) {
          final targetSlugs = scannedBean.recommendedRecipes.map((r) => r.slug.toLowerCase()).toSet();
          filteredRecipes.sort((a, b) {
            final titleA = (a['title'] ?? '').toString().toLowerCase();
            final titleB = (b['title'] ?? '').toString().toLowerCase();
            final isMatchA = targetSlugs.any((s) => titleA.contains(s.replaceAll('-', ' '))) ||
                (scannedBean.process.toLowerCase().contains('natural') && titleA.contains('natural'));
            final isMatchB = targetSlugs.any((s) => titleB.contains(s.replaceAll('-', ' '))) ||
                (scannedBean.process.toLowerCase().contains('natural') && titleB.contains('natural'));
            if (isMatchA && !isMatchB) return -1;
            if (!isMatchA && isMatchB) return 1;
            return 0;
          });
        }

        final showBackButton = Navigator.canPop(context) || _selectedMethodFilter != 'All';

        return PopScope(
          canPop: !showBackButton,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && showBackButton) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                _clearMethodFilterAndGoHome();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leadingWidth: showBackButton ? 48 : 72,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.chevron_back),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          _clearMethodFilterAndGoHome();
                        }
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            '${filteredRecipes.length}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ),
                    ),
              title: const Text('World Recipes'),
              centerTitle: true,
              actions: [
                Builder(
                  builder: (ctx) {
                    final isLandscape = MediaQuery.of(ctx).orientation == Orientation.landscape;
                    final isWide = MediaQuery.of(ctx).size.width >= 720;
                    if (!isLandscape && !isWide) return const SizedBox.shrink();

                    return IconButton(
                      tooltip: _isSplitMode
                          ? (isEn ? 'Switch to Multi-Grid View' : 'Mode Multi-Grid Katalog')
                          : (isEn ? 'Switch to Split Inspector Cockpit' : 'Mode Cockpit Inspeksi Barista (Split)'),
                      icon: Icon(
                        _isSplitMode ? CupertinoIcons.rectangle_grid_2x2 : CupertinoIcons.sidebar_right,
                        color: _isSplitMode ? AppTheme.accentGold : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSplitMode = !_isSplitMode;
                          if (_isSplitMode && _selectedInspectionRecipe == null && filteredRecipes.isNotEmpty) {
                            _selectedInspectionRecipe = filteredRecipes.first;
                          }
                        });
                      },
                    );
                  },
                ),
                IconButton(
                  tooltip: isEn ? 'Surprise Me (Random Recipe)' : 'Pilihkan Resep Acak',
                  icon: const Icon(CupertinoIcons.sparkles),
                  onPressed: () => _surpriseMe(filteredRecipes),
                ),
                IconButton(
                  tooltip: isEn ? 'Add Custom Recipe' : 'Tambah Resep Sendiri',
                  icon: const Icon(CupertinoIcons.add),
                  onPressed: () async {
                    final didAdd = await context.push(AppRoutes.addRecipe);
                    if (didAdd == true) {
                      ref.read(recipeListControllerProvider.notifier).refreshRecipes();
                    }
                  },
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final mediaQuery = MediaQuery.of(context);
                final isLandscape = mediaQuery.orientation == Orientation.landscape;
                final isWide = constraints.maxWidth >= 720;
                final isLandscapeOrWide = isLandscape || isWide;

                if (isLandscapeOrWide && _isSplitMode) {
                  return Row(
                    children: [
                      // Panel Kiri: Kontrol Pencarian, Filter & Grid 2-Kolom
                      Expanded(
                        flex: 11,
                        child: Column(
                          children: [
                            RecipeFeedSearchBar(
                              activeFilterCount: _activeFilterCount,
                              categories: _categories,
                              selectedCategory: _selectedCategory,
                              selectedPourFilter: _selectedPourFilter,
                              selectedDripperFilter: _selectedDripperFilter,
                              selectedBaristaFilter: _selectedBaristaFilter,
                              selectedNoteFilter: _selectedNoteFilter,
                              selectedOriginFilter: _selectedOriginFilter,
                              onSearchChanged: (val) => setState(() => _searchQuery = val),
                              onOpenFilter: _openFilterModal,
                              onOpenSort: _openSortModal,
                              isSortActive: _selectedSort != RecipeSortOption.defaultCurated,
                              activeSortLabel: _selectedSort != RecipeSortOption.defaultCurated ? _selectedSort.label : null,
                              onResetSort: () => setState(() => _selectedSort = RecipeSortOption.defaultCurated),
                              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                              onRemovePourFilter: () => setState(() => _selectedPourFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                              onRemoveDripperFilter: () => setState(() => _selectedDripperFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                              onRemoveBaristaFilter: () => setState(() => _selectedBaristaFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                              onRemoveNoteFilter: () => setState(() => _selectedNoteFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                              onRemoveOriginFilter: () => setState(() => _selectedOriginFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                              onResetAll: _resetAllFilters,
                            ),
                            if (scannedBean != null) _buildScannedBeanBanner(scannedBean),
                            if (_selectedMethodFilter != 'All') _buildMethodFilterBanner(isEn),
                            const SizedBox(height: 4),
                            Expanded(
                              child: _buildRecipeGrid(
                                context,
                                filteredRecipes,
                                isSplitMode: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1, color: AppTheme.dividerColor),
                      // Panel Kanan: Cockpit Inspeksi Resep Barista & Mulai Seduh
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                          child: LandscapeRecipeInspector(
                            rawRecipe: _selectedInspectionRecipe ?? (filteredRecipes.isNotEmpty ? filteredRecipes.first : null),
                            isTrial: _isTrial,
                            onTrialLocked: _showTrialLockDialog,
                            onOpenFullDetail: () {
                              if (_selectedInspectionRecipe != null) {
                                _openDetail(_selectedInspectionRecipe);
                              }
                            },
                            onClose: () => setState(() => _isSplitMode = false),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Default Tampilan Adaptif Grid Presisi (Bebas Ruang Kosong Berlebih)
                return Column(
                  children: [
                    RecipeFeedSearchBar(
                      activeFilterCount: _activeFilterCount,
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      selectedPourFilter: _selectedPourFilter,
                      selectedDripperFilter: _selectedDripperFilter,
                      selectedBaristaFilter: _selectedBaristaFilter,
                      selectedNoteFilter: _selectedNoteFilter,
                      selectedOriginFilter: _selectedOriginFilter,
                      onSearchChanged: (val) => setState(() => _searchQuery = val),
                      onOpenFilter: _openFilterModal,
                      onOpenSort: _openSortModal,
                      isSortActive: _selectedSort != RecipeSortOption.defaultCurated,
                      activeSortLabel: _selectedSort != RecipeSortOption.defaultCurated ? _selectedSort.label : null,
                      onResetSort: () => setState(() => _selectedSort = RecipeSortOption.defaultCurated),
                      onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                      onRemovePourFilter: () => setState(() => _selectedPourFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                      onRemoveDripperFilter: () => setState(() => _selectedDripperFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                      onRemoveBaristaFilter: () => setState(() => _selectedBaristaFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                      onRemoveNoteFilter: () => setState(() => _selectedNoteFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                      onRemoveOriginFilter: () => setState(() => _selectedOriginFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
                      onResetAll: _resetAllFilters,
                    ),
                    if (scannedBean != null) _buildScannedBeanBanner(scannedBean),
                    if (_selectedMethodFilter != 'All') _buildMethodFilterBanner(isEn),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _buildRecipeGrid(
                        context,
                        filteredRecipes,
                        isSplitMode: false,
                      ),
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: _isSplitMode
                ? null
                : FloatingActionButton.extended(
                    heroTag: 'recipe_feed_social_fab',
                    backgroundColor: AppTheme.primaryBrown,
                    onPressed: () {
                      context.push(AppRoutes.social);
                    },
                    icon: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.white, size: 20),
                    label: const Text(
                      'Social Coffee',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMethodFilterBanner(bool isEn) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.slider_horizontal_3, size: 14, color: AppTheme.primaryBrown),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isEn
                  ? 'Method: ${_currentMethodTitle ?? widget.initialMethodTitle ?? _selectedMethodFilter}'
                  : 'Metode: ${_currentMethodTitle ?? widget.initialMethodTitle ?? _selectedMethodFilter}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
            ),
          ),
          GestureDetector(
            onTap: _clearMethodFilterOnly,
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 16, color: AppTheme.primaryBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedBeanBanner(ResolvedCoffeeBean bean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF261D16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A21).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.center_focus_strong_rounded, color: Color(0xFFD4AF37), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '⭐ BIJI TERDETEKSI: ',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10.5, fontWeight: FontWeight.w900),
                    ),
                    Expanded(
                      child: Text(
                        '${bean.roasteryName} - ${bean.beanName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Proses: ${bean.process} • Varietas: ${bean.variety} • Target Suhu: ${bean.recommendedWaterTempC}°C',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: Colors.white38),
            onPressed: () => ref.read(selectedBrewBeanProvider.notifier).clear(),
            tooltip: 'Hapus filter biji',
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid(
    BuildContext context,
    List<dynamic> recipes, {
    required bool isSplitMode,
  }) {
    if (recipes.isEmpty) {
      final isEn = LanguageService.isEnglish;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.search, size: 42, color: AppTheme.textMuted),
            const SizedBox(height: 10),
            Text(isEn ? 'No recipes match this filter.' : 'Tidak ada resep yang cocok dengan filter ini.'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _resetAllFilters,
              child: Text(isEn ? 'Reset Filter' : 'Reset Filter'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryBrown,
      onRefresh: () => ref.read(recipeListControllerProvider.notifier).refreshRecipes(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: 208,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return _buildGridCard(context, recipes[index], index, isSplitMode: isSplitMode);
        },
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, dynamic rawRecipe, int index, {bool isSplitMode = false}) {
    final recipe = ApiService.sanitizeRecipe(rawRecipe);
    final isSelected = isSplitMode &&
        _selectedInspectionRecipe != null &&
        _selectedInspectionRecipe['id'] == recipe['id'];

    return RecipeFeedGridCard(
      rawRecipe: rawRecipe,
      index: index,
      isTrial: _isTrial,
      isSelected: isSelected,
      onTap: () {
        if (isSplitMode) {
          setState(() => _selectedInspectionRecipe = rawRecipe);
        } else {
          _openDetail(recipe, index: index);
        }
      },
      onLongPress: recipe['isCustom'] == true
          ? () => _confirmDelete(recipe['id'] as int, CoffeeTranslator.translateTitle(recipe['title'] as String))
          : null,
      onBaristaTap: () => _openBarista(recipe),
      onTrialLocked: _showTrialLockDialog,
    );
  }
}
