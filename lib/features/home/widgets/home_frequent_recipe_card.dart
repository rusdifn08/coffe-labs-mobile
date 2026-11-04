import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/barista_profile_screen.dart';
import '../../../services/coffee_translator.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/barista_utils.dart';

/// Kartu resep yang paling sering diseduh pada halaman beranda.
class HomeFrequentRecipeCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;

  const HomeFrequentRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      onTap: onTap,
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
}
