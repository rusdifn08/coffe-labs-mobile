import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../models/admin_control_models.dart';

/// Tab 3 Panel Admin Mobile: Kronologi Audit Log Perubahan Kunci & Harga.
class AdminAuditLogTabView extends StatelessWidget {
  final List<AdminControlAuditLogItem> logs;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const AdminAuditLogTabView({
    super.key,
    required this.logs,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && logs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      );
    }
    if (logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 48),
            Icon(Icons.history_rounded, size: 46, color: AppTheme.textMuted),
            SizedBox(height: 10),
            Text(
              'Belum ada riwayat perubahan Admin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: logs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, idx) {
          final log = logs[idx];
          final ts = DateFormat('dd MMM HH:mm:ss').format(log.createdAt.toLocal());
          return Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.actionCategory,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        log.targetKey,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Text(
                      'v${log.configVersionAfter}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${log.adminEmail} • $ts',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  jsonEncode(log.newState),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF5D4D44),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
