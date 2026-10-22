import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';

class BrewJournalScreen extends StatefulWidget {
  const BrewJournalScreen({super.key});

  @override
  State<BrewJournalScreen> createState() => _BrewJournalScreenState();
}

class _BrewJournalScreenState extends State<BrewJournalScreen> {
  List<dynamic> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await ApiService.getJournalEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _openAddSheet({Map<String, dynamic>? recipe}) async {
    final noteCtrl = TextEditingController();
    final grindCtrl = TextEditingController(text: recipe?['grindSize']?.toString() ?? '');
    double rating = 4;
    String? selectedRecipeTitle = recipe?['title']?.toString();
    int? selectedRecipeId = recipe?['id'] as int?;
    String? author = recipe?['author']?.toString();
    String? imageUrl = (recipe?['authorAvatarUrl'] ?? recipe?['authorImageUrl'])?.toString();
    String? coverImageUrl = (recipe?['coverImageUrl'] ?? recipe?['authorImageUrl'])?.toString();

    final recipes = await ApiService.getRecipes();

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(LanguageService.isEnglish ? 'Log Brew Result' : 'Catat Hasil Brew', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      key: ValueKey(selectedRecipeId),
                      initialValue: selectedRecipeId,
                      decoration: InputDecoration(
                        labelText: LanguageService.isEnglish ? 'Recipe' : 'Resep',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: recipes.map<DropdownMenuItem<int>>((r) {
                        final rawT = (r['title'] as String?) ?? 'Recipe';
                        final t = LanguageService.isEnglish ? CoffeeTranslator.translateTitle(rawT) : rawT;
                        return DropdownMenuItem(
                          value: r['id'] as int,
                          child: Text(
                            t,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (id) {
                        final r = recipes.firstWhere((e) => e['id'] == id);
                        setModal(() {
                          selectedRecipeId = id;
                          selectedRecipeTitle = r['title']?.toString();
                          author = r['author']?.toString();
                          imageUrl = (r['authorAvatarUrl'] ?? r['authorImageUrl'])?.toString();
                          coverImageUrl = (r['coverImageUrl'] ?? r['authorImageUrl'])?.toString();
                          grindCtrl.text = r['grindSize']?.toString() ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: grindCtrl,
                      decoration: InputDecoration(
                        labelText: LanguageService.isEnglish ? 'Grind / technical notes' : 'Grind / catatan teknis',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Rating: ${rating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      activeColor: AppTheme.accentAmber,
                      label: rating.toStringAsFixed(1),
                      onChanged: (v) => setModal(() => rating = v),
                    ),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: LanguageService.isEnglish ? 'Flavor notes (sweet, acid, body...)' : 'Catatan rasa (manis, asam, body...)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedRecipeId == null
                            ? null
                            : () async {
                                await ApiService.addJournalEntry({
                                  'recipeId': selectedRecipeId,
                                  'recipeTitle': selectedRecipeTitle,
                                  'author': author,
                                  'authorAvatarUrl': imageUrl,
                                  'authorImageUrl': coverImageUrl ?? imageUrl,
                                  'grindNote': grindCtrl.text.trim(),
                                  'rating': rating,
                                  'notes': noteCtrl.text.trim(),
                                });
                                if (ctx.mounted) Navigator.pop(ctx);
                                _load();
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                        child: Text(LanguageService.isEnglish ? 'Save Journal' : 'Simpan Jurnal', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      noteCtrl.dispose();
      grindCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Brew Journal' : 'Jurnal Brew'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'brew_journal_add_fab',
        onPressed: () => _openAddSheet(),
        backgroundColor: AppTheme.primaryBrown,
        icon: const Icon(CupertinoIcons.pen, color: Colors.white),
        label: Text(isEn ? 'Log Brew' : 'Catat', style: const TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : _entries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      isEn
                          ? 'Journal is still empty.\nRecord flavor, grind, and rating after brewing.'
                          : 'Jurnal masih kosong.\nCatat rasa, grind, dan rating setelah brew.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBrown,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final e = _entries[index];
                      final rating = (e['rating'] as num?)?.toDouble() ?? 0;
                      final created = e['createdAt']?.toString() ?? '';
                      final date = created.length >= 10 ? created.substring(0, 10) : created;
                      return Dismissible(
                        key: ValueKey(e['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(CupertinoIcons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await ApiService.deleteJournalEntry(e['id'] as int);
                          _load();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BaristaAvatar(
                                imageUrl: (e['authorAvatarUrl'] ?? e['authorImageUrl'])?.toString(),
                                radius: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e['recipeTitle']?.toString() ?? 'Brew',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${BaristaUtils.cleanName(e['author']?.toString() ?? '')} · $date',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < rating.round()
                                              ? CupertinoIcons.star_fill
                                              : CupertinoIcons.star,
                                          size: 14,
                                          color: AppTheme.accentAmber,
                                        );
                                      }),
                                    ),
                                    if ((e['grindNote']?.toString() ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text('Grind: ${e['grindNote']}',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
                                    ],
                                    if ((e['notes']?.toString() ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(e['notes'].toString(),
                                          style: const TextStyle(fontSize: 13, height: 1.4)),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
