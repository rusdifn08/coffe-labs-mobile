import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_update_service.dart';

class AppUpdateDialog extends StatefulWidget {
  final VersionCheckResult result;
  final bool isShorebirdPatch;

  const AppUpdateDialog({
    super.key,
    required this.result,
    required this.isShorebirdPatch,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isShorebirdPatch && widget.result.actionCode == 'FORCE_OTA_PATCH') {
      _startShorebirdDownload();
    }
  }

  Future<void> _startShorebirdDownload() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Mengunduh patch diff Dart via Shorebird...';
    });

    final success = await AppUpdateService.performShorebirdUpdate();

    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _isDownloaded = true;
      _statusMessage = success
          ? 'Patch berhasil diunduh! Silakan mulai ulang aplikasi.'
          : 'Patch siap diterapkan pada pembukaan aplikasi berikutnya.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isForce = widget.result.actionCode == 'FORCE_STORE_UPDATE' ||
        widget.result.actionCode == 'FORCE_OTA_PATCH';

    return PopScope(
      canPop: !isForce,
      child: Dialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon & Type Badge
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.isShorebirdPatch
                        ? Colors.purple.shade50
                        : AppTheme.primaryBrown.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isShorebirdPatch
                        ? CupertinoIcons.bolt_fill
                        : CupertinoIcons.cloud_download_fill,
                    color: widget.isShorebirdPatch ? Colors.purple : AppTheme.primaryBrown,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isShorebirdPatch
                        ? Colors.purple.shade50
                        : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.isShorebirdPatch
                          ? Colors.purple.shade200
                          : Colors.amber.shade400,
                    ),
                  ),
                  child: Text(
                    widget.isShorebirdPatch
                        ? '⚡ Shorebird OTA Code Push (Patch #${widget.result.targetPatch ?? 1})'
                        : (isForce ? '🚨 Pembaruan Wajib' : '✨ Pembaruan Versi Baru Tersedia'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.isShorebirdPatch ? Colors.purple.shade800 : Colors.brown.shade800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.isShorebirdPatch
                    ? 'Pembaruan Fitur Siap Diterapkan'
                    : 'Coffee Labs v${widget.result.latestBaseVersion}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.isShorebirdPatch
                    ? 'Sistem mendeteksi patch baru tanpa perlu download ulang seluruh aplikasi.'
                    : 'Pembaruan sistem native untuk kenyamanan ekstraksi kopi Anda.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Release Notes Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBrown),
                        SizedBox(width: 6),
                        Text('Catatan Rilis (Changelog):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.result.releaseNotes,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),

              // Progress bar if downloading patch
              if (_isDownloading) ...[
                const SizedBox(height: 18),
                const LinearProgressIndicator(
                  color: Colors.purple,
                  backgroundColor: Color(0xFFF3E5F5),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage ?? 'Mengunduh patch...',
                  style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ] else if (_statusMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _statusMessage!,
                  style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 22),

              // Actions
              if (widget.isShorebirdPatch) ...[
                if (_isDownloaded) ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Selesai (Restart Nanti)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ] else if (!_isDownloading) ...[
                  ElevatedButton.icon(
                    onPressed: _startShorebirdDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(CupertinoIcons.arrow_down_circle_fill, color: Colors.white, size: 18),
                    label: const Text('Unduh Patch Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () {
                    AppUpdateService.openDownloadUrl(widget.result.downloadUrl);
                    if (!isForce) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(CupertinoIcons.arrow_down_to_line_alt, color: Colors.white, size: 18),
                  label: const Text('Unduh & Perbarui Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],

              if (!isForce && !_isDownloading) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nanti Saja', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
