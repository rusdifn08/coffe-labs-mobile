import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/monitoring_models.dart';

class Account360DossierSheet extends StatelessWidget {
  final Account360DossierDto dossier;

  const Account360DossierSheet({super.key, required this.dossier});

  static String formatDuration(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    if (m < 60) return '${m}m ${s % 60}s';
    final h = m ~/ 60;
    return '${h}j ${m % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final a = dossier.account;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
                  child: Text(
                    a.username.isNotEmpty ? a.username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${a.username} • ${a.accountTier}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        a.isOnline
                            ? 'ONLINE • ${a.currentActiveRoute ?? '/'}'
                            : 'Offline • Terakhir ${a.lastSeenAt?.toLocal().toString().substring(0, 16) ?? '-'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: a.isOnline ? Colors.green.shade700 : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Health ${a.healthScore}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _statChip('Hari Ini', formatDuration(a.todayScreenTimeSec), CupertinoIcons.time),
                _statChip('7 Hari', formatDuration(a.total7dScreenTimeSec), CupertinoIcons.calendar),
                _statChip('Lifetime', formatDuration(a.totalLifetimeScreenTimeSec), CupertinoIcons.chart_bar),
                _statChip('Total Seduh', '${a.totalBrewsExecuted}x', CupertinoIcons.flame),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Proporsi Fitur yang Sering Dipakai',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),
            if (dossier.featureBreakdown.isEmpty)
              const Text(
                'Belum ada rincian durasi fitur untuk akun ini.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              )
            else
              ...dossier.featureBreakdown.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(f.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          Text(
                            '${formatDuration(f.seconds)} (${f.sharePercent.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryBrown, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: (f.sharePercent / 100.0).clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor: AppTheme.dividerColor,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Eksperimen Seduh Terakhir',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            if (dossier.recentBrewExperiments.isEmpty)
              const Text(
                'Belum ada log eksperimen seduh.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              )
            else
              ...dossier.recentBrewExperiments.take(8).map(
                (b) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    b.completed ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.pause_circle,
                    color: b.completed ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  title: Text(b.recipeTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('${b.brewMethod} • ${formatDuration(b.brewDurationSec)}', style: const TextStyle(fontSize: 11.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, IconData icon) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBrown),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
