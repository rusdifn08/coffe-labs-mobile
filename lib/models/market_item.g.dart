// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketItem _$MarketItemFromJson(Map<String, dynamic> json) => _MarketItem(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  itemType: json['itemType'] as String,
  condition: json['condition'] as String,
);

Map<String, dynamic> _$MarketItemToJson(_MarketItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'itemType': instance.itemType,
      'condition': instance.condition,
    };
