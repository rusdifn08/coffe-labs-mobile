import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../utils/barista_utils.dart';
import 'barista_profile_screen.dart';
import 'brew_journal_screen.dart';
import 'brew_timer_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'taste_match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _history = [];
  List<dynamic> _frequent = [];
  List<Map<String, dynamic>> _baristas = [];
  int _favCount = 0;
  int _journalCount = 0;
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
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final history = await ApiService.getBrewHistory();
    final frequent = await ApiService.getFrequentBrews();
    final userName = await ProfileService.getUserName();
    final userImagePath = await ProfileService.getUserImagePath();
    final baristas = await ApiService.getUniqueBaristas();
    final favs = await ApiService.getFavoriteIds();
    final journal = await ApiService.getJournalEntries();
    if (!mounted) return;
    setState(() {
      _history = history;
      _frequent = frequent;
      _userName = userName;
      _userImagePath = userImagePath;
      _baristas = baristas.take(12).toList();
      _favCount = favs.length;
      _journalCount = journal.length;
      _isLoading = false;
    });
    _fadeCtrl.forward(from: 0);
  }

  void _brewRecipe(dynamic recipe) {
    ApiService.recordBrew(Map<String, dynamic>.from(recipe as Map));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipe)),
    ).then((_) => _loadData());
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
    if (hour < 12) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 19) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
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
                              backgroundImage: _userImagePath != null
                                  ? FileImage(File(_userImagePath!)) as ImageProvider
                                  : const AssetImage('lib/theme/rusdi.png'),
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
                    'Mau brew\napa hari ini?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toolkit, juara dunia, dan riwayat seduh Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Quick toolkit row
                  Row(
                    children: [
                      _quickAction(
                        icon: CupertinoIcons.heart_fill,
                        label: 'Favorit',
                        badge: '$_favCount',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ).then((_) => _loadData()),
                      ),
                      const SizedBox(width: 10),
                      _quickAction(
                        icon: CupertinoIcons.doc_text_fill,
                        label: 'Jurnal',
                        badge: '$_journalCount',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
                        ).then((_) => _loadData()),
                      ),
                      const SizedBox(width: 10),
                      _quickAction(
                        icon: CupertinoIcons.heart_circle,
                        label: 'Match',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TasteMatchScreen()),
                        ),
                      ),
                    ],
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BaristaProfileScreen(
                                    rawAuthor: b['author'] as String,
                                    imageUrl: b['imageUrl'] as String?,
                                    coverImageUrl: b['coverImageUrl'] as String?,
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
                                    heroTag: 'home_barista_${BaristaUtils.slugFromAuthor(b['author'] as String)}',
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
                    Text('Paling Sering Dipakai', style: Theme.of(context).textTheme.titleLarge),
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
                    Text('Baru Dicoba', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    if (_history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            'Belum ada brew. Mulai dari tab Recipes atau Brew.',
                            style: TextStyle(color: AppTheme.textMuted),
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

  Widget _quickAction({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: AppTheme.primaryBrown, size: 22),
                    if (badge != null && badge != '0')
                      Positioned(
                        right: -10,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.accentAmber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, dynamic recipe) {
    final title = recipe['title'] ?? 'Unknown Recipe';
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
                child: coverImageUrl != null && coverImageUrl.startsWith('assets/')
                    ? Image.asset(coverImageUrl, fit: BoxFit.cover, cacheWidth: 340)
                    : Image.network(
                        coverImageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/avatars/generic_fallback.jpg',
                          fit: BoxFit.cover,
                        ),
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
    final title = recipe['title'] ?? 'Unknown Recipe';
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
