import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/active_long_brew_batch.dart';
import '../../domain/arrhenius_coldbrew_calculator.dart';
import '../controllers/cold_brew_alarm_hub_controller.dart';

class ColdBrewAlarmRingingModal extends ConsumerWidget {
  final ActiveLongBrewBatch batch;

  const ColdBrewAlarmRingingModal({super.key, required this.batch});

  static Future<void> show(
    BuildContext context,
    ActiveLongBrewBatch batch,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ColdBrewAlarmRingingModal(batch: batch),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dilution = ArrheniusColdBrewCalculator.calculateDilution(
      coffeeDoseG: batch.coffeeDoseG,
      waterMl: batch.waterMl,
    );
    final now = DateTime.now();
    final remaining = batch.remainingAt(now);
    final isRinging = remaining == Duration.zero || batch.status == 'RINGING';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRinging ? const Color(0xFF0E7490) : AppTheme.borderWarm,
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRinging
                        ? const Color(0xFFECFEFF)
                        : AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isRinging
                        ? Icons.notifications_active_rounded
                        : Icons.ac_unit_rounded,
                    color: isRinging
                        ? const Color(0xFF0891B2)
                        : AppTheme.primaryBrown,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRinging
                            ? 'WAKTUNYA SARING COLD BREW!'
                            : 'Alarm Cold Brew Terjadwal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isRinging
                              ? const Color(0xFF0E7490)
                              : AppTheme.lightBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        batch.recipeTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRinging
                        ? 'Segera pisahkan ampas agar ekstraksi tidak pahit berlebih.'
                        : 'Sisa Waktu Ekstraksi: ${ArrheniusColdBrewCalculator.formatHHMMSS(remaining)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetricPill(
                        label: 'Rasio',
                        value: dilution.brewRatioLabel,
                      ),
                      _MetricPill(
                        label: 'Konsentrat Bersih',
                        value: '${dilution.concentrateYieldMl.toStringAsFixed(0)} ml',
                      ),
                      _MetricPill(
                        label: 'Saran Pengencer (1:15)',
                        value: '+${dilution.suggestedDilutionMl.toStringAsFixed(0)} ml air/susu',
                      ),
                      _MetricPill(
                        label: 'Alternatif Es Batu',
                        value: '${dilution.suggestedIceG.toStringAsFixed(0)} g es',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(coldBrewAlarmHubProvider.notifier)
                          .snoozeBatch(batch.id, minutes: 15);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Alarm Cold Brew ditunda +15 menit.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.snooze_rounded, size: 18),
                    label: const Text('Snooze +15m'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: const BorderSide(color: AppTheme.primaryBrown),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(coldBrewAlarmHubProvider.notifier)
                          .completeBatch(batch.id);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${batch.recipeTitle} selesai disaring (${dilution.concentrateYieldMl.toStringAsFixed(0)} ml konsentrat).',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Selesai & Saring'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(coldBrewAlarmHubProvider.notifier)
                      .cancelBatch(batch.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text(
                  'Batalkan Batch Alarm',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBrown,
            ),
          ),
        ],
      ),
    );
  }
}
