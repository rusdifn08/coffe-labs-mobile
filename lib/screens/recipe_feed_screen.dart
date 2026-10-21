import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../data/brew_visual_catalog.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'basecamp_screen.dart';
import 'barista_profile_screen.dart';
import 'recipe_detail_screen.dart';
import 'brew_timer_screen.dart';
import 'add_recipe_screen.dart';
import 'onboarding_screen.dart';
import '../services/api_service.dart';
import '../services/trial_service.dart';

class _NoteCategoryItem {
  final String id;
  final String label;
  final String emoji;
  final List<String> groups;
  final List<String> keywords;

  const _NoteCategoryItem({
    required this.id,
    required this.label,
    required this.emoji,
    required this.groups,
    required this.keywords,
  });
}

const List<_NoteCategoryItem> _noteCategories = [
  _NoteCategoryItem(
    id: 'floral',
    label: 'Floral',
    emoji: '🌸',
    groups: ['Floral'],
    keywords: ['floral', 'flower', 'jasmine', 'rose', 'hibiscus', 'blossom', 'lavender', 'chamomile', 'bunga', 'elderflower'],
  ),
  _NoteCategoryItem(
    id: 'fruity',
    label: 'Fruity & Tropical',
    emoji: '🍑',
    groups: ['Stone Fruit', 'Tropical', 'Orchard Fruit'],
    keywords: ['fruit', 'fruity', 'peach', 'apricot', 'plum', 'mango', 'passion', 'pineapple', 'lychee', 'guava', 'papaya', 'melon', 'apple', 'pear', 'grape', 'buah'],
  ),
  _NoteCategoryItem(
    id: 'citrus',
    label: 'Citrus',
    emoji: '🍋',
    groups: ['Citrus'],
    keywords: ['citrus', 'lemon', 'bergamot', 'orange', 'grapefruit', 'lime', 'mandarin', 'yuzu', 'tangerine', 'jeruk'],
  ),
  _NoteCategoryItem(
    id: 'berry',
    label: 'Berry',
    emoji: '🍓',
    groups: ['Berry'],
    keywords: ['berry', 'strawberry', 'blueberry', 'currant', 'raspberry', 'cherry', 'blackberry', 'cranberry'],
  ),
  _NoteCategoryItem(
    id: 'sweet_cocoa',
    label: 'Cokelat & Manis',
    emoji: '🍫',
    groups: ['Sweet', 'Cocoa'],
    keywords: ['choco', 'chocolate', 'cocoa', 'cacao', 'honey', 'caramel', 'toffee', 'maple', 'sugar', 'sweet', 'vanilla', 'creamy', 'madu', 'cokelat', 'karamel'],
  ),
  _NoteCategoryItem(
    id: 'nutty_spices',
    label: 'Nutty & Rempah',
    emoji: '🥜',
    groups: ['Nutty', 'Herbal'],
    keywords: ['nut', 'nutty', 'almond', 'hazelnut', 'walnut', 'pecan', 'spice', 'spices', 'cinnamon', 'herbal', 'lemongrass', 'rempah', 'kacang'],
  ),
  _NoteCategoryItem(
    id: 'tea_winey',
    label: 'Teh & Fermentasi',
    emoji: '🍵',
    groups: ['Tea-like', 'Winey'],
    keywords: ['tea', 'earl grey', 'oolong', 'black tea', 'green tea', 'wine', 'winey', 'rum', 'whiskey', 'ferment', 'teh'],
  ),
  _NoteCategoryItem(
    id: 'mouthfeel',
    label: 'Mouthfeel & Body',
    emoji: '✨',
    groups: ['Mouthfeel'],
    keywords: ['clean', 'juicy', 'silky', 'body', 'creamy', 'round', 'smooth', 'mouthfeel', 'finish'],
  ),
];

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  List<dynamic> _allRecipes = [];
  List<Map<String, dynamic>> _uniqueBaristas = [];
  bool _isLoading = true;
  bool _isTrial = false;

  // Filter States
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedPourFilter = 'Semua';
  String _selectedDripperFilter = 'Semua';
  String _selectedBaristaFilter = 'Semua';
  String _selectedNoteFilter = 'Semua';
  String _selectedOriginFilter = 'Semua';
  String _selectedNoteCategoryTab = 'floral';

  final List<String> _categories = const [
    'All',
    'V60',
    'Japanese',
    'AeroPress',
    'French Press',
    'Immersion',
    'Hybrid',
    'Flat Bottom',
    'Origami',
    'Cone',
  ];

  final List<String> _pourFilterOptions = const [
    'Semua',
    '1-2x Pour',
    '3x Pouring',
    '4x Pouring',
    '5x+ Pouring',
    'Full Immersion',
  ];

  final List<String> _originFilterOptions = const [
    'Semua',
    '🇮🇩 Barista Indonesia',
    '🌍 Barista Internasional',
    '❄️ Resep Pakai Es',
    '⚡ Cepat (≤ 2:15)',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    ApiService.changeNotifier.addListener(_loadData);
    TrialService.changeNotifier.addListener(_onTrialChanged);
    _checkTrial();
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
    ApiService.changeNotifier.removeListener(_loadData);
    TrialService.changeNotifier.removeListener(_onTrialChanged);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await ApiService.getRecipes();
      final baristas = await ApiService.getUniqueBaristas();
      final isTrial = await TrialService.isTrialMode();
      if (!mounted) return;
      setState(() {
        _allRecipes = recipes;
        _uniqueBaristas = baristas;
        _isTrial = isTrial;
      });
    } catch (e) {
      debugPrint('Error loading recipes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _activeFilterCount {
    int c = 0;
    if (_selectedCategory != 'All') c++;
    if (_selectedPourFilter != 'Semua') c++;
    if (_selectedDripperFilter != 'Semua') c++;
    if (_selectedBaristaFilter != 'Semua') c++;
    if (_selectedNoteFilter != 'Semua') c++;
    if (_selectedOriginFilter != 'Semua') c++;
    return c;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedPourFilter = 'Semua';
      _selectedDripperFilter = 'Semua';
      _selectedBaristaFilter = 'Semua';
      _selectedNoteFilter = 'Semua';
      _selectedOriginFilter = 'Semua';
      _selectedNoteCategoryTab = 'floral';
      _searchQuery = '';
    });
  }

  bool _matchesPourFilter(Map<String, dynamic> r) {
    if (_selectedPourFilter == 'Semua') return true;
    final pours = BrewVisualCatalog.countPours(r);
    final cat = (r['category'] ?? '').toString().toLowerCase();
    if (_selectedPourFilter == 'Full Immersion') {
      return cat.contains('immersion');
    }
    if (_selectedPourFilter == '1-2x Pour') return pours <= 2;
    if (_selectedPourFilter == '3x Pouring') return pours == 3;
    if (_selectedPourFilter == '4x Pouring') return pours == 4;
    if (_selectedPourFilter == '5x+ Pouring') return pours >= 5;
    return true;
  }

  bool _matchesDripperFilter(Map<String, dynamic> r) {
    if (_selectedDripperFilter == 'Semua') return true;
    final matched = BrewVisualCatalog.matchDripper(
      r['method']?.toString(),
      category: r['category']?.toString(),
    );
    return matched.shortName == _selectedDripperFilter;
  }

  bool _matchesNoteFilter(Map<String, dynamic> r) {
    if (_selectedNoteFilter == 'Semua') return true;
    final notesStr = '${r['tastingNotes'] ?? ''} ${r['beanName'] ?? ''} ${r['description'] ?? ''}'.toLowerCase();

    // Cek apakah filter merupakan tingkat kategori (misal: "🌸 Floral" atau "Semua Floral")
    for (final cat in _noteCategories) {
      if (_selectedNoteFilter == '${cat.emoji} ${cat.label}' ||
          _selectedNoteFilter == 'Semua ${cat.label}' ||
          _selectedNoteFilter == cat.label) {
        if (cat.keywords.any((kw) => notesStr.contains(kw.toLowerCase()))) return true;
        final catNotes = BrewVisualCatalog.flavorNotes.where((fn) => cat.groups.contains(fn.group));
        return catNotes.any((fn) {
          final l = fn.label.toLowerCase();
          return notesStr.contains(l) || notesStr.contains(l.split(' ').first);
        });
      }
    }

    final target = _selectedNoteFilter.toLowerCase();
    final firstWord = target.split(' ').first;
    return notesStr.contains(target) || notesStr.contains(firstWord);
  }

  void _openFilterModal() {
    String activeNoteCategoryModal = _selectedNoteCategoryTab;
    if (_selectedNoteFilter != 'Semua') {
      for (final cat in _noteCategories) {
        if (_selectedNoteFilter == '${cat.emoji} ${cat.label}' ||
            _selectedNoteFilter == 'Semua ${cat.label}' ||
            _selectedNoteFilter == cat.label) {
          activeNoteCategoryModal = cat.id;
          break;
        }
        final inGroup = BrewVisualCatalog.flavorNotes
            .where((fn) => cat.groups.contains(fn.group))
            .any((fn) => fn.label == _selectedNoteFilter);
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
            void updateFilter(VoidCallback fn) {
              fn();
              setModalState(() {});
              setState(() {});
            }

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
                          const Row(
                            children: [
                              Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Filter Resep Lengkap',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (_activeFilterCount > 0)
                                TextButton(
                                  onPressed: () => updateFilter(_resetAllFilters),
                                  child: const Text('Reset Semua', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
                          _filterSectionTitle(CupertinoIcons.drop_fill, '1. Jumlah Pouring / Struktur Tuangan'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _pourFilterOptions.map((opt) {
                              final selected = _selectedPourFilter == opt;
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
                                onSelected: (_) => updateFilter(() => _selectedPourFilter = opt),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),

                          // 2. FILTER BY DRIPPER / ALAT SEDUH (VISUAL GAMBAR)
                          _filterSectionTitle(CupertinoIcons.cube_box_fill, '2. Pilih Dripper / Alat Seduh'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 106,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _dripperFilterCard(
                                  shortName: 'Semua',
                                  subtitle: 'Semua Alat',
                                  selected: _selectedDripperFilter == 'Semua',
                                  item: null,
                                  onTap: () => updateFilter(() => _selectedDripperFilter = 'Semua'),
                                ),
                                ...BrewVisualCatalog.drippers.map((d) {
                                  final selected = _selectedDripperFilter == d.shortName;
                                  return _dripperFilterCard(
                                    shortName: d.shortName,
                                    subtitle: d.defaultCategory,
                                    selected: selected,
                                    item: d,
                                    onTap: () => updateFilter(() => _selectedDripperFilter = d.shortName),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // 3. FILTER BY BARISTA / ORANGNYA SIAPA (VISUAL FOTO WAJAH)
                          _filterSectionTitle(CupertinoIcons.person_2_fill, '3. Pilih Barista / Brewer'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 104,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _uniqueBaristas.length + 1,
                              itemBuilder: (context, idx) {
                                if (idx == 0) {
                                  final sel = _selectedBaristaFilter == 'Semua';
                                  return GestureDetector(
                                    onTap: () => updateFilter(() => _selectedBaristaFilter = 'Semua'),
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
                                            'Semua',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : AppTheme.textDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                final b = _uniqueBaristas[idx - 1];
                                final name = b['name'] as String;
                                final sel = _selectedBaristaFilter == name;
                                return GestureDetector(
                                  onTap: () => updateFilter(() => _selectedBaristaFilter = name),
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
                          _filterSectionTitle(CupertinoIcons.lab_flask_solid, '4. Teknik Seduh'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((cat) {
                              final selected = _selectedCategory == cat;
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
                                onSelected: (_) => updateFilter(() => _selectedCategory = cat),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),

                          // 5. FILTER BY TASTING NOTES (FILTER KATEGORI: FLORAL, FRUITY, CITRUS, DLL.)
                          _filterSectionTitle(CupertinoIcons.sparkles, '5. Tasting Notes & Karakter Rasa'),
                          const SizedBox(height: 6),
                          Text(
                            _selectedNoteFilter == 'Semua'
                                ? 'Pilih kategori rasa untuk menampilkan pilihan notes yang relevan:'
                                : 'Filter aktif: $_selectedNoteFilter',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _selectedNoteFilter == 'Semua' ? AppTheme.textMuted : AppTheme.primaryBrown,
                              fontWeight: _selectedNoteFilter == 'Semua' ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Horizontal Category Pills
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _noteCategories.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 8),
                              itemBuilder: (ctx, idx) {
                                final cat = _noteCategories[idx];
                                final isCatActive = activeNoteCategoryModal == cat.id;
                                return ChoiceChip(
                                  label: Text(
                                    '${cat.emoji} ${cat.label}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isCatActive ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                  selected: isCatActive,
                                  selectedColor: AppTheme.primaryBrown,
                                  backgroundColor: AppTheme.surfaceWhite,
                                  side: BorderSide(
                                    color: isCatActive ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                                  ),
                                  onSelected: (_) {
                                    setModalState(() {
                                      activeNoteCategoryModal = cat.id;
                                      _selectedNoteCategoryTab = cat.id;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Container Pilihan Notes untuk Kategori Terpilih
                          Builder(
                            builder: (_) {
                              final curCat = _noteCategories.firstWhere(
                                (c) => c.id == activeNoteCategoryModal,
                                orElse: () => _noteCategories.first,
                              );
                              final categoryNotes = BrewVisualCatalog.flavorNotes
                                  .where((fn) => curCat.groups.contains(fn.group))
                                  .toList();
                              final isCategorySelected = _selectedNoteFilter == '${curCat.emoji} ${curCat.label}' ||
                                  _selectedNoteFilter == 'Semua ${curCat.label}' ||
                                  _selectedNoteFilter == curCat.label;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primaryBrown.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${curCat.emoji} Pilihan Notes ${curCat.label} (${categoryNotes.length})',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        if (_selectedNoteFilter != 'Semua')
                                          GestureDetector(
                                            onTap: () => updateFilter(() => _selectedNoteFilter = 'Semua'),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(CupertinoIcons.clear_circled_solid, size: 13, color: Colors.redAccent),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Hapus Notes',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        // Pilihan Semua di kategori ini
                                        ChoiceChip(
                                          label: Text(
                                            'Semua ${curCat.label} ${curCat.emoji}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: isCategorySelected ? Colors.white : AppTheme.textDark,
                                            ),
                                          ),
                                          selected: isCategorySelected,
                                          selectedColor: AppTheme.primaryBrown,
                                          backgroundColor: AppTheme.bgCream,
                                          side: BorderSide(
                                            color: isCategorySelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                                          ),
                                          onSelected: (_) {
                                            updateFilter(() {
                                              _selectedNoteFilter = isCategorySelected ? 'Semua' : '${curCat.emoji} ${curCat.label}';
                                            });
                                          },
                                        ),
                                        // Notes spesifik dalam kategori ini
                                        ...categoryNotes.map((fn) {
                                          final sel = _selectedNoteFilter == fn.label;
                                          return FlavorNoteVisualBadge(
                                            noteText: fn.label,
                                            selected: sel,
                                            onTap: () => updateFilter(() {
                                              _selectedNoteFilter = sel ? 'Semua' : fn.label;
                                            }),
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 22),

                          // 6. FILTER BY ASAL & DURASI
                          _filterSectionTitle(CupertinoIcons.globe, '6. Asal Barista & Durasi'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _originFilterOptions.map((opt) {
                              final selected = _selectedOriginFilter == opt;
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
                                onSelected: (_) => updateFilter(() => _selectedOriginFilter = opt),
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
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Terapkan Filter',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _filterSectionTitle(IconData icon, String text) {
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

  Widget _dripperFilterCard({
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

  void _confirmDelete(int id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Resep?'),
        content: Text('Yakin ingin menghapus "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteRecipe(id);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resep dihapus')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openDetail(dynamic recipe, {int? index}) {
    if (_isTrial && index != null && index >= 10) {
      TrialService.showLockedDialog(
        context: context,
        title: 'Resep Terkunci (Mode Trial)',
        message: 'Resep ini berada di luar batas 10 resep mode trial.\n\nSilakan login dengan akun resmi yang disetujui Admin untuk membuka seluruh koleksi resep!',
        onLoginTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
        },
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeData: recipe)),
    );
  }

  void _openBarista(dynamic recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BaristaProfileScreen(
          rawAuthor: recipe['author']?.toString() ?? '',
          imageUrl: (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString(),
          coverImageUrl: (recipe['coverImageUrl'] ?? recipe['authorImageUrl'])?.toString(),
        ),
      ),
    );
  }

  void _surpriseMe(List<dynamic> pool) {
    var source = pool.isNotEmpty ? pool : _allRecipes;
    if (_isTrial && source.length > 10) {
      source = source.take(10).toList();
    }
    if (source.isEmpty) return;
    final picked = (List<dynamic>.from(source)..shuffle()).first;
    _openDetail(picked, index: 0);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredRecipes = _allRecipes.where((raw) {
      final r = raw is Map ? ApiService.sanitizeRecipe(raw) : <String, dynamic>{};
      final catLower = _selectedCategory.toLowerCase();
      bool matchesCategory = _selectedCategory == 'All' ||
          r['category'] == _selectedCategory ||
          (r['category'] ?? '').toString().toLowerCase().contains(catLower) ||
          (r['method'] ?? '').toString().toLowerCase().contains(catLower) ||
          (r['title'] ?? '').toString().toLowerCase().contains(catLower);
      final authorStr = (r['author'] ?? '').toString();
      final cleanAuthor = BaristaUtils.cleanName(authorStr);
      bool matchesBarista = _selectedBaristaFilter == 'Semua' ||
          cleanAuthor.toLowerCase() == _selectedBaristaFilter.toLowerCase();

      final isIndo = BaristaUtils.countryCode(authorStr) == 'id';
      final iceGrams = (r['iceWeightGrams'] ?? 0) as num;
      final isIced = iceGrams > 0 || (r['category'] ?? '').toString().toLowerCase().contains('iced');
      final totalSecs = (r['totalTimeSeconds'] ?? 180) as num;

      bool matchesOrigin = true;
      if (_selectedOriginFilter == '🇮🇩 Barista Indonesia') {
        matchesOrigin = isIndo;
      } else if (_selectedOriginFilter == '🌍 Barista Internasional') {
        matchesOrigin = !isIndo;
      } else if (_selectedOriginFilter == '❄️ Resep Pakai Es') {
        matchesOrigin = isIced;
      } else if (_selectedOriginFilter == '⚡ Cepat (≤ 2:15)') {
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

      return matchesCategory &&
          matchesBarista &&
          matchesOrigin &&
          _matchesPourFilter(r) &&
          _matchesDripperFilter(r) &&
          _matchesNoteFilter(r) &&
          matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: Padding(
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
          IconButton(
            tooltip: 'Pilihkan Resep Acak',
            icon: const Icon(CupertinoIcons.sparkles),
            onPressed: () => _surpriseMe(filteredRecipes),
          ),
          IconButton(
            tooltip: 'Tambah Resep Sendiri',
            icon: const Icon(CupertinoIcons.add),
            onPressed: () async {
              bool? didAdd = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
              if (didAdd == true) _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar + Filter Modal Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari barista, biji, dripper, notes...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                        border: InputBorder.none,
                        icon: const Icon(CupertinoIcons.search, color: AppTheme.textMuted, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openFilterModal,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _activeFilterCount > 0 ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          size: 18,
                          color: _activeFilterCount > 0 ? Colors.white : AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _activeFilterCount > 0 ? 'Filter ($_activeFilterCount)' : 'Filter',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _activeFilterCount > 0 ? Colors.white : AppTheme.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Quick Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String cat = _categories[index];
                bool isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Active Filters Banner (if any active)
          if (_activeFilterCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 2),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedPourFilter != 'Semua')
                            _activeFilterChip(_selectedPourFilter, () => setState(() => _selectedPourFilter = 'Semua')),
                          if (_selectedDripperFilter != 'Semua')
                            _activeFilterChip(_selectedDripperFilter, () => setState(() => _selectedDripperFilter = 'Semua')),
                          if (_selectedBaristaFilter != 'Semua')
                            _activeFilterChip(_selectedBaristaFilter, () => setState(() => _selectedBaristaFilter = 'Semua')),
                          if (_selectedNoteFilter != 'Semua')
                            _activeFilterChip(_selectedNoteFilter, () => setState(() => _selectedNoteFilter = 'Semua')),
                          if (_selectedOriginFilter != 'Semua')
                            _activeFilterChip(_selectedOriginFilter, () => setState(() => _selectedOriginFilter = 'Semua')),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetAllFilters,
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('Reset', style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),
          // Feed Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
                : filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.search, size: 42, color: AppTheme.textMuted),
                            const SizedBox(height: 10),
                            const Text('Tidak ada resep yang cocok dengan filter ini.'),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _resetAllFilters,
                              child: const Text('Reset Filter'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.66,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          return _buildGridCard(context, filteredRecipes[index], index);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recipe_feed_basecamp_fab',
        backgroundColor: AppTheme.primaryBrown,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BasecampScreen()));
        },
        child: const Icon(CupertinoIcons.group_solid, color: Colors.white),
      ),
    );
  }

  Widget _activeFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 13, color: AppTheme.primaryBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, dynamic rawRecipe, int index) {
    final recipe = rawRecipe is Map ? ApiService.sanitizeRecipe(rawRecipe) : <String, dynamic>{};
    int id = recipe['id'] as int;
    String title = recipe['title'] as String;
    String rawAuthor = recipe['author'] as String;
    String authorName = BaristaUtils.cleanName(rawAuthor);
    String countryCode = BaristaUtils.countryCode(rawAuthor);
    String category = recipe['category'] as String;
    String description = recipe['description'] as String;
    String shortGrind = BaristaUtils.shortGrindLabel(recipe['grindSize']?.toString());
    num coffeeWeight = recipe['coffeeWeightGrams'] as int;
    num totalWater = recipe['totalWaterWeightGrams'] as int;
    int iceWeight = recipe['iceWeightGrams'] as int? ?? 0;
    int pourCount = BrewVisualCatalog.countPours(recipe);
    final rawNotes = (recipe['tastingNotes'] ?? '').toString().split(',');
    final noteVisuals = rawNotes
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .take(3)
        .map((n) => BrewVisualCatalog.matchNote(n))
        .toList();

    return GestureDetector(
      onLongPress: recipe['isCustom'] == true ? () => _confirmDelete(id, title) : null,
      onTap: () => _openDetail(recipe, index: index),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _openBarista(recipe),
                    child: BaristaAvatar(
                      imageUrl: (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString(),
                      radius: 18,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_isTrial && index >= 10) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.lock_fill, size: 9, color: Colors.deepOrange),
                                SizedBox(width: 2),
                                Text(
                                  'Trial Lock',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Text(
                          '${coffeeWeight}g',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          iceWeight > 0 ? CupertinoIcons.snow : CupertinoIcons.drop,
                          size: 10,
                          color: Colors.blueAccent,
                        ),
                        Flexible(
                          child: Text(
                            iceWeight > 0 ? '${totalWater + iceWeight}g' : '${totalWater}ml',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openBarista(recipe),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (countryCode.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flag.fromString(countryCode, height: 10, width: 14),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13.5, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (noteVisuals.isNotEmpty) ...[
                            ...noteVisuals.take(2).map((nv) {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: nv.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: nv.color.withValues(alpha: 0.25), width: 0.8),
                                ),
                                child: Text(nv.emoji, style: const TextStyle(fontSize: 11)),
                              );
                            }),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${pourCount}x Pour',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (description.isNotEmpty)
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Category and Short Grind Size (Hanya "Medium" / "Medium-Fine" tanpa klik agar tidak overflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      category
                          .replaceAll('V60 Pour Over', 'V60')
                          .replaceAll('Japanese Iced', 'Japanese'),
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.circle_grid_hex, size: 10, color: AppTheme.primaryBrown),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            shortGrind,
                            style: const TextStyle(color: AppTheme.primaryBrown, fontSize: 10, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)));
                  },
                  icon: const Icon(CupertinoIcons.play_arrow_solid, size: 12, color: Colors.white),
                  label: const Text('Brew', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
