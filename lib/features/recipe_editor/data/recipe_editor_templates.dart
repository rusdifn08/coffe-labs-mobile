import 'package:flutter/cupertino.dart';
import '../models/recipe_step_draft.dart';

class RecipeEditorTemplates {
  static const List<Map<String, dynamic>> categories = [
    {'label': 'V60', 'icon': CupertinoIcons.drop},
    {'label': 'Japanese', 'icon': CupertinoIcons.snow},
    {'label': 'Kalita', 'icon': CupertinoIcons.circle_grid_hex},
    {'label': 'Aeropress', 'icon': CupertinoIcons.layers},
    {'label': 'Origami', 'icon': CupertinoIcons.suit_diamond},
    {'label': 'Immersion', 'icon': CupertinoIcons.timer},
    {'label': 'Hybrid', 'icon': CupertinoIcons.lab_flask},
    {'label': 'Espresso', 'icon': CupertinoIcons.flame},
    {'label': 'Lainnya', 'icon': CupertinoIcons.ellipsis},
  ];

  static const List<Map<String, String>> grindPresets = [
    {'label': 'Fine'},
    {'label': 'Medium-Fine'},
    {'label': 'Medium'},
    {'label': 'Medium-Coarse'},
    {'label': 'Coarse'},
  ];

  static List<RecipeStepDraft> getTemplateSteps(String key) {
    switch (key) {
      case 'japanese_iced':
        return [
          RecipeStepDraft(
            title: 'Bloom Cepat',
            duration: '35',
            water: '45',
            instruction: 'Tuang air 93°C di tengah memutar halus untuk bloom.',
          ),
          RecipeStepDraft(
            title: 'Main Pour 1',
            duration: '35',
            water: '55',
            instruction: 'Tuang spiral perlahan langsung menetes ke es server.',
          ),
          RecipeStepDraft(
            title: 'Concentrated Finish',
            duration: '35',
            water: '50',
            instruction: 'Tuang sisa air konsentrat tinggi, swirl server hingga es larut.',
          ),
        ];

      case 'immersion':
        return [
          RecipeStepDraft(
            title: 'Tuang Penuh & Aduk',
            duration: '40',
            water: '225',
            instruction: 'Tuang seluruh air 225g sekaligus, aduk 5 putaran perlahan.',
          ),
          RecipeStepDraft(
            title: 'Steep Rendam',
            duration: '90',
            water: '0',
            instruction: 'Biarkan kopi terendam penuh selama 1 menit 30 detik.',
          ),
          RecipeStepDraft(
            title: 'Press / Release',
            duration: '35',
            water: '0',
            instruction: 'Tekan plunger secara konsisten atau letakkan Clever di server.',
          ),
        ];

      case 'hybrid_switch':
        return [
          RecipeStepDraft(
            title: 'Open Valve Bloom',
            duration: '40',
            water: '60',
            instruction: 'Klep terbuka: Tuang 60g air perkolasi standar.',
          ),
          RecipeStepDraft(
            title: 'Open Valve Pour 2',
            duration: '40',
            water: '60',
            instruction: 'Klep masih terbuka: Tuang 60g kedua untuk mengejar acidity.',
          ),
          RecipeStepDraft(
            title: 'Close Valve Steep',
            duration: '60',
            water: '120',
            instruction: 'Tutup klep: Tuang 120g air sisa dan biarkan terendam 1 menit.',
          ),
          RecipeStepDraft(
            title: 'Release Drain',
            duration: '30',
            water: '0',
            instruction: 'Buka klep Switch untuk pengurasan cairan manis dan bersih.',
          ),
        ];

      case 'v60_3pour':
      default:
        return [
          RecipeStepDraft(
            title: 'Bloom',
            duration: '40',
            water: '50',
            instruction: 'Tuang 50g melingkar basahi seluruh bubuk kopi, swirl 1x.',
          ),
          RecipeStepDraft(
            title: 'Second Pour',
            duration: '40',
            water: '85',
            instruction: 'Tuang spiral perlahan dari tengah keluar hingga 135g.',
          ),
          RecipeStepDraft(
            title: 'Final Pour & Drawdown',
            duration: '40',
            water: '90',
            instruction: 'Tuang sisa 90g di tengah dengan debit lembut hingga total 225g.',
          ),
        ];
    }
  }

  static Map<String, String> getTemplateMeta(String key) {
    switch (key) {
      case 'japanese_iced':
        return {
          'category': 'Japanese',
          'method': 'Hario V60 02 + Es di Server',
          'coffee': '16',
          'water': '150',
          'ice': '90',
          'temp': '93',
        };
      case 'immersion':
        return {
          'category': 'Immersion',
          'method': 'AeroPress Inverted / Clever Dripper',
          'coffee': '15',
          'water': '225',
          'ice': '0',
          'temp': '90',
        };
      case 'hybrid_switch':
        return {
          'category': 'Hybrid',
          'method': 'Hario Switch 02',
          'coffee': '16',
          'water': '240',
          'ice': '0',
          'temp': '92',
        };
      case 'v60_3pour':
      default:
        return {
          'category': 'V60',
          'method': 'Hario V60 02',
          'coffee': '15',
          'water': '225',
          'ice': '0',
          'temp': '92',
        };
    }
  }
}
