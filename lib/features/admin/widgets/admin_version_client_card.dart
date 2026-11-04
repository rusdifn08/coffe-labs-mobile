import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminVersionClientCard extends StatelessWidget {
  final bool isShorebird;
  final Map<String, dynamic> clientInfo;

  const AdminVersionClientCard({
    super.key,
    required this.isShorebird,
    required this.clientInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.device_phone_portrait, color: AppTheme.primaryBrown, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Klien Saat Ini',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      'Data build runtime device Anda',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isShorebird ? Colors.purple.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isShorebird ? Colors.purple.shade200 : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isShorebird ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash,
                      size: 12,
                      color: isShorebird ? Colors.purple : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isShorebird ? 'Shorebird Aktif' : 'Shorebird Dev/Desktop',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isShorebird ? Colors.purple : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoPill('Base Version', 'v${clientInfo['version'] ?? '1.0.0'}'),
              const SizedBox(width: 10),
              _buildInfoPill('Build Number', '#${clientInfo['buildNumber'] ?? 1}'),
              const SizedBox(width: 10),
              _buildInfoPill('Current Patch', '#${clientInfo['patchNumber'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }
}
