import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../controllers/system_control_sync_controller.dart';
import '../../data/admin_control_api_service.dart';
import '../../models/admin_control_models.dart';
import '../widgets/admin_audit_log_tab_view.dart';
import '../widgets/admin_feature_lock_editor_sheet.dart';
import '../widgets/admin_pricing_tab_view.dart';

/// Pusat Kendali Admin Real-Time di Aplikasi Mobile (Khusus Role `ADMIN`):
/// - Tab 1: Lock/Unlock Setiap Kartu Barista Toolkit (`Maintenance`, `Coming Soon`, `Updated`)
/// - Tab 2: Dynamic Pricing Paket Pro & Business Real-Time
/// - Tab 3: Immutable Audit Log Perubahan Admin
class AdminControlPanelScreen extends ConsumerStatefulWidget {
  const AdminControlPanelScreen({super.key});

  @override
  ConsumerState<AdminControlPanelScreen> createState() =>
      _AdminControlPanelScreenState();
}

class _AdminControlPanelScreenState
    extends ConsumerState<AdminControlPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _sectionFilter = 'ALL';
  List<AdminControlAuditLogItem> _auditLogs = const [];
  bool _loadingAudit = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.index == 2 && _auditLogs.isEmpty) {
        _loadAuditLogs();
      }
    });
    Future.microtask(() {
      ref.read(systemControlProvider.notifier).refreshAsAdmin();
      _loadAuditLogs();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _loadingAudit = true);
    try {
      final logs =
          await ref.read(adminControlApiProvider).fetchAuditLogs(limit: 50);
      if (mounted) {
        setState(() => _auditLogs = logs);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAudit = false);
    }
  }

  Future<void> _quickToggleLock(FeatureControlItem item, bool nextLocked) async {
    final nextStatus = nextLocked
        ? (item.lockStatus == FeatureLockStatus.unlocked
            ? FeatureLockStatus.maintenance
            : item.lockStatus)
        : FeatureLockStatus.unlocked;
    final ok = await ref.read(systemControlProvider.notifier).updateFeatureLock(
          featureKey: item.featureKey,
          isLocked: nextLocked,
          lockStatus: nextStatus,
          customBadgeLabel: item.customBadgeLabel,
          lockTitle: item.lockTitle,
          lockMessage: item.lockMessage,
          estimatedUnlockAt: nextLocked ? item.estimatedUnlockAt : null,
          allowAdminBypass: item.allowAdminBypass,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok
            ? (nextLocked ? nextStatus.accentTextColor : const Color(0xFF047857))
            : const Color(0xFFDC2626),
        content: Text(
          ok
              ? '${item.displayName} ${nextLocked ? "dikunci (${nextStatus.defaultBadgeLabel})" : "dibuka kembali"} secara real-time!'
              : (ref.read(systemControlProvider).errorMessage ??
                  'Gagal memperbarui status kunci.'),
        ),
      ),
    );
  }

  Future<void> _openFeatureEditor(FeatureControlItem item) async {
    final result =
        await AdminFeatureLockEditorSheet.show(context, item: item);
    if (result == null || !mounted) return;
    final ok = await ref.read(systemControlProvider.notifier).updateFeatureLock(
          featureKey: item.featureKey,
          isLocked: result.isLocked,
          lockStatus: result.lockStatus,
          customBadgeLabel: result.customBadgeLabel,
          lockTitle: result.lockTitle,
          lockMessage: result.lockMessage,
          estimatedUnlockAt: result.estimatedUnlockAt,
          allowAdminBypass: result.allowAdminBypass,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppTheme.primaryBrown : const Color(0xFFDC2626),
        content: Text(
          ok
              ? '${item.displayName} berhasil disinkronkan real-time ke semua akun!'
              : (ref.read(systemControlProvider).errorMessage ??
                  'Gagal menyimpan perubahan.'),
        ),
      ),
    );
  }

  Future<void> _confirmBulkAction(bool shouldLock) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          shouldLock ? 'Lock Semua Kartu (Maintenance)?' : 'Unlock Semua Kartu?',
        ),
        content: Text(
          shouldLock
              ? 'Semua kartu Barista Toolkit akan langsung terkunci mode MAINTENANCE di seluruh akun user non-Admin.'
              : 'Semua kartu Barista Toolkit akan langsung dibuka kembali untuk seluruh pengguna.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  shouldLock ? const Color(0xFFDC2626) : const Color(0xFF047857),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(shouldLock ? 'Lock Semua' : 'Unlock Semua'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref.read(systemControlProvider.notifier).bulkLockAll(
          isLocked: shouldLock,
          lockStatus: shouldLock
              ? FeatureLockStatus.maintenance
              : FeatureLockStatus.unlocked,
          lockTitle: shouldLock ? 'Maintenance Sistem Terjadwal' : '',
          lockMessage: shouldLock
              ? 'Tim Coffee Labs sedang melakukan pemeliharaan sistem menyeluruh.'
              : '',
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppTheme.primaryBrown : const Color(0xFFDC2626),
        content: Text(
          ok
              ? (shouldLock
                  ? 'Semua kartu berhasil di-LOCK real-time!'
                  : 'Semua kartu berhasil di-UNLOCK real-time!')
              : 'Gagal mengeksekusi aksi massal.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(systemControlProvider);
    final snap = state.snapshot;
    final lockedCount = snap.features.where((f) => f.isLocked).length;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1E17),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Control Panel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${state.isWsConnected ? "🟢 Live WS" : "🟠 REST Sync"} • v${snap.configVersion} • ${snap.connectedClients} Perangkat',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFFE7C79E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan Sekarang',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(systemControlProvider.notifier).refreshAsAdmin();
              _loadAuditLogs();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
          tabs: [
            Tab(text: 'Lock Kartu ($lockedCount)'),
            const Tab(text: 'Harga Pro/Bisnis'),
            const Tab(text: 'Audit Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildFeatureLocksTab(snap.features, state.isMutating),
          AdminPricingTabView(
            plans: snap.plans,
            isMutating: state.isMutating,
          ),
          AdminAuditLogTabView(
            logs: _auditLogs,
            isLoading: _loadingAudit,
            onRefresh: _loadAuditLogs,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureLocksTab(
    List<FeatureControlItem> allFeatures,
    bool isMutating,
  ) {
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = allFeatures.where((f) {
      if (_sectionFilter != 'ALL' && f.groupSection != _sectionFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return f.displayName.toLowerCase().contains(q) ||
          f.featureKey.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // Panic Bulk Actions
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isMutating ? null : () => _confirmBulkAction(true),
                icon: const Icon(Icons.warning_amber_rounded, size: 16),
                label: const Text(
                  'Lock Semua',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isMutating ? null : () => _confirmBulkAction(false),
                icon: const Icon(CupertinoIcons.lock_open_fill, size: 15),
                label: const Text(
                  'Unlock Semua',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Search Bar
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari kartu Barista Toolkit...',
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderWarm),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Section Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _sectionChip('ALL', 'Semua'),
              const SizedBox(width: 6),
              _sectionChip('LEARNING_BREW', 'Learning Brew'),
              const SizedBox(width: 6),
              _sectionChip('EKOSISTEM_KOMUNITAS', 'Ekosistem'),
              const SizedBox(width: 6),
              _sectionChip('LAB_EKSTRAKSI_AI', 'Lab AI'),
              const SizedBox(width: 6),
              _sectionChip('SAINS_KOPI', 'Sains'),
              const SizedBox(width: 6),
              _sectionChip('MONETISASI_BISNIS', 'Bisnis'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Feature Lock Cards List
        ...filtered.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildFeatureControlRowCard(item, isMutating),
          ),
        ),
      ],
    );
  }

  Widget _sectionChip(String key, String label) {
    final sel = _sectionFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: sel ? Colors.white : AppTheme.textDark,
        ),
      ),
      selected: sel,
      selectedColor: AppTheme.primaryBrown,
      backgroundColor: Colors.white,
      onSelected: (_) => setState(() => _sectionFilter = key),
    );
  }

  Widget _buildFeatureControlRowCard(FeatureControlItem item, bool isMutating) {
    final status = item.lockStatus;
    final accent = status.accentTextColor;
    final pillBg = status.pillBackgroundColor;
    final borderColor = item.isLocked ? status.cardBorderColor : AppTheme.borderWarm;

    return Container(
      decoration: BoxDecoration(
        color: item.isLocked
            ? pillBg.withValues(alpha: 0.45)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: item.isLocked ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openFeatureEditor(item),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.isLocked
                      ? pillBg
                      : AppTheme.primaryBrown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.isLocked ? status.statusIcon : CupertinoIcons.lock_open_fill,
                  size: 19,
                  color: item.isLocked ? accent : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: item.isLocked ? pillBg : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: item.isLocked
                                  ? borderColor
                                  : const Color(0xFF86EFAC),
                            ),
                          ),
                          child: Text(
                            item.isLocked ? item.effectiveBadgeLabel : 'ACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: item.isLocked
                                  ? accent
                                  : const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.isLocked
                          ? item.effectiveCardSubtitle
                          : 'Ketuk untuk pilih Maintenance / Coming Soon / Updated',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: item.isLocked ? FontWeight.w700 : FontWeight.w500,
                        color: item.isLocked ? accent : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Switch.adaptive(
                key: Key('admin_lock_switch_${item.featureKey}'),
                value: item.isLocked,
                activeThumbColor: accent,
                onChanged: isMutating
                    ? null
                    : (val) => _quickToggleLock(item, val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
