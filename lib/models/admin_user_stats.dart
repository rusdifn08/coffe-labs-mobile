import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_stats.freezed.dart';
part 'admin_user_stats.g.dart';

/// Model statistik pengguna Admin Dashboard menggunakan Freezed & JsonSerializable.
@freezed
abstract class AdminUserStats with _$AdminUserStats {
  const factory AdminUserStats({
    @JsonKey(name: 'total_users') @Default(0) int totalUsers,
    @JsonKey(name: 'new_registrations_7d') @Default(0) int newRegistrations7d,
    @JsonKey(name: 'active_users') @Default(0) int activeUsers,
    @JsonKey(name: 'pending_or_declined') @Default(0) int pendingOrDeclined,
  }) = _AdminUserStats;

  factory AdminUserStats.empty() => const AdminUserStats();

  factory AdminUserStats.fromJson(Map<String, dynamic> json) =>
      _$AdminUserStatsFromJson(json);
}
