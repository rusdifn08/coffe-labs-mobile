import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/recipes/controllers/recipe_list_controller.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'onboarding_screen.dart';
import 'four_six_calculator_screen.dart';
import 'dial_in_assistant_screen.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';

/// Halaman Resep Custom Saya yang menggunakan Riverpod ConsumerWidget dan AsyncValue.when.
class BrewSelectionScreen extends ConsumerWidget {
  const BrewSelectionScreen({super.key});

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Custom Brews'),
        centerTitle: true,
      ),
      body: recipesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
          ),
        ),
        data: (allRecipes) {
          final myRecipes = allRecipes.where((r) => r['isCustom'] == true).toList();

          if (myRecipes.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 215,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: myRecipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(context, ref, myRecipes[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'brew_selection_add_fab',
        backgroundColor: AppTheme.primaryBrown,
        onPressed: () async {
          final didAdd = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
          if (didAdd == true) {
            ref.read(recipeListControllerProvider.notifier).refreshRecipes();
          }
        },
        icon: const Icon(CupertinoIcons.add, color: Colors.white),
        label: const Text('New Recipe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.doc_text_search, size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 14),
            Text(
              isEn ? 'No Custom Recipes Yet' : 'Belum Ada Resep Custom',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              isEn
                  ? 'Create your own precision recipe, or launch one of our master calculators below:'
                  : 'Buat resep seduh Anda sendiri, atau gunakan kalkulator seduh presisi di bawah:',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FourSixCalculatorScreen()));
              },
              icon: const Icon(CupertinoIcons.timer, size: 16),
              label: Text(isEn ? 'Open 4:6 Method Calculator' : 'Buka Kalkulator Metode 4:6'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                side: const BorderSide(color: AppTheme.primaryBrown),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DialInAssistantScreen()));
              },
              icon: const Icon(CupertinoIcons.slider_horizontal_below_rectangle, size: 16),
              label: Text(isEn ? 'Espresso & Filter Dial-In' : 'Asisten Dial-In Kopi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, WidgetRef ref, dynamic rawRecipe) {
    final recipe = rawRecipe is Map ? ApiService.sanitizeRecipe(rawRecipe) : <String, dynamic>{};
    int id = (recipe['id'] as num?)?.toInt() ?? 1;
    String title = recipe['title'] as String;
    int time = (recipe['totalTimeSeconds'] as num?)?.toInt() ?? 130;
    num coffee = (recipe['coffeeWeightGrams'] as num?) ?? 15;
    num water = (recipe['totalWaterWeightGrams'] as num?) ?? 225;
    num ice = (recipe['iceWeightGrams'] as num?) ?? 0;
    num totalLiquid = water + ice;
    String ratio = '1:${(totalLiquid / (coffee > 0 ? coffee : 15)).toStringAsFixed(1)}';
    String category = recipe['category'] as String;
    String grindSize = BaristaUtils.shortGrindLabel(recipe['grindSize']?.toString());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeData: recipe)),
        );
      },
      onLongPress: () => _confirmDelete(context, ref, id, title),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
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
                            if (!context.mounted) return;
                            if (!canBrew) {
                              final remaining = await TrialService.getRemainingLockDuration();
                              if (!context.mounted) return;
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
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, int id, String title) {
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
              await ref.read(recipeListControllerProvider.notifier).deleteRecipe(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEn ? 'Recipe deleted successfully' : 'Resep berhasil dihapus')),
                );
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
