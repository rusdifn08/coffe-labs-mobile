// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffee_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoffeeCard _$CoffeeCardFromJson(Map<String, dynamic> json) => _CoffeeCard(
  id: json['id'] as String?,
  beanName: json['beanName'] as String,
  origin: json['origin'] as String,
  roaster: json['roaster'] as String,
  acidityLevel: (json['acidityLevel'] as num?)?.toInt() ?? 0,
  bodyLevel: (json['bodyLevel'] as num?)?.toInt() ?? 0,
  sweetnessLevel: (json['sweetnessLevel'] as num?)?.toInt() ?? 0,
  flavorNotes: json['flavorNotes'] as String,
  tastedAt: DateTime.parse(json['tastedAt'] as String),
);

Map<String, dynamic> _$CoffeeCardToJson(_CoffeeCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'beanName': instance.beanName,
      'origin': instance.origin,
      'roaster': instance.roaster,
      'acidityLevel': instance.acidityLevel,
      'bodyLevel': instance.bodyLevel,
      'sweetnessLevel': instance.sweetnessLevel,
      'flavorNotes': instance.flavorNotes,
      'tastedAt': instance.tastedAt.toIso8601String(),
    };
