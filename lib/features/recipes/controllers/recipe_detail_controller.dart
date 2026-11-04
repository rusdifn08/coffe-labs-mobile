import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../repositories/recipe_repository.dart';

part 'recipe_detail_controller.g.dart';

/// State terhitung untuk detail resep dengan penskalaan dosis dinamis dan checklist persiapan.
class RecipeDetailState {
  final Map<String, dynamic> baseRecipe;
  final double scaledCoffeeGrams;
  final double baseCoffeeGrams;
  final Set<int> checkedPrepIndices;
  final bool isFavorite;

  const RecipeDetailState({
    required this.baseRecipe,
    required this.scaledCoffeeGrams,
    required this.baseCoffeeGrams,
    this.checkedPrepIndices = const {},
    this.isFavorite = false,
  });

  double get scaleFactor => baseCoffeeGrams > 0 ? scaledCoffeeGrams / baseCoffeeGrams : 1.0;

  int get totalWaterGrams {
    final baseWater = (baseRecipe['totalWaterWeightGrams'] ?? 240) as int;
    return (baseWater * scaleFactor).round();
  }

  int get iceWeightGrams {
    final baseIce = (baseRecipe['iceWeightGrams'] ?? 0) as int;
    return (baseIce * scaleFactor).round();
  }

  /// Menghasilkan resep lengkap dengan seluruh gramasi air tiap tahap yang diskalakan secara matematis.
  Map<String, dynamic> get scaledRecipe {
    final copy = Map<String, dynamic>.from(baseRecipe);
    copy['coffeeWeightGrams'] = scaledCoffeeGrams.round();
    copy['totalWaterWeightGrams'] = totalWaterGrams;
    if (iceWeightGrams > 0) {
      copy['iceWeightGrams'] = iceWeightGrams;
    }

    final rawSteps = baseRecipe['steps'];
    if (rawSteps is List) {
      copy['steps'] = rawSteps.map((step) {
        if (step is Map) {
          final sCopy = Map<String, dynamic>.from(step);
          final w = (sCopy['waterAddedGrams'] ?? sCopy['waterGrams'] ?? 0) as int;
          sCopy['waterAddedGrams'] = (w * scaleFactor).round();
          return sCopy;
        }
        return step;
      }).toList();
    }
    return copy;
  }

  RecipeDetailState copyWith({
    Map<String, dynamic>? baseRecipe,
    double? scaledCoffeeGrams,
    double? baseCoffeeGrams,
    Set<int>? checkedPrepIndices,
    bool? isFavorite,
  }) {
    return RecipeDetailState(
      baseRecipe: baseRecipe ?? this.baseRecipe,
      scaledCoffeeGrams: scaledCoffeeGrams ?? this.scaledCoffeeGrams,
      baseCoffeeGrams: baseCoffeeGrams ?? this.baseCoffeeGrams,
      checkedPrepIndices: checkedPrepIndices ?? this.checkedPrepIndices,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.
@riverpod
class RecipeDetailController extends _$RecipeDetailController {
  @override
  RecipeDetailState build(Map<String, dynamic> initialRecipe) {
    final baseCoffee = ((initialRecipe['coffeeWeightGrams'] ?? 15) as num).toDouble();
    return RecipeDetailState(
      baseRecipe: initialRecipe,
      scaledCoffeeGrams: baseCoffee,
      baseCoffeeGrams: baseCoffee,
      checkedPrepIndices: const {},
      isFavorite: false,
    );
  }

  /// Mengubah takaran dosis kopi (otomatis menghitung ulang seluruh air dan tuangan).
  void setDose(double newDose) {
    if (newDose > 0) {
      state = state.copyWith(scaledCoffeeGrams: newDose);
    }
  }

  /// Mengembalikan dosis ke gramasi default pembuat resep.
  void resetDose() {
    state = state.copyWith(scaledCoffeeGrams: state.baseCoffeeGrams);
  }

  /// Menandai/membatalkan checklist persiapan pra-seduh.
  void togglePrepItem(int index) {
    final updated = Set<int>.from(state.checkedPrepIndices);
    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    state = state.copyWith(checkedPrepIndices: updated);
  }

  /// Toggle status favorit resep ini.
  Future<void> toggleFavorite() async {
    final id = state.baseRecipe['id'] as int? ?? 0;
    if (id > 0) {
      final repo = ref.read(recipeRepositoryProvider);
      final isFav = await repo.toggleFavorite(id);
      state = state.copyWith(isFavorite: isFav);
    }
  }
}
