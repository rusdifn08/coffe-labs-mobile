import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/recipes/controllers/recipe_list_controller.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';
import 'recipe_detail_screen.dart';

/// Halaman Resep Favorit yang sepenuhnya mengadopsi Riverpod ConsumerWidget dan AsyncValue.when.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = LanguageService.isEnglish;
    final recipesAsync = ref.watch(recipeListControllerProvider);
    final favoritesAsync = ref.watch(favoriteIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Favorite Recipes' : 'Resep Favorit'),
        centerTitle: true,
      ),
      body: recipesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat favorit: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (allRecipes) {
          final favIds = favoritesAsync.value ?? <int>{};
          final favorites = allRecipes.where((r) {
            final id = r['id'] is int ? r['id'] as int : int.tryParse(r['id'].toString()) ?? 0;
            return favIds.contains(id);
          }).toList();

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  isEn
                      ? 'No favorites yet.\nTap the heart icon on a recipe detail to save.'
                      : 'Belum ada favorit.\nTap ikon hati di detail resep untuk menyimpan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryBrown,
            onRefresh: () => ref.read(recipeListControllerProvider.notifier).refreshRecipes(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                final id = recipe['id'] is int ? recipe['id'] as int : int.tryParse(recipe['id'].toString()) ?? 0;
                final author = recipe['author']?.toString() ?? '';
                final rawTitle = recipe['title']?.toString() ?? 'Recipe';
                final title = isEn ? CoffeeTranslator.translateTitle(rawTitle) : rawTitle;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: BaristaAvatar(
                        imageUrl: BaristaUtils.imageUrlFromRecipe(recipe),
                        radius: 24,
                      ),
                      title: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        BaristaUtils.cleanName(author),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.heart_slash, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              ref.read(recipeListControllerProvider.notifier).toggleFavorite(id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.play_circle_fill, color: AppTheme.primaryBrown, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeData: recipe)),
                        );
                      },
                    ),
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
