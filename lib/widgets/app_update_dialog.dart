import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_update_service.dart';
import '../services/apk_installer_service.dart';

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
  double _downloadProgress = 0.0;
  String? _statusMessage;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    if (widget.isShorebirdPatch && widget.result.actionCode == 'FORCE_OTA_PATCH') {
      _startShorebirdDownload();
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
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

  Future<void> _startApkDownload() async {
    final downloadUrl = widget.result.downloadUrl ??
        'https://github.com/rusdi-labs/coffee-hub-mobile/releases/latest/download/app-arm64-v8a-release.apk';

    // Jika bukan Android, buka browser langsung
    if (kIsWeb || !Platform.isAndroid) {
      await AppUpdateService.openDownloadUrl(downloadUrl);
      if (mounted) Navigator.pop(context);
      return;
    }

    _cancelToken = CancelToken();

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = 'Menyiapkan unduhan APK...';
    });

    try {
      // Cek apakah permission install unknown apps aktif
      final canInstall = await ApkInstallerService.canRequestPackageInstalls();
      if (!canInstall && mounted) {
        final ask = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Izin Pemasangan APK', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
              'Untuk memperbarui aplikasi langsung dari Coffee Labs, aktifkan izin "Install unknown apps" di pengaturan Android.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  ApkInstallerService.openInstallPermissionSettings();
                  Navigator.pop(ctx, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                child: const Text('Buka Pengaturan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        if (ask != true) {
          if (mounted) {
            setState(() {
              _isDownloading = false;
              _statusMessage = 'Unduhan dibatalkan: Izin instalasi belum diberikan.';
            });
          }
          return;
        }
      }

      await ApkInstallerService.downloadAndInstallApk(
        downloadUrl: downloadUrl,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          if (!mounted) return;
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
            final mbTotal = (total / (1024 * 1024)).toStringAsFixed(1);
            final percent = (progress * 100).toInt();

            setState(() {
              _downloadProgress = progress;
              _statusMessage = 'Mengunduh APK: $percent% ($mbReceived MB / $mbTotal MB)';
            });
          } else {
            final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
            setState(() {
              _downloadProgress = 0.0;
              _statusMessage = 'Mengunduh APK: $mbReceived MB...';
            });
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
        _statusMessage = 'Membuka jendela pemasang sistem Android...';
      });
    } on DioException catch (dioErr) {
      if (!mounted) return;
      if (CancelToken.isCancel(dioErr)) {
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Unduhan dibatalkan.';
        });
      } else {
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Gagal mengunduh: ${dioErr.message}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Terjadi kendala saat memasang APK: $e';
      });
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel('User cancelled download');
    setState(() {
      _isDownloading = false;
      _statusMessage = 'Unduhan dibatalkan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isForce = widget.result.actionCode == 'FORCE_STORE_UPDATE' ||
        widget.result.actionCode == 'FORCE_OTA_PATCH';

    return PopScope(
      canPop: !isForce && !_isDownloading,
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
                    : 'Pembaruan rilis resmi. Unduh langsung satu ketukan tanpa Play Store.',
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

              // Progress bar if downloading patch or APK
              if (_isDownloading) ...[
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: _downloadProgress > 0.0 ? _downloadProgress : null,
                  color: widget.isShorebirdPatch ? Colors.purple : AppTheme.primaryBrown,
                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage ?? 'Mengunduh...',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isShorebirdPatch ? Colors.purple : AppTheme.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _cancelDownload,
                    icon: const Icon(CupertinoIcons.clear_circled, size: 16, color: Colors.redAccent),
                    label: const Text('Batalkan Unduhan', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                ),
              ] else if (_statusMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 11,
                    color: _isDownloaded ? Colors.green : Colors.brown,
                    fontWeight: FontWeight.w600,
                  ),
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
                if (!_isDownloading) ...[
                  ElevatedButton.icon(
                    onPressed: _startApkDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(CupertinoIcons.arrow_down_to_line_alt, color: Colors.white, size: 18),
                    label: const Text('Unduh & Pasang Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        AppUpdateService.openDownloadUrl(widget.result.downloadUrl);
                      },
                      child: const Text(
                        'Atau buka tautan di browser external',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
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
