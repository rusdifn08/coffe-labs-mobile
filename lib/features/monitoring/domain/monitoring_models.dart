class TelemetryEventItem {
  final String eventId;
  final String sessionId;
  final String eventType;
  final String featureBucket;
  final String routeName;
  final int durationSec;
  final bool isAodMode;
  final Map<String, dynamic> metadataJson;
  final DateTime recordedAt;

  const TelemetryEventItem({
    required this.eventId,
    required this.sessionId,
    required this.eventType,
    required this.featureBucket,
    required this.routeName,
    required this.durationSec,
    this.isAodMode = false,
    this.metadataJson = const {},
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'session_id': sessionId,
        'event_type': eventType,
        'feature_bucket': featureBucket,
        'route_name': routeName,
        'duration_sec': durationSec,
        'is_aod_mode': isAodMode,
        'metadata_json': metadataJson,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
      };

  factory TelemetryEventItem.fromJson(Map<String, dynamic> json) {
    return TelemetryEventItem(
      eventId: json['event_id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? 'SCREEN_VIEW',
      featureBucket: json['feature_bucket']?.toString() ?? 'general',
      routeName: json['route_name']?.toString() ?? '/',
      durationSec: (json['duration_sec'] as num?)?.toInt() ?? 0,
      isAodMode: json['is_aod_mode'] == true,
      metadataJson: (json['metadata_json'] as Map?)?.cast<String, dynamic>() ?? const {},
      recordedAt: DateTime.tryParse(json['recorded_at']?.toString() ?? '') ?? DateTime.now().toUtc(),
    );
  }
}

class FeatureAdoptionDto {
  final String featureKey;
  final String label;
  final int activeUsers7d;
  final double adoptionPercent;
  final int totalMinutes7d;

  const FeatureAdoptionDto({
    required this.featureKey,
    required this.label,
    required this.activeUsers7d,
    required this.adoptionPercent,
    required this.totalMinutes7d,
  });

  factory FeatureAdoptionDto.fromJson(Map<String, dynamic> j) => FeatureAdoptionDto(
        featureKey: j['feature_key']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        activeUsers7d: (j['active_users_7d'] as num?)?.toInt() ?? 0,
        adoptionPercent: (j['adoption_percent'] as num?)?.toDouble() ?? 0.0,
        totalMinutes7d: (j['total_minutes_7d'] as num?)?.toInt() ?? 0,
      );
}

class RetentionCohortDto {
  final String cohortDate;
  final int cohortSize;
  final double? d1Pct;
  final double? d3Pct;
  final double? d7Pct;
  final double? d14Pct;
  final double? d30Pct;

  const RetentionCohortDto({
    required this.cohortDate,
    required this.cohortSize,
    this.d1Pct,
    this.d3Pct,
    this.d7Pct,
    this.d14Pct,
    this.d30Pct,
  });

  factory RetentionCohortDto.fromJson(Map<String, dynamic> j) => RetentionCohortDto(
        cohortDate: j['cohort_date']?.toString() ?? '',
        cohortSize: (j['cohort_size'] as num?)?.toInt() ?? 0,
        d1Pct: (j['d1_pct'] as num?)?.toDouble(),
        d3Pct: (j['d3_pct'] as num?)?.toDouble(),
        d7Pct: (j['d7_pct'] as num?)?.toDouble(),
        d14Pct: (j['d14_pct'] as num?)?.toDouble(),
        d30Pct: (j['d30_pct'] as num?)?.toDouble(),
      );
}

class TopBrewRecipeDto {
  final String recipeTitle;
  final String brewMethod;
  final int totalRuns;
  final int completedRuns;
  final double completionRatePct;

  const TopBrewRecipeDto({
    required this.recipeTitle,
    required this.brewMethod,
    required this.totalRuns,
    required this.completedRuns,
    required this.completionRatePct,
  });

  factory TopBrewRecipeDto.fromJson(Map<String, dynamic> j) => TopBrewRecipeDto(
        recipeTitle: j['recipe_title']?.toString() ?? 'V60',
        brewMethod: j['brew_method']?.toString() ?? 'V60',
        totalRuns: (j['total_runs'] as num?)?.toInt() ?? 0,
        completedRuns: (j['completed_runs'] as num?)?.toInt() ?? 0,
        completionRatePct: (j['completion_rate_pct'] as num?)?.toDouble() ?? 0.0,
      );
}

class PlatformOverviewDto {
  final int onlineNow;
  final int totalAccounts;
  final int trialAccounts;
  final int proAccounts;
  final int businessAccounts;
  final int dauToday;
  final int wau7d;
  final int mau30d;
  final double stickinessPct;
  final int avgTodayScreenTimeSec;
  final int totalBrews7d;
  final int atRiskHighCount;
  final int dormantCount;
  final List<FeatureAdoptionDto> featureAdoption;
  final List<RetentionCohortDto> cohorts;
  final List<TopBrewRecipeDto> topBrewRecipes;

  const PlatformOverviewDto({
    required this.onlineNow,
    required this.totalAccounts,
    required this.trialAccounts,
    required this.proAccounts,
    required this.businessAccounts,
    required this.dauToday,
    required this.wau7d,
    required this.mau30d,
    required this.stickinessPct,
    required this.avgTodayScreenTimeSec,
    required this.totalBrews7d,
    required this.atRiskHighCount,
    required this.dormantCount,
    required this.featureAdoption,
    required this.cohorts,
    required this.topBrewRecipes,
  });

  factory PlatformOverviewDto.fromJson(Map<String, dynamic> j) => PlatformOverviewDto(
        onlineNow: (j['online_now'] as num?)?.toInt() ?? 0,
        totalAccounts: (j['total_accounts'] as num?)?.toInt() ?? 0,
        trialAccounts: (j['trial_accounts'] as num?)?.toInt() ?? 0,
        proAccounts: (j['pro_accounts'] as num?)?.toInt() ?? 0,
        businessAccounts: (j['business_accounts'] as num?)?.toInt() ?? 0,
        dauToday: (j['dau_today'] as num?)?.toInt() ?? 0,
        wau7d: (j['wau_7d'] as num?)?.toInt() ?? 0,
        mau30d: (j['mau_30d'] as num?)?.toInt() ?? 0,
        stickinessPct: (j['stickiness_pct'] as num?)?.toDouble() ?? 0.0,
        avgTodayScreenTimeSec: (j['avg_today_screen_time_sec'] as num?)?.toInt() ?? 0,
        totalBrews7d: (j['total_brews_7d'] as num?)?.toInt() ?? 0,
        atRiskHighCount: (j['at_risk_high_count'] as num?)?.toInt() ?? 0,
        dormantCount: (j['dormant_count'] as num?)?.toInt() ?? 0,
        featureAdoption: (j['feature_adoption'] as List? ?? [])
            .map((e) => FeatureAdoptionDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        cohorts: (j['cohorts'] as List? ?? [])
            .map((e) => RetentionCohortDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        topBrewRecipes: (j['top_brew_recipes'] as List? ?? [])
            .map((e) => TopBrewRecipeDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class AccountMonitorSummaryDto {
  final String userId;
  final String username;
  final String fullName;
  final String role;
  final String accountTier;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String? currentActiveRoute;
  final String? currentFeatureBucket;
  final bool isBrewingNow;
  final String platform;
  final int todayScreenTimeSec;
  final int todayAodTimeSec;
  final int total7dScreenTimeSec;
  final int total30dScreenTimeSec;
  final int totalLifetimeScreenTimeSec;
  final int totalBrewsExecuted;
  final int totalRecipesCreated;
  final int totalSocialPosts;
  final String? lastBrewedRecipeTitle;
  final int healthScore;
  final String churnRiskLevel;

  const AccountMonitorSummaryDto({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.accountTier,
    this.avatarUrl,
    required this.isOnline,
    this.lastSeenAt,
    this.currentActiveRoute,
    this.currentFeatureBucket,
    required this.isBrewingNow,
    required this.platform,
    required this.todayScreenTimeSec,
    required this.todayAodTimeSec,
    required this.total7dScreenTimeSec,
    required this.total30dScreenTimeSec,
    required this.totalLifetimeScreenTimeSec,
    required this.totalBrewsExecuted,
    required this.totalRecipesCreated,
    required this.totalSocialPosts,
    this.lastBrewedRecipeTitle,
    required this.healthScore,
    required this.churnRiskLevel,
  });

  factory AccountMonitorSummaryDto.fromJson(Map<String, dynamic> j) => AccountMonitorSummaryDto(
        userId: j['user_id']?.toString() ?? '',
        username: j['username']?.toString() ?? '',
        fullName: j['full_name']?.toString() ?? '',
        role: j['role']?.toString() ?? 'user',
        accountTier: j['account_tier']?.toString() ?? 'Trial',
        avatarUrl: j['avatar_url']?.toString(),
        isOnline: j['is_online'] == true,
        lastSeenAt: DateTime.tryParse(j['last_seen_at']?.toString() ?? ''),
        currentActiveRoute: j['current_active_route']?.toString(),
        currentFeatureBucket: j['current_feature_bucket']?.toString(),
        isBrewingNow: j['is_brewing_now'] == true,
        platform: j['platform']?.toString() ?? 'android',
        todayScreenTimeSec: (j['today_screen_time_sec'] as num?)?.toInt() ?? 0,
        todayAodTimeSec: (j['today_aod_time_sec'] as num?)?.toInt() ?? 0,
        total7dScreenTimeSec: (j['total_7d_screen_time_sec'] as num?)?.toInt() ?? 0,
        total30dScreenTimeSec: (j['total_30d_screen_time_sec'] as num?)?.toInt() ?? 0,
        totalLifetimeScreenTimeSec: (j['total_lifetime_screen_time_sec'] as num?)?.toInt() ?? 0,
        totalBrewsExecuted: (j['total_brews_executed'] as num?)?.toInt() ?? 0,
        totalRecipesCreated: (j['total_recipes_created'] as num?)?.toInt() ?? 0,
        totalSocialPosts: (j['total_social_posts'] as num?)?.toInt() ?? 0,
        lastBrewedRecipeTitle: j['last_brewed_recipe_title']?.toString(),
        healthScore: (j['health_score'] as num?)?.toInt() ?? 50,
        churnRiskLevel: j['churn_risk_level']?.toString() ?? 'MEDIUM',
      );
}

class FeatureBreakdownDto {
  final String feature;
  final String label;
  final int seconds;
  final double sharePercent;

  const FeatureBreakdownDto({
    required this.feature,
    required this.label,
    required this.seconds,
    required this.sharePercent,
  });

  factory FeatureBreakdownDto.fromJson(Map<String, dynamic> j) => FeatureBreakdownDto(
        feature: j['feature']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        seconds: (j['seconds'] as num?)?.toInt() ?? 0,
        sharePercent: (j['share_percent'] as num?)?.toDouble() ?? 0.0,
      );
}

class BrewExperimentDto {
  final String recipeTitle;
  final String brewMethod;
  final int brewDurationSec;
  final bool completed;
  final DateTime createdAt;

  const BrewExperimentDto({
    required this.recipeTitle,
    required this.brewMethod,
    required this.brewDurationSec,
    required this.completed,
    required this.createdAt,
  });

  factory BrewExperimentDto.fromJson(Map<String, dynamic> j) => BrewExperimentDto(
        recipeTitle: j['recipe_title']?.toString() ?? '',
        brewMethod: j['brew_method']?.toString() ?? 'V60',
        brewDurationSec: (j['brew_duration_sec'] as num?)?.toInt() ?? 0,
        completed: j['completed'] == true,
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
}

class Account360DossierDto {
  final AccountMonitorSummaryDto account;
  final int totalSessions30d;
  final int totalAiScans;
  final List<FeatureBreakdownDto> featureBreakdown;
  final List<BrewExperimentDto> recentBrewExperiments;

  const Account360DossierDto({
    required this.account,
    required this.totalSessions30d,
    required this.totalAiScans,
    required this.featureBreakdown,
    required this.recentBrewExperiments,
  });

  factory Account360DossierDto.fromJson(Map<String, dynamic> j) => Account360DossierDto(
        account: AccountMonitorSummaryDto.fromJson(
          Map<String, dynamic>.from(j['account'] as Map),
        ),
        totalSessions30d: (j['total_sessions_30d'] as num?)?.toInt() ?? 0,
        totalAiScans: (j['total_ai_scans'] as num?)?.toInt() ?? 0,
        featureBreakdown: (j['feature_breakdown'] as List? ?? [])
            .map((e) => FeatureBreakdownDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        recentBrewExperiments: (j['recent_brew_experiments'] as List? ?? [])
            .map((e) => BrewExperimentDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
