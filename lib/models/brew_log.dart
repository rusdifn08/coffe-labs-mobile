import 'package:freezed_annotation/freezed_annotation.dart';

part 'brew_log.freezed.dart';
part 'brew_log.g.dart';

/// Model domain & DTO immutable untuk Riwayat Seduh (BrewLog) menggunakan Freezed.
@freezed
abstract class BrewLog with _$BrewLog {
  const factory BrewLog({
    String? id,
    required String beanName,
    required String method,
    @Default(15.0) double coffeeWeight,
    @Default(240.0) double waterWeight,
    @Default(180) int totalBrewTimeSeconds,
    required DateTime createdAt,
  }) = _BrewLog;

  factory BrewLog.fromJson(Map<String, dynamic> json) => _$BrewLogFromJson(json);
}
