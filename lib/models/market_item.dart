import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_item.freezed.dart';
part 'market_item.g.dart';

/// Model domain & DTO immutable untuk Item Marketplace Alat & Biji Kopi menggunakan Freezed.
@freezed
abstract class MarketItem with _$MarketItem {
  const factory MarketItem({
    String? id,
    required String title,
    required String description,
    required double price,
    required String itemType,
    required String condition,
  }) = _MarketItem;

  factory MarketItem.fromJson(Map<String, dynamic> json) => _$MarketItemFromJson(json);
}
