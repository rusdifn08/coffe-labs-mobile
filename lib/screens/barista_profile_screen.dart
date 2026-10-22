import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../data/barista_catalog.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';
import 'recipe_detail_screen.dart';

class BaristaProfileScreen extends StatefulWidget {
  final String rawAuthor;
  final String? imageUrl;
  final String? coverImageUrl;
  final String? heroTag;

  const BaristaProfileScreen({
    super.key,
    required this.rawAuthor,
    this.imageUrl,
    this.coverImageUrl,
    this.heroTag,
  });

  @override
  State<BaristaProfileScreen> createState() => _BaristaProfileScreenState();
}

class _BaristaProfileScreenState extends State<BaristaProfileScreen> {
  List<dynamic> _recipes = [];
  bool _loading = true;

  late final BaristaProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = BaristaCatalog.resolve(widget.rawAuthor, imageUrl: widget.imageUrl);
    _load();
  }

  Future<void> _load() async {
    final recipes = await ApiService.getRecipesByAuthor(widget.rawAuthor);
    if (!mounted) return;
    setState(() {
      _recipes = recipes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _profile.imageAsset ?? widget.imageUrl;
    final coverImageUrl = widget.coverImageUrl ?? widget.imageUrl ?? imageUrl;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryBrown,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BaristaUtils.buildOfflineImage(
                    coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaristaAvatar(
                          imageUrl: imageUrl,
                          radius: 36,
                          heroTag: widget.heroTag ?? 'barista_${_profile.slug}',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (_profile.countryCode.isNotEmpty) ...[
                              Flag.fromString(_profile.countryCode, height: 14, width: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _profile.localizedCountry,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _profile.localizedSpecialty,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LanguageService.isEnglish ? 'About Barista' : 'Tentang Barista', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    _profile.localizedBio,
                    style: const TextStyle(height: 1.55, color: AppTheme.textDark, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _statChip(
                        CupertinoIcons.book_fill,
                        '${_recipes.length}',
                        LanguageService.isEnglish ? 'Recipes' : 'Resep',
                      ),
                      const SizedBox(width: 12),
                      _statChip(
                        CupertinoIcons.flame_fill,
                        _profile.localizedSpecialty.split(' ').first,
                        LanguageService.isEnglish ? 'Focus' : 'Fokus',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    LanguageService.isEnglish ? 'Recipes by ${_profile.name}' : 'Resep dari ${_profile.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown)),
            )
          else if (_recipes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    LanguageService.isEnglish ? 'No recipes yet.' : 'Belum ada resep.',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = _recipes[index];
                  return _recipeTile(context, recipe);
                },
                childCount: _recipes.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBrown, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeTile(BuildContext context, dynamic recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeData: recipe)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CoffeeTranslator.translateTitle(recipe['title']?.toString() ?? 'Recipe'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recipe['method'] ?? ''} · ${recipe['coffeeWeightGrams'] ?? '-'}g',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.play_circle_fill, color: AppTheme.primaryBrown),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
