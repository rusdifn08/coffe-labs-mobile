import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

/// Model domain & DTO immutable untuk Resep Kopi menggunakan Freezed & JsonSerializable.
@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    String? id,
    required String title,
    required String beanName,
    required String method,
    @Default(92) int waterTempCelsius,
    @Default('') String steps,
    String? forkedFromId,
    @Default(15) int coffeeWeightGrams,
    @Default(240) int totalWaterWeightGrams,
    @Default(180) int totalTimeSeconds,
    @Default(false) bool isCustom,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
