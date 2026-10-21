import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AuthUser> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await AuthService.getAdminUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat pengguna: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAccept(AuthUser user) async {
    final success = await AuthService.acceptUser(user.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Akun '${user.username}' berhasil disetujui (Approved)!"),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyetujui akun."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleDecline(AuthUser user) async {
    final success = await AuthService.declineUser(user.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Akun '${user.username}' ditolak (Declined)."),
          backgroundColor: Colors.redAccent,
        ),
      );
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menolak akun."),
          backgroundColor: Colors.redAccent,
        ),
      );
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
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingUsers = _users.where((u) => u.status == 'pending').toList();
    final approvedUsers = _users.where((u) => u.status == 'approved').toList();
    final declinedUsers = _users.where((u) => u.status == 'declined').toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Admin Approval Hub'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            tooltip: 'Segarkan Data',
            onPressed: _loadUsers,
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
                  const Text('Pending'),
                  if (pendingUsers.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pendingUsers.length}',
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
                  const Text('Approved'),
                  const SizedBox(width: 6),
                  Text('(${approvedUsers.length})', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Declined'),
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
                        onPressed: _loadUsers,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBrown,
                  onRefresh: _loadUsers,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserList(pendingUsers, type: 'pending'),
                      _buildUserList(approvedUsers, type: 'approved'),
                      _buildUserList(declinedUsers, type: 'declined'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserList(List<AuthUser> users, {required String type}) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pending'
                  ? CupertinoIcons.check_mark_circled
                  : type == 'approved'
                      ? CupertinoIcons.person_3
                      : CupertinoIcons.clear_circled,
              size: 54,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              type == 'pending'
                  ? 'Tidak ada akun yang menunggu persetujuan.'
                  : type == 'approved'
                      ? 'Belum ada akun yang disetujui.'
                      : 'Tidak ada akun yang ditolak.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isRusdiAdmin = user.username == 'rusdifn08';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1.5,
          color: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.bgCream,
                      backgroundImage: ProfileService.getImageProvider(user.avatarUrl),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isRusdiAdmin) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.username}',
                            style: const TextStyle(color: AppTheme.primaryBrown, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          if (user.createdAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Daftar: ${user.createdAt!.split("T").first}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildStatusChip(user.status),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.dividerColor),
                const SizedBox(height: 12),

                // Action Buttons
                if (type == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleDecline(user),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(CupertinoIcons.xmark, size: 16),
                          label: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleAccept(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(CupertinoIcons.checkmark, size: 16),
                          label: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else if (type == 'approved') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isRusdiAdmin) ...[
                        TextButton.icon(
                          onPressed: () => _handleDecline(user),
                          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                          icon: const Icon(CupertinoIcons.clear, size: 14),
                          label: const Text('Cabut Akses (Decline)'),
                        ),
                      ] else ...[
                        const Text('Akun Admin Utama', style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _handleDelete(user),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey),
                        icon: const Icon(CupertinoIcons.trash, size: 14),
                        label: const Text('Hapus'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _handleAccept(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(CupertinoIcons.checkmark, size: 14),
                        label: const Text('Accept Sekarang'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Approved';
        break;
      case 'declined':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Declined';
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
