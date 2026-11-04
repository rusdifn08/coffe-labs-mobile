import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../../../theme/app_theme.dart';

class AdminUserCard extends StatelessWidget {
  final AuthUser user;
  final bool isNewRegistration;
  final Function(AuthUser) onAccept;
  final Function(AuthUser) onDecline;
  final Function(AuthUser) onDelete;

  const AdminUserCard({
    super.key,
    required this.user,
    this.isNewRegistration = false,
    required this.onAccept,
    required this.onDecline,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRusdiAdmin = user.username == 'rusdifn08';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNewRegistration
            ? BorderSide(color: Colors.orange.shade300, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNewRegistration) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.bell_fill, size: 13, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Notifikasi: Pendaftaran Baru • Otomatis Aktif (Trial)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.bgCream,
                  backgroundImage: ProfileService.getImageProvider(user.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
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
                              child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(color: AppTheme.primaryBrown, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (user.createdAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Terdaftar: ${_formatDate(user.createdAt!)}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusChip(user.status),
              ],
            ),
            if (!isRusdiAdmin) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.dividerColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (user.status == 'declined') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onAccept(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(CupertinoIcons.checkmark_alt, size: 14),
                        label: const Text('Aktifkan Kembali', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onDecline(user),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade800,
                          side: BorderSide(color: Colors.orange.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(CupertinoIcons.nosign, size: 14),
                        label: const Text('Nonaktifkan', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 18),
                    tooltip: 'Hapus User',
                    onPressed: () => onDelete(user),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case 'approved':
        bg = Colors.green.shade50;
        text = Colors.green.shade800;
        label = 'Aktif (Trial)';
        icon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'declined':
        bg = Colors.red.shade50;
        text = Colors.red.shade800;
        label = 'Nonaktif';
        icon = CupertinoIcons.xmark_circle_fill;
        break;
      case 'pending':
      default:
        bg = Colors.orange.shade50;
        text = Colors.orange.shade800;
        label = 'Baru';
        icon = CupertinoIcons.bell_fill;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: text),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.split('T').first;
    }
  }
}
