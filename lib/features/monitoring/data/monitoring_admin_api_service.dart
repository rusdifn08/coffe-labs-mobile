import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/monitoring_models.dart';

final monitoringAdminApiProvider = Provider<MonitoringAdminApiService>((ref) {
  return MonitoringAdminApiService(ref.watch(dioClientProvider));
});

class PaginatedAccountsPageDto {
  final List<AccountMonitorSummaryDto> items;
  final int total;
  final int page;
  final int onlineNow;

  const PaginatedAccountsPageDto({
    required this.items,
    required this.total,
    required this.page,
    required this.onlineNow,
  });

  factory PaginatedAccountsPageDto.fromJson(Map<String, dynamic> j) =>
      PaginatedAccountsPageDto(
        items: (j['items'] as List? ?? [])
            .map((e) => AccountMonitorSummaryDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        onlineNow: (j['online_now'] as num?)?.toInt() ?? 0,
      );
}

class MonitoringDashboardFetchResult {
  final PlatformOverviewDto overview;
  final PaginatedAccountsPageDto accountsPage;
  final bool isLegacyFallback;
  final String? fallbackNotice;

  const MonitoringDashboardFetchResult({
    required this.overview,
    required this.accountsPage,
    this.isLegacyFallback = false,
    this.fallbackNotice,
  });
}

class MonitoringAdminApiService {
  final Dio _dio;
  MonitoringAdminApiService(this._dio);

  Future<MonitoringDashboardFetchResult> fetchDashboardData({
    String? search,
    String? tier,
    String? risk,
    bool onlineOnly = false,
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final results = await Future.wait([
        fetchOverview(),
        fetchAccounts(
          search: search,
          tier: tier,
          risk: risk,
          onlineOnly: onlineOnly,
          page: page,
          perPage: perPage,
        ),
      ]);
      return MonitoringDashboardFetchResult(
        overview: results[0] as PlatformOverviewDto,
        accountsPage: results[1] as PaginatedAccountsPageDto,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _fetchLegacyAdminFallback(
          search: search,
          tier: tier,
          onlineOnly: onlineOnly,
        );
      }
      rethrow;
    }
  }

  Future<MonitoringDashboardFetchResult> _fetchLegacyAdminFallback({
    String? search,
    String? tier,
    bool onlineOnly = false,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/admin/users');
    final rawList = res.data?['data'] as List? ?? [];
    final allMapped = rawList.whereType<Map>().map((raw) {
      final u = Map<String, dynamic>.from(raw);
      final rawTier = (u['tier']?.toString() ?? 'trial').toLowerCase();
      final tierLabel = rawTier == 'business'
          ? 'Business'
          : (rawTier == 'pro' ? 'Pro' : 'Trial');
      final status = (u['status']?.toString() ?? 'pending').toLowerCase();
      return AccountMonitorSummaryDto(
        userId: u['id']?.toString() ?? '',
        username: u['username']?.toString() ?? '',
        fullName: u['full_name']?.toString() ?? 'Barista',
        role: u['role']?.toString() ?? 'user',
        accountTier: tierLabel,
        avatarUrl: u['avatar_url']?.toString(),
        isOnline: false,
        lastSeenAt: DateTime.tryParse(u['created_at']?.toString() ?? ''),
        isBrewingNow: false,
        platform: 'mobile',
        todayScreenTimeSec: 0,
        todayAodTimeSec: 0,
        total7dScreenTimeSec: 0,
        total30dScreenTimeSec: 0,
        totalLifetimeScreenTimeSec: 0,
        totalBrewsExecuted: (u['trial_brews_count'] as num?)?.toInt() ?? 0,
        totalRecipesCreated: 0,
        totalSocialPosts: 0,
        healthScore: status == 'approved' ? 65 : 40,
        churnRiskLevel: status == 'approved' ? 'LOW' : 'MEDIUM',
      );
    }).toList();

    final trialCnt =
        allMapped.where((e) => e.accountTier.toLowerCase() == 'trial').length;
    final proCnt =
        allMapped.where((e) => e.accountTier.toLowerCase() == 'pro').length;
    final bizCnt =
        allMapped.where((e) => e.accountTier.toLowerCase() == 'business').length;

    final q = search?.trim().toLowerCase() ?? '';
    final tf = tier?.trim().toLowerCase() ?? '';
    final filtered = allMapped.where((u) {
      if (onlineOnly && !u.isOnline) return false;
      if (tf.isNotEmpty && u.accountTier.toLowerCase() != tf) return false;
      if (q.isNotEmpty &&
          !u.username.toLowerCase().contains(q) &&
          !u.fullName.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();

    return MonitoringDashboardFetchResult(
      overview: PlatformOverviewDto(
        onlineNow: 0,
        totalAccounts: allMapped.length,
        trialAccounts: trialCnt,
        proAccounts: proCnt,
        businessAccounts: bizCnt,
        dauToday: 0,
        wau7d: 0,
        mau30d: allMapped.length,
        stickinessPct: 0,
        avgTodayScreenTimeSec: 0,
        totalBrews7d: 0,
        atRiskHighCount: 0,
        dormantCount: 0,
        featureAdoption: const [],
        cohorts: const [],
        topBrewRecipes: const [],
      ),
      accountsPage: PaginatedAccountsPageDto(
        items: filtered,
        total: filtered.length,
        page: 1,
        onlineNow: 0,
      ),
      isLegacyFallback: true,
      fallbackNotice:
          'Server cloud sedang memakai rilis sebelum modul Telemetry Real-Time (/api/v1/monitoring/* → 404). Menampilkan daftar akun terdaftar dari /api/admin/users.',
    );
  }

  Future<PlatformOverviewDto> fetchOverview() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/monitoring/overview',
      options: Options(extra: const {'silentTelemetry': true}),
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return PlatformOverviewDto.fromJson(data);
  }

  Future<PaginatedAccountsPageDto> fetchAccounts({
    String? search,
    String? tier,
    String? risk,
    bool onlineOnly = false,
    int page = 1,
    int perPage = 25,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/monitoring/accounts',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
        if (tier != null && tier.isNotEmpty) 'tier': tier,
        if (risk != null && risk.isNotEmpty) 'risk': risk,
        'online_only': onlineOnly,
        'page': page,
        'per_page': perPage,
      },
      options: Options(extra: const {'silentTelemetry': true}),
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return PaginatedAccountsPageDto.fromJson(data);
  }

  Future<Account360DossierDto> fetchAccountDossier(
    String userId, {
    AccountMonitorSummaryDto? fallbackAccount,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/monitoring/accounts/$userId/dossier',
        options: Options(extra: const {'silentTelemetry': true}),
      );
      final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
      return Account360DossierDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && fallbackAccount != null) {
        return Account360DossierDto(
          account: fallbackAccount,
          totalSessions30d: 0,
          totalAiScans: 0,
          featureBreakdown: const [],
          recentBrewExperiments: const [],
        );
      }
      rethrow;
    }
  }
}
