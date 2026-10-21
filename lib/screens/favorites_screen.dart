import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ApiService.getFavoriteRecipes();
    if (!mounted) return;
    setState(() {
      _favorites = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resep Favorit'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : _favorites.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Belum ada favorit.\nTap ikon hati di detail resep untuk menyimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, height: 1.5),
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBrown,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final recipe = _favorites[index];
                      final author = recipe['author']?.toString() ?? '';
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
                              imageUrl: (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString(),
                              radius: 24,
                            ),
                            title: Text(
                              recipe['title'] ?? 'Resep',
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
                                  onPressed: () async {
                                    await ApiService.toggleFavorite(recipe['id'] as int);
                                    _load();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(CupertinoIcons.play_fill, color: AppTheme.primaryBrown, size: 20),
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
                              ).then((_) => _load());
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
