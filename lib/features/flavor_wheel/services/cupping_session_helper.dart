import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../screens/brew_journal_screen.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';

class CuppingSessionHelper {
  static Future<void> save({
    required BuildContext context,
    required bool hasEvaluated,
    required String beanName,
    required String origin,
    required String variety,
    required String process,
    required String roast,
    required String cupper,
    required String aftertaste,
    required String mouthfeel,
    required Set<String> selectedNotes,
    required String evalNotes,
    required double score,
    required String cuppingGradeLabel,
    required double aromaScore,
    required double acidityScore,
    required double sweetnessScore,
    required double mouthfeelScore,
    required double aftertasteScore,
    required double balanceScore,
  }) async {
    if (!hasEvaluated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lakukan penilaian skor cupping (geser slider sensori) sebelum menyimpan.'),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    final safeBean = beanName.trim().isEmpty ? 'Specialty Single Origin' : beanName.trim();
    final safeCupper = cupper.trim().isEmpty ? 'Cupper' : cupper.trim();
    final notesText = selectedNotes.isEmpty ? 'Balanced Specialty Cup' : selectedNotes.join(', ');
    final rating = (score / 20.0).clamp(1.0, 5.0);

    final summary = '''[SCA Cupping Session • Score: ${score.toStringAsFixed(2)} - $cuppingGradeLabel]
• Kopi: $safeBean ($origin)
• Varietas: $variety | Proses: $process | Sangrai: $roast
• Cupper: $safeCupper
• Profil Sensoris:
  - Aroma: ${aromaScore.toStringAsFixed(2)} | Acidity: ${acidityScore.toStringAsFixed(2)} | Sweetness: ${sweetnessScore.toStringAsFixed(2)}
  - Mouthfeel / Body: ${mouthfeelScore.toStringAsFixed(2)} ($mouthfeel)
  - Aftertaste: ${aftertasteScore.toStringAsFixed(2)} ($aftertaste)
  - Overall Balance: ${balanceScore.toStringAsFixed(2)}
• Tasting Notes: $notesText
• Catatan Cupping: ${evalNotes.isEmpty ? '-' : evalNotes}''';

    await ApiService.addJournalEntry({
      'recipeId': 0,
      'recipeTitle': 'Cupping: $safeBean ($score Poin)',
      'author': safeCupper,
      'authorAvatarUrl': 'assets/images/avatars/generic_fallback.jpg',
      'authorImageUrl': 'assets/images/avatars/generic_fallback.jpg',
      'grindNote': 'Cupping ($roast • $process)',
      'rating': rating,
      'notes': summary,
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sesi Cupping "$safeBean" berhasil disimpan ke Brew Journal!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBrown,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Lihat Journal',
          textColor: AppTheme.accentAmber,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
            );
          },
        ),
      ),
    );
  }
}
