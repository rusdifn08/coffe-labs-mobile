import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CuppingConstants {
  static const List<String> roastPresets = [
    'Light',
    'Light-Medium',
    'Medium',
    'Medium-Dark',
    'Dark',
  ];

  static const List<String> popularVarieties = [
    'Bourbon',
    'Pink Bourbon',
    'Typica / Sigarar Utang',
    'Ateng Super / TimTim',
    'S-795 / Kartika',
    'Geisha / Gesha',
    'Ethiopian Heirloom',
    'SL-28 / SL-34',
    'Caturra / Catuai',
    'Pacamara',
    'Andungsari',
    'Kopyol (Bali)',
    'Custom...',
  ];

  static const List<String> popularProcesses = [
    'Washed',
    'Natural',
    'Honey Process',
    'Natural Anaerobic',
    'Washed Anaerobic',
    'Yeast Inoculation',
    'Thermal Shock',
    'Slow Dry Natural',
    'Custom...',
  ];

  static const List<String> noteCategories = [
    '🍑 Fruity (Tropis & Batu)',
    '🍎 Orchard Fruit',
    '🍓 Berry',
    '🍋 Citrus',
    '🌸 Floral',
    '🍫 Cokelat & Manis',
    '🥜 Nutty & Rempah',
    '🍵 Teh & Fermentasi',
    '✨ Body & Finish',
  ];

  static const List<String> aftertastePresets = [
    'Juicy',
    'Creamy',
    'Lingering Sweetness',
    'Clean & Refreshing',
    'Dark Chocolate Finish',
    'Winey & Fruity',
    'Silky Tea-like',
    'Custom...',
  ];

  static const List<String> mouthfeelPresets = [
    'Silky & Smooth',
    'Juicy & Round',
    'Creamy & Buttery',
    'Light & Tea-like',
    'Syrupy & Heavy',
    'Velvety & Dense',
    'Clean & Crisp',
    'Custom...',
  ];

  static String normalizeRoast(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('light-medium') || lower.contains('light medium')) return 'Light-Medium';
    if (lower.contains('medium-dark') || lower.contains('medium dark')) return 'Medium-Dark';
    if (lower.contains('light')) return 'Light';
    if (lower.contains('dark')) return 'Dark';
    if (lower.contains('medium')) return 'Medium';
    return 'Light-Medium';
  }

  static String getGradeLabel(bool hasEvaluated, double score) {
    if (!hasEvaluated) return '📋 Belum Dinilai (Siap Cupping)';
    if (score >= 90.0) return '🌟 Outstanding (Presidential Award)';
    if (score >= 85.0) return '🏆 Specialty Grade (Excellent)';
    if (score >= 80.0) return '✨ Specialty Grade (Very Good)';
    return '☕ Commercial / Below Specialty';
  }

  static Color getGradeColor(bool hasEvaluated, double score) {
    if (!hasEvaluated) return AppTheme.textMuted;
    if (score >= 90.0) return const Color(0xFFD48806);
    if (score >= 85.0) return AppTheme.primaryBrown;
    if (score >= 80.0) return const Color(0xFF2E7D32);
    return Colors.redAccent;
  }
}

class CuppingDemoData {
  static const String beanName = 'Aceh Gayo Bener Meriah';
  static const String origin = 'Bener Meriah, Aceh 🇮🇩';
  static const String cupper = 'Q-Grader Cupping Lab';
  static const String variety = 'Bourbon';
  static const String process = 'Natural Anaerobic';
  static const String roast = 'Light-Medium';
  static const List<String> notes = ['Jasmine', 'Sweet Orange', 'Wild Honey'];
  static const String aftertaste = 'Juicy';
  static const String mouthfeel = 'Silky & Smooth';
  static const double aromaScore = 8.50;
  static const double acidityScore = 8.50;
  static const double sweetnessScore = 8.75;
  static const double mouthfeelScore = 8.50;
  static const double aftertasteScore = 8.50;
  static const double balanceScore = 8.50;
  static const String notesText =
      'Aroma melati sangat semerbak saat crust dibuka. Acidity jeruk manis menyegarkan dengan aftertaste juicy madu yang bertahan panjang.';
}
