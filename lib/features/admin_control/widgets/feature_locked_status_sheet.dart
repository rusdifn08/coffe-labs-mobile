import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../models/admin_control_models.dart';

/// Bottom Sheet informatif saat pengguna mengetuk kartu Barista Toolkit yang terkunci.
/// Menampilkan warna teks/badge sesuai status (`MAINTENANCE` / `COMING_SOON` / `UPDATED`),
/// pesan kustom Admin, estimasi buka (ETA), dan tombol Admin QA Bypass khusus role `ADMIN`.
class FeatureLockedStatusSheet extends StatelessWidget {
  final FeatureControlItem control;
  final bool canAdminBypass;
  final VoidCallback? onAdminBypassEnter;
  final VoidCallback? onRefreshStatus;

  const FeatureLockedStatusSheet({
    super.key,
    required this.control,
    this.canAdminBypass = false,
    this.onAdminBypassEnter,
    this.onRefreshStatus,
  });

  static Future<void> show(
    BuildContext context, {
    required FeatureControlItem control,
    bool canAdminBypass = false,
    VoidCallback? onAdminBypassEnter,
    VoidCallback? onRefreshStatus,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => FeatureLockedStatusSheet(
        control: control,
        canAdminBypass: canAdminBypass,
        onAdminBypassEnter: onAdminBypassEnter,
        onRefreshStatus: onRefreshStatus,
      ),
    );
  }

  String _formatEta(DateTime eta) {
    final local = eta.toLocal();
    final diff = local.difference(DateTime.now());
    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(local);
    if (diff.isNegative) return formatted;
    if (diff.inMinutes < 60) {
      return '$formatted (±${diff.inMinutes.clamp(1, 59)} menit lagi)';
    }
    return '$formatted (±${diff.inHours} jam lagi)';
  }

  @override
  Widget build(BuildContext context) {
    final status = control.lockStatus;
    final accent = status.accentTextColor;
    final pillBg = status.pillBackgroundColor;
    final borderColor = status.cardBorderColor;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.4),
                  ),
                  alignment: Alignment.center,
                  child: Icon(status.statusIcon, color: accent, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lock_fill, size: 11, color: accent),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                control.effectiveBadgeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        control.effectiveTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    control.effectiveMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textDark,
                      height: 1.45,
                    ),
                  ),
                  if (control.estimatedUnlockAt != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.clock_fill, size: 14, color: accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Estimasi selesai: ${_formatEta(control.estimatedUnlockAt!)}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (canAdminBypass && onAdminBypassEnter != null) ...[
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.primaryBrown, width: 1.3),
                    backgroundColor: const Color(0xFFFFF8E7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAdminBypassEnter!();
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                  label: const Text(
                    'Masuk Sebagai Admin (QA Bypass)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                if (onRefreshStatus != null) ...[
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: borderColor, width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          onRefreshStatus!();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cek Ulang',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 46,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
