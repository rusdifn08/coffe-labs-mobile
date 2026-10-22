import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../utils/barista_utils.dart';
import 'barista_profile_screen.dart';
import 'brew_timer_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'onboarding_screen.dart';
import '../services/trial_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _history = [];
  List<dynamic> _frequent = [];
  List<Map<String, dynamic>> _baristas = [];
  bool _isLoading = true;
  String _userName = 'Barista';
  String? _userImagePath;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadData();
    ApiService.changeNotifier.addListener(_onExternalChange);
    ProfileService.changeNotifier.addListener(_onExternalChange);
    LanguageService.changeNotifier.addListener(_onExternalChange);
  }

  @override
  void dispose() {
    ApiService.changeNotifier.removeListener(_onExternalChange);
    ProfileService.changeNotifier.removeListener(_onExternalChange);
    LanguageService.changeNotifier.removeListener(_onExternalChange);
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onExternalChange() {
    _loadData(silent: true);
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final history = await ApiService.getBrewHistory();
    final frequent = await ApiService.getFrequentBrews();
    final userName = await ProfileService.getUserName();
    final userImagePath = await ProfileService.getUserImagePath();
    final baristas = await ApiService.getUniqueBaristas();
    if (!mounted) return;
    setState(() {
      _history = history;
      _frequent = frequent;
      _userName = userName;
      _userImagePath = userImagePath;
      _baristas = baristas.take(12).toList();
      _isLoading = false;
    });
    if (!silent) {
      _fadeCtrl.forward(from: 0);
    }
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
          },
        );
      }
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    ).then((changed) {
      if (changed == true) _loadData();
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
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primaryBrown,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _openSettings,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.bgCream,
                              backgroundImage: ProfileService.getImageProvider(_userImagePath),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(), style: Theme.of(context).textTheme.bodyMedium),
                                Text(_userName, style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.heart_fill),
                          color: AppTheme.primaryBrown,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                            ).then((_) => _loadData());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
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
                  const SizedBox(height: 28),

                  // Barista spotlight
                  if (!_isLoading && _baristas.isNotEmpty) ...[
                    Text('Barista Spotlight', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 108,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _baristas.length,
                        itemBuilder: (context, index) {
                          final b = _baristas[index];
                          final heroTag = 'home_barista_${BaristaUtils.slugFromAuthor(b['author'] as String)}';
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BaristaProfileScreen(
                                    rawAuthor: b['author'] as String,
                                    imageUrl: b['imageUrl'] as String?,
                                    coverImageUrl: b['coverImageUrl'] as String?,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 76,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  BaristaAvatar(
                                    imageUrl: b['imageUrl'] as String?,
                                    radius: 30,
                                    heroTag: heroTag,
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
                  else if (_frequent.isNotEmpty) ...[
                    Text(
                      isEn ? 'Most Frequently Brewed' : 'Paling Sering Dipakai',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: _frequent.length,
                        itemBuilder: (context, index) => _buildRecipeCard(context, _frequent[index]),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  if (!_isLoading) ...[
                    Text(
                      isEn ? 'Recent Brews' : 'Baru Dicoba',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_history.isEmpty)
                      Padding(
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
                      )
                    else
                      ..._history.take(10).map((recipe) => _buildHistoryTile(context, recipe)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, dynamic recipe) {
    final title = CoffeeTranslator.translateTitle(recipe['title']?.toString() ?? 'Unknown Recipe');
    final author = recipe['author'] ?? 'Anonymous';
    final category = recipe['category'] ?? 'V60';

    IconData catIcon = CupertinoIcons.flame_fill;
    Color catColor = Colors.orange;
    if (category.toLowerCase().contains('hybrid') || category.toLowerCase().contains('origami')) {
      catIcon = CupertinoIcons.lab_flask_solid;
      catColor = Colors.blue;
    } else if (category.toLowerCase().contains('flat')) {
      catIcon = CupertinoIcons.cube_fill;
      catColor = Colors.green;
    }

    final coverImageUrl = (recipe['coverImageUrl'] ?? recipe['authorImageUrl'])?.toString();
    final authorAvatarUrl = (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString();

    return GestureDetector(
      onTap: () => _brewRecipe(recipe),
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BaristaProfileScreen(
              rawAuthor: author.toString(),
              imageUrl: authorAvatarUrl,
              coverImageUrl: coverImageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: BaristaUtils.buildOfflineImage(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 340,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              BaristaUtils.cleanName(author.toString()),
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(catIcon, color: catColor, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, dynamic recipe) {
    final title = CoffeeTranslator.translateTitle(recipe['title']?.toString() ?? 'Unknown Recipe');
    final author = recipe['author'] ?? 'Anonymous';
    final authorImageUrl =
        (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString();

    return GestureDetector(
      onTap: () => _brewRecipe(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            BaristaAvatar(imageUrl: authorImageUrl, radius: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${BaristaUtils.cleanName(author.toString())}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.play_arrow_solid, color: AppTheme.primaryBrown, size: 16),
          ],
        ),
      ),
    );
  }
}
