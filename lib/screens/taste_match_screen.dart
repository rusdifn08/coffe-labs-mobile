import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import 'brew_timer_screen.dart';
import 'recipe_detail_screen.dart';

/// Taste Match interaktif berbasis resep lokal.
class TasteMatchScreen extends StatefulWidget {
  const TasteMatchScreen({super.key});

  @override
  State<TasteMatchScreen> createState() => _TasteMatchScreenState();
}

class _TasteMatchScreenState extends State<TasteMatchScreen> {
  List<dynamic> _deck = [];
  int _index = 0;
  bool _loading = true;
  final List<dynamic> _liked = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final recipes = await ApiService.getRecipes();
    recipes.shuffle();
    if (!mounted) return;
    setState(() {
      _deck = recipes;
      _index = 0;
      _loading = false;
    });
  }

  void _swipe(bool like) {
    if (_index >= _deck.length) return;
    if (like) _liked.add(_deck[_index]);
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown)),
      );
    }

    final done = _index >= _deck.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taste Match'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              done
                  ? 'Sesi selesai — ${_liked.length} resep cocok dengan selera Anda.'
                  : 'Geser hati jika rasa/teknik menarik. Skip jika kurang cocok.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: done
                  ? _liked.isEmpty
                      ? const Center(child: Text('Tidak ada match. Coba lagi!', style: TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          itemCount: _liked.length,
                          itemBuilder: (context, i) {
                            final r = _liked[i];
                            return ListTile(
                              leading: BaristaAvatar(
                                  imageUrl: (r['authorAvatarUrl'] ?? r['authorImageUrl'])?.toString(),
                                  radius: 22),
                              title: Text(r['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(BaristaUtils.cleanName(r['author']?.toString() ?? '')),
                              trailing: const Icon(CupertinoIcons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeData: r)),
                                );
                              },
                            );
                          },
                        )
                  : _buildCard(_deck[_index]),
            ),
            if (!done) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roundBtn(CupertinoIcons.clear, Colors.redAccent, () => _swipe(false)),
                  _roundBtn(CupertinoIcons.play_fill, AppTheme.primaryBrown, () {
                    final r = _deck[_index];
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: r)),
                    );
                  }),
                  _roundBtn(CupertinoIcons.heart_fill, Colors.green, () => _swipe(true)),
                ],
              ),
              const SizedBox(height: 12),
              Text('${_index + 1} / ${_deck.length}', style: const TextStyle(color: AppTheme.textMuted)),
            ] else ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _liked.clear();
                    _index = 0;
                    _deck.shuffle();
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                child: const Text('Mulai Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(dynamic recipe) {
    final imageUrl = (recipe['coverImageUrl'] ?? recipe['authorImageUrl'])?.toString();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: Container(
        key: ValueKey(recipe['id']),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: imageUrl != null && imageUrl.startsWith('assets/')
                  ? Image.asset(imageUrl, width: double.infinity, fit: BoxFit.cover)
                  : Image.network(
                      imageUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/avatars/generic_fallback.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${BaristaUtils.cleanName(recipe['author']?.toString() ?? '')} · ${recipe['method'] ?? ''}',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text('${recipe['coffeeWeightGrams'] ?? '-'}g'),
                          backgroundColor: AppTheme.bgCream,
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text('${recipe['waterTempCelsius'] ?? '-'}°C'),
                          backgroundColor: AppTheme.bgCream,
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text(recipe['category']?.toString() ?? ''),
                          backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.2),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
