import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_card.freezed.dart';
part 'coffee_card.g.dart';

/// Model domain & DTO immutable untuk Kartu Evaluasi Sensorik Biji Kopi (CoffeeCard) menggunakan Freezed.
@freezed
abstract class CoffeeCard with _$CoffeeCard {
  const factory CoffeeCard({
    String? id,
    required String beanName,
    required String origin,
    required String roaster,
    @Default(0) int acidityLevel,
    @Default(0) int bodyLevel,
    @Default(0) int sweetnessLevel,
    required String flavorNotes,
    required DateTime tastedAt,
  }) = _CoffeeCard;

  factory CoffeeCard.fromJson(Map<String, dynamic> json) => _$CoffeeCardFromJson(json);
}
