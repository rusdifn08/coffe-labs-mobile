import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../core/storage/user_scoped_storage.dart';
import '../features/bean_scanner/widgets/home_floating_scanner_fab.dart';
import '../features/brew/controllers/brew_history_controller.dart';
import '../features/gamification/models/coffee_level.dart';
import '../features/gamification/services/gamification_service.dart';
import '../features/gamification/widgets/level_roadmap_modal.dart';
import '../features/recipes/controllers/recipe_list_controller.dart';
import '../features/home/widgets/home_admin_quick_bar.dart';
import '../features/home/widgets/home_quick_access_section.dart';
import '../features/home/widgets/home_brew_methods_section.dart';
import '../features/home/widgets/home_bean_recommender_banner.dart';
import '../features/multi_method_brewing/presentation/widgets/active_cold_brew_floating_banner.dart';
import '../features/home/widgets/home_frequent_recipe_card.dart';
import '../features/home/widgets/home_recent_brew_tile.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/language_service.dart';
import '../services/trial_service.dart';
import '../services/user_brew_usage_service.dart';
import '../features/brew_methods/models/brew_method_item.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import '../widgets/home_header_profile_row.dart';
import 'brew_methods_screen.dart';

/// Halaman Beranda Coffee Labs yang terintegrasi penuh dengan Riverpod ConsumerStatefulWidget.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showBrewMethods = false;
  bool _isAdmin = false;
  String _userName = 'Barista';
  String? _userImagePath;
  List<Map<String, dynamic>> _baristas = [];
  GamificationStats? _gamificationStats;

  List<dynamic>? _lastHistoryRef;
  List<Map<String, dynamic>>? _lastBaristasRef;
  List<BrewMethodItem> _cachedSortedMethods = BrewMethodItem.allMethods;
  List<Map<String, dynamic>> _cachedDisplayedBaristas = const [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndBaristas();
    GamificationService.changeNotifier.addListener(_loadGamificationStats);
    ProfileService.changeNotifier.addListener(_loadProfileAndBaristas);
    AuthService.changeNotifier.addListener(_loadProfileAndBaristas);
    UserScopedStorage.activeUserIdNotifier.addListener(_loadProfileAndBaristas);
  }

  @override
  void dispose() {
    GamificationService.changeNotifier.removeListener(_loadGamificationStats);
    ProfileService.changeNotifier.removeListener(_loadProfileAndBaristas);
    AuthService.changeNotifier.removeListener(_loadProfileAndBaristas);
    UserScopedStorage.activeUserIdNotifier.removeListener(_loadProfileAndBaristas);
    super.dispose();
  }

  Future<void> _loadGamificationStats() async {
    final stats = await GamificationService.instance.getStats();
    if (!mounted) return;
    setState(() => _gamificationStats = stats);
  }

  Future<void> _loadProfileAndBaristas() async {
    final results = await Future.wait<dynamic>([
      ProfileService.getUserName(),
      ProfileService.getUserImagePath(),
      ApiService.getUniqueBaristas(),
      GamificationService.instance.getStats(),
      AuthService.isAdmin(),
    ]);
    if (!mounted) return;
    setState(() {
      _userName = results[0] as String;
      _userImagePath = results[1] as String?;
      _baristas = results[2] as List<Map<String, dynamic>>;
      _gamificationStats = results[3] as GamificationStats;
      _isAdmin = results[4] as bool;
      _lastBaristasRef = null;
    });
  }

  Future<void> _refreshAll() async {
    await ref.read(recipeListControllerProvider.notifier).refreshRecipes();
    ref.invalidate(brewHistoryControllerProvider);
    await _loadProfileAndBaristas();
  }

  Future<void> _brewRecipe(dynamic recipe) async {
    final canBrew = await TrialService.canBrew();
    if (!canBrew) {
      final remaining = await TrialService.getRemainingLockDuration();
      final days = remaining != null ? (remaining.inDays + 1) : 7;
      if (mounted) {
        TrialService.showLockedDialog(
          context: context,
          title: 'Batas Seduh Trial Tercapai',
          message: 'Anda telah mencapai batas 10 kali seduh pada mode trial. Fitur seduh terkunci selama 1 minggu ($days hari tersisa).\n\nSilakan login atau daftar akun resmi yang disetujui Admin untuk seduh tanpa batas!',
          onLoginTap: () {
            context.push('${AppRoutes.onboarding}?upgrade=true');
          },
        );
      }
      return;
    }
    if (!mounted) return;
    context.push(AppRoutes.brewTimer, extra: recipe);
  }

  void _openSettings() {
    context.push(AppRoutes.settings).then((changed) {
      if (changed == true) _loadProfileAndBaristas();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final isEn = LanguageService.isEnglish;
    if (hour < 12) return isEn ? 'Good morning,' : 'Selamat pagi,';
    if (hour < 15) return isEn ? 'Good afternoon,' : 'Selamat siang,';
    if (hour < 19) return isEn ? 'Good evening,' : 'Selamat sore,';
    return isEn ? 'Good evening,' : 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    if (_showBrewMethods) {
      return BrewMethodsScreen(
        onBack: () => setState(() => _showBrewMethods = false),
      );
    }

    final isEn = LanguageService.isEnglish;
    final historyAsync = ref.watch(brewHistoryControllerProvider);
    final recipesAsync = ref.watch(recipeListControllerProvider);

    // Dapatkan riwayat seduh untuk menyusun urutan metode & barista berdasarkan data riil pengguna (memoized)
    final history = historyAsync.value ?? const [];
    if (!identical(_lastHistoryRef, history) || !identical(_lastBaristasRef, _baristas)) {
      _lastHistoryRef = history;
      _lastBaristasRef = _baristas;
      _cachedSortedMethods =
          UserBrewUsageService.sortMethodsByUserUsage(BrewMethodItem.allMethods, history);
      final sortedBaristas =
          UserBrewUsageService.sortBaristasByUserUsage(_baristas, history);
      _cachedDisplayedBaristas = sortedBaristas.take(15).toList();
    }
    final sortedMethods = _cachedSortedMethods;
    final displayedBaristas = _cachedDisplayedBaristas;

    final currentLvl = _gamificationStats?.level ?? CoffeeLevel.allLevels.first;

    return Scaffold(
      floatingActionButton: const HomeFloatingScannerFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: AppTheme.primaryBrown,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeaderProfileRow(
                    userImagePath: _userImagePath,
                    userName: _userName,
                    gamificationStats: _gamificationStats,
                    currentLevel: currentLvl,
                    greeting: _getGreeting(),
                    onTapProfile: () {
                      if (_gamificationStats != null) {
                        LevelRoadmapModal.show(context, stats: _gamificationStats!, avatarPath: _userImagePath);
                      } else {
                        _openSettings();
                      }
                    },
                    onTapFavorites: () {
                      context.push(AppRoutes.favorites);
                    },
                  ),
                  const SizedBox(height: 22),

                  Text(
                    isEn ? 'What would you\nlike to brew today?' : 'Mau brew\napa hari ini?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEn
                        ? 'Explore precision recipes, brewing inspiration, and craft flavors.'
                        : 'Eksplorasi resep presisi, inspirasi seduh, dan kreasi rasa terbaik.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Quick Access Section (Social, Marketplace, Beans Radar)
                  HomeQuickAccessSection(isEn: isEn),
                  if (_isAdmin) ...[
                    const SizedBox(height: 14),
                    HomeAdminQuickBar(isEn: isEn),
                  ],
                  const SizedBox(height: 20),

                  // Brew Methods Section (Disusun berdasarkan frekuensi seduh user)
                  HomeBrewMethodsSection(
                    isEn: isEn,
                    onSeeAll: () => setState(() => _showBrewMethods = true),
                    methods: sortedMethods,
                  ),
                  const SizedBox(height: 20),

                  // Active Cold Brew Background Alarms Banner
                  const ActiveColdBrewFloatingBanner(),

                  // Smart Brew Dial-In Banner
                  HomeBeanRecommenderBanner(isEn: isEn),
                  const SizedBox(height: 20),

                  // Barista spotlight (Disusun berdasarkan frekuensi seduh resep barista oleh user)
                  if (displayedBaristas.isNotEmpty) ...[
                    Text('Barista Spotlight', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 114,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        cacheExtent: 420,
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayedBaristas.length,
                        itemBuilder: (context, index) {
                          final b = displayedBaristas[index];
                          final brewCount = (b['userBrewCount'] as num?)?.toInt() ?? 0;
                          final heroTag = 'home_barista_${BaristaUtils.slugFromAuthor(b['author'] as String)}_$index';
                          return RepaintBoundary(
                            child: GestureDetector(
                              onTap: () {
                                context.push(
                                  AppRoutes.baristaProfile,
                                  extra: {
                                    'rawAuthor': b['author'] as String,
                                    'imageUrl': b['imageUrl'] as String?,
                                    'coverImageUrl': b['coverImageUrl'] as String?,
                                    'heroTag': heroTag,
                                  },
                                );
                              },
                              child: Container(
                                width: 76,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        BaristaAvatar(
                                          imageUrl: b['imageUrl'] as String?,
                                          radius: 30,
                                          heroTag: heroTag,
                                        ),
                                        if (brewCount > 0)
                                          Positioned(
                                            right: -2,
                                            bottom: -2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentGold,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.white, width: 1.2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.25),
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                '${brewCount}x',
                                                style: const TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      b['name'] as String,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Paling sering diseduh (dari recipes)
                  recipesAsync.maybeWhen(
                    data: (recipes) {
                      final frequent = recipes.take(6).toList();
                      if (frequent.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Featured Precision Brews' : 'Resep Pilihan Rekomendasi',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              cacheExtent: 540,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              itemCount: frequent.length,
                              itemBuilder: (context, index) {
                                return RepaintBoundary(
                                  child: HomeFrequentRecipeCard(
                                    recipe: frequent[index],
                                    onTap: () => _brewRecipe(frequent[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),

                  // Recent Brews (dari historyAsync)
                  Text(
                    isEn ? 'Recent Brews' : 'Baru Dicoba',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  historyAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
                    ),
                    data: (history) {
                      if (history.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: Text(
                              isEn
                                  ? 'No brews yet. Start from Recipes or Brew tab.'
                                  : 'Belum ada brew. Mulai dari tab Recipes atau Brew.',
                              style: const TextStyle(color: AppTheme.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: history
                            .take(10)
                            .map((r) => HomeRecentBrewTile(
                                  recipe: r,
                                  onTap: () => _brewRecipe(r),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
