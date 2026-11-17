import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../theme/app_theme.dart';
import '../../data/monitoring_admin_api_service.dart';
import '../../data/telemetry_batch_outbox_service.dart';
import '../../domain/monitoring_models.dart';
import '../widgets/account_360_dossier_sheet.dart';

class PlatformMonitoringDashboardScreen extends ConsumerStatefulWidget {
  const PlatformMonitoringDashboardScreen({super.key});

  @override
  ConsumerState<PlatformMonitoringDashboardScreen> createState() =>
      _PlatformMonitoringDashboardScreenState();
}

class _PlatformMonitoringDashboardScreenState
    extends ConsumerState<PlatformMonitoringDashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _pollTimer;
  PlatformOverviewDto? _overview;
  List<AccountMonitorSummaryDto> _accounts = [];
  bool _loading = true;
  bool _onlineOnly = false;
  bool _isLegacyFallback = false;
  String? _tierFilter;
  String? _error;
  String? _notice;

  @override
  void initState() {
    super.initState();
    TelemetryBatchOutboxService.instance.resetEndpointCooldown();
    unawaited(_loadAll());
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && !_isLegacyFallback) unawaited(_loadAll(silent: true));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll({bool silent = false}) async {
    if (!silent) {
      TelemetryBatchOutboxService.instance.resetEndpointCooldown();
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final api = ref.read(monitoringAdminApiProvider);
      final data = await api.fetchDashboardData(
        search: _searchCtrl.text,
        tier: _tierFilter,
        onlineOnly: _onlineOnly,
        perPage: 30,
      );
      if (!mounted) return;
      setState(() {
        _overview = data.overview;
        _accounts = data.accountsPage.items;
        _isLegacyFallback = data.isLegacyFallback;
        _notice = data.fallbackNotice;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final readable = e is DioException
          ? GlobalErrorAndLoggingInterceptor.mapDioException(e).message
          : e.toString();
      setState(() {
        _error = readable;
        _loading = false;
      });
    }
  }

  Future<void> _openDossier(AccountMonitorSummaryDto summary) async {
    try {
      final dossier = await ref
          .read(monitoringAdminApiProvider)
          .fetchAccountDossier(summary.userId, fallbackAccount: summary);
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Account360DossierSheet(dossier: dossier),
      );
    } catch (e) {
      if (!mounted) return;
      final readable = e is DioException
          ? GlobalErrorAndLoggingInterceptor.mapDioException(e).message
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat dossier: $readable')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ov = _overview;
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Monitoring Pengguna Real-Time'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.person_2_fill, color: AppTheme.primaryBrown),
            tooltip: 'Manajemen Users',
            onPressed: () => context.push(AppRoutes.adminApproval),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () => _loadAll(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadAll(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _buildAdminNavChips(),
            const SizedBox(height: 12),
            if (_notice != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.info_circle_fill, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _notice!,
                        style: const TextStyle(color: Color(0xFF92400E), fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade800, fontSize: 12)),
              ),
            if (ov != null) _buildKpiGrid(ov),
            if (ov != null && ov.featureAdoption.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAdoptionCard(ov),
            ],
            const SizedBox(height: 16),
            _buildFilterBar(),
            const SizedBox(height: 10),
            if (_loading && _accounts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_accounts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Belum ada akun cocok dengan filter.', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              ..._accounts.map(_buildAccountCard),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminNavChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _navChip('● User Online', CupertinoIcons.dot_radiowaves_left_right, active: true, onTap: () {}),
          const SizedBox(width: 8),
          _navChip('Manajemen Users', CupertinoIcons.person_2_fill, onTap: () => context.push(AppRoutes.adminApproval)),
          const SizedBox(width: 8),
          _navChip('Pusat Feedback', CupertinoIcons.chat_bubble_2_fill, onTap: () => context.push(AppRoutes.adminFeedback)),
          const SizedBox(width: 8),
          _navChip('Version & OTA', CupertinoIcons.bolt_badge_a_fill, onTap: () => context.push(AppRoutes.adminVersion)),
        ],
      ),
    );
  }

  Widget _navChip(String label, IconData icon, {bool active = false, required VoidCallback onTap}) {
    return Material(
      color: active ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: active ? null : Border.all(color: AppTheme.borderWarm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.5, color: active ? Colors.white : AppTheme.primaryBrown),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(PlatformOverviewDto ov) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.05,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _kpiTile('Online Live', '${ov.onlineNow} / ${ov.totalAccounts}', CupertinoIcons.dot_radiowaves_left_right, Colors.green),
        _kpiTile('DAU / WAU / MAU', '${ov.dauToday} / ${ov.wau7d} / ${ov.mau30d}', CupertinoIcons.chart_pie_fill, AppTheme.primaryBrown),
        _kpiTile('Avg Screen Time', Account360DossierSheet.formatDuration(ov.avgTodayScreenTimeSec), CupertinoIcons.time_solid, Colors.blueGrey),
        _kpiTile('Stickiness • Risk', '${ov.stickinessPct.toStringAsFixed(1)}% • ${ov.atRiskHighCount} Risk', CupertinoIcons.shield_lefthalf_fill, Colors.orange.shade800),
      ],
    );
  }

  Widget _kpiTile(String label, String val, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accent),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAdoptionCard(PlatformOverviewDto ov) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adopsi Fitur 7 Hari (RoaringBitmap)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 10),
          ...ov.featureAdoption.take(5).map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(f.label, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: (f.adoptionPercent / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppTheme.dividerColor,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${f.adoptionPercent.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => unawaited(_loadAll(silent: true)),
          decoration: InputDecoration(
            hintText: 'Cari @username atau nama barista...',
            prefixIcon: const Icon(CupertinoIcons.search, size: 18),
            filled: true,
            fillColor: AppTheme.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.dividerColor)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Online Live'),
                selected: _onlineOnly,
                onSelected: (v) {
                  setState(() => _onlineOnly = v);
                  unawaited(_loadAll());
                },
              ),
              DropdownButton<String?>(
                value: _tierFilter,
                hint: const Text('Tier'),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Semua Tier')),
                  DropdownMenuItem(value: 'trial', child: Text('Trial')),
                  DropdownMenuItem(value: 'pro', child: Text('Pro')),
                  DropdownMenuItem(value: 'business', child: Text('Business')),
                ],
                onChanged: (v) {
                  setState(() => _tierFilter = v);
                  unawaited(_loadAll());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(AccountMonitorSummaryDto u) {
    final screenToday = Account360DossierSheet.formatDuration(u.todayScreenTimeSec);
    return Card(
      color: AppTheme.surfaceWhite,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.dividerColor),
      ),
      child: ListTile(
        onTap: () => _openDossier(u),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
              child: Text(u.username.isNotEmpty ? u.username[0].toUpperCase() : '?'),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: u.isOnline ? Colors.green : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text('@${u.username} • ${u.accountTier}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        subtitle: Text(
          'Hari ini: $screenToday • ☕ ${u.totalBrewsExecuted} seduh • Health ${u.healthScore}',
          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
        ),
        trailing: const Icon(CupertinoIcons.chevron_forward, size: 16),
      ),
    );
  }
}
