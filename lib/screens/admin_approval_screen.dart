import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/admin/widgets/admin_user_card.dart';
import '../features/admin/widgets/admin_user_stats_card.dart';
import '../models/admin_user_stats.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

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
        title: const Text('Manajemen Pengguna & Pendaftaran'),
        centerTitle: true,
        actions: [
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
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Notifikasi Baru'),
                  if (newRegistrations.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${newRegistrations.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Semua'),
                  const SizedBox(width: 6),
                  Text('(${allUsers.length})', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nonaktif'),
                  const SizedBox(width: 6),
                  Text('(${declinedUsers.length})', style: const TextStyle(fontSize: 12)),
                ],
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
        );
      },
    );
  }
}
