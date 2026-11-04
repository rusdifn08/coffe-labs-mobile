import 'package:freezed_annotation/freezed_annotation.dart';

part 'basecamp.freezed.dart';
part 'basecamp.g.dart';

/// Model domain & DTO immutable untuk Komunitas Basecamp Barista menggunakan Freezed.
@freezed
abstract class Basecamp with _$Basecamp {
  const factory Basecamp({
    String? id,
    required String name,
    required String description,
    @Default(false) bool isPrivate,
  }) = _Basecamp;

  factory Basecamp.fromJson(Map<String, dynamic> json) => _$BasecampFromJson(json);
}
