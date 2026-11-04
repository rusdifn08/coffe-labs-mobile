// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: json['id'] as String?,
  title: json['title'] as String,
  beanName: json['beanName'] as String,
  method: json['method'] as String,
  waterTempCelsius: (json['waterTempCelsius'] as num?)?.toInt() ?? 92,
  steps: json['steps'] as String? ?? '',
  forkedFromId: json['forkedFromId'] as String?,
  coffeeWeightGrams: (json['coffeeWeightGrams'] as num?)?.toInt() ?? 15,
  totalWaterWeightGrams:
      (json['totalWaterWeightGrams'] as num?)?.toInt() ?? 240,
  totalTimeSeconds: (json['totalTimeSeconds'] as num?)?.toInt() ?? 180,
  isCustom: json['isCustom'] as bool? ?? false,
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'beanName': instance.beanName,
  'method': instance.method,
  'waterTempCelsius': instance.waterTempCelsius,
  'steps': instance.steps,
  'forkedFromId': instance.forkedFromId,
  'coffeeWeightGrams': instance.coffeeWeightGrams,
  'totalWaterWeightGrams': instance.totalWaterWeightGrams,
  'totalTimeSeconds': instance.totalTimeSeconds,
  'isCustom': instance.isCustom,
};
