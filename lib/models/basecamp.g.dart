// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basecamp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Basecamp _$BasecampFromJson(Map<String, dynamic> json) => _Basecamp(
  id: json['id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String,
  isPrivate: json['isPrivate'] as bool? ?? false,
);

Map<String, dynamic> _$BasecampToJson(_Basecamp instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'isPrivate': instance.isPrivate,
};
