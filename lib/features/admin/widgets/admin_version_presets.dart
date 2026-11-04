import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminVersionPresets extends StatelessWidget {
  final Function({
    required int latestBuild,
    required int minBuild,
    required int latestPatch,
    required bool forceUpdate,
    required bool patchRequired,
    required String notes,
  }) onApplyPreset;

  const AdminVersionPresets({super.key, required this.onApplyPreset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Simulasi Cepat (Presets)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                title: '🟢 Normal (Up-To-Date)',
                onTap: () => onApplyPreset(
                  latestBuild: 1,
                  minBuild: 1,
                  latestPatch: 0,
                  forceUpdate: false,
                  patchRequired: false,
                  notes: 'Sistem aplikasi stabil dan mutakhir.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '⚡ Shorebird Patch (#2)',
                onTap: () => onApplyPreset(
                  latestBuild: 1,
                  minBuild: 1,
                  latestPatch: 2,
                  forceUpdate: false,
                  patchRequired: true,
                  notes: 'Pembaruan Shorebird Patch #2: Perbaikan performa kalkulator rasio seduh dan optimasi cache.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '🚨 Force Native Update',
                onTap: () => onApplyPreset(
                  latestBuild: 2,
                  minBuild: 2,
                  latestPatch: 0,
                  forceUpdate: true,
                  patchRequired: false,
                  notes: 'Pembaruan Besar v1.1.0 (Build #2): Upgrade native engine, sinkronisasi cloud real-time, dan perbaikan keamanan wajib.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({required String title, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.surfaceWhite,
      side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: onTap,
    );
  }
}
