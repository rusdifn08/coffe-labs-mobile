import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/brew/controllers/brew_journal_controller.dart';
import '../features/recipes/controllers/recipe_list_controller.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';

/// Halaman Jurnal Seduh Kopi yang mengadopsi Riverpod ConsumerStatefulWidget & AsyncValue.
class BrewJournalScreen extends ConsumerStatefulWidget {
  const BrewJournalScreen({super.key});

  @override
  ConsumerState<BrewJournalScreen> createState() => _BrewJournalScreenState();
}

class _BrewJournalScreenState extends ConsumerState<BrewJournalScreen> {
  Future<void> _openAddSheet({Map<String, dynamic>? recipe}) async {
    final noteCtrl = TextEditingController();
    final grindCtrl = TextEditingController(text: recipe?['grindSize']?.toString() ?? '');
    double rating = 4;
    String? selectedRecipeTitle = recipe?['title']?.toString();
    int? selectedRecipeId = recipe?['id'] as int?;
    String? author = recipe?['author']?.toString();
    String? imageUrl = recipe != null ? BaristaUtils.imageUrlFromRecipe(recipe) : null;
    String? coverImageUrl = recipe != null ? BaristaUtils.coverUrlFromRecipe(recipe) : null;

    final allRecipes = ref.read(recipeListControllerProvider).value ?? [];

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
            final isEn = LanguageService.isEnglish;
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Log Brew Tasting' : 'Catat Hasil Seduh',
                      style: Theme.of(ctx).textTheme.displayLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    if (recipe == null) ...[
                      DropdownButtonFormField<int>(
                        initialValue: selectedRecipeId,
                        decoration: InputDecoration(
                          labelText: isEn ? 'Select Recipe' : 'Pilih Resep',
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: allRecipes.map((r) {
                          return DropdownMenuItem<int>(
                            value: r['id'] as int,
                            child: Text(
                              r['title']?.toString() ?? 'Recipe',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final match = allRecipes.firstWhere((e) => e['id'] == val, orElse: () => {});
                          setModal(() {
                            selectedRecipeId = val;
                            selectedRecipeTitle = match['title']?.toString();
                            author = match['author']?.toString();
                            imageUrl = BaristaUtils.imageUrlFromRecipe(match);
                            coverImageUrl = BaristaUtils.coverUrlFromRecipe(match);
                            if (match['grindSize'] != null) {
                              grindCtrl.text = match['grindSize'].toString();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Text(
                        selectedRecipeTitle ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: grindCtrl,
                      decoration: InputDecoration(
                        labelText: isEn ? 'Grind Size Used' : 'Ukuran Gilingan yang Digunakan',
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: isEn ? 'Tasting Notes & Observations' : 'Catatan Rasa & Evaluasi',
                        hintText: isEn ? 'e.g. Bright acidity, floral aroma, sweet finish' : 'misal: Asam buah cerah, aroma melati, manis seimbang',
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEn ? 'Rating' : 'Penilaian Rasa', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: List.generate(5, (starIdx) {
                            return IconButton(
                              icon: Icon(
                                starIdx < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                                color: AppTheme.accentAmber,
                                size: 24,
                              ),
                              onPressed: () => setModal(() => rating = starIdx + 1.0),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if ((selectedRecipeTitle ?? '').isEmpty) return;
                          final entry = {
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'recipeId': selectedRecipeId,
                            'title': selectedRecipeTitle,
                            'author': author ?? '',
                            'imageUrl': imageUrl,
                            'coverImageUrl': coverImageUrl,
                            'grindSize': grindCtrl.text.trim(),
                            'notes': noteCtrl.text.trim(),
                            'rating': rating,
                            'createdAt': DateTime.now().toIso8601String(),
                          };
                          await ref.read(brewJournalControllerProvider.notifier).addEntry(entry);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: Text(isEn ? 'Save Journal Entry' : 'Simpan Catatan Jurnal'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final journalAsync = ref.watch(brewJournalControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Brew Journal' : 'Jurnal Seduh'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle, color: AppTheme.primaryBrown),
            onPressed: () => _openAddSheet(),
          ),
        ],
      ),
      body: journalAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat jurnal: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.book, size: 54, color: AppTheme.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      isEn
                          ? 'No brew notes yet.\nLog your extraction grind, notes, and ratings.'
                          : 'Belum ada catatan seduh.\nCatat rasa, grind size, dan rating hasil seduhanmu.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openAddSheet(),
                      icon: const Icon(CupertinoIcons.plus),
                      label: Text(isEn ? 'Write First Note' : 'Tulis Catatan Pertama'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryBrown,
            onRefresh: () async => ref.invalidate(brewJournalControllerProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final item = entries[index];
                final id = item['id'] as int? ?? 0;
                final rawTitle = item['title']?.toString() ?? 'Recipe';
                final title = isEn ? CoffeeTranslator.translateTitle(rawTitle) : rawTitle;
                final notes = item['notes']?.toString() ?? '';
                final grind = item['grindSize']?.toString() ?? '';
                final rating = (item['rating'] ?? 4).toDouble();
                final createdAt = DateTime.tryParse(item['createdAt']?.toString() ?? '') ?? DateTime.now();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                starIdx < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                                color: AppTheme.accentAmber,
                                size: 14,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (grind.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(CupertinoIcons.slider_horizontal_3, size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              grind,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (notes.isNotEmpty) ...[
                        Text(
                          notes,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ref.read(brewJournalControllerProvider.notifier).deleteEntry(id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
