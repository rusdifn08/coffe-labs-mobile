import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminVersionFormCard extends StatelessWidget {
  final TextEditingController latestBuildNumberCtrl;
  final TextEditingController minBuildNumberCtrl;
  final TextEditingController latestBaseVersionCtrl;
  final TextEditingController minBaseVersionCtrl;
  final TextEditingController latestPatchNumberCtrl;
  final TextEditingController releaseNotesCtrl;
  final TextEditingController downloadUrlCtrl;
  final bool isForceUpdate;
  final ValueChanged<bool> onForceUpdateChanged;
  final bool isPatchRequired;
  final ValueChanged<bool> onPatchRequiredChanged;

  const AdminVersionFormCard({
    super.key,
    required this.latestBuildNumberCtrl,
    required this.minBuildNumberCtrl,
    required this.latestBaseVersionCtrl,
    required this.minBaseVersionCtrl,
    required this.latestPatchNumberCtrl,
    required this.releaseNotesCtrl,
    required this.downloadUrlCtrl,
    required this.isForceUpdate,
    required this.onForceUpdateChanged,
    required this.isPatchRequired,
    required this.onPatchRequiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 20),
              SizedBox(width: 8),
              Text(
                'Konfigurasi Kebijakan Versi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Build numbers row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: latestBuildNumberCtrl,
                  label: 'Latest Build #',
                  hint: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: minBuildNumberCtrl,
                  label: 'Min Build #',
                  hint: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Versions row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: latestBaseVersionCtrl,
                  label: 'Latest Version',
                  hint: '1.0.0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: minBaseVersionCtrl,
                  label: 'Min Version',
                  hint: '1.0.0',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Shorebird Latest Patch Number
          _buildTextField(
            controller: latestPatchNumberCtrl,
            label: 'Shorebird Target Patch #',
            hint: '0',
            keyboardType: TextInputType.number,
            helperText: 'Isi angka patch jika ada pembaruan kode Dart via Shorebird (0 = tidak ada patch)',
          ),
          const SizedBox(height: 16),

          // Toggles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppTheme.primaryBrown,
                  title: const Text(
                    'Wajibkan Pembaruan Native (Force Update)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  subtitle: const Text(
                    'Blokir layar aplikasi bagi pengguna dengan versi di bawah batas minimum.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  value: isForceUpdate,
                  onChanged: onForceUpdateChanged,
                ),
                const Divider(height: 1, color: AppTheme.dividerColor),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.purple,
                  title: const Text(
                    'Wajibkan Shorebird Patch Segera',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  subtitle: const Text(
                    'Jika aktif: Tampilkan progress modal FORCE_OTA_PATCH. Jika nonaktif: unduh patch secara diam-diam (SILENT_OTA_PATCH).',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  value: isPatchRequired,
                  onChanged: onPatchRequiredChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Release Notes
          _buildTextField(
            controller: releaseNotesCtrl,
            label: 'Catatan Rilis (Release Notes)',
            hint: 'Deskripsikan perbaikan fitur atau patch...',
            maxLines: 4,
          ),
          const SizedBox(height: 14),

          // Download URL
          _buildTextField(
            controller: downloadUrlCtrl,
            label: 'URL Unduhan APK / Toko Aplikasi',
            hint: 'https://github.com/rusdi-labs/coffee-hub-mobile/releases/latest',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.bgCream,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
