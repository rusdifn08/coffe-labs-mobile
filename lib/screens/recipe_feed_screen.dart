import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'basecamp_screen.dart';
import 'barista_profile_screen.dart';
import 'recipe_detail_screen.dart';
import 'brew_timer_screen.dart';
import 'add_recipe_screen.dart';
import '../services/api_service.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  List<dynamic> _allRecipes = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'V60 Pour Over', 'Hybrid', 'Flat Bottom', 'Origami', 'Cone'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      _allRecipes = await ApiService.getRecipes();
    } catch (e) {
      debugPrint("Error loading recipes: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete(int id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteRecipe(id);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe Deleted')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _openDetail(dynamic recipe) {
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

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredRecipes = _allRecipes.where((r) {
      bool matchesCategory = _selectedCategory == 'All' || r['category'] == _selectedCategory;
      bool matchesSearch = _searchQuery.isEmpty || 
          (r['author'] != null && r['author'].toString().toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (r['title'] != null && r['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (r['method'] != null && r['method'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Recipes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add), 
            onPressed: () async {
              bool? didAdd = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
              if (didAdd == true) _loadData();
            }
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search brewer or technique...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  border: InputBorder.none,
                  icon: const Icon(CupertinoIcons.search, color: AppTheme.textMuted),
                ),
              ),
            ),
          ),
          
          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
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
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.2),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppTheme.primaryBrown.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Feed
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
              : filteredRecipes.isEmpty 
                  ? const Center(child: Text('No recipes found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(24.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68, // Adjusted for new compact layout
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
        backgroundColor: AppTheme.primaryBrown,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BasecampScreen()));
        },
        child: const Icon(CupertinoIcons.group_solid, color: Colors.white),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, dynamic recipe, int index) {
    int id = recipe['id'];
    String title = recipe['title'] ?? 'Unknown Recipe';
    String rawAuthor = recipe['author'] ?? 'Anonymous';
    String authorName = BaristaUtils.cleanName(rawAuthor);
    String countryCode = BaristaUtils.countryCode(rawAuthor);
    String category = recipe['category'] ?? 'V60 Pour Over';
    String description = recipe['description'] ?? '';
    String grindSize = recipe['grindSize'] ?? 'Medium';
    num coffeeWeight = recipe['coffeeWeightGrams'] ?? 15;
    num totalWater = recipe['totalWaterWeightGrams'] ?? 250;
    
    return GestureDetector(
      onLongPress: () => _confirmDelete(id, title),
      onTap: () => _openDetail(recipe),
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
            )
          ]
        ),
        child: Stack(
          children: [
            Padding(
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
                            const Icon(CupertinoIcons.circle_bottomthird_split, size: 10, color: AppTheme.textMuted),
                            const SizedBox(width: 2),
                            Text("${coffeeWeight}g", style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            const Icon(CupertinoIcons.drop, size: 10, color: Colors.blueAccent),
                            const SizedBox(width: 2),
                            Text("${totalWater}ml", style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, height: 1.2),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (description.isNotEmpty)
                          Expanded(
                            child: Text(
                              description,
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.2),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category and Grind Size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          category, 
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.circle_grid_hex, size: 10, color: AppTheme.primaryBrown),
                          const SizedBox(width: 2),
                          Text(
                            grindSize, 
                            style: const TextStyle(color: AppTheme.primaryBrown, fontSize: 10, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ApiService.recordBrew(recipe);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)));
                      },
                      icon: const Icon(CupertinoIcons.play_arrow_solid, size: 12, color: Colors.white),
                      label: const Text('Brew', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
