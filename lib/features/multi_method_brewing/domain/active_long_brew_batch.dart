import 'dart:convert';

class ActiveLongBrewBatch {
  final String id;
  final String? serverAlarmId;
  final int? recipeId;
  final String recipeTitle;
  final String methodSlug;
  final String brewMode;
  final double coffeeDoseG;
  final double waterMl;
  final double ambientTempC;
  final int? dripRateBpm;
  final DateTime startedAt;
  final DateTime targetFinishAt;
  final int totalDurationSec;
  final String status;
  final int snoozeCount;
  final Map<String, dynamic>? recipeSnapshot;

  const ActiveLongBrewBatch({
    required this.id,
    this.serverAlarmId,
    this.recipeId,
    required this.recipeTitle,
    required this.methodSlug,
    required this.brewMode,
    required this.coffeeDoseG,
    required this.waterMl,
    required this.ambientTempC,
    this.dripRateBpm,
    required this.startedAt,
    required this.targetFinishAt,
    required this.totalDurationSec,
    this.status = 'ACTIVE',
    this.snoozeCount = 0,
    this.recipeSnapshot,
  });

  int get notificationId => id.hashCode & 0x7fffffff;

  Duration remainingAt(DateTime now) {
    final diff = targetFinishAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  bool isDueAt(DateTime now) =>
      (status == 'ACTIVE' || status == 'SNOOZED' || status == 'RINGING') &&
      !targetFinishAt.isAfter(now);

  double progressAt(DateTime now) {
    if (totalDurationSec <= 0) return 1.0;
    final elapsed = now.difference(startedAt).inSeconds;
    return (elapsed / totalDurationSec).clamp(0.0, 1.0);
  }

  ActiveLongBrewBatch copyWith({
    String? serverAlarmId,
    DateTime? targetFinishAt,
    String? status,
    int? snoozeCount,
  }) {
    return ActiveLongBrewBatch(
      id: id,
      serverAlarmId: serverAlarmId ?? this.serverAlarmId,
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      methodSlug: methodSlug,
      brewMode: brewMode,
      coffeeDoseG: coffeeDoseG,
      waterMl: waterMl,
      ambientTempC: ambientTempC,
      dripRateBpm: dripRateBpm,
      startedAt: startedAt,
      targetFinishAt: targetFinishAt ?? this.targetFinishAt,
      totalDurationSec: totalDurationSec,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      recipeSnapshot: recipeSnapshot,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverAlarmId': serverAlarmId,
        'recipeId': recipeId,
        'recipeTitle': recipeTitle,
        'methodSlug': methodSlug,
        'brewMode': brewMode,
        'coffeeDoseG': coffeeDoseG,
        'waterMl': waterMl,
        'ambientTempC': ambientTempC,
        'dripRateBpm': dripRateBpm,
        'startedAt': startedAt.toIso8601String(),
        'targetFinishAt': targetFinishAt.toIso8601String(),
        'totalDurationSec': totalDurationSec,
        'status': status,
        'snoozeCount': snoozeCount,
        'recipeSnapshot': recipeSnapshot,
      };

  factory ActiveLongBrewBatch.fromJson(Map<String, dynamic> json) {
    return ActiveLongBrewBatch(
      id: json['id']?.toString() ?? '',
      serverAlarmId: json['serverAlarmId']?.toString(),
      recipeId: (json['recipeId'] as num?)?.toInt(),
      recipeTitle: json['recipeTitle']?.toString() ?? 'Cold Brew',
      methodSlug: json['methodSlug']?.toString() ?? 'cold_brew',
      brewMode: json['brewMode']?.toString() ?? 'IMMERSION_FRIDGE',
      coffeeDoseG: (json['coffeeDoseG'] as num?)?.toDouble() ?? 50.0,
      waterMl: (json['waterMl'] as num?)?.toDouble() ?? 500.0,
      ambientTempC: (json['ambientTempC'] as num?)?.toDouble() ?? 4.0,
      dripRateBpm: (json['dripRateBpm'] as num?)?.toInt(),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ??
          DateTime.now(),
      targetFinishAt:
          DateTime.tryParse(json['targetFinishAt']?.toString() ?? '') ??
              DateTime.now().add(const Duration(hours: 12)),
      totalDurationSec: (json['totalDurationSec'] as num?)?.toInt() ?? 43200,
      status: json['status']?.toString() ?? 'ACTIVE',
      snoozeCount: (json['snoozeCount'] as num?)?.toInt() ?? 0,
      recipeSnapshot: json['recipeSnapshot'] is Map<String, dynamic>
          ? json['recipeSnapshot'] as Map<String, dynamic>
          : null,
    );
  }

  static List<ActiveLongBrewBatch> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => ActiveLongBrewBatch.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
