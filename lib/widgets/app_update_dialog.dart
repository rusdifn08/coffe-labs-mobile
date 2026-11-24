import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';

typedef ShorebirdPatchRunner = Future<ShorebirdPatchOutcome> Function();
typedef ExternalDownloadLauncher = Future<bool> Function(String? url);

class AppUpdateDialog extends StatefulWidget {
  final VersionCheckResult result;
  final bool isShorebirdPatch;
  final ShorebirdPatchRunner? shorebirdRunner;
  final ExternalDownloadLauncher? downloadLauncher;

  const AppUpdateDialog({
    super.key,
    required this.result,
    required this.isShorebirdPatch,
    this.shorebirdRunner,
    this.downloadLauncher,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _isWorking = false;
  bool _isPatchReady = false;
  bool _isShorebirdUnavailable = false;
  String? _statusMessage;
  bool _isErrorStatus = false;

  @override
  void initState() {
    super.initState();
    if (widget.isShorebirdPatch && widget.result.actionCode == 'FORCE_OTA_PATCH') {
      _startShorebirdDownload();
    }
  }

  Future<void> _startShorebirdDownload() async {
    setState(() {
      _isWorking = true;
      _isErrorStatus = false;
      _isShorebirdUnavailable = false;
      _statusMessage = 'Mengunduh delta patch ringan (~1–5 MB) tanpa install ulang...';
    });

    final runner = widget.shorebirdRunner ?? AppUpdateService.runShorebirdPatchUpdate;
    final outcome = await runner();

    if (!mounted) return;
    setState(() {
      _isWorking = false;
      switch (outcome) {
        case ShorebirdPatchOutcome.downloaded:
        case ShorebirdPatchOutcome.restartRequired:
          _isPatchReady = true;
          _isErrorStatus = false;
          _statusMessage =
              'Delta patch selesai diunduh! Tutup lalu buka ulang aplikasi untuk menerapkan pembaruan tanpa install ulang.';
          break;
        case ShorebirdPatchOutcome.upToDate:
          _isPatchReady = true;
          _isErrorStatus = false;
          _statusMessage = 'Aplikasi Anda sudah menjalankan patch terbaru.';
          break;
        case ShorebirdPatchOutcome.unavailable:
          _isPatchReady = false;
          _isShorebirdUnavailable = true;
          _isErrorStatus = true;
          _statusMessage =
              'Build APK ini belum memuat mesin Delta OTA (Shorebird). Unduh rilis resmi terbaru satu kali agar pembaruan berikutnya otomatis ringan di dalam aplikasi.';
          break;
        case ShorebirdPatchOutcome.error:
          _isPatchReady = false;
          _isErrorStatus = true;
          _statusMessage =
              'Gagal mengunduh delta patch. Periksa koneksi internet lalu coba lagi.';
          break;
      }
    });
  }

  Future<void> _launchOfficialReleaseDownload() async {
    setState(() {
      _isWorking = true;
      _isErrorStatus = false;
      _statusMessage = 'Membuka unduhan rilis resmi di pengelola unduhan perangkat...';
    });

    final launcher = widget.downloadLauncher ?? AppUpdateService.openDownloadUrl;
    final opened = await launcher(widget.result.downloadUrl);

    if (!mounted) return;
    setState(() {
      _isWorking = false;
      _isErrorStatus = !opened;
      _statusMessage = opened
          ? 'Unduhan rilis resmi dimulai di browser/Download Manager perangkat Anda (aman Google Play Protect).'
          : 'Tidak dapat membuka tautan unduhan secara otomatis. Anda bisa menyalin link di bawah.';
    });
  }

  Future<void> _copyDownloadLink() async {
    final url = widget.result.downloadUrl ?? AppUpdateService.defaultPlatformDownloadUrl();
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan unduhan rilis resmi disalin ke clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _snoozeAndClose() async {
    await AppUpdateService.snoozeFlexibleUpdate(widget.result.latestBaseVersion);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isForce = widget.result.actionCode == 'FORCE_STORE_UPDATE' ||
        widget.result.actionCode == 'FORCE_OTA_PATCH';
    final bool showNativeFallback = !widget.isShorebirdPatch || _isShorebirdUnavailable;

    return PopScope(
      canPop: !isForce && !_isWorking,
      child: Dialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        ? '⚡ Delta OTA Patch #${widget.result.targetPatch ?? 1} (Tanpa Install Ulang)'
                        : (isForce ? '🚨 Pembaruan Native Wajib' : '✨ Pembaruan Resmi Tersedia'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.isShorebirdPatch
                          ? Colors.purple.shade800
                          : Colors.brown.shade800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                widget.isShorebirdPatch
                    ? 'Pembaruan Ringan Siap Diterapkan'
                    : 'Coffee Labs v${widget.result.latestBaseVersion}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.isShorebirdPatch
                    ? 'Hanya mengunduh perubahan kode yang diperlukan langsung di aplikasi — hemat kuota & tanpa install ulang.'
                    : 'Pembaruan modul native & performa baru. Unduhan dijalankan lewat pengelola unduhan OS agar 100% aman Google Play Protect.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBrown),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Catatan Rilis (Changelog):',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.result.releaseNotes,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                    ),
                    if (widget.result.checksumSha256 != null &&
                        widget.result.checksumSha256!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'SHA-256: ${widget.result.checksumSha256!.trim()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (_isWorking) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  color: widget.isShorebirdPatch ? Colors.purple : AppTheme.primaryBrown,
                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage ?? 'Memproses pembaruan...',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: widget.isShorebirdPatch ? Colors.purple : AppTheme.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else if (_statusMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isErrorStatus
                        ? Colors.amber.shade50
                        : (_isPatchReady ? const Color(0xFFF0FDF4) : AppTheme.bgCream),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isErrorStatus
                          ? Colors.amber.shade300
                          : (_isPatchReady
                              ? const Color(0xFFBBF7D0)
                              : AppTheme.primaryBrown.withValues(alpha: 0.15)),
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _isErrorStatus
                          ? Colors.brown.shade900
                          : (_isPatchReady ? const Color(0xFF166534) : AppTheme.textDark),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (widget.isShorebirdPatch && !_isShorebirdUnavailable) ...[
                if (_isPatchReady) ...[
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    ),
                    icon: const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Colors.white, size: 18),
                    label: const Text(
                      'Siap — Mulai Ulang Aplikasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ] else if (!_isWorking) ...[
                  ElevatedButton.icon(
                    onPressed: _startShorebirdDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    ),
                    icon: const Icon(CupertinoIcons.arrow_down_circle_fill, color: Colors.white, size: 18),
                    label: const Text(
                      'Unduh Delta Patch Sekarang',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],

              if (showNativeFallback && !_isWorking) ...[
                ElevatedButton.icon(
                  onPressed: _launchOfficialReleaseDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  icon: const Icon(CupertinoIcons.arrow_down_to_line_alt, color: Colors.white, size: 18),
                  label: const Text(
                    'Unduh Rilis Resmi Terbaru',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: _copyDownloadLink,
                    icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 14, color: AppTheme.textMuted),
                    label: const Text(
                      'Salin Link Unduhan',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  ),
                ),
              ],

              if (!isForce && !_isWorking) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _snoozeAndClose,
                  child: const Text(
                    'Nanti Saja (Ingatkan Besok)',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
