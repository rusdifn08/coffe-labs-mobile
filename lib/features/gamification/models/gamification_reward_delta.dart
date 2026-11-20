class XpBreakdownItem {
  final String label;
  final int xp;

  const XpBreakdownItem({required this.label, required this.xp});

  factory XpBreakdownItem.fromJson(Map<String, dynamic> json) {
    return XpBreakdownItem(
      label: json['label']?.toString() ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
    );
  }
}

class GamificationRewardDelta {
  final String sourceKind;
  final String sourceLabel;
  final int xpBefore;
  final int xpGained;
  final int xpAfter;
  final int levelBefore;
  final int levelAfter;
  final bool didLevelUp;
  final String rankBefore;
  final String rankAfter;
  final double progressRatioBefore;
  final double progressRatioAfter;
  final String? methodId;
  final int? methodNewCompletedCount;
  final int newStreakDays;
  final List<XpBreakdownItem> breakdownItems;

  const GamificationRewardDelta({
    required this.sourceKind,
    required this.sourceLabel,
    required this.xpBefore,
    required this.xpGained,
    required this.xpAfter,
    required this.levelBefore,
    required this.levelAfter,
    required this.didLevelUp,
    required this.rankBefore,
    required this.rankAfter,
    required this.progressRatioBefore,
    required this.progressRatioAfter,
    this.methodId,
    this.methodNewCompletedCount,
    this.newStreakDays = 1,
    this.breakdownItems = const [],
  });

  factory GamificationRewardDelta.fromJson(Map<String, dynamic> json) {
    final rawItems = json['breakdown_items'] as List<dynamic>? ?? const [];
    return GamificationRewardDelta(
      sourceKind: json['source_kind']?.toString() ?? 'VERIFIED_BREW',
      sourceLabel: json['source_label']?.toString() ?? 'Seduhan Selesai!',
      xpBefore: (json['xp_before'] as num?)?.toInt() ?? 0,
      xpGained: (json['xp_gained'] as num?)?.toInt() ?? 0,
      xpAfter: (json['xp_after'] as num?)?.toInt() ?? 0,
      levelBefore: (json['level_before'] as num?)?.toInt() ?? 1,
      levelAfter: (json['level_after'] as num?)?.toInt() ?? 1,
      didLevelUp: json['did_level_up'] == true,
      rankBefore: json['rank_before']?.toString() ?? 'Home Brewer',
      rankAfter: json['rank_after']?.toString() ?? 'Home Brewer',
      progressRatioBefore:
          (json['progress_ratio_before'] as num?)?.toDouble() ?? 0.0,
      progressRatioAfter:
          (json['progress_ratio_after'] as num?)?.toDouble() ?? 0.0,
      methodId: json['method_id']?.toString(),
      methodNewCompletedCount:
          (json['method_new_completed_count'] as num?)?.toInt(),
      newStreakDays: (json['new_streak_days'] as num?)?.toInt() ?? 1,
      breakdownItems: rawItems
          .whereType<Map<String, dynamic>>()
          .map(XpBreakdownItem.fromJson)
          .toList(),
    );
  }
}
