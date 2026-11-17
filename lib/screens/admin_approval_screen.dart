import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/admin/widgets/admin_user_card.dart';
import '../features/admin/widgets/admin_user_stats_card.dart';
import '../features/monitoring/presentation/screens/platform_monitoring_dashboard_screen.dart';
import '../models/admin_user_stats.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'admin_trial_control_screen.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AuthUser> _users = [];
  AdminUserStats _stats = AdminUserStats.empty();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final listFuture = AuthService.getAdminUsers();
      final statsFuture = AuthService.getAdminUserStats();
      final results = await Future.wait([listFuture, statsFuture]);

      if (!mounted) return;
      setState(() {
        _users = results[0] as List<AuthUser>;
        _stats = results[1] as AdminUserStats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data pengguna: $e';
        _isLoading = false;
      });
    }
  }

  bool _isNewRegistration(AuthUser user) {
    if (user.status == 'pending') return true;
    if (user.createdAt != null) {
      try {
        final created = DateTime.parse(user.createdAt!);
        return DateTime.now().difference(created).inDays <= 7;
      } catch (_) {}
    }
    return false;
  }

  Future<void> _handleAccept(AuthUser user) async {
    final success = await AuthService.acceptUser(user.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Akun '${user.username}' berhasil diaktifkan!"),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    }
  }

  Future<void> _handleDecline(AuthUser user) async {
    final success = await AuthService.declineUser(user.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Akun '${user.username}' telah dinonaktifkan."),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      _loadData();
    }
  }

  Future<void> _handleDelete(AuthUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Yakin ingin menghapus permanen pengguna '${user.username}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await AuthService.deleteUser(user.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pengguna '${user.username}' berhasil dihapus."),
          backgroundColor: Colors.brown,
        ),
      );
      _loadData();
    }
  }

  Future<void> _handleChangeTier(AuthUser user) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Atur Akses & Tier @${user.username}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih skema akses atau aktifkan Trial 7 Hari Full Non-Bisnis khusus akun ini.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(CupertinoIcons.sparkles, color: Color(0xFF15803D)),
                title: const Text('Trial 7 Hari Full Access (Non-Bisnis)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Buka semua resep, Dial-In, Scanner & Toolkit selama 7 hari; Bisnis POS tetap terkunci'),
                onTap: () => Navigator.pop(ctx, 'trial_7d'),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.lock_shield, color: AppTheme.primaryBrown),
                title: const Text('Trial Terbatas (Strict Default)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Ikuti kebijakan trial terbatas standar (10 resep kanonik)'),
                onTap: () => Navigator.pop(ctx, 'trial'),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.star_circle_fill, color: Colors.amber),
                title: const Text('Coffee Labs Pro', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Akses Brewer Penuh Permanen (Non-Bisnis)'),
                onTap: () => Navigator.pop(ctx, 'pro'),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.briefcase_fill, color: Colors.deepOrange),
                title: const Text('Coffee Labs Business', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Buka semua fitur termasuk Kasir POS & OLED Kiosk'),
                onTap: () => Navigator.pop(ctx, 'business'),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final ok = await AuthService.updateUserTier(
      user.id,
      choice,
      trialDays: choice == 'trial_7d' ? 7 : null,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Akses '@${user.username}' diperbarui menjadi $choice"
              : "Gagal mengubah tier '@${user.username}'.",
        ),
        backgroundColor: ok ? const Color(0xFF2E7D32) : Colors.redAccent,
      ),
    );
    if (ok) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final newRegistrations = _users.where(_isNewRegistration).toList();
    final allUsers = _users;
    final declinedUsers = _users.where((u) => u.status == 'declined').toList();
    final activeUsers = _users.where((u) => u.status == 'approved').toList();

    final totalCount = _stats.totalUsers > 0 ? _stats.totalUsers : _users.length;
    final newCount = _stats.newRegistrations7d > 0 ? _stats.newRegistrations7d : newRegistrations.length;
    final activeCount = _stats.activeUsers > 0 ? _stats.activeUsers : activeUsers.length;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          'Manajemen Pengguna',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown),
            tooltip: 'Kontrol Trial 7 Hari Non-Bisnis',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminTrialControlScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.chart_bar_alt_fill, color: AppTheme.primaryBrown),
            tooltip: 'Monitoring User Online',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlatformMonitoringDashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            tooltip: 'Segarkan Data',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBrown,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Baru',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (newRegistrations.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${newRegistrations.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Text(
                'Semua (${allUsers.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tab(
              child: Text(
                'Nonaktif (${declinedUsers.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(color: AppTheme.textDark)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBrown,
                  onRefresh: _loadData,
                  child: Column(
                    children: [
                      AdminUserStatsCard(
                        totalUsers: totalCount,
                        newRegistrationsCount: newCount,
                        activeUsers: activeCount,
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(newRegistrations, isNotificationTab: true),
                            _buildList(allUsers),
                            _buildList(declinedUsers),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildList(List<AuthUser> users, {bool isNotificationTab = false}) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNotificationTab ? CupertinoIcons.bell_slash : CupertinoIcons.person_3,
              size: 50,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isNotificationTab
                  ? 'Belum ada notifikasi pendaftaran baru.'
                  : 'Tidak ada data pengguna di tab ini.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isNew = _isNewRegistration(user);

        return AdminUserCard(
          user: user,
          isNewRegistration: isNotificationTab || isNew,
          onAccept: _handleAccept,
          onDecline: _handleDecline,
          onDelete: _handleDelete,
          onChangeTier: _handleChangeTier,
        );
      },
    );
  }
}
