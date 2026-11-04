// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brew_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BrewLog _$BrewLogFromJson(Map<String, dynamic> json) => _BrewLog(
  id: json['id'] as String?,
  beanName: json['beanName'] as String,
  method: json['method'] as String,
  coffeeWeight: (json['coffeeWeight'] as num?)?.toDouble() ?? 15.0,
  waterWeight: (json['waterWeight'] as num?)?.toDouble() ?? 240.0,
  totalBrewTimeSeconds: (json['totalBrewTimeSeconds'] as num?)?.toInt() ?? 180,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BrewLogToJson(_BrewLog instance) => <String, dynamic>{
  'id': instance.id,
  'beanName': instance.beanName,
  'method': instance.method,
  'coffeeWeight': instance.coffeeWeight,
  'waterWeight': instance.waterWeight,
  'totalBrewTimeSeconds': instance.totalBrewTimeSeconds,
  'createdAt': instance.createdAt.toIso8601String(),
};
