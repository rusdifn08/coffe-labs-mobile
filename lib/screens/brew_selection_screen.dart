import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'brew_timer_screen.dart';
import 'add_recipe_screen.dart';

class BrewSelectionScreen extends StatefulWidget {
  const BrewSelectionScreen({super.key});

  @override
  State<BrewSelectionScreen> createState() => _BrewSelectionScreenState();
}

class _BrewSelectionScreenState extends State<BrewSelectionScreen> {
  late Future<List<dynamic>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _recipesFuture = ApiService.getRecipes();
    });
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Custom Brews'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          List<dynamic> allRecipes = snapshot.data!;
          List<dynamic> myRecipes = allRecipes.where((r) => r['isCustom'] == true).toList();

          if (myRecipes.isEmpty) {
            return _buildEmptyState();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              
              return GridView.builder(
                padding: const EdgeInsets.all(24.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, 
                ),
                itemCount: myRecipes.length,
                itemBuilder: (context, index) {
                  return _buildRecipeCard(myRecipes[index]);
                },
              );
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBrown,
        onPressed: () async {
          bool? didAdd = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
          if (didAdd == true) _loadRecipes();
        },
        icon: const Icon(CupertinoIcons.add, color: Colors.white),
        label: const Text('New Recipe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.doc_text_search, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            const Text('No Custom Recipes Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            const Text('Tap the + button below to create your very first custom brewing recipe!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      )
    );
  }

  Widget _buildRecipeCard(dynamic recipe) {
    int time = recipe['totalTimeSeconds'] ?? 0;
    int coffee = recipe['coffeeWeightGrams'] ?? 15;
    int water = recipe['totalWaterWeightGrams'] ?? 250;
    String ratio = '1:${(water / coffee).toStringAsFixed(1)}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryBrown.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recipe['title'] ?? 'My Recipe',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(CupertinoIcons.play_circle_fill, color: AppTheme.primaryBrown, size: 36),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By ${recipe['author'] ?? 'Me'}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        recipe['description'] ?? '',
                        style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.8), fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.1))),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricIcon(CupertinoIcons.timer, _formatTime(time)),
                      _buildMetricIcon(CupertinoIcons.drop, '${water}g'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricIcon(CupertinoIcons.circle, '${coffee}g'), 
                      _buildMetricIcon(CupertinoIcons.divide, ratio),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryBrown),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }
}
