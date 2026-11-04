import 'package:flutter/cupertino.dart';
import '../../../../services/language_service.dart';

/// 5 Kategori Sortir Resep Dunia (+ opsi kurasi standar).
enum RecipeSortOption {
  defaultCurated,
  alphabetical,
  newest,
  fastestBrew,
  coffeeDose,
  baristaName;

  String get label {
    final isEn = LanguageService.isEnglish;
    switch (this) {
      case RecipeSortOption.defaultCurated:
        return isEn ? 'Championship Curated (Default)' : 'Rekomendasi Juara (Standar)';
      case RecipeSortOption.alphabetical:
        return isEn ? 'Alphabetical (A - Z)' : 'Abjad (A - Z)';
      case RecipeSortOption.newest:
        return isEn ? 'Newest Added' : 'Terbaru';
      case RecipeSortOption.fastestBrew:
        return isEn ? 'Fastest Brew Time' : 'Waktu Seduh Tercepat';
      case RecipeSortOption.coffeeDose:
        return isEn ? 'Coffee Dose (Lightest First)' : 'Dosis Kopi (Terkecil)';
      case RecipeSortOption.baristaName:
        return isEn ? 'Barista Name (A - Z)' : 'Nama Barista (A - Z)';
    }
  }

  String get description {
    final isEn = LanguageService.isEnglish;
    switch (this) {
      case RecipeSortOption.defaultCurated:
        return isEn
            ? 'Original curated ranking of World Brewers & Barista Champions'
            : 'Urutan kurasi resmi World Brewers Cup & Barista Champion';
      case RecipeSortOption.alphabetical:
        return isEn
            ? 'Sort recipe titles in alphabetical order from A to Z'
            : 'Urutkan judul resep secara alfabetis dari A ke Z';
      case RecipeSortOption.newest:
        return isEn
            ? 'Latest released recipes and your custom recipes first'
            : 'Resep paling baru ditambahkan dan resep kustom Anda';
      case RecipeSortOption.fastestBrew:
        return isEn
            ? 'Shortest extraction and preparation time (quick brew)'
            : 'Durasi ekstraksi dan waktu penyeduhan tersingkat';
      case RecipeSortOption.coffeeDose:
        return isEn
            ? 'Lowest coffee powder weight in grams (lightest dose)'
            : 'Gramasi bubuk kopi terendah hingga dosis terbesar';
      case RecipeSortOption.baristaName:
        return isEn
            ? 'Sort by brewer or roastery name from A to Z'
            : 'Urutkan nama brewer, roastery, atau kreator A ke Z';
    }
  }

  IconData get icon {
    switch (this) {
      case RecipeSortOption.defaultCurated:
        return CupertinoIcons.star_fill;
      case RecipeSortOption.alphabetical:
        return CupertinoIcons.textformat_abc;
      case RecipeSortOption.newest:
        return CupertinoIcons.sparkles;
      case RecipeSortOption.fastestBrew:
        return CupertinoIcons.stopwatch_fill;
      case RecipeSortOption.coffeeDose:
        return CupertinoIcons.circle_grid_hex_fill;
      case RecipeSortOption.baristaName:
        return CupertinoIcons.person_2_fill;
    }
  }
}
