import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/arrhenius_coldbrew_calculator.dart';
import '../controllers/cold_brew_alarm_hub_controller.dart';
import 'cold_brew_alarm_ringing_modal.dart';

/// Banner mengambang di Beranda untuk memantau Cold Brew / Kyoto Drip yang sedang berjalan di latar belakang.
class ActiveColdBrewFloatingBanner extends ConsumerWidget {
  const ActiveColdBrewFloatingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(coldBrewAlarmHubProvider);
    if (batches.isEmpty) return const SizedBox.shrink();

    final primary = batches.first;
    final now = DateTime.now();
    final remaining = primary.remainingAt(now);
    final isRinging = remaining == Duration.zero || primary.status == 'RINGING';
    final progress = primary.progressAt(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isRinging ? const Color(0xFFECFEFF) : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRinging ? const Color(0xFF0891B2) : AppTheme.borderWarm,
          width: isRinging ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => ColdBrewAlarmRingingModal.show(context, primary),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0891B2).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isRinging
                            ? Icons.alarm_on_rounded
                            : Icons.ac_unit_rounded,
                        color: const Color(0xFF0E7490),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRinging
                                ? 'ALARM COLD BREW SELESAI!'
                                : 'Cold Brew Latar Belakang Aktif (${batches.length} Batch)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0E7490),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            primary.recipeTitle,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isRinging
                            ? const Color(0xFF0E7490)
                            : AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isRinging
                            ? 'SARING!'
                            : ArrheniusColdBrewCalculator.formatHHMMSS(
                                remaining,
                              ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isRinging ? Colors.white : AppTheme.primaryBrown,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppTheme.dividerColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0891B2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
