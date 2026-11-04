// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUserStats _$AdminUserStatsFromJson(Map<String, dynamic> json) =>
    _AdminUserStats(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      newRegistrations7d: (json['new_registrations_7d'] as num?)?.toInt() ?? 0,
      activeUsers: (json['active_users'] as num?)?.toInt() ?? 0,
      pendingOrDeclined: (json['pending_or_declined'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AdminUserStatsToJson(_AdminUserStats instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'new_registrations_7d': instance.newRegistrations7d,
      'active_users': instance.activeUsers,
      'pending_or_declined': instance.pendingOrDeclined,
    };
