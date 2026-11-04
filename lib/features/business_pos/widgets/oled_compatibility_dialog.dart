import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/oled_detector_service.dart';

class OledCompatibilityDialog extends StatelessWidget {
  final OledDiagnosticReport report;
  final VoidCallback onProceedToAod;
  final VoidCallback? onOpenDiagnostic;

  const OledCompatibilityDialog({
    super.key,
    required this.report,
    required this.onProceedToAod,
    this.onOpenDiagnostic,
  });

  static Future<bool> checkAndShowIfNeeded(
    BuildContext context, {
    required VoidCallback onProceed,
    VoidCallback? onOpenDiagnostic,
  }) async {
    final report = await OledDetectorService.inspectDisplay(context);
    if (!report.requiresBacklightWarning) {
      onProceed();
      return true;
    }

    if (!context.mounted) return false;

    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => OledCompatibilityDialog(
        report: report,
        onProceedToAod: () => Navigator.pop(ctx, true),
        onOpenDiagnostic: onOpenDiagnostic,
      ),
    );

    if (shouldProceed == true) {
      onProceed();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Warning
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 1.2),
                  ),
                  child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peringatan Panel Layar AOD',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Deteksi Teknologi Backlight Perangkat',
                        style: TextStyle(color: Colors.white54, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Panel Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.device_laptop, color: Color(0xFFD4AF37), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        report.panelName,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Perangkat ini terdeteksi menggunakan panel LCD/IPS atau monitor eksternal. Mode Always-On Display (AOD) True Pitch-Black (#000000) dirancang paling optimal untuk layar berpanel AMOLED/OLED.',
                    style: TextStyle(color: Color(0xFFB5B5B5), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Perbandingan Teknis
            const Text(
              'Perbedaan Teknis AMOLED vs LCD:',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildComparisonRow(
              title: 'Layar AMOLED / OLED',
              desc: 'Piksel hitam #000000 mati total (0 Watt). Hemat baterai hingga 75% & tablet dingin.',
              isPositive: true,
            ),
            const SizedBox(height: 6),
            _buildComparisonRow(
              title: 'Layar IPS / LCD',
              desc: 'Lampu latar (backlight) tetap menyala di balik warna hitam. Baterai dan suhu operasional tetap terpakai.',
              isPositive: false,
            ),

            const SizedBox(height: 16),

            // Saran Operasional
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.lightbulb_fill, color: Color(0xFFD4AF37), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saran: Pasang charger daya konstan di meja bar jika menggunakan tablet LCD selama lebih dari 8 jam.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                if (onOpenDiagnostic != null) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, false);
                      onOpenDiagnostic!();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(CupertinoIcons.waveform_path_badge_plus, size: 16),
                    label: const Text('Tes Layar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onProceedToAod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Pahami & Lanjutkan ke AOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow({required String title, required String desc, required bool isPositive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isPositive ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.info_circle_fill,
          color: isPositive ? Colors.greenAccent : Colors.orangeAccent,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isPositive ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
