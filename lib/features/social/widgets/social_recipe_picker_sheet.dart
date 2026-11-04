import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_theme.dart';
import 'social_recipe_picker_tile.dart';

class SocialRecipePickerSheet extends StatefulWidget {
  final List<dynamic> allRecipes;
  final int? selectedRecipeId;

  const SocialRecipePickerSheet({
    super.key,
    required this.allRecipes,
    this.selectedRecipeId,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required List<dynamic> allRecipes,
    int? selectedRecipeId,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SocialRecipePickerSheet(
        allRecipes: allRecipes,
        selectedRecipeId: selectedRecipeId,
      ),
    );
  }

  @override
  State<SocialRecipePickerSheet> createState() => _SocialRecipePickerSheetState();
}

class _SocialRecipePickerSheetState extends State<SocialRecipePickerSheet> {
  int _selectedTab = 0; // 0: World Recipe, 1: Resep Saya
  String _searchQuery = '';
  String _selectedMethod = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _worldRecipes = [];
  final List<Map<String, dynamic>> _myRecipes = [];

  final List<String> _methods = [
    'Semua',
    'V60',
    'Aeropress',
    'Origami',
    'Kalita',
    'French Press',
    'Syphon',
    'Cold Brew',
    'Espresso',
  ];

  @override
  void initState() {
    super.initState();
    for (final r in widget.allRecipes) {
      if (r is Map) {
        final map = Map<String, dynamic>.from(r);
        final isCustom = map['isCustom'] == true || (map['id'] is int && (map['id'] as int) >= 500);
        if (isCustom) {
          _myRecipes.add(map);
        } else {
          _worldRecipes.add(map);
        }
      }
    }
    if (widget.selectedRecipeId != null) {
      final isSelCustom = _myRecipes.any((r) => r['id'] == widget.selectedRecipeId);
      if (isSelCustom) {
        _selectedTab = 1;
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredList {
    final pool = _selectedTab == 0 ? _worldRecipes : _myRecipes;
    return pool.where((recipe) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = (recipe['title'] ?? '').toString().toLowerCase();
        final author = (recipe['author'] ?? '').toString().toLowerCase();
        final bean = (recipe['beanName'] ?? '').toString().toLowerCase();
        final variety = (recipe['variety'] ?? '').toString().toLowerCase();
        final method = (recipe['method'] ?? recipe['category'] ?? '').toString().toLowerCase();
        if (!title.contains(q) && !author.contains(q) && !bean.contains(q) && !variety.contains(q) && !method.contains(q)) {
          return false;
        }
      }
      if (_selectedMethod != 'Semua') {
        final m = (recipe['method'] ?? recipe['category'] ?? '').toString().toLowerCase();
        if (!m.contains(_selectedMethod.toLowerCase())) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Top title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Resep Kopi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'World Recipe Juara atau Resep Kustom Anda',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Segmented Tabs: World Recipe vs Resep Saya
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppTheme.primaryBrown : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '🏆 World Recipe (${_worldRecipes.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0 ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppTheme.primaryBrown : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '✍️ Resep Saya (${_myRecipes.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1 ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search & Method Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                // Search Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.search, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Cari nama resep, barista, varietas, beans...',
                            hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(CupertinoIcons.clear_circled_solid, size: 16, color: AppTheme.textMuted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Method Pills horizontal list
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _methods.map((m) {
                      final isSel = _selectedMethod == m;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(m),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? Colors.white : AppTheme.textDark,
                          ),
                          selected: isSel,
                          selectedColor: AppTheme.primaryBrown,
                          backgroundColor: AppTheme.bgCream,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(
                            color: isSel ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          visualDensity: VisualDensity.compact,
                          onSelected: (val) => setState(() => _selectedMethod = m),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          // Recipes List
          Expanded(
            child: list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isSelected = item['id'] != null && item['id'] == widget.selectedRecipeId;
                      return SocialRecipePickerTile(
                        recipe: item,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context, item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_selectedTab == 1 && _myRecipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.bgCream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.book, size: 36, color: AppTheme.primaryBrown),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Resep Kustom',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Anda belum memiliki resep buatan sendiri. Anda bisa membuat resep baru di menu Toolkit > Jurnal Brew atau menyalin resep dari World Recipe!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.search, size: 36, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text(
              'Tidak Ditemukan Resep',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
            ),
            SizedBox(height: 6),
            Text(
              'Tidak ada resep yang sesuai dengan filter pencarian.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
