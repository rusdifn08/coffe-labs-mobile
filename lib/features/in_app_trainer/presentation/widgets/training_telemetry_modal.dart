import 'dart:typed_data';
import 'package:flutter/material.dart';

enum TrainingPhase {
  preprocessing,
  augmenting,
  trainingHead,
  completed,
  failed,
}

class TrainingTelemetryModal extends StatelessWidget {
  final TrainingPhase phase;
  final String statusMessage;
  final double overallProgress; // 0.0 .. 1.0
  final int currentAugmentation;
  final int totalAugmentations;
  final Uint8List? latestThumbnailBytes;
  final int currentEpoch;
  final int totalEpochs;
  final double currentLoss;
  final double currentAccuracy;
  final VoidCallback? onDismiss;

  const TrainingTelemetryModal({
    super.key,
    required this.phase,
    required this.statusMessage,
    required this.overallProgress,
    this.currentAugmentation = 0,
    this.totalAugmentations = 30,
    this.latestThumbnailBytes,
    this.currentEpoch = 0,
    this.totalEpochs = 60,
    this.currentLoss = 0.0,
    this.currentAccuracy = 0.0,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: phase == TrainingPhase.completed
                ? const Color(0xFF10B981)
                : const Color(0xFFEADBCE),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C3A21).withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Icon Header Animasi
            _buildHeaderIcon(),
            const SizedBox(height: 16),

            // 2. Judul Status Fase
            Text(
              _phaseTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1F17),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // 3. Deskripsi Pesan
            Text(
              statusMessage,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF7A6858),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 4. Live Augmentation Thumbnail Stream (Fase B)
            if (phase == TrainingPhase.augmenting && latestThumbnailBytes != null) ...[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    latestThumbnailBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Variasi Augmentasi Citra',
                style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Live Epoch & Loss Chart Telemetry (Fase C)
            if (phase == TrainingPhase.trainingHead) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5DDD3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('EPOCH', '$currentEpoch / $totalEpochs'),
                    Container(width: 1, height: 28, color: const Color(0xFFE0D5C7)),
                    _buildStatCol('LOSS', currentLoss.toStringAsFixed(3)),
                    Container(width: 1, height: 28, color: const Color(0xFFE0D5C7)),
                    _buildStatCol(
                      'AKURASI',
                      '${(currentAccuracy * 100).toStringAsFixed(1)}%',
                      valueColor: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 6. Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overallProgress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFEFE8DE),
                color: phase == TrainingPhase.completed
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(overallProgress * 100).toInt()}%',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8F857D), fontWeight: FontWeight.bold),
              ),
            ),

            // 7. Tombol Selesai (Bila Complete)
            if (phase == TrainingPhase.completed || phase == TrainingPhase.failed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: phase == TrainingPhase.completed
                        ? const Color(0xFF059669)
                        : const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    phase == TrainingPhase.completed ? 'Selesai & Gunakan Biji Kopi' : 'Tutup',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    switch (phase) {
      case TrainingPhase.preprocessing:
        return const _PulsingIcon(icon: Icons.crop, color: Color(0xFFF59E0B));
      case TrainingPhase.augmenting:
        return const _PulsingIcon(icon: Icons.auto_awesome, color: Color(0xFFF59E0B));
      case TrainingPhase.trainingHead:
        return const _PulsingIcon(icon: Icons.model_training, color: Color(0xFFF59E0B));
      case TrainingPhase.completed:
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 34, color: Colors.white),
        );
      case TrainingPhase.failed:
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 34, color: Colors.white),
        );
    }
  }

  String get _phaseTitle {
    switch (phase) {
      case TrainingPhase.preprocessing:
        return 'Fase 1: Pre-Processing Citra & CLAHE';
      case TrainingPhase.augmenting:
        return 'Fase 2: 10x Data Augmentation (30 Variasi)';
      case TrainingPhase.trainingHead:
        return 'Fase 3: MobileNetV4 Hybrid 1280-D Training';
      case TrainingPhase.completed:
        return 'Model AI Berhasil Dilatih!';
      case TrainingPhase.failed:
        return 'Pelatihan Terhenti';
    }
  }

  Widget _buildStatCol(String title, String val, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF8F857D), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? const Color(0xFF2D1F17),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PulsingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PulsingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Icon(icon, size: 30, color: color),
    );
  }
}
