import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'onboarding_screen.dart';
import '../services/trial_service.dart';

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
    ApiService.changeNotifier.addListener(_loadRecipes);
  }

  @override
  void dispose() {
    ApiService.changeNotifier.removeListener(_loadRecipes);
    super.dispose();
  }

  void _loadRecipes() {
    if (!mounted) return;
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
        heroTag: 'brew_selection_add_fab',
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

  Widget _buildRecipeCard(dynamic rawRecipe) {
    final recipe = rawRecipe is Map ? ApiService.sanitizeRecipe(rawRecipe) : <String, dynamic>{};
    int id = recipe['id'] as int;
    String title = recipe['title'] as String;
    int time = recipe['totalTimeSeconds'] as int;
    int coffee = recipe['coffeeWeightGrams'] as int;
    int water = recipe['totalWaterWeightGrams'] as int;
    int ice = recipe['iceWeightGrams'] as int? ?? 0;
    int totalLiquid = water + ice;
    String ratio = '1:${(totalLiquid / (coffee > 0 ? coffee : 15)).toStringAsFixed(1)}';
    String category = recipe['category'] as String;
    String grindSize = BaristaUtils.shortGrindLabel(recipe['grindSize']?.toString());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeData: recipe)),
        ).then((_) => _loadRecipes());
      },
      onLongPress: () => _confirmDelete(id, title),
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
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final canBrew = await TrialService.canBrew();
                            if (!mounted) return;
                            if (!canBrew) {
                              final remaining = await TrialService.getRemainingLockDuration();
                              if (!mounted) return;
                              final days = remaining != null ? (remaining.inDays + 1) : 7;
                              final isEn = LanguageService.isEnglish;
                              TrialService.showLockedDialog(
                                context: context,
                                title: isEn ? 'Trial Brew Limit Reached' : 'Batas Seduh Trial Tercapai',
                                message: isEn
                                    ? 'You have reached the 10-brew limit on trial mode. Brewing is locked for 1 week ($days days remaining).\n\nPlease log in or sign up with an Admin-approved account to brew without limits!'
                                    : 'Anda telah mencapai batas 10 kali seduh pada mode trial. Fitur seduh terkunci selama 1 minggu ($days hari tersisa).\n\nSilakan login atau daftar akun resmi yang disetujui Admin untuk seduh tanpa batas!',
                                onLoginTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
                                },
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
                            );
                          },
                          child: const Icon(CupertinoIcons.play_circle_fill, color: AppTheme.primaryBrown, size: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$category · $grindSize',
                      style: const TextStyle(color: AppTheme.primaryBrown, fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        recipe['description'] as String,
                        style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.85), fontSize: 11),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      _buildMetricIcon(
                        ice > 0 ? CupertinoIcons.snow : CupertinoIcons.drop,
                        ice > 0 ? '${water}g+${ice}g' : '${water}g',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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

  void _confirmDelete(int id, String title) {
    final isEn = LanguageService.isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Delete Recipe?' : 'Hapus Resep?'),
        content: Text(isEn ? 'Are you sure you want to delete recipe "$title"?' : 'Yakin ingin menghapus resep "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEn ? 'Cancel' : 'Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.deleteRecipe(id);
              _loadRecipes();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEn ? 'Recipe deleted successfully' : 'Resep berhasil dihapus')));
              }
            },
            child: Text(isEn ? 'Delete' : 'Hapus', style: const TextStyle(color: Colors.red)),
          ),
        ],
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
