import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'barista_profile_screen.dart';
import 'brew_timer_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipeData;

  const RecipeDetailScreen({super.key, required this.recipeData});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final id = widget.recipeData['id'] as int?;
    if (id == null) return;
    final fav = await ApiService.isFavorite(id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final id = widget.recipeData['id'] as int?;
    if (id == null) return;
    await ApiService.toggleFavorite(id);
    setState(() => _isFavorite = !_isFavorite);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.recipeData['title'] ?? 'Unknown Recipe';
    String rawAuthor = widget.recipeData['author'] ?? 'Anonymous';
    String authorName = BaristaUtils.cleanName(rawAuthor);
    String countryCode = BaristaUtils.countryCode(rawAuthor);
    String description = widget.recipeData['description'] ?? '';
    String category = widget.recipeData['category'] ?? 'V60 Pour Over';
    String grindSize = widget.recipeData['grindSize'] ?? 'Medium';
    num coffeeWeight = widget.recipeData['coffeeWeightGrams'] ?? 15;
    num totalWater = widget.recipeData['totalWaterWeightGrams'] ?? 250;
    String coverImageUrl = widget.recipeData['coverImageUrl'] ??
        widget.recipeData['authorImageUrl'] ??
        'assets/images/avatars/generic_fallback.jpg';
    String authorAvatarUrl = widget.recipeData['authorAvatarUrl'] ??
        widget.recipeData['authorImageUrl'] ??
        'assets/images/avatars/generic_fallback.jpg';
    
    List<dynamic> steps = widget.recipeData['steps'] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (coverImageUrl.startsWith('assets/'))
                      ? Image.asset(coverImageUrl, fit: BoxFit.cover, cacheWidth: 800)
                      : Image.network(
                          coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/avatars/generic_fallback.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: _isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Row(
                          children: [
                            Icon(
                              _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isFavorite ? 'Favorit' : 'Simpan',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, height: 1.2)),
                  const SizedBox(height: 24),
                  
                  // Author Info — tap untuk profil barista
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BaristaProfileScreen(
                            rawAuthor: rawAuthor,
                            imageUrl: authorAvatarUrl,
                            coverImageUrl: coverImageUrl,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        BaristaAvatar(
                          imageUrl: authorAvatarUrl,
                          radius: 24,
                          heroTag: 'detail_${BaristaUtils.slugFromAuthor(rawAuthor)}',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recipe Creator', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      authorName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (countryCode.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Flag.fromString(countryCode, height: 14, width: 20),
                                  ],
                                  const SizedBox(width: 4),
                                  const Icon(CupertinoIcons.chevron_right, size: 14, color: AppTheme.textMuted),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Technical Parameters Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildParamItem(CupertinoIcons.circle_bottomthird_split, "Coffee", "${coffeeWeight}g"),
                      _buildParamItem(CupertinoIcons.drop, "Water", "${totalWater}g"),
                      _buildParamItem(CupertinoIcons.circle_grid_hex, "Grind", grindSize),
                      _buildParamItem(CupertinoIcons.thermometer, "Temp", "${widget.recipeData['waterTempCelsius'] ?? 92}°C"),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Description / Philosophy
                  Text("The Philosophy & Technique", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(color: AppTheme.textDark, height: 1.6, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  // Pour Steps
                  Text("Pouring Steps", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...steps.asMap().entries.map((entry) {
                     int idx = entry.key;
                     var s = entry.value;
                     return Container(
                       margin: const EdgeInsets.only(bottom: 12),
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: AppTheme.surfaceWhite,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1))
                       ),
                       child: Row(
                         children: [
                           Container(
                             width: 30,
                             height: 30,
                             decoration: BoxDecoration(color: AppTheme.primaryBrown.withValues(alpha: 0.1), shape: BoxShape.circle),
                             child: Center(child: Text("${idx + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBrown))),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(s['title'] ?? 'Pour', style: const TextStyle(fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 4),
                                 Text("Pour ${s['waterAddedGrams']}g over ${s['durationSeconds']}s", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                               ],
                             ),
                           ),
                           const Icon(CupertinoIcons.arrow_right, color: AppTheme.textMuted, size: 16)
                         ],
                       ),
                     );
                  }),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: widget.recipeData)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text('Mulai Brewing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildParamItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppTheme.primaryBrown.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))]
          ),
          child: Icon(icon, color: AppTheme.primaryBrown, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }
}
