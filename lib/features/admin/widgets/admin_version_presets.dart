import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminVersionPresets extends StatelessWidget {
  final String currentVersion;
  final int currentBuild;
  final int currentPatch;
  final int currentManifestVersion;
  final Function({
    required String latestVersion,
    required int latestBuild,
    required int minBuild,
    required int latestPatch,
    required int contentManifestVersion,
    required bool forceUpdate,
    required bool patchRequired,
    required String notes,
  }) onApplyPreset;

  const AdminVersionPresets({
    super.key,
    this.currentVersion = '2.5.1',
    this.currentBuild = 9,
    this.currentPatch = 0,
    this.currentManifestVersion = 1,
    required this.onApplyPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat & Preset Rilis',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                title: '🟢 Normal (v$currentVersion #$currentBuild)',
                onTap: () => onApplyPreset(
                  latestVersion: currentVersion,
                  latestBuild: currentBuild,
                  minBuild: 2,
                  latestPatch: currentPatch,
                  contentManifestVersion: currentManifestVersion,
                  forceUpdate: false,
                  patchRequired: false,
                  notes: 'Coffee Labs v$currentVersion berjalan stabil dan mutakhir.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '⚡ Delta OTA Patch (#${currentPatch + 1})',
                onTap: () => onApplyPreset(
                  latestVersion: currentVersion,
                  latestBuild: currentBuild,
                  minBuild: 2,
                  latestPatch: currentPatch + 1,
                  contentManifestVersion: currentManifestVersion,
                  forceUpdate: false,
                  patchRequired: false,
                  notes:
                      'Delta OTA Patch #${currentPatch + 1}: Perbaikan cepat langsung di dalam aplikasi (~1-5 MB) tanpa install ulang.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '☁️ Hot Content Sync (v${currentManifestVersion + 1})',
                onTap: () => onApplyPreset(
                  latestVersion: currentVersion,
                  latestBuild: currentBuild,
                  minBuild: 2,
                  latestPatch: currentPatch,
                  contentManifestVersion: currentManifestVersion + 1,
                  forceUpdate: false,
                  patchRequired: false,
                  notes: 'Sinkronisasi katalog & kebijakan terbaru tanpa restart aplikasi.',
                ),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                title: '🚨 Force Native (#${currentBuild + 1})',
                onTap: () => onApplyPreset(
                  latestVersion: currentVersion,
                  latestBuild: currentBuild + 1,
                  minBuild: currentBuild + 1,
                  latestPatch: 0,
                  contentManifestVersion: currentManifestVersion + 1,
                  forceUpdate: true,
                  patchRequired: false,
                  notes:
                      'Pembaruan Native Wajib Build #${currentBuild + 1}: Upgrade engine native & peningkatan keamanan wajib.',
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
