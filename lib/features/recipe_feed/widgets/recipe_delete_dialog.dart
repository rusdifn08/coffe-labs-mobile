import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/language_service.dart';

/// Confirmation dialog for deleting custom recipes.
class RecipeDeleteDialog {
  static Future<bool?> show(BuildContext context, {required int id, required String title}) {
    final isEn = LanguageService.isEnglish;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Delete Recipe?' : 'Hapus Resep?'),
        content: Text(
          isEn ? 'Are you sure you want to delete "$title"?' : 'Yakin ingin menghapus "$title"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEn ? 'Cancel' : 'Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              try {
                await ApiService.deleteRecipe(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEn ? 'Recipe deleted' : 'Resep dihapus')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(isEn ? 'Delete' : 'Hapus', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
