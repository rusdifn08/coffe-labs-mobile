import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';
import '../../../../widgets/thermal_receipt_sheet.dart';
import '../../../../screens/add_recipe_screen.dart';

class RecipeDetailAppBar extends StatelessWidget {
  final String coverImageUrl;
  final String authorName;
  final String countryCode;
  final bool isFavorite;
  final Map<String, dynamic> scaledRecipe;
  final VoidCallback onToggleFavorite;

  const RecipeDetailAppBar({
    super.key,
    required this.coverImageUrl,
    required this.authorName,
    required this.countryCode,
    required this.isFavorite,
    required this.scaledRecipe,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: AppTheme.primaryBrown,
      elevation: 2,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (countryCode.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Flag.fromString(countryCode, height: 12, width: 17, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            BaristaUtils.buildOfflineImage(
              coverImageUrl,
              fit: BoxFit.cover,
              cacheWidth: 800,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 36,
                decoration: const BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Print Struk Resep (Bluetooth Kasir)',
              icon: const Icon(CupertinoIcons.printer_fill, color: Colors.white, size: 18),
              onPressed: () => ThermalReceiptSheet.show(context, scaledRecipe),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Duplikat & Modifikasi ke Resep Saya',
              icon: const Icon(CupertinoIcons.doc_on_doc, color: Colors.white, size: 18),
              onPressed: () async {
                final didAdd = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddRecipeScreen(initialRecipe: scaledRecipe),
                  ),
                );
                if (didAdd == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resep berhasil diduplikasi ke My Custom Brews!')),
                  );
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7.0, bottom: 7.0, right: 12.0, left: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
              icon: Icon(
                isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isFavorite ? Colors.redAccent : Colors.white,
                size: 20,
              ),
              onPressed: onToggleFavorite,
            ),
          ),
        ),
      ],
    );
  }
}
