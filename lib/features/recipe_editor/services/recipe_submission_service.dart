import 'package:flutter/material.dart';
import '../../../../services/api_service.dart';
import '../../../../services/profile_service.dart';
import '../../../../theme/app_theme.dart';
import '../models/recipe_editor_controllers.dart';
import '../models/recipe_step_draft.dart';

class RecipeSubmissionService {
  static Future<bool> submitRecipe({
    required BuildContext context,
    required List<RecipeStepDraft> steps,
    required String selectedCategory,
    required bool isIcedMethod,
    required RecipeEditorControllers controllers,
  }) async {
    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 step seduh!')),
      );
      return false;
    }

    try {
      int totalTime = 0;
      int cumulativeWater = 0;
      final List<Map<String, dynamic>> parsedSteps = [];

      for (int i = 0; i < steps.length; i++) {
        final s = steps[i];
        final time = (int.tryParse(s.durationCtrl.text.trim()) ?? 30).clamp(1, 3600);
        final water = (int.tryParse(s.waterCtrl.text.trim()) ?? 0).clamp(0, 5000);
        totalTime += time;
        cumulativeWater += water;

        final rawTitle = s.titleCtrl.text.trim();
        final stepTitle = rawTitle.isEmpty ? 'Step ${i + 1}' : rawTitle;
        final rawInstruction = s.instructionCtrl.text.trim();
        final instruction = rawInstruction.isNotEmpty
            ? rawInstruction
            : (water > 0
                ? 'Tuang ${water}g air secara merata hingga mencapai ${cumulativeWater}g dalam ${time}s.'
                : 'Biarkan fase imersi / pengurasan (drawdown) berlangsung selama ${time}s.');

        parsedSteps.add({
          'stepOrder': i + 1,
          'title': stepTitle,
          'durationSeconds': time,
          'waterAddedGrams': water,
          'timeSeconds': time,
          'waterGrams': water,
          'cumulativeWaterGrams': cumulativeWater,
          'instruction': instruction,
        });
      }

      final coffeeGrams = (num.tryParse(controllers.coffee.text.trim()) ?? 15).clamp(1, 500);
      final inputWater = int.tryParse(controllers.water.text.trim()) ?? 0;
      final totalWaterGrams = inputWater > 0 ? inputWater : (cumulativeWater > 0 ? cumulativeWater : 225);
      final iceGrams = isIcedMethod ? (int.tryParse(controllers.ice.text.trim()) ?? 90).clamp(0, 2000) : 0;
      final tempCelsius = (int.tryParse(controllers.temp.text.trim()) ?? 92).clamp(40, 100);

      final titleText = controllers.title.text.trim().isEmpty
          ? 'Resep $selectedCategory Saya'
          : controllers.title.text.trim();
      final authorText = controllers.author.text.trim().isEmpty
          ? 'Barista 🇮🇩'
          : controllers.author.text.trim();
      final beanText = controllers.bean.text.trim().isEmpty
          ? 'Arabika Nusantara Single Origin'
          : controllers.bean.text.trim();
      final methodText = controllers.method.text.trim().isEmpty
          ? selectedCategory
          : controllers.method.text.trim();
      final grindText = controllers.grind.text.trim().isEmpty
          ? 'Medium (23 Klik Comandante C40)'
          : controllers.grind.text.trim();
      final tastingText = controllers.tasting.text.trim().isEmpty
          ? 'Sweet, Balanced, Clean Finish'
          : controllers.tasting.text.trim();
      final descText = controllers.desc.text.trim().isEmpty
          ? 'Resep seduh $selectedCategory menggunakan alat $methodText dengan suhu $tempCelsius°C dan gilingan $grindText.'
          : controllers.desc.text.trim();

      final userAvatar = await ProfileService.getUserImagePath();

      final Map<String, dynamic> payload = {
        'title': titleText,
        'author': authorText,
        'coverImageUrl': userAvatar,
        'authorAvatarUrl': userAvatar,
        'authorImageUrl': userAvatar,
        'beanName': beanText,
        'grindSize': grindText,
        'method': methodText,
        'category': selectedCategory,
        'waterTempCelsius': tempCelsius,
        'coffeeWeightGrams': coffeeGrams,
        'totalWaterWeightGrams': totalWaterGrams,
        'iceWeightGrams': iceGrams,
        'waterPpm': '75 ppm',
        'tastingNotes': tastingText,
        'totalTimeSeconds': totalTime,
        'description': descText,
        'isCustom': true,
        'steps': parsedSteps,
      };

      await ApiService.createRecipe(payload);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil disimpan & siap digunakan!'),
            backgroundColor: AppTheme.primaryBrown,
          ),
        );
        Navigator.pop(context, true);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan resep: $e'), backgroundColor: Colors.redAccent),
        );
      }
      return false;
    }
  }
}
