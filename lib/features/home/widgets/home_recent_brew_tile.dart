import 'package:flutter/cupertino.dart';
import '../../../services/coffee_translator.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/barista_utils.dart';

/// Item riwayat seduh terkini pada halaman beranda.
class HomeRecentBrewTile extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;

  const HomeRecentBrewTile({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = CoffeeTranslator.translateTitle(recipe['title']?.toString() ?? 'Unknown Recipe');
    final author = recipe['author'] ?? 'Anonymous';
    final authorImageUrl = (recipe['authorAvatarUrl'] ?? recipe['authorImageUrl'])?.toString();

    return GestureDetector(
      onTap: onTap,
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
