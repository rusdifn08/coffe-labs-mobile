import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/smart_scale_model.dart';
import '../../../services/social_service.dart';
import '../../../theme/app_theme.dart';
import '../services/scale_brew_history_service.dart';
import 'extraction_chart_painter.dart';

/// Tab 3 of Smart Scale Studio: Brew Curve History & Community Sharing.
class ScaleHistoryTab extends StatefulWidget {
  final bool isEn;

  const ScaleHistoryTab({super.key, required this.isEn});

  @override
  State<ScaleHistoryTab> createState() => _ScaleHistoryTabState();
}

class _ScaleHistoryTabState extends State<ScaleHistoryTab> {
  String? _sharingLogId;

  @override
  void initState() {
    super.initState();
    ScaleBrewHistoryService.loadLogs();
  }

  Future<void> _shareToCommunity(ScaleBrewLog log) async {
    setState(() => _sharingLogId = log.id);
    try {
      await SocialService.createPost(
        content: log.toCommunitySummary(isEn: widget.isEn),
        recipeSnapshot: log.toSocialRecipeSnapshot(),
        tags: ['SmartScale', log.mode.label(isEn: false), 'KurvaSeduh'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F766E),
            content: Text(
              widget.isEn
                  ? 'Brew curve & recipe shared to Social Coffee community!'
                  : 'Kurva & resep seduhan berhasil dibagikan ke Komunitas Social Coffee!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB91C1C),
            content: Text(
              widget.isEn
                  ? 'Could not share to community: $e'
                  : 'Gagal membagikan ke komunitas: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharingLogId = null);
    }
  }

  Future<void> _shareExternal(ScaleBrewLog log) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: log.toCommunitySummary(isEn: widget.isEn)),
      );
    } catch (_) {}
  }

  String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} • $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEn;

    return ValueListenableBuilder<List<ScaleBrewLog>>(
      valueListenable: ScaleBrewHistoryService.logsNotifier,
      builder: (context, logs, _) {
        if (logs.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppTheme.bgCream,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.show_chart_rounded,
                        size: 28,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEn
                          ? 'No Recorded Brew Curves Yet'
                          : 'Belum Ada Riwayat Kurva Seduh',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEn
                          ? 'Connect your Bluetooth scale, brew with the timer, and tap "Save Curve" to store weight, flow rate, and yield logs to share with the Coffee Labs community.'
                          : 'Hubungkan timbangan Bluetooth Anda, seduh bersama timer, lalu tekan "Simpan Kurva" untuk menyimpan grafik debit air, waktu seduh, dan yield serta membagikannya ke komunitas.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          itemCount: logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, idx) => _buildLogCard(logs[idx], isEn),
        );
      },
    );
  }

  Widget _buildLogCard(ScaleBrewLog log, bool isEn) {
    final isSharing = _sharingLogId == log.id;
    final isEsp = log.mode == ScaleBrewMode.espresso;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isEsp
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log.mode.label(isEn: isEn).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isEsp
                        ? const Color(0xFFC2410C)
                        : const Color(0xFF0F766E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatDate(log.createdAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              InkWell(
                onTap: () => ScaleBrewHistoryService.deleteLog(log.id),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    CupertinoIcons.trash,
                    size: 15,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.recipeTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            '${log.deviceName} • ${log.methodName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          // Key Telemetry Grid (Wrap for 360px safety)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricChip(
                isEn ? 'Dose' : 'Dosis',
                '${log.coffeeDoseGrams.toStringAsFixed(1)} g',
              ),
              _metricChip(
                isEsp ? 'Yield' : (isEn ? 'Water' : 'Air'),
                '${log.finalWeightGrams.toStringAsFixed(1)} g',
              ),
              _metricChip(
                isEn ? 'Ratio' : 'Rasio',
                '1:${log.actualRatio.toStringAsFixed(1)}',
              ),
              _metricChip(
                isEn ? 'Time' : 'Waktu',
                log.formattedDuration,
              ),
              _metricChip(
                isEn ? 'Avg Flow' : 'Rata-rata',
                '${log.avgFlowRate.toStringAsFixed(1)} g/s',
              ),
              _metricChip(
                isEn ? 'Peak' : 'Puncak',
                '${log.peakFlowRate.toStringAsFixed(1)} g/s',
              ),
            ],
          ),

          if (log.points.length >= 2) ...[
            const SizedBox(height: 12),
            Container(
              height: 125,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: CustomPaint(
                painter: ExtractionChartPainter(
                  dataPoints: log.points,
                  targetMaxWeight: log.targetWaterGrams > 0
                      ? log.targetWaterGrams
                      : log.finalWeightGrams,
                  targetMaxSeconds: log.durationSeconds > 0
                      ? log.durationSeconds.toDouble()
                      : 60.0,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSharing ? null : () => _shareToCommunity(log),
                  icon: const Icon(CupertinoIcons.paperplane_fill, size: 14),
                  label: Text(
                    isSharing
                        ? (isEn ? 'Sharing...' : 'Membagikan...')
                        : (isEn
                            ? 'Share to Community'
                            : 'Bagikan ke Komunitas'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _shareExternal(log),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  side: const BorderSide(color: AppTheme.borderWarm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  isEn ? 'Export' : 'Ekspor',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
